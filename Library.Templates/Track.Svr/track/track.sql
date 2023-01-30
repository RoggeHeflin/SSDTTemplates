CREATE SCHEMA [track];
GO

EXECUTE sp_addextendedproperty
	@name		= 'MS_Description',		@value		= 'Tracks database operations.',
	@level0type	= 'schema',				@level0name	= 'track';