CREATE PROCEDURE [$SchemaName$].[Delete_UnMapped]
AS
BEGIN

	SET	NOCOUNT ON;
	SET	LOCK_TIMEOUT 100;

	DECLARE	@ErrorCode		INT				= 0;
	DECLARE	@TxnActive		VARCHAR(32)		= REPLACE(CONVERT(VARCHAR(36), NEWID(), 0), '-', '');

	DECLARE	@TrackingLogId	INT;

	EXECUTE	@TrackingLogId	= [track].[Insert_ProcedureLogBegin] @@PROCID;

	BEGIN TRY
	BEGIN TRANSACTION @TxnActive;
	/*-------------------------------------------------------------------------------------------*/

		TRUNCATE TABLE [$SchemaName$].[UnMapped];

	/*-------------------------------------------------------------------------------------------*/
	COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH

		SET	@ErrorCode = @@ERROR;

		IF (XACT_STATE() = -1) ROLLBACK TRANSACTION @TxnActive;
		IF (XACT_STATE() =  1) COMMIT TRANSACTION;

		EXECUTE	[track].[Insert_ProcedureLogError] @@PROCID, @TrackingLogId;

		THROW;

	END CATCH;

	EXECUTE	[track].[Insert_ProcedureLogEnd] @@PROCID, @TrackingLogId;

	RETURN	@ErrorCode;

END;
GO

EXECUTE sp_addextendedproperty
	@name		= N'MS_Description',
	@value		= N'Delete data from [$SchemaName$].[UnMapped].',
	@level0type	= N'schema',		@level0name	= N'$SchemaName$',
	@level1type	= N'procedure',		@level1name	= N'Delete_UnMapped';