CREATE PROCEDURE [$SchemaName$].[Update_$rawname$ParentHierarchy]
AS
BEGIN

	SET NOCOUNT ON;
	SET LOCK_TIMEOUT 100;

	WITH [cte]([txId_$rawname$], [ParentId], [Hierarchy], [Prefix])
	AS
	(
		SELECT
			[p].[txId_$rawname$],
			[p].[ParentId],
				[Hierarchy]	= sys.hierarchyid::Parse(N'/'
								+ CAST(ROW_NUMBER() OVER(ORDER BY [l].[SortKey]) AS NVARCHAR(MAX)) + N'/'),
				[Prefix]	= CAST(N'' AS NVARCHAR(MAX))
		FROM
			[$SchemaName$].[$rawname$LookUp]			[l]
		INNER JOIN
			[$SchemaName$].[$rawname$Parent]			[p]
				ON	([l].[txId_$rawname$]	=	[p].[txId_$rawname$])
		WHERE
			([p].[IsRoot] = 1)

		UNION ALL

		SELECT
			[p].[txId_$rawname$],
			[p].[ParentId],
				[Hierarchy]	= sys.hierarchyid::Parse([c].[Hierarchy].ToString()
								+ CAST(ROW_NUMBER() OVER(ORDER BY [l].[SortKey]) AS NVARCHAR(MAX)) + N'/'),
				[Prefix]	= [$SchemaName$].[HierarchyPrefix]([c].[Prefix], ROW_NUMBER() OVER(ORDER BY [l].[SortKey] DESC))
		FROM
			[$SchemaName$].[$rawname$LookUp]			[l]
		INNER JOIN
			[$SchemaName$].[$rawname$Parent]			[p]
				ON	([l].[txId_$rawname$]	=	[p].[txId_$rawname$])
		INNER JOIN
			[cte]							[c]
				ON	([p].[ParentId]		=	[c].[txId_$rawname$])
		WHERE
			([p].[IsRoot] = 0)
	)
	MERGE INTO [$SchemaName$].[$rawname$ParentHierarchy] [t]
	USING
	(
		SELECT
			[c].[txId_$rawname$],
			[c].[Hierarchy],
				[HierarchyPath]		= [c].[Hierarchy].ToString(),
				[HierarchyDepth]	= [c].[Hierarchy].GetLevel(),
				[HierarchyDepthMax]	= MAX([c].[Hierarchy].GetLevel()) OVER(),
				[HierarchyIsLeaf]	= CASE WHEN (EXISTS(SELECT TOP 1 1 FROM [$SchemaName$].[$rawname$Parent] [x] WITH (NOLOCK) WHERE ([x].[ParentId] = [c].[txId_$rawname$]))) THEN 0 ELSE 1 END,
				[HierarchyChildren]	= (SELECT COUNT(*) - 1 FROM [cte] [x] WITH (NOLOCK) WHERE ([x].[Hierarchy].IsDescendantOf([c].[Hierarchy]) = 1)),
				[HierarchyItem]		= ROW_NUMBER() OVER(ORDER BY [c].[Hierarchy] ASC),
				[HierarchyPrefix]	= [c].[Prefix]
		FROM
			[cte]	[c]
	) [s]([txId_$rawname$], [Hierarchy], [HierarchyPath], [HierarchyDepth], [HierarchyDepthMax], [HierarchyIsLeaf], [HierarchyChildren], [HierarchyItem], [HierarchyPrefix])
		ON	([s].[txId_$rawname$]	= [t].[txId_$rawname$])

	WHEN NOT MATCHED BY TARGET THEN
		INSERT(    [txId_$rawname$],     [Hierarchy],     [HierarchyPath],     [HierarchyDepth],     [HierarchyDepthMax],     [HierarchyIsLeaf],     [HierarchyChildren],     [HierarchyItem],     [HierarchyPrefix])
		VALUES([s].[txId_$rawname$], [s].[Hierarchy], [s].[HierarchyPath], [s].[HierarchyDepth], [s].[HierarchyDepthMax], [s].[HierarchyIsLeaf], [s].[HierarchyChildren], [s].[HierarchyItem], [s].[HierarchyPrefix])

	WHEN NOT MATCHED BY SOURCE THEN
		DELETE

	WHEN MATCHED THEN
		UPDATE SET
			[t].[Hierarchy]				= [s].[Hierarchy],
			[t].[HierarchyPath]			= [s].[HierarchyPath],
			[t].[HierarchyDepth]		= [s].[HierarchyDepth],
			[t].[HierarchyDepthMax]		= [s].[HierarchyDepthMax],
			[t].[HierarchyIsLeaf]		= [s].[HierarchyIsLeaf],
			[t].[HierarchyChildren]		= [s].[HierarchyChildren],
			[t].[HierarchyItem]			= [s].[HierarchyItem],
			[t].[HierarchyPrefix]		= [s].[HierarchyPrefix];

END;