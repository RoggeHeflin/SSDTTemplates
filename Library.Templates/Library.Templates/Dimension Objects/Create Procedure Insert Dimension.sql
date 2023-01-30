CREATE PROCEDURE [$SchemaName$].[Insert_$rawname$]
(
	@Tag			NVARCHAR(10),
	@Abbr			NVARCHAR(60),
	@Name			NVARCHAR(60),
	@Desc			NVARCHAR(80),

	@ParentTag		NVARCHAR(10),

	@SortKey		INT,
	@Operator		CHAR(1)
)
AS
BEGIN

	SET NOCOUNT ON;
	SET LOCK_TIMEOUT 100;

	DECLARE @Out TABLE
	(
		[txId_$rawname$]		INT	NOT	NULL
	);

	DECLARE @txId_$rawname$		INT;

	INSERT INTO [$SchemaName$].[$rawname$LookUp]
	(
		[$rawname$Tag],
		[$rawname$Abbr],
		[$rawname$Name],
		[$rawname$Desc],
		[SortKey],
		[Operator]
	)
	OUTPUT [inserted].[txId_$rawname$]
	INTO @Out([txId_$rawname$])
	VALUES
	(
		@Tag,
		@Abbr,
		@Name,
		@Desc,
		@SortKey,
		@Operator
	);

	SELECT @txId_$rawname$ = [o].[txId_$rawname$] FROM @Out [o];

	INSERT INTO [$SchemaName$].[$rawname$Parent]
	(
		[txId_$rawname$],
		[ParentId]
	)
	VALUES
	(
		@txId_$rawname$,
		[$SchemaName$].[$rawname$ReturnId](@ParentTag)
	);

	EXECUTE [$SchemaName$].[Update_$rawname$];

END;