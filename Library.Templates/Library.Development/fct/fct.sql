CREATE SCHEMA [fact];
GO

EXECUTE sp_addextendedproperty
	@name		= N'MS_Description',
	@value		= N'Stores normalized values transferred from [stg]',
	@level0type	= N'schema',	@level0name	= N'fact';
GO