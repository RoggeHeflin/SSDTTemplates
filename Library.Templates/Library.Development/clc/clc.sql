CREATE SCHEMA [calc];
GO

EXECUTE sp_addextendedproperty
	@name		= N'MS_Description',
	@value		= N'Calculates and stores values from [fact]',
	@level0type	= N'schema',	@level0name	= N'calc';
GO