CREATE SCHEMA [doc];
GO

EXECUTE sp_addextendedproperty
	@name		= N'MS_Description',
	@value		= N'Database Documentation',
	@level0type	= N'schema',	@level0name	= N'doc';