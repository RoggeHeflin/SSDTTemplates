CREATE SCHEMA [rpt];
GO

EXECUTE sp_addextendedproperty
	@name		= N'MS_Description',
	@value		= N'Prepares calculated data for reporting [calc]',
	@level0type	= N'schema',	@level0name	= N'rpt';
GO