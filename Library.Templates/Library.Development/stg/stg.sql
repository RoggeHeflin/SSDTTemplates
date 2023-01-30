CREATE SCHEMA [stg];
GO

EXECUTE sp_addextendedproperty
	@name		= N'MS_Description',
	@value		= N'Stores raw data imported into SQL Server',
	@level0type	= N'schema',	@level0name	= N'stg';
GO