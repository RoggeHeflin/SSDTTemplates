CREATE FUNCTION [$SchemaName$].[$rawname$ReturnId]
(
	@$rawname$Tag		NVARCHAR(10)
)
RETURNS INT
WITH SCHEMABINDING, RETURNS NULL ON NULL INPUT
AS
BEGIN

	DECLARE @txId_$rawname$		INT;

	SELECT TOP(1)
		@txId_$rawname$	= [l].[txId_$rawname$]
	FROM
		[$SchemaName$].[$rawname$LookUp]	[l]
	WHERE
		([l].[$rawname$Tag] = @$rawname$Tag);

	RETURN @txId_$rawname$;

END;