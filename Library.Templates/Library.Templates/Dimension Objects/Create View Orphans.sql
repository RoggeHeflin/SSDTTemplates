CREATE VIEW [$SchemaName$].[$rawname$Orphans]
WITH SCHEMABINDING, VIEW_METADATA
AS
SELECT
	[l].[txId_$rawname$],
	[l].[$rawname$Tag],
	[l].[$rawname$Abbr],
	[l].[$rawname$Name],
	[l].[$rawname$Desc]
FROM
	[$SchemaName$].[$rawname$LookUp]			[l]
LEFT OUTER JOIN
	[$SchemaName$].[$rawname$Parent]			[p]
		ON	([l].[txId_$rawname$]	=	[p].[txId_$rawname$])
WHERE
	([p].[txId_$rawname$] IS NULL);