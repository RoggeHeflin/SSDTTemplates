CREATE FUNCTION [$SchemaName$].[$rawname$Peers]
(
	@txId_$rawname$	INT
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
(
	SELECT
		[n].[txId_$rawname$],
		[n].[ParentId]
	FROM
		[$SchemaName$].[$rawname$ParentHierarchy]		[h]
	INNER JOIN
		[$SchemaName$].[$rawname$ParentHierarchy]		[c]
			ON	([h].[HierarchyDepth]	=	[c].[HierarchyDepth])
	INNER JOIN
		[$SchemaName$].[$rawname$Parent]				[n]
			ON	([c].[txId_$rawname$]		=	[n].[txId_$rawname$])
	WHERE
		([h].[txId_$rawname$]	=	@txId_$rawname$)
);