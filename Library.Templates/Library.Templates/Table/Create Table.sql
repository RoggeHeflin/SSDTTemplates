CREATE TABLE $SchemaQualifiedObjectName$
(
	[Column1]						INT					NOT	NULL,
	[Column2]						INT					NOT	NULL,

	[txId_$rawname$]		 	INT					NOT	NULL	IDENTITY(1, 1)	NOT FOR REPLICATION,
	[txInserted]					DATETIMEOFFSET(7)	NOT	NULL	CONSTRAINT	[DF_$rawname$_txInserted]				DEFAULT(SYSDATETIMEOFFSET()),
	[txInsertedSID]					VARBINARY(85)		NOT	NULL	CONSTRAINT	[DF_$rawname$_txInsertedSID]			DEFAULT(SUSER_SID()),
	[txInsertedUserExecuted]		NVARCHAR(128)		NOT	NULL	CONSTRAINT	[DF_$rawname$_txInsertedUserExecuted]	DEFAULT(SUSER_SNAME()),
	[txInsertedUserOriginal]		NVARCHAR(128)		NOT	NULL	CONSTRAINT	[DF_$rawname$_txInsertedUserOriginal]	DEFAULT(ORIGINAL_LOGIN()),
	[txInsertedHost]				NVARCHAR(128)		NOT	NULL	CONSTRAINT	[DF_$rawname$_txInsertedHost]			DEFAULT(HOST_NAME()),
	[txInsertedApplication]			NVARCHAR(128)		NOT	NULL	CONSTRAINT	[DF_$rawname$_txInsertedApplication]	DEFAULT(APP_NAME()),
	[txInsertedProcedure]			NVARCHAR(257)			NULL	CONSTRAINT	[DF_$rawname$_txInsertedProcedure]		DEFAULT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID))),

	[txIsLatest]					BIT					NOT	NULL	CONSTRAINT	[DF_$rawname$_txIsLatest]				DEFAULT(1),
	[txUpdated]						DATETIMEOFFSET(7)	NOT	NULL	CONSTRAINT	[DF_$rawname$_txUpdated]				DEFAULT(SYSDATETIMEOFFSET()),

	[txValidBeg_UTC]				DATETIME2(7)		NOT	NULL	GENERATED ALWAYS AS ROW START,
	[txValidEnd_UTC]				DATETIME2(7)		NOT	NULL	GENERATED ALWAYS AS ROW END HIDDEN,
									PERIOD FOR SYSTEM_TIME ([txValidBeg_UTC], [txValidEnd_UTC]),

	[txRowReplication]				UNIQUEIDENTIFIER	NOT	NULL	CONSTRAINT	[DF_$rawname$_txRowReplication]			DEFAULT(NEWSEQUENTIALID())	ROWGUIDCOL,
	[txRowVersion]					ROWVERSION			NOT	NULL,

	CONSTRAINT [PK_$rawname$]		PRIMARY KEY CLUSTERED([txId_$rawname$]	ASC),
	CONSTRAINT [UK_$rawname$]		UNIQUE NONCLUSTERED([Column1] ASC, [Column2] ASC)
)
WITH
(
	SYSTEM_VERSIONING = ON
	(
		HISTORY_TABLE			= [$SchemaName$].[$rawname$_History],
		DATA_CONSISTENCY_CHECK	= ON
	)
);
GO

EXECUTE sp_addextendedproperty
	@name		= N'MS_Description',
	@value		= N'{Enter Description or Purpose}',
	@level0type	= N'schema',	@level0name	= N'$SchemaName$',
	@level1type	= N'table',		@level1name	= N'$rawname$';
GO

/*	Indexed columns are generally used in this sequence(s)
		A)	1) WHERE,
			2) JOIN,
			3) GROUP,
			4) PARTITION,
			5) ORDER
		B)	1) Equality,
			2) Sort,
			3) Inequality
*/
CREATE UNIQUE NONCLUSTERED INDEX [UX_$rawname$_Covering]
ON $SchemaQualifiedObjectName$
(
	[Column1]	ASC
)
INCLUDE
(
	[Column2]
);
GO

CREATE TRIGGER [$SchemaName$].[Trigger_Update_$rawname$]
ON $SchemaQualifiedObjectName$
AFTER UPDATE
AS
BEGIN

	SET	NOCOUNT ON;
	SET	LOCK_TIMEOUT 100;

	DECLARE	@TxnExists		BIT				= IIF((@@TRANCOUNT = 0), 0, 1);
	DECLARE	@TxnActive		VARCHAR(32)		= REPLACE(CONVERT(VARCHAR(36), NEWID(), 0), '-', '');

	DECLARE	@TrackingLogId	INT;
	EXECUTE	@TrackingLogId	= [track].[Insert_ProcedureLogBegin] @@PROCID;

	BEGIN TRY
	IF (@TxnExists = 0) BEGIN TRANSACTION @TxnActive ELSE SAVE TRANSACTION @TxnActive;
	/*-------------------------------------------------------------------------------------------*/

		UPDATE $SchemaQualifiedObjectName$
		SET
			[txUpdated] = SYSDATETIMEOFFSET()
		WHERE
			([$rawname$Id] IN (SELECT [x].[$rawname$Id] FROM INSERTED [x]));

	/*-------------------------------------------------------------------------------------------*/
	IF (@TxnExists = 0) COMMIT TRANSACTION @TxnActive ELSE SAVE TRANSACTION @TxnActive;
	END TRY
	BEGIN CATCH

		IF (XACT_STATE() = -1) ROLLBACK TRANSACTION @TxnActive;
		IF (XACT_STATE() =  1) AND (@TxnExists = 0) COMMIT TRANSACTION @TxnActive;

		EXECUTE	[track].[Insert_ProcedureLogError] @@PROCID, @TrackingLogId;

		THROW;

	END CATCH;

	EXECUTE	[track].[Insert_ProcedureLogEnd] @@PROCID, @TrackingLogId;

END;
GO

/*	Create a single-column index for column indicating last update	*/
CREATE NONCLUSTERED INDEX [IX_$rawname$_txUpdated_LastUpdate]
ON $SchemaQualifiedObjectName$
(
	[txUpdated]	DESC
);
GO

/*	Create a function returning the last update; verify data type for target query	*/
CREATE FUNCTION [$SchemaName$].[Return_$rawname$_LastUpdate]()
RETURNS CHAR(19)
AS
BEGIN

	DECLARE @LastUpdate		DATETIMEOFFSET(7);

	SELECT
		@LastUpdate	= MAX([t].[txUpdated])
	FROM
		$SchemaQualifiedObjectName$	[t]
	WHERE
		([t].[txUpdated] IS NOT NULL);

	RETURN FORMAT(CONVERT(DATETIME, @LastUpdate), 'yyyy-MM-dd:HH:mm:ss')

END;