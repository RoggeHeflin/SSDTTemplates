CREATE PROCEDURE [$SchemaName$].[Insert_UnMapped]
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

		DECLARE @MappingConstraint	NVARCHAR(128);
		DECLARE @SourceSchema		NVARCHAR(128);
		DECLARE @SourceTable		NVARCHAR(128);
		DECLARE @SourceColumn		NVARCHAR(128);
		DECLARE @MapSchema			NVARCHAR(128);
		DECLARE @MapTable			NVARCHAR(128);
		DECLARE @MapColumn			NVARCHAR(128);

		DECLARE CursorPairs CURSOR FORWARD_ONLY FAST_FORWARD READ_ONLY
		FOR
		SELECT
			[t].[MappingConstraint],
			[t].[SourceSchema],
			[t].[SourceTable],
			[t].[SourceColumn],
			[t].[MapSchema],
			[t].[MapTable],
			[t].[MapColumn]
		FROM
			[$SchemaName$].[UnMappedForeignKeys]	[t];

		OPEN CursorPairs;

		FETCH NEXT FROM CursorPairs
		INTO
			@MappingConstraint,
			@SourceSchema,
			@SourceTable,
			@SourceColumn,
			@MapSchema,
			@MapTable,
			@MapColumn;

		WHILE (@@FETCH_STATUS = 0)
		BEGIN

			INSERT INTO [$SchemaName$].[UnMapped]([MappingConstraint], [SourceSchema], [SourceTable], [SourceColumn], [MapSchema], [MapTable], [MapColumn], [SourceValue], [MissingItems])
			EXECUTE [$SchemaName$].[Check_UnMapped] @MappingConstraint, @SourceSchema, @SourceTable, @SourceColumn, @MapSchema, @MapTable, @MapColumn;

			FETCH NEXT FROM CursorPairs
			INTO
				@MappingConstraint,
				@SourceSchema,
				@SourceTable,
				@SourceColumn,
				@MapSchema,
				@MapTable,
				@MapColumn;

		END;

		CLOSE CursorPairs;

		DEALLOCATE CursorPairs;

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
	@value		= N'Stores missing source values not mapped.',
	@level0type	= N'schema',	@level0name	= N'$SchemaName$',
	@level1type	= N'procedure',	@level1name	= N'Insert_UnMapped';