CREATE PROCEDURE [$SchemaName$].[Delete_$rawname$]
AS
BEGIN

	SET	NOCOUNT ON;
	SET	LOCK_TIMEOUT 100;

	DECLARE	@ErrorCode		INT				= 0;
	DECLARE	@TxnExists		BIT				= IIF((@@TRANCOUNT = 0), 0, 1);
	DECLARE	@TxnActive		VARCHAR(32)		= REPLACE(CONVERT(VARCHAR(36), NEWID(), 0), '-', '');

	DECLARE	@TrackingLogId	INT;
	EXECUTE	@TrackingLogId	= [track].[Insert_ProcedureLogBegin] @@PROCID;

	BEGIN TRY
	IF (@TxnExists = 0) BEGIN TRANSACTION @TxnActive ELSE SAVE TRANSACTION @TxnActive;
	/*-------------------------------------------------------------------------------------------*/

		TRUNCATE TABLE [$SchemaName$].[$rawname$];

	/*-------------------------------------------------------------------------------------------*/
	IF (@TxnExists = 0) COMMIT TRANSACTION @TxnActive ELSE SAVE TRANSACTION @TxnActive;
	END TRY
	BEGIN CATCH

		SET	@ErrorCode = @@ERROR;

		IF (XACT_STATE() = -1) ROLLBACK TRANSACTION @TxnActive;
		IF (XACT_STATE() =  1) AND (@TxnExists = 0) COMMIT TRANSACTION @TxnActive;

		EXECUTE	[track].[Insert_ProcedureLogError] @@PROCID, @TrackingLogId;

		THROW;

		RETURN	@ErrorCode;

	END CATCH;

	EXECUTE	[track].[Insert_ProcedureLogEnd] @@PROCID, @TrackingLogId;

	RETURN	@ErrorCode;

END;
GO

EXECUTE sp_addextendedproperty
	@name		= N'MS_Description',
	@value		= N'Delete data from [$SchemaName$].[$rawname$].',
	@level0type	= N'schema',		@level0name	= N'$SchemaName$',
	@level1type	= N'procedure',		@level1name	= N'Delete_$rawname$';