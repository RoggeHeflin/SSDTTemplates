CREATE FUNCTION [$SchemaName$].[$rawname$Distance]
(
	@txId_$rawname$_Beg	INT,
	@txId_$rawname$_End	INT
)
RETURNS INT
AS
BEGIN

	DECLARE @Distance	INT;

	SELECT
		@Distance = [a].[Distance] + [b].[Distance]
	FROM
		[$SchemaName$].[$rawname$Bridge]			[a]
	INNER JOIN
		[$SchemaName$].[$rawname$Bridge]			[b]
			ON	([a].[txId_$rawname$]	=	[b].[txId_$rawname$])
	WHERE
			([a].[DescendantId]		= @txId_$rawname$_Beg)
		AND	([b].[DescendantId]		= @txId_$rawname$_End)

	RETURN COALESCE(@Distance, 0);

END;