import React from 'react';
import Layout from '@theme/Layout';
import Link from '@docusaurus/Link';

import { Column, Container, Row } from '../components/Grid';
import Sponsors from '../components/Sponsors';


const LATEST_VERSION = '5.0.0-beta3';


const DownloadLink = ({ arch }) => {
	let filename, label, icon;
	switch (arch) {
	case 'macos':
		filename = 'macosx.tar.gz';
		label = 'MacOS';
		icon = 'fa-apple';
		break;
	case 'linux':
		filename = 'linux.tar.gz';
		label = 'Linux';
		icon = 'fa-linux';
		break;
	case 'src':
		filename = 'src.zip';
		label = 'Source Code';
		icon = 'fa-code';
		break;
	case 'windows':
		filename = 'windows.zip';
		label = 'Windows';
		icon = 'fa-windows';
		break;
	}
	return (
		<li>
			<i className={`inline-image fa ${icon}`}></i>
			<Link to={`https://github.com/premake/premake-core/releases/download/v${LATEST_VERSION}/premake-${LATEST_VERSION}-${filename}`}>
				<b>{label}</b>
			</Link>
		</li>
	);
};


const Download = () =>
	<Layout title="Download">
		<main className="download">
			<Container className="intro">
				<Row>
					<Column>
						<h1>Download Premake</h1>
						<p>
							Premake is a self-contained, single file command line executable which should build and run pretty much everywhere.
							See <Link to="/docs/Using-Premake">Using Premake</Link> for usage instructions and help getting started.
						</p>
						<p>
							The latest released version is <b>v{LATEST_VERSION}</b>. <Link to="https://github.com/premake/premake-core/releases">See all releases</Link>.
						</p>
					</Column>
				</Row>
			</Container>
			<Container>
				<Row>
					<Column>
						<h3>Pre-Built Binaries</h3>
						<p>Binaries simply need to be unpacked and placed somewhere on the system search path or any other convenient location.</p>
						<ul className="download-links">
							<DownloadLink arch="windows" />
							<DownloadLink arch="linux" />
							<DownloadLink arch="macos" />
						</ul>
					</Column>
					<Column>
						<h3>Build It Yourself</h3>
						<p>
							The source code package includes project files for all supported toolsets.
							See <Link to="https://github.com/premake/premake-core/blob/master/BUILD.txt">BUILD.txt</Link> for
							build instructions.
						</p>
						<ul className="download-links">
							<DownloadLink arch="src" />
						</ul>
						<p>
							The latest sources (without prebuilt project files) are available
							on <Link to="https://github.com/premake/premake-core">GitHub</Link>.
							See <Link to="https://github.com/premake/premake-core/blob/master/BUILD.txt">BUILD.txt</Link> for
							build instructions.
						</p>
					</Column>
				</Row>
				<Row>
					<Column>
						<section className="sponsors">
							<h1>Sponsors</h1>
							<p>
								Continued Premake development is made possible by our <b><Link to="https://opencollective.com/premake">OpenCollective sponsors</Link></b> and <b><Link to="https://github.com/premake/premake-core/graphs/contributors">code contributors</Link></b>. 🙌 ❤️
							</p>
							<Sponsors />
						</section>
					</Column>
				</Row>
			</Container>
		</main>
	</Layout>;

export default Download;
