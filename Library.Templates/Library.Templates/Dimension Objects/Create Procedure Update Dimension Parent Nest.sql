CREATE PROCEDURE [$SchemaName$].[Update_$rawname$ParentNest]
AS
BEGIN

	SET NOCOUNT ON;
	SET LOCK_TIMEOUT 100;

	MERGE INTO [$SchemaName$].[$rawname$ParentNest] [t]
	USING
	(
		SELECT
			[h].[txId_$rawname$],
			[h].[NestLeft],
				[NestRight]	= (2 * [h].[HierarchyChildren]) + [h].[NestLeft] + 1,
				[NestSpan]	= (2 * [h].[HierarchyChildren]) + 1
		FROM (
			SELECT
				[h].[txId_$rawname$],
					[HierarchyChildren]	= [h].[HierarchyChildren],
					[NestLeft]			= (2 * [HierarchyItem]) - [h].[HierarchyDepth]
			FROM
				[$SchemaName$].[$rawname$ParentHierarchy]	[h]
		) [h]
	) [s]([txId_$rawname$], [NestLeft], [NestRight], [NestSpan])
		ON	([s].[txId_$rawname$]	= [t].[txId_$rawname$])

	WHEN NOT MATCHED BY TARGET THEN
		INSERT(    [txId_$rawname$],     [NestLeft],     [NestRight],     [NestSpan])
		VALUES([s].[txId_$rawname$], [s].[NestLeft], [s].[NestRight], [s].[NestSpan])

	WHEN NOT MATCHED BY SOURCE THEN
		DELETE

	WHEN MATCHED THEN
		UPDATE SET
			[t].[NestLeft]	= [s].[NestLeft],
			[t].[NestRight]	= [s].[NestRight],
			[t].[NestSpan]	= [s].[NestSpan];

END;