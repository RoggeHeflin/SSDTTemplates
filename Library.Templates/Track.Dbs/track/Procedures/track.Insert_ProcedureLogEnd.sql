CREATE PROCEDURE [track].[Insert_ProcedureLogEnd]
(
	@ProcId				INT,
	@ProcedureLogId		INT
)
AS
BEGIN

	SET NOCOUNT ON;
	SET LOCK_TIMEOUT 100;

	DECLARE @ErrorCode		INT				= 0;
	DECLARE @TxnActive		VARCHAR(32)		= REPLACE(CONVERT(VARCHAR(36), NEWID(), 0), '-', '');

	BEGIN TRY
	BEGIN TRANSACTION @TxnActive;
	PRINT CONVERT(NCHAR(23), SYSDATETIME(), 121) + NCHAR(9) + N'End   ' + QUOTENAME(OBJECT_SCHEMA_NAME(@ProcId)) + N'.' + QUOTENAME(OBJECT_NAME(@ProcId));
	/*-------------------------------------------------------------------------------------------*/

		INSERT INTO [$(TrackSvr)].[track].[ProcedureLogEnd]
		(
			[ProcedureLogId]
		)
		SELECT
			[ProcedureLogId] = @ProcedureLogId;

	/*-------------------------------------------------------------------------------------------*/
	COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH

		SET @ErrorCode = @@ERROR;

		IF (XACT_STATE() = -1) ROLLBACK TRANSACTION @TxnActive;
		IF (XACT_STATE() =  1) COMMIT TRANSACTION;

		THROW;

	END CATCH;

	RETURN @ErrorCode;

END;
GO

EXECUTE sp_addextendedproperty
	@name		= 'MS_Description',		@value		= 'Inserts procedure end meta data into [track].[ProcedureLogEnd].',
	@level0type	= 'schema',				@level0name	= 'track',
	@level1type	= 'procedure',			@level1name	= 'Insert_ProcedureLogEnd';