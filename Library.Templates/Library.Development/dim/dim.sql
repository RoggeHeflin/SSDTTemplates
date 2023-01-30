CREATE SCHEMA [dim];
GO

EXECUTE sp_addextendedproperty
	@name		= N'MS_Description',
	@value		= N'Attributes, Dimensions, and Features',
	@level0type	= N'schema',	@level0name	= N'dim';