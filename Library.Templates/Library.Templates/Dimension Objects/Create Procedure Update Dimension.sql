CREATE PROCEDURE [$SchemaName$].[Update_$rawname$]
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