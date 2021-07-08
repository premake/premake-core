import React from 'react';


export default function Sponsors() {
	const containerRef = React.useRef();

	React.useEffect(() => {
		const script = document.createElement('script');
		script.id = 'opencollective-script';
		script.src = 'https://opencollective.com/premake/banner.js';
		script.async = true;
		containerRef.current.appendChild(script);

		return () => {
			// Short-circuit "load once" check in OpenCollective script
			window.OC = null;
		}
	}, [containerRef]);

	return (
		<div ref={containerRef} />
	);
}
