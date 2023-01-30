CREATE PROCEDURE [track].[Insert_ProcedureLogError]
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
	PRINT CONVERT(NCHAR(23), SYSDATETIME(), 121) + NCHAR(9) + N'ERROR ' + QUOTENAME(OBJECT_SCHEMA_NAME(@ProcId)) + N'.' + QUOTENAME(OBJECT_NAME(@ProcId));
	/*-------------------------------------------------------------------------------------------*/

		INSERT INTO [$(TrackSvr)].[track].[ProcedureLogErrors]
		(
			[ProcedureLogId],

			[ErrorNumber],
			[ErrorSeverity],
			[ErrorState],
			[ErrorProcedure],
			[ErrorLine],
			[ErrorMessage]
		)
		SELECT
			[ProcedureLogId]	= @ProcedureLogId,

			[ErrorNumber]		= ERROR_NUMBER(),
			[ErrorSeverity]		= ERROR_SEVERITY(),
			[ErrorState]		= ERROR_STATE(),
			[ErrorProcedure]	= COALESCE(ERROR_PROCEDURE(), 'Dynamic SQL'),
			[ErrorLine]			= ERROR_LINE(),
			[ErrorMessage]		= ERROR_MESSAGE();

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
	@name		= 'MS_Description',		@value		= 'Inserts procedure error meta data into [track].[ProcedureLogErrors].',
	@level0type	= 'schema',				@level0name	= 'track',
	@level1type	= 'procedure',			@level1name	= 'Insert_ProcedureLogError';