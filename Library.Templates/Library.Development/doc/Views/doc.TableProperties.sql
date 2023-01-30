CREATE VIEW [doc].[TableProperties]
WITH VIEW_METADATA
AS
SELECT
	[SchemaName]			= [s].[name],
	[TableName]				= [t].[name],
	[TableDescriptionName]	= [p].[name],
	[TableDescription]		= [p].[value],

	[IndexName]				= [i].[name],
	[IndexPrimaryKey]		= IIF(([i].[is_primary_key] = 1), 'Primary', 'Unique'),
	[UniqueKey]				= STUFF((
								SELECT
									N', ' + QUOTENAME([z].[name]) + IIF([y].[is_descending_key] = 0, N' ASC', N' DESC')
								FROM
									sys.index_columns				[y]
								INNER JOIN
									sys.columns						[z]
										ON	([y].[object_id]	=	[z].[object_id])
										AND	([y].[column_id]	=	[z].[column_id])
								WHERE
										([y].[object_id]			=	[i].[object_id])
									AND	([y].[index_id]				=	[i].[index_id])
									AND	([y].[is_included_column]	=	0)
								ORDER BY
									[y].[key_ordinal]	ASC
								FOR XML PATH(N'')), 1, 2, N'')
FROM
	sys.schemas						[s]
INNER JOIN
	sys.tables						[t]
		ON	([s].[schema_id]	=	[t].[schema_id])
INNER JOIN
	sys.indexes						[i]
		ON	([t].[object_id]	=	[i].[object_id])
INNER JOIN
	sys.extended_properties			[p]
		ON	([t].[object_id]	=	[p].[major_id])
		AND	([p].[minor_id]		=	0)
WHERE
	([i].[is_unique]			=	1);
GO

EXECUTE sp_addextendedproperty
	@name		= N'MS_Description',
	@value		= N'List tables and descriptions',
	@level0type	= N'schema',	@level0name	= N'doc',
	@level1type	= N'view',		@level1name	= N'TableProperties';