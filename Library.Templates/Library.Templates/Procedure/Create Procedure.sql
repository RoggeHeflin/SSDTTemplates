CREATE PROCEDURE $SchemaQualifiedObjectName$
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

		/*	Certain errors cannot be trapped by TRY...CATCH in store procedures:
				Name resolution - SELECT [t].* FROM [dbo].[NonExistantTable] [t];
	
		*/


		/*	Place drop table statements at the beginning and end of the stored procedure.

			IF (OBJECT_ID('[schema].[Table]') IS NOT NULL) DROP TABLE [schema].[Table];
			IF (OBJECT_ID('[tempdb]..[#Table]') IS NOT NULL) DROP TABLE [tempdb]..[#Table];

			DROP TABLE IF EXISTS [schema].[Table];
			DROP TABLE IF EXISTS [tempdb]..[#Table];

		*/

		EXECUTE [$SchemaName$].[Delete_$rawname$];

		INSERT INTO [$SchemaName$].[$rawname$]
		(
		)
		SELECT
			[t].*
		FROM
			[table];

	/*-------------------------------------------------------------------------------------------*/
	IF (@TxnExists = 0) COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH

		SET	@ErrorCode = @@ERROR;

		IF (XACT_STATE() = -1) ROLLBACK TRANSACTION @TxnActive;
		IF (XACT_STATE() =  1) AND (@TxnExists = 0) COMMIT TRANSACTION;
		IF (XACT_STATE() =  1) AND (@TxnExists = 1) ROLLBACK TRANSACTION @TxnActive;

		EXECUTE	[track].[Insert_ProcedureLogError] @@PROCID, @TrackingLogId;

		THROW;

	END CATCH;

	EXECUTE	[track].[Insert_ProcedureLogEnd] @@PROCID, @TrackingLogId;

	RETURN	@ErrorCode;

END;
GO

EXECUTE sp_addextendedproperty
	@name		= N'MS_Description',
	@value		= N'{Enter Description or Purpose}',
	@level0type	= N'schema',	@level0name	= N'$SchemaName$',
	@level1type	= N'procedure',	@level1name	= N'$rawname$';