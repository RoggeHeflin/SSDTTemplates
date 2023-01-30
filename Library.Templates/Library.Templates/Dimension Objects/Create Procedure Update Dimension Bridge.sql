CREATE PROCEDURE [$SchemaName$].[Update_$rawname$Bridge]
AS
BEGIN

	SET NOCOUNT ON;
	SET LOCK_TIMEOUT 100;

	MERGE INTO [$SchemaName$].[$rawname$Bridge] [t]
	USING
	(
		SELECT
			[a].[txId_$rawname$],
				[DescendantId]	= [d].[txId_$rawname$],
				[Distance]		= [d].[Hierarchy].GetLevel() - [a].[Hierarchy].GetLevel()
		FROM
			[$SchemaName$].[$rawname$ParentHierarchy]	[a]
		INNER JOIN
			[$SchemaName$].[$rawname$ParentHierarchy]	[d]
				ON	([d].[Hierarchy].IsDescendantOf([a].[Hierarchy]) = 1)
	) [s]([txId_$rawname$], [DescendantId], [Distance])
		ON	([s].[txId_$rawname$]	= [t].[txId_$rawname$])
		AND	([s].[DescendantId]	= [t].[DescendantId])

	WHEN NOT MATCHED BY TARGET THEN
		INSERT(    [txId_$rawname$],     [DescendantId],     [Distance])
		VALUES([s].[txId_$rawname$], [s].[DescendantId], [s].[Distance])

	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;

END;