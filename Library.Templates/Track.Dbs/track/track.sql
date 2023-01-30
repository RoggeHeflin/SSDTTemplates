CREATE SCHEMA [track];
GO

EXECUTE sp_addextendedproperty
	@name		= 'MS_Description',		@value		= 'Tracks database stored procedure executions.',
	@level0type	= 'schema',				@level0name	= 'track';