import React from 'react';
import Layout from '@theme/Layout';
import Link from '@docusaurus/Link';

import { Container, Column, Row } from '../components/Grid';


const Banner = () =>
	<Container className="banner">
		<img className="feature-image" src="/img/premake-logo.png" alt="Premake logo" />
		<h1 className="hero__title">Premake</h1>
		<p className="hero__subtitle">Powerfully simple build configuration</p>
		<div className=".buttons">
			<Link
				className="button button--outline button--primary button--lg"
				to="docs/">
				Get Started
			</Link>
			&nbsp;&nbsp;
			<Link
				className="button button--outline button--primary button--lg"
				to="download">
				Download
			</Link>
		</div>
	</Container>;


const Feature = ({ title, children }) =>
	<Column>
		<h3>{title}</h3>
		<div>{children}</div>
	</Column>;


function Home() {
	return (
		<Layout>
			<header className="hero hero-banner shadow--lw">
				<Banner />
			</header>
			<main className="home">
				<section className="features">
					<Container>
						<Row>
							<Feature title="Easy to Learn, Easy to Use">
								<p>
									Describe your software project just once, using Premake's simple and easy to read
									syntax, and build it everywhere.
								</p>
								<p>
									&#8594; <Link to="docs/Your-First-Script">See an example</Link>
								</p>
							</Feature>
							<Feature title="Script Once, Target Many">
								<p>
									Generate project files for Visual Studio, GNU Make, Xcode, CodeLite, and more
									across Windows, Mac OS X, and Linux.
								</p>
								<p>
									&#8594; <Link to="docs/Using-Premake">See the full list</Link>
								</p>
							</Feature>
							<Feature title="Full Powered">
								<p>
									Use the built-in general purpose <Link to="https://www.lua.org">Lua scripting
									engine</Link> (plus lots of extras) to make build configuration tasks a breeze.
								</p>
								<p>
									&#8594; <Link to="docs">Learn more</Link>
								</p>
							</Feature>
						</Row>
					</Container>
				</section>
			</main>
		</Layout>
	);
}

export default Home;
