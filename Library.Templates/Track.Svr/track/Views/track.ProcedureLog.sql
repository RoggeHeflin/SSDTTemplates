CREATE VIEW [track].[ProcedureLog]
WITH SCHEMABINDING, VIEW_METADATA
AS
SELECT
	[b].[ProcedureLogId],

	[b].[database_id],
	[b].[schema_id],
	[b].[object_id],

		[NameServer]			= @@SERVERNAME,
	[b].[NameDatabase],
	[b].[NameSchema],
	[b].[NameObject],
	[b].[NameQualified],

		[ProcedureSPID]			= [b].[SPID],
		[ProcedureNestLevel]	= [b].[NestLevel],
		[ProcedureTranCount]	= [b].[TransactionCount],

		[ProcedureUserExecuted]	= [b].[txInsertedUserExecuted],
		[ProcedureUserOriginal]	= [b].[txInsertedUserOriginal],
		[ProcedureHost]			= [b].[txInsertedHost],
		[ProcedureApplication]	= [b].[txInsertedApplication],

		[ProcedureStatus]		= CASE
									WHEN ([e].[txInserted] IS NOT NULL)	THEN 'Succeeded'
									WHEN ([r].[txInserted] IS NOT NULL)	THEN 'Failed'
									WHEN ([o].[txInserted] IS NOT NULL)	THEN 'Ended Unexpectedly'
									ELSE 'Running'
									END,

		[ProcedureBegin]		= CONVERT(DATETIME2,	[b].[txInserted]),
		[ProcedureBeginDate]	= CONVERT(DATE,			[b].[txInserted]),
		[ProcedureBeginTime]	= CONVERT(TIME,			[b].[txInserted]),
		[ProcedureBeginZone]	= [b].[txInserted],

		[ProcedureEnd]			= CONVERT(DATETIME2,	[e].[txInserted]),
		[ProcedureEndDate]		= CONVERT(DATE,			[e].[txInserted]),
		[ProcedureEndTime]		= CONVERT(TIME,			[e].[txInserted]),
		[ProcedureEndZone]		= [e].[txInserted],

		[ProcedureError]		= CONVERT(DATETIME2,	[r].[txInserted]),
		[ProcedureErrorDate]	= CONVERT(DATE,			[r].[txInserted]),
		[ProcedureErrorTime]	= CONVERT(TIME,			[r].[txInserted]),
		[ProcedureErrorZone]	= [r].[txInserted],

		[ProcedureOrphaned]		= CONVERT(DATETIME2,	[o].[txInserted]),
		[ProcedureOrphanedDate]	= CONVERT(DATE,			[o].[txInserted]),
		[ProcedureOrphanedTime]	= CONVERT(TIME,			[o].[txInserted]),
		[ProcedureOrphanedZone]	= [o].[txInserted],

		[DurationDays]			= DATEDIFF(SECOND, [b].[txInserted], COALESCE([e].[txInserted], [r].[txInserted], IIF(([o].[txInserted] IS NULL), SYSDATETIMEOFFSET(), NULL))) / 86400.0,
		[DurationMinutes]		= DATEDIFF(SECOND, [b].[txInserted], COALESCE([e].[txInserted], [r].[txInserted], IIF(([o].[txInserted] IS NULL), SYSDATETIMEOFFSET(), NULL))) / 60.0,
		[DurationSeconds]		= DATEDIFF(SECOND, [b].[txInserted], COALESCE([e].[txInserted], [r].[txInserted], IIF(([o].[txInserted] IS NULL), SYSDATETIMEOFFSET(), NULL))),

	[r].[ErrorNumber],
	[r].[ErrorSeverity],
	[r].[ErrorState],
	[r].[ErrorProcedure],
	[r].[ErrorLine],
	[r].[ErrorMessage]
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
		ON	([b].[ProcedureLogId]	=	[o].[ProcedureLogId]);
GO

EXECUTE sp_addextendedproperty
	@name		= 'MS_Description',		@value		= 'Procedure execution report',
	@level0type	= 'schema',				@level0name	= 'track',
	@level1type	= 'view',				@level1name	= 'ProcedureLog';