import React from 'react';

const Column = ({ children }) =>
	<div className="col">
		{children}
	</div>;


const Container = ({ children, className }) =>
	<div className={`container ${className ?? ""}`}>
		{children}
	</div>;


const Row = ({ children }) =>
	<div className="row">
		{children}
	</div>;


export {
	Column,
	Container,
	Row
};
