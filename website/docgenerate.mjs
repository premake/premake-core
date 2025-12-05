import fs from "fs";
import { ref } from "process";
import readline from "readline";
class Prompt {
	constructor(rl) {
		console.clear();


		this.rl = rl

		process.stdin.setRawMode(true);
		process.stdin.resume();
		process.stdin.setEncoding("utf8");
	}

	// Generic helper to ask a question and assign to a property
	async askAndStore(question, property) {
		return new Promise(resolve => {
			this.rl.question(question, answer => {
				this[property] = answer.trim();
				console.clear();
				resolve(this[property]);
			});
		});
	}

	async confirm(message = "Are you sure? (y/n): ") {
		return new Promise(resolve => {
			this.rl.question(message, answer => {
				const confirmed = answer.trim().toLowerCase() === "y";
				resolve(confirmed);
			});
		});
	}
	async selectFromList(message, options) {
		return new Promise(resolve => {
			let index = 0;

			const render = () => {
				console.clear();
				console.log(message);
				options.forEach((opt, i) => {
					if (i === index) {
						console.log(`> ${opt}`); // highlight current selection
					} else {
						console.log(`  ${opt}`);
					}
				});
			};

			render();

			const onKeyPress = (key) => {
				if (key === "\u0003") { // ctrl+c
					process.exit();
				} else if (key === "\r") { // enter
					process.stdin.removeListener("data", onKeyPress);
					resolve(options[index]);
				} else if (key === "\u001b[A") { // up arrow
					index = (index - 1 + options.length) % options.length;
					render();
				} else if (key === "\u001b[B") { // down arrow
					index = (index + 1) % options.length;
					render();
				}
			};

			process.stdin.on("data", onKeyPress);
		});
	}
}

// Example specialization for documentation prompts
class DocPrompt extends Prompt {
	constructor(rl) {
		super(rl);
		this.title = null;
		this.description = null;
		this.keywords = [];
	}

	async askTitle() {
		return await this.askAndStore("Enter the function name: ", "title");
	}

	async askDescription() {
		return await this.askAndStore("Enter the description: ", "description");
	}

	async askKeywords() {
		const answer = await this.askAndStore("Enter a comma separated list of keywords: ", "keywords");
		this.keywords = answer.split(",").map(k => k.trim()).filter(Boolean);
		return this.keywords;
	}

	async run() {
		let confirmed = false;
		while (!confirmed) {
			await this.askTitle();
			await this.askDescription();
			await this.askKeywords();

			console.log("\nheader:", {
				title: this.title,
				description: this.description,
				keywords: this.keywords
			});

			confirmed = await this.confirm();
		}
	}
}

/**
 * Storage class containing param info
 */
class Param {
	constructor(name = null, description = null, type = null, subtype = null) {
		this.name = name;
		this.description = description;
		this.type = type;
		this.subtype = subtype;
	}
	getType() {
		if (this.subtype === "none") {
			return this.type;
		} else if (this.subtype === "array") {
			return `${this.type}[]`;
		}
	}

	getSignature() {
		if (this.subtype === null) {
			return this.getEnumTable();
		}
		return this.getValueSignature();
	}

	getValueSignature() {
		return `\`${this.name}\` **${this.getType()}** - ${this.description}`;
	}
	getEnumTable() {

		// Table header: use this.name as the first column title
		let md = `| ${this.name} | Description |\n`;
		md += `|-------------|-------------|\n`;

		// Each type value becomes a row
		this.type.forEach(val => {
			md += `| ${val} |  |\n`;
		});

		return md;
	}
}

class ParamPrompt extends Prompt {
	static PARAM_TYPES = [
		"nil",
		"any",
		"boolean",
		"string",
		"number",
		"integer",
		"function",
		"table",
		"thread",
		"userdata",
		"lightuserdata"
	];

	static PARAM_SUB_TYPE = [
		"array",
		"table",
		"none",
	];
	constructor(rl) {
		super(rl);
		this.name = null;
		this.description = null;
		this.type = null;
		this.subtype = null;
		this.enumValues = null;
	}
	async askName() {
		return await this.askAndStore("Enter the parameter name: ", "name");
	}

	async askEnumValues() {
		const answer = await this.askAndStore("Enter a comma separated list of enum values: ", "enumValues");
		this.enumValues = answer.split(",").map(k => k.trim()).filter(Boolean);
		this.subtype = null;
		this.description = null;
		this.type = null;
	}

	async askDescription() {
		return await this.askAndStore("Enter the parameter description: ", "description");
	}

	async askType() {
		this.type = await this.selectFromList("choose an appropriate parameter type", ParamPrompt.PARAM_TYPES)
	}

	async askSubType() {
		this.subtype = await this.selectFromList("choose an appropriate parameter sub type", ParamPrompt.PARAM_SUB_TYPE)
	}

	getParam() {
		return new Param(this.name, this.description, this.type ?? this.enumValues, this.subtype)
	}
	async run() {
		let confirmed = false;
		while (!confirmed) {
			await this.askName();
			if (await this.confirm("is the parameter and enum type? (y/n): ")) {
				await this.askEnumValues();
			} else {
				await this.askDescription();
				await this.askType();
				await this.askSubType();
			}

			console.log("param:", this.getParam())

			confirmed = await this.confirm();
		}
	}
}


class ParamsPrompt extends Prompt {
	constructor(rl) {
		super(rl);
		this.params = []
	}
	async run() {
		let confirmed = !await this.confirm("Does this function have input parameters? (y/n): ");;
		let paramPrompt = new ParamPrompt(this.rl);
		while (!confirmed) {
			await paramPrompt.run();
			const param = paramPrompt.getParam();
			confirmed = !await this.confirm("Are there more parameters? (y/n): ");
			this.params = [...this.params, param]
		}
		console.log(this.params);
	}
}

class AvailabilityPrompt extends Prompt {
	constructor(rl) {
		super(rl);
		this.availability = null;
	}
	async askAvailability() {
		return await this.askAndStore("Pls enter the function availability: ", "availability");
	}
	async run() {
		let confirmed = false;
		while (!confirmed) {
			await this.askAvailability();
			console.log("\navailability: ", this.availability);
			confirmed = await this.confirm();
		}
	}
}

class AppliesPrompt extends Prompt {
	constructor(rl) {
		super(rl);
		this.applies = null;
	}
	async askApplies() {
		return await this.askAndStore("Pls enter the scope the function applies to: ", "applies");
	}
	async run() {
		let confirmed = false;
		while (!confirmed) {
			await this.askApplies();
			console.log("\napplies: ", this.applies);
			confirmed = await this.confirm();
		}
	}
}

class ReferencesPrompt extends Prompt {
	constructor(rl) {
		super(rl);
		this.reference = null
		this.references = [];
	}
	async askReference() {
		return await this.askAndStore("Pls enter the function/reference name: ", "reference");
	}
	async run() {
		let confirmed = !await this.confirm("Are there noteworthy references (function)s? (y/n): ");
		while (!confirmed) {
			this.references = [...this.references, await this.askReference()];
			console.log("\nreference: ", this.availability);
			confirmed = !await this.confirm("Are there more references? (y/n): ");
		}
	}
}

class info {
	static async prompt() {
		const rl = readline.createInterface({
			input: process.stdin,
			output: process.stdout
		});
		const header = new DocPrompt(rl);
		await header.run();

		const params = new ParamsPrompt(rl);
		await params.run();

		const applies = new AppliesPrompt(rl);
		await applies.run();

		const availability = new AvailabilityPrompt(rl);
		await availability.run();

		const references = new ReferencesPrompt(rl);
		await references.run();
		return {
			header: header,
			params: params,
			applies: applies,
			availability: availability,
			references: references
		}
	};
}

class header {
	/**
	 *
	 * @param {*} header
	 * @param {Param[]} params
	 */
	constructor(header, params) {
		this.header = header;
		this.params = params;
	}
	getHeader() {
		return `---\r\ntitle: ${this.header.title}\r\ndescription: ${this.header.description}\r\nkeywords: [${this.header.keywords.join(', ')}]\r\n---`
	}
	getParams() {
		if (this.params.length > 1) {
			return `(${this.params
				.map(p => p.name)
				.filter(Boolean)       // remove null/undefined
				.join(", ")})`;
		} else if (this.params.length === 1) {
			if (this.params[0].subtype && this.params[0].subtype.toLowerCase() !== "none") {
				return ` { "${this.params[0].name}" } `;
			} else {
				return ` ("${this.params[0].name}")`;
			}
		}
	}
	getSignature() {
		return `\`\`\`lua\r\n${this.header.title}${this.getParams()}\r\n\`\`\``;
	}
	getSection() {
		return [
			this.getHeader(),
			this.header.description,
			this.getSignature()
		].join("\n\n");
	}
}

class params {
	constructor(params) {
		this.params = params.params;
	}
	getSection() {
		const signatures = this.params.map((param) => param.getSignature());
		return [
			"### Parameters ###",
			...signatures
		].join("\n\n")
	}
}

class applies {
	constructor(applies) {
		this.applies = applies;
	}

	getSection() {
		return `### Applies To ###\r\n\r\n${this.applies.applies}`;
	}
}

class availability {
	constructor(availability) {
		this.availability = availability;
	}

	getSection() {
		return `### Availability ###\r\n\r\n${this.availability.availability}`;
	}
}

class references {
	constructor(references) {
		this.references = references.references;
	}

	getReference(reference){
		return `* [${reference}](${reference.replace(" ","-")}.md)`;
	}

	getReferences(){
		return this.references.map((ref) => this.getReference(ref)).join("n\n");
	}
	getSection() {
		return `### See Also ###\r\n\r\n${this.getReferences()}`;
	}
}
/**
 * store so we can later recover stdout
 */
const _stdoutSnapshot = process.stdout.write.toString();
console.clear();
// Example usage:

const promptInfo = await info.prompt()

const headerSection = new header(promptInfo.header, promptInfo.params.params).getSection();
const paramSection = new params(promptInfo.params).getSection();
const appliesSection = new applies(promptInfo.applies).getSection();
const availabilitySection = new availability(promptInfo.availability).getSection();
let 	sections = [headerSection, paramSection, appliesSection, availabilitySection];
if(promptInfo.references.references.length > 0) {
	sections = [...sections,,new references(promptInfo.references).getSection()]
}

fs.writeFileSync(`docs/${promptInfo.header.title}.md`, sections.join("\n"), "utf8");
