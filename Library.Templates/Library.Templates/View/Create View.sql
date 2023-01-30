CREATE VIEW $SchemaQualifiedObjectName$
WITH SCHEMABINDING, VIEW_METADATA
AS
SELECT
	[t].*
FROM
	[$UnknownParentPlaceholder$]		[t];
GO

EXECUTE sp_addextendedproperty
	@name		= N'MS_Description',
	@value		= N'{Enter Description or Purpose Here}',
	@level0type	= N'schema',	@level0name	= N'$SchemaName$',
	@level1type	= N'view',		@level1name	= N'$rawname$';

CREATE UNIQUE CLUSTERED INDEX [CX_$rawname$]
ON $SchemaQualifiedObjectName$
(
	[Id]		ASC
);
GO

/*
https://docs.microsoft.com/en-us/sql/t-sql/queries/hints-transact-sql-table?view=sql-server-ver15#using-noexpand

SELECT
	[t].*
FROM
	$SchemaQualifiedObjectName$	WITH(NOEXPAND);
*/