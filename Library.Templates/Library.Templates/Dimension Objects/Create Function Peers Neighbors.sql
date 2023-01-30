CREATE FUNCTION [$SchemaName$].[$rawname$PeersNeighbors]
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
		[$SchemaName$].[$rawname$Parent]				[p]
			ON	([h].[txId_$rawname$]		=	[p].[txId_$rawname$])
	INNER JOIN
		[$SchemaName$].[$rawname$ParentHierarchy]		[c]
			ON	([h].[HierarchyDepth]	=	[c].[HierarchyDepth])
	INNER JOIN
		[$SchemaName$].[$rawname$Parent]				[n]
			ON	([c].[txId_$rawname$]		=	[n].[txId_$rawname$])
			AND	([p].[ParentId]			=	[n].[ParentId])
	WHERE
		([h].[txId_$rawname$]	=	@txId_$rawname$)
);