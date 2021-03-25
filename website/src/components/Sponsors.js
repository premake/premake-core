import React from 'react';

const Sponsors = ({ width }) => {
	width = width ?? 800;
	return (
		<div className="sponsors">
			<div>
				<a href="https://opencollective.com/premake#sponsors" target="_blank">
					<img src={`https://opencollective.com/premake/sponsors.svg?width=${width}&avatarHeight=92&button=false`} />
				</a>
			</div>
			<div>
				<a href="https://opencollective.com/premake#backers" target="_blank">
					<img src={`https://opencollective.com/premake/backers.svg?width=${width}&button=false`} />
				</a>
			</div>
		</div>
	);
};

export default Sponsors;
