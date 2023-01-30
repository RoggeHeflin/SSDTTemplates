CREATE FUNCTION [$SchemaName$].[HierarchyPrefix]
(
	@Prefix		NVARCHAR(MAX),
	@RowNum		INT
)
RETURNS NVARCHAR(MAX)
WITH SCHEMABINDING, RETURNS NULL ON NULL INPUT
AS
BEGIN

	RETURN	REPLACE(REPLACE(@Prefix, N'└', N' '), N'├', N'│') + CASE WHEN (@RowNum = 1) THEN N' └ ' ELSE N' ├ ' END;

END;
GO

EXECUTE sp_addextendedproperty
	@name		= N'MS_Description',
	@value		= N'Returns ASCII block diagram characters for displaying lookups with parent-child relationships. Monspaced fonts provide best results.',
	@level0type	= N'schema',	@level0name	= N'$SchemaName$',
	@level1type	= N'function',	@level1name	= N'HierarchyPrefix';