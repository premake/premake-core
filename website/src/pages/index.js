import React from 'react';
import clsx from 'clsx';
import Layout from '@theme/Layout';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import useBaseUrl from '@docusaurus/useBaseUrl';
import styles from '../css/styles.module.css';

const features = [
  {
    title: 'Easy to Use',
    description: (
      <div>
        <p>Describe your software project just once, using Premake's simple and easy to read syntax, and build it everywhere.</p>
        <p>Generate project files for Visual Studio, GNU Make, Xcode, Code::Blocks, and more across Windows, Mac OS X, and
        Linux. Use the full featured Lua scripting engine to make build configuration tasks a breeze.</p>
      </div>
    ),
  },
  {
    title: 'Version 5.0 (alpha)',
    description: (
      <div>
        <p>The latest iteration of Premake, featuring an improved platform system, support for third-party modules, and loads of new features.</p>
		    <p className={styles.bigText}>
          <a href='download/'>Download</a>&nbsp;·&nbsp;<a href='docs/'>Documentation</a>
        </p>
      </div>
    ),
  },
  {
    title: 'Version 4.4 (beta)',
    description: (
      <div>
        <p>The latest in Premake's 4.x stable branch.</p>
		    <p className={styles.bigText}>
          <a href='download/'>Download</a>&nbsp;·&nbsp;<a href='https://github.com/premake/premake-4.x/wiki'>Documentation</a>
        </p>
      </div>
    ),
  },
];

function Feature({imageUrl, title, description}) {
  const imgUrl = useBaseUrl(imageUrl);
  return (
    <div className={clsx('col col--4', styles.feature)}>
      <h3>{title}</h3>
      <>{description}</>
    </div>
  );
}

function Home() {
  const context = useDocusaurusContext();
  const {siteConfig = {}} = context;
  return (
    <Layout
      title={`${siteConfig.title}`}
      description="Description will go into a meta tag in <head />">
      <header className={clsx('hero shadow--lw', styles.heroBanner)}>
        <div className="container">
          <img className={styles.featureImage} src={useBaseUrl('img/premake-logo.png')} alt={'Premake logo'} />
          <h1 className="hero__title">{siteConfig.title}</h1>
          <p className="hero__subtitle">{siteConfig.tagline}</p>
          <div className={styles.buttons}>
            <Link
              className={clsx(
                'button button--outline button--primary button--lg',
                styles.getStarted,
              )}
              to={useBaseUrl('docs/')}>
              Get Started
            </Link>
            &nbsp;&nbsp;
            <Link
              className={clsx(
                'button button--outline button--primary button--lg',
                styles.getStarted,
              )}
              to={useBaseUrl('download/')}>
              Download
            </Link>
          </div>
        </div>
      </header>
      <main>
        {features && features.length > 0 && (
          <section className={styles.features}>
            <div className="container">
              <div className="row">
                {features.map((props, idx) => (
                  <Feature key={idx} {...props} />
                ))}
              </div>
            </div>
          </section>
        )}
      </main>
    </Layout>
  );
}

export default Home;
