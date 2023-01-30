CREATE VIEW [$SchemaName$].[$rawname$]
WITH SCHEMABINDING, VIEW_METADATA
AS
SELECT
	[l].[txId_$rawname$],

	[l].[$rawname$Tag],
	[l].[$rawname$Abbr],
	[l].[$rawname$Name],
	[l].[$rawname$Desc],

	[l].[SortKey],
	[l].[Operator],
	[l].[Multiplier],

	[p].[ParentId],
	[p].[IsRoot],

	[h].[Hierarchy],
	[h].[HierarchyPath],
	[h].[HierarchyItem],
	[h].[HierarchyDepth],
	[h].[HierarchyDepthMax],
	[h].[HierarchyChildren],
	[h].[HierarchyIsLeaf],
	[h].[HierarchyPrefix],

	[n].[NestLeft],
	[n].[NestRight],
	[n].[NestSpan],

	[PathName]	= STUFF(((
		SELECT		N'|' + [x].[$rawname$Name]
		FROM		[$SchemaName$].[$rawname$Ancestors]([l].[txId_$rawname$]) [x]
		ORDER BY	[x].[Hierarchy] ASC
		FOR XML PATH (N''),
		TYPE).value(N'(./text())[1]', N'NVARCHAR(MAX)')), 1, 1, N''),

	[PathSort]	= STUFF(((
		SELECT		N'|' + CAST([x].[SortKey] AS NVARCHAR(MAX))
		FROM		[$SchemaName$].[$rawname$Ancestors]([l].[txId_$rawname$]) [x]
		ORDER BY	[x].[Hierarchy] ASC
		FOR XML PATH (N''),
		TYPE).value(N'(./text())[1]', N'NVARCHAR(MAX)')), 1, 1, N'')

FROM
	[$SchemaName$].[$rawname$LookUp]			[l]
INNER JOIN
	[$SchemaName$].[$rawname$Parent]			[p]
		ON	([l].[txId_$rawname$]	=	[p].[txId_$rawname$])
INNER JOIN
	[$SchemaName$].[$rawname$ParentHierarchy]	[h]
		ON	([l].[txId_$rawname$]	=	[h].[txId_$rawname$])
INNER JOIN
	[$SchemaName$].[$rawname$ParentNest]		[n]
		ON	([l].[txId_$rawname$]	=	[n].[txId_$rawname$]);