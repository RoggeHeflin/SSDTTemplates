CREATE PROCEDURE [track].[Insert_ProcedureLogOrphan]
AS
BEGIN

	SET NOCOUNT ON;
	SET LOCK_TIMEOUT 100;

	DECLARE @ErrorCode		INT				= 0;
	DECLARE @TxnActive		VARCHAR(32)		= REPLACE(CONVERT(VARCHAR(36), NEWID(), 0), '-', '');

	BEGIN TRY
	BEGIN TRANSACTION @TxnActive;
	PRINT CONVERT(NCHAR(23), SYSDATETIME(), 121) + NCHAR(9) + N'Begin [track].[Insert_ProcedureLogOrphan] (Not Logged)';
	/*-------------------------------------------------------------------------------------------*/

		INSERT INTO [track].[ProcedureLogOrphans]
		(
			[ProcedureLogId]
		)
		SELECT
			[b].[ProcedureLogId]
		FROM
			[track].[ProcedureLogBegin]			[b]
		LEFT OUTER JOIN
			[track].[ProcedureLogEnd]			[e]
				ON	([b].[ProcedureLogId]	=	[e].[ProcedureLogId])
		LEFT OUTER JOIN
			[track].[ProcedureLogErrors]		[r]
				ON	([b].[ProcedureLogId]	=	[r].[ProcedureLogId])
		LEFT OUTER JOIN
			[track].[ProcedureLogOrphans]		[o]
				ON	([b].[ProcedureLogId]	=	[o].[ProcedureLogId])
		WHERE
				([e].[ProcedureLogId]	IS NULL)
			AND	([r].[ProcedureLogId]	IS NULL)
			AND	([o].[ProcedureLogId]	IS NULL)
			AND	([b].[txInserted]		<	GETDATE());
	
	/*-------------------------------------------------------------------------------------------*/
	COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH

		PRINT CONVERT(NCHAR(23), SYSDATETIME(), 121) + NCHAR(9) + N'Error [track].[Insert_ProcedureLogOrphan]';

		SET @ErrorCode = @@ERROR;

		IF (XACT_STATE() = -1) ROLLBACK TRANSACTION	@TxnActive;
		IF (XACT_STATE() =  1) COMMIT TRANSACTION;

		THROW;

	END CATCH;

	PRINT CONVERT(NCHAR(23), SYSDATETIME(), 121) + NCHAR(9) + N'End   [track].[Insert_ProcedureLogOrphan]';

	RETURN @ErrorCode;

END;
GO

EXECUTE sp_addextendedproperty
	@name		= 'MS_Description',		@value		= 'Flags orphaned stored procedures in the log.',
	@level0type	= 'schema',				@level0name	= 'track',
	@level1type	= 'procedure',			@level1name	= 'Insert_ProcedureLogOrphan';