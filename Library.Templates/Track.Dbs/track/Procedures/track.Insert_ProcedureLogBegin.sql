CREATE PROCEDURE [track].[Insert_ProcedureLogBegin]
(
	@ProcId				INT
)
AS
BEGIN

	SET NOCOUNT ON;
	SET LOCK_TIMEOUT 100;

	DECLARE @ErrorCode		INT				= 0;
	DECLARE @TxnActive		VARCHAR(32)		= REPLACE(CONVERT(VARCHAR(36), NEWID(), 0), '-', '');
	DECLARE @TxnId			BIGINT			= NULL;

	BEGIN TRY
	BEGIN TRANSACTION @TxnActive;
	PRINT CONVERT(NCHAR(23), SYSDATETIME(), 121) + NCHAR(9) + N'Begin ' + QUOTENAME(OBJECT_SCHEMA_NAME(@ProcId)) + N'.' + QUOTENAME(OBJECT_NAME(@ProcId));
	/*-------------------------------------------------------------------------------------------*/

		INSERT INTO [$(TrackSvr)].[track].[ProcedureLogBegin]
		(
			[database_id],
			[schema_id],
			[object_id],

			[NameDatabase],
			[NameSchema],
			[NameObject],

			[SPID],
			[NestLevel],
			[TransactionCount]
		)
		SELECT
			[database_id]		= DB_ID(),
			[schema_id]			= SCHEMA_ID(OBJECT_SCHEMA_NAME(@ProcId)),
			[object_id]			= @ProcId,

			[NameDatabase]		= DB_NAME(),
			[NameSchema]		= OBJECT_SCHEMA_NAME(@ProcId),
			[NameObject]		= OBJECT_NAME(@ProcId),

			[SPID]				= @@SPID,
			[NestLevel]			= @@NESTLEVEL - 1,
			[TransactionCount]	= @@TRANCOUNT - 1;

		SET	@TxnId	= SCOPE_IDENTITY();

	/*-------------------------------------------------------------------------------------------*/
	COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH

		SET @ErrorCode = @@ERROR;

		IF (XACT_STATE() = -1) ROLLBACK TRANSACTION @TxnActive;
		IF (XACT_STATE() =  1) COMMIT TRANSACTION;

		THROW;

	END CATCH;

	RETURN @TxnId;

END;
GO

EXECUTE sp_addextendedproperty
	@name		= 'MS_Description',		@value		= 'Inserts procedure begin meta data into [track].[ProcedureLogBegin].',
	@level0type	= 'schema',				@level0name	= 'track',
	@level1type	= 'procedure',			@level1name	= 'Insert_ProcedureLogBegin';
