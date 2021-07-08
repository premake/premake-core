import React from 'react';
import Layout from '@theme/Layout';
import Link from '@docusaurus/Link';

import { Column, Container, Row } from '../components/Grid';


const Download = () =>
	<Layout title="Download">
		<main className="download">
			<Container className="intro">
				<Row>
					<Column>
						<h1>Download Premake</h1>
						<p>
							We'll start making official binary releases once v6.0 reaches a beta state. Until then <Link to="https://github.com/premake/premake-core">use the source</Link>.
						</p>
					</Column>
				</Row>
			</Container>
		</main>
	</Layout>;

export default Download;
