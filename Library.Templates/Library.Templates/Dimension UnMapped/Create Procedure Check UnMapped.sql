CREATE PROCEDURE [$SchemaName$].[Check_UnMapped]
(
	@MappingConstraint	NVARCHAR(128),
	@SourceSchema		NVARCHAR(128),
	@SourceTable		NVARCHAR(128),
	@SourceColumn		NVARCHAR(128),
	@MapSchema			NVARCHAR(128),
	@MapTable			NVARCHAR(128),
	@MapColumn			NVARCHAR(128)
)
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

		DECLARE @SQL	NVARCHAR(MAX) = 'SET NO COUNT ON;

		SELECT
			[MappingConstraint]	= ''' + @MappingConstraint	+ ''',
			[SourceSchema]		= ''' + @SourceSchema		+ ''',
			[SourceTable]		= ''' + @SourceTable		+ ''',
			[SourceColumn]		= ''' + @SourceColumn		+ ''',
			[MapSchema]			= ''' + @MapSchema			+ ''',
			[MapTable]			= ''' + @MapTable			+ ''',
			[MapColumn]			= ''' + @MapColumn			+ ''',

			[SourceValue]		= [s].[' + @SourceColumn + '],
			[MissingItems]		= COUNT(*)
		FROM
			[' + @SourceSchema + '].[' + @SourceTable + '] [s] WITH (NOLOCK)
		LEFT OUTER JOIN
			[' + @MapSchema + '].[' + @MapTable + '] [d] WIHT (NOLOCK)
				ON ([s].[' + @SourceColumn + '] = [d].[' + @MapColumn + '])
		WHERE
				([s].[' + @SourceColumn + '] IS NOT NULL)
			AND	(RTRIM(LTRIM([s].[' + @SourceColumn + '])) <> '''')
			AND	([d].[' + @MapColumn + '] IS NULL)
		GROUP BY
			[s].[' + @SourceColumn + '];';

		EXECUTE(@SQL);

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