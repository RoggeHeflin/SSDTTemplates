CREATE VIEW [$SchemaName$].[UnMappedForeignKeys]
WITH VIEW_METADATA
AS
SELECT
	[MappingConstraint]	= [kc].[name],
	[SourceSchema]		= [fs].[name],
	[SourceTable]		= [ft].[name],
	[SourceColumn]		= [fc].[name],
	[MapSchema]			= [ms].[name],
	[MapTable]			= [mt].[name],
	[MapColumn]			= [mc].[name]
FROM
	sys.foreign_key_columns						[fk]
LEFT OUTER JOIN
	sys.foreign_keys							[kc]
		ON	([fk].[constraint_object_id]	=	[kc].[object_id])
INNER JOIN
	sys.tables									[ft]
		ON	([fk].[parent_object_id]		=	[ft].[object_id])
INNER JOIN
	sys.schemas									[fs]
		ON	([ft].[schema_id]				=	[fs].[schema_id])
INNER JOIN
	sys.columns									[fc]
		ON	([ft].[object_id]				=	[fc].[object_id])
		AND	([fk].[parent_column_id]		=	[fc].[column_id])
INNER JOIN
	sys.tables									[mt]
		ON	([fk].[referenced_object_id]	=	[mt].[object_id])
INNER JOIN
	sys.schemas									[ms]
		ON	([mt].[schema_id]				=	[ms].[schema_id])
INNER JOIN
	sys.columns									[mc]
		ON	([mt].[object_id]				=	[mc].[object_id])
		AND	([fk].[referenced_column_id]	=	[mc].[column_id])
WHERE
		([kc].[name]	LIKE 'MC_FK%')
	AND	([mt].[name]	LIKE '%Map')
	AND	([ms].[name]	=	'$SchemaName$');
GO

EXECUTE sp_addextendedproperty
	@name		= N'MS_Description',
	@value		= N'Returns mapped columns based on foreign key constraints.',
	@level0type	= N'schema',	@level0name	= N'$SchemaName$',
	@level1type	= N'view',		@level1name	= N'UnMappedForeignKeys';