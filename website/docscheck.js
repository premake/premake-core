const { Console } = require("console");
const fs = require("fs");
const path = require("path");

class FormatClass {
	/**
	 * Validate either a single check or an array of checks
	 * @param {Function|Object[]} checkFnOrArray - single function or array of {fn, value, msg}
	 * @param {any} value - value to pass if single function
	 * @param {string} errorMessage - error message if single function
	 * @returns {boolean} true if all checks pass, false if any fail
	 */
	static validate(checkFnOrArray, value, errorMessage) {
		// Case 1: single function
		if (typeof checkFnOrArray === "function") {
			if (!checkFnOrArray(value)) {
				console.error(errorMessage);
				return false;
			}
			return true;
		}

		// Case 2: array of objects
		if (Array.isArray(checkFnOrArray)) {
			let allValid = true;
			for (const { fn, value, msg } of checkFnOrArray) {
				if (!fn(value)) {
					console.error(msg);
					allValid = false;
				}
			}
			return allValid;
		}

		throw new Error("Invalid argument passed to FormatClass.validate");
	}
}

class documentationfiles {

	/**
	 * this function retrieves all the documentationfiles that are functions
	 * @param {string} directory directory to check
	 * @returns a list of all the documentation files
	 */
	static getFunctionDocs(directory = "docs") {
		const files = fs.readdirSync(directory);

		// Regex: lowercase letters, numbers, underscores, hyphens, ending with .md
		const validPattern = /^[a-z0-9_-]+\.md$/;

		return files.filter(file => validPattern.test(file));
	}
}

class region {
	getRegionRegex(name) {
		const escapedName = name.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");

		return new RegExp(
			`###\\s*${escapedName}\\s*###([\\s\\S]*?)(?=###\\s.*?###|$)`,
			"i"
		);
	}
	constructor(inputText, region) {
		const regex = this.getRegionRegex(region)
		const match = inputText.match(regex);
		if (match && match[1])
			this.regionText = match[1].trim()
	}
	get() {
		return this.regionText;
	}
}

class HeaderCheck {
	/**
	 *
	 * @param {string} inputText
	 * @param {string} filename
	 */
	constructor(inputText, filename) {
		this.inputText = inputText;
		this.filename = filename;
	}

	extractBlock() {
		const blockRegex = /---([\s\S]*?)---/;
		const match = this.inputText.match(blockRegex);
		return match ? match[1].trim() : null;
	}

	/**
	 * this function extracts the header from the input text
	 * @param {string}
	 */
	extract() {
		const block = this.extractBlock();

		if (block === null) return null;

		const titleMatch = block.match(/title:\s*(.+)/i);
		const descMatch = block.match(/description:\s*(.+)/i);
		const keywordsMatch = block.match(/keywords:\s*\[([^\]]*)\]/i);

		if (!titleMatch || !descMatch || !keywordsMatch) return null;

		return {
			title: titleMatch[1].trim(),
			description: descMatch[1].trim(),
			keywords: keywordsMatch[1].split(",").map(k => k.trim())
		};
	}

	check_header = header_obj => header_obj !== null;
	check_title = header_obj => header_obj.title != null;
	check_keywords = header_obj => header_obj.keywords != null;
	check_description = header_obj => header_obj.description != null;
	check_title_name = header_obj => (header_obj.title + ".md") === this.filename;
	check() {
		const header_obj = this.extract();
		this.header = header_obj;
		return FormatClass.validate([
			{
				//CHECK HEADER EXISTS
				fn: this.check_header,
				value: header_obj,
				msg: "[MD] Error: missing required header block.\nExpected format:\n---\ntitle: <value>\ndescription: <value>\nkeywords: [<values>]\n---"
			},
			{
				//CHEK TITLE EXISTS
				fn: this.check_title,
				value: header_obj,
				msg: "[MD] Error: header is missing a title field."
			},
			{
				fn: this.check_keywords,
				value: header_obj,
				msg: "[MD] Error: header is missing a keywords field."
			},
			{
				fn: this.check_title_name,
				value: header_obj,
				msg: "[MD] Error: header title and filename must match"
			}
		]);
	}
}

class ParamsCheck {
	constructor(inputText) {
		this.region = new region(inputText, "Parameters");
		this.params = this.parse();
	}

	// --- Core parsing ---
	parse() {
		const content = this.region.get();
		if (!content) return null;
		return content.split(/\r?\n/).filter(Boolean);
	}

	// --- Validation functions ---
	check_region_exists(content) {
		return !!content;
	}

	check_inline_format(line) {
		const regex = /`([^`]+)`\s+\*\*([^\*]+)\*\*\s*-\s*(.+)/;
		return regex.test(line);
	}

	check_table_row(line) {
		const regex = /^\|\s*([^|]+?)\s*\|\s*([^|]*?)\s*\|$/;
		const match = line.match(regex);
		if (!match) return false;

		const name = match[1].trim();
		const description = match[2].trim();

		// Separator rows are valid
		if (/^-+$/.test(name) && /^-+$/.test(description)) return true;

		return !!(name && description);
	}

	check_encapsulated_comment(line) {

		const oneLine = /^:::\s*([a-zA-Z0-9_-]+)\s+(.+?):::$/;
		if (oneLine.test(line)) return true;

		//multiline blocks
		if (/^:::\s*comment\b/.test(line)) return true;
		if (/^:::\s*$/.test(line)) return true;

		return false;
	}

	check() {
		return FormatClass.validate([
			{
				// Region must exist
				fn: this.check_region_exists,
				value: this.params,
				msg: "[MD] Error: missing required Parameters region.\nExpected format:\n### Parameters ###\n`<name>` **<type>** - <description>\nOR\n| <name> | <description> |\nOR\n::::<type> <comment>::::"
			},
			{
				// Inline params
				fn: () => this.params.every(line =>
					!line.trim() || this.check_inline_format(line)
				),
				value: this.params,
				msg: "[MD] Error: inline parameter must follow format:\n`<name>` **<type>** - <description>"
			},
			{
				// Table rows
				fn: () => this.params.every(line =>
					!line.trim() || this.check_table_row(line)
				),
				value: this.params,
				msg: "[MD] Error: table row must follow format:\n| <name> | <description> |"
			},
			{
				// Encapsulated comments
				fn: () => this.params.every(line =>
					!line.trim() || this.check_encapsulated_comment(line)
				),
				value: this.params,
				msg: "[MD] Error: encapsulated comment must follow format:\n:::<type> <comment>:::\nOr multiline:\n:::comment\ntext...\n:::"
			}
		]);
	}
}

class AvailabilityCheck {
	constructor(inputText) {
		this.region = new region(inputText, "Availability");
	}

	check() {
		if(this.region.get() === null){
			return false;
		}
		// Only allow plain text lines (no markdown headings, no code fences)
		return this.region.get().split(/\r?\n/).filter(l => l.trim() !== "").every(line =>
			!/^#{1,6}\s/.test(line) && !line.startsWith("```")
		);
	}
}



const functiondocs = documentationfiles.getFunctionDocs();

for (const doc of functiondocs) {
	const filePath = path.join(__dirname, "docs", doc);
	const content = fs.readFileSync(filePath, "utf8");

	const headerChecker = new HeaderCheck(content, doc);

	if (!headerChecker.check()) {
		console.error(`[MD] ${doc}: invalid header section.`);
		return;
	}
	const paramsChecker = new ParamsCheck(content);

	if (!paramsChecker.check()) {
		console.error(`[MD] ${doc}: invalid parameters section.`);
		return;
	}

	const availabilityChecker = new AvailabilityCheck(content);
	if (!availabilityChecker.check()) {
		console.error(`[MD] ${doc}: invalid parameters section.`);
		return;
	}
}
