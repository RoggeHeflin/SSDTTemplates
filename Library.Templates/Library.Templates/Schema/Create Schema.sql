CREATE SCHEMA [$rawname$];
GO

EXECUTE sp_addextendedproperty
	@name		= N'MS_Description',
	@value		= N'{Enter Description or Purpose}',
	@level0type	= N'schema',	@level0name	= N'$rawname$';