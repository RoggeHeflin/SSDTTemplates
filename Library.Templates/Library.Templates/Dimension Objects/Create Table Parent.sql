CREATE TABLE [$SchemaName$].[$rawname$Parent]
(
	[txId_$rawname$]						INT						NOT	NULL	CONSTRAINT [FK_$rawname$Parent_$rawname$Lookup]			FOREIGN KEY ([txId_$rawname$])	REFERENCES [$SchemaName$].[$rawname$LookUp]([txId_$rawname$]),
	[ParentId]								INT						NOT	NULL	CONSTRAINT [FK_$rawname$Parent_$rawname$Lookup_Parent]	FOREIGN KEY ([ParentId])	REFERENCES [$SchemaName$].[$rawname$LookUp]([txId_$rawname$]),
																				CONSTRAINT [FK_$rawname$Parent_$rawname$Lookup_Self]	FOREIGN KEY ([ParentId])	REFERENCES [$SchemaName$].[$rawname$Parent]([txId_$rawname$]),
	[IsRoot]								AS CONVERT(BIT, CASE WHEN ([txId_$rawname$] = [ParentId]) THEN 1 ELSE 0 END)
											PERSISTED				NOT	NULL,

	[txInserted]							DATETIMEOFFSET(7)		NOT	NULL	CONSTRAINT [DF_$rawname$Parent_txInserted]				DEFAULT(SYSDATETIMEOFFSET()),
	[txInsertedSID]							VARBINARY(85)			NOT	NULL	CONSTRAINT [DF_$rawname$Parent_txInsertedSID]			DEFAULT(SUSER_SID()),
	[txInsertedUser]						NVARCHAR(128)			NOT	NULL	CONSTRAINT [DF_$rawname$Parent_txInsertedUser]			DEFAULT(SUSER_SNAME()),
	[txInsertedHost]						NVARCHAR(128)			NOT	NULL	CONSTRAINT [DF_$rawname$Parent_txInsertedHost]			DEFAULT(HOST_NAME()),
	[txInsertedApp]							NVARCHAR(128)			NOT	NULL	CONSTRAINT [DF_$rawname$Parent_txInsertedApp]			DEFAULT(HOST_NAME()),
	[txRowReplication]						UNIQUEIDENTIFIER		NOT	NULL	CONSTRAINT [DF_$rawname$Parent_txRowReplication]		DEFAULT(NEWSEQUENTIALID())	ROWGUIDCOL,
	[txRowVersion]							ROWVERSION				NOT	NULL,

	CONSTRAINT [PK_$rawname$Parent]			PRIMARY KEY CLUSTERED([txId_$rawname$]	ASC)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_$rawname$Parent_Function]
ON [$SchemaName$].[$rawname$Parent]
(
	[txId_$rawname$]		ASC
)
INCLUDE
(
	[ParentId]
);
GO

CREATE TRIGGER [$SchemaName$].[$rawname$Parent_AfterUpdate]
ON [$SchemaName$].[$rawname$Parent]
AFTER INSERT, UPDATE
AS
BEGIN

	SET NOCOUNT ON;
	SET LOCK_TIMEOUT 100;

	DECLARE @TxnsCount		INT			= @@TRANCOUNT;
	DECLARE @ActiveTxns		VARCHAR(32)	= REPLACE(CONVERT(VARCHAR(36), NEWID(), 0), '-', '');

	DECLARE @TrackingLogId	INT;
	EXECUTE @TrackingLogId	= [track].[Insert_ProcedureLogBegin] @@PROCID, NULL, NULL;

	IF (@TxnsCount = 0) BEGIN TRANSACTION @ActiveTxns ELSE SAVE TRANSACTION @ActiveTxns;
	BEGIN TRY
	-------------------------------------------------------------------------------

		EXECUTE	[$SchemaName$].[Update_$rawname$ParentHierarchy];
		EXECUTE	[$SchemaName$].[Update_$rawname$ParentNest];
		EXECUTE	[$SchemaName$].[Update_$rawname$Bridge];
		
	-------------------------------------------------------------------------------
	IF (@TxnsCount = 0) COMMIT TRANSACTION @ActiveTxns;
	END TRY
	BEGIN CATCH

		IF (XACT_STATE() = -1) ROLLBACK	TRANSACTION @ActiveTxns;
		IF (XACT_STATE() =  1) COMMIT	TRANSACTION	@ActiveTxns;

		EXECUTE [track].[Insert_ProcedureLogError] @TrackingLogId;

		THROW;

	END CATCH;

	EXECUTE [track].[Insert_ProcedureLogEnd] @TrackingLogId;

END;