CREATE FUNCTION [$SchemaName$].[$rawname$Ancestors]
(
	@txId_$rawname$	INT
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
(
	SELECT
		[l].[txId_$rawname$],
		[l].[$rawname$Name],
		[l].[SortKey],
		[h].[Hierarchy]
	FROM
		[$SchemaName$].[$rawname$Bridge]			[b]
	INNER JOIN
		[$SchemaName$].[$rawname$LookUp]			[l]
			ON	([b].[txId_$rawname$]	=	[l].[txId_$rawname$])
	INNER JOIN
		[$SchemaName$].[$rawname$ParentHierarchy]	[h]
			ON	([b].[txId_$rawname$]	=	[h].[txId_$rawname$])
	WHERE
		([b].[DescendantId]	= @txId_$rawname$)
);