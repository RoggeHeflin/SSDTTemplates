CREATE VIEW [track].[SqlAgentHistory]
WITH VIEW_METADATA
AS
SELECT
	[t].[ServerName],
	[t].[JobName],

	[t].[StepId],
	[t].[StepName],
		[StepStatus]		= CASE [t].[StepStatus]
								WHEN 0 THEN 'Failed'
								WHEN 1 THEN 'Succeeded'
								WHEN 2 THEN 'Retry'
								WHEN 3 THEN 'Canceled'
								WHEN 4 THEN 'In Progress'
								ELSE CONVERT(VARCHAR(1), [t].[StepStatus]) END,

	[t].[StepSeverity],
	[t].[StepMessage],

	[t].[JobBeginDate],
	[t].[JobBeginTime],
		[JobBegin]			= CONVERT(DATETIME, [t].[JobBeginDate]) + CONVERT(DATETIME, [t].[JobBeginTime]),

		[DurationDays]		= [t].[DurationSeconds] / 86400.0,
		[DurationMinutes]	= [t].[DurationSeconds] / 60.0,
	[t].[DurationSeconds]
FROM (
	SELECT
		[t].[ServerName],
		[t].[JobName],
		[t].[StepStatus],

		[t].[StepId],
		[t].[StepName],
		[t].[StepSeverity],
		[t].[StepMessage],

		[t].[JobBeginDate],
		[t].[JobBeginTime],

			[DurationSeconds] =		CONVERT(INT, LEFT([t].[Duration], 2))			* 60 * 60 * 24
								+	CONVERT(INT, SUBSTRING([t].[Duration], 4, 2))	* 60 * 60
								+	CONVERT(INT, SUBSTRING([t].[Duration], 7, 2))	* 60
								+	CONVERT(INT, RIGHT([t].[Duration], 2))
	FROM (
		SELECT
			[ServerName]			= [v].[name],
			[JobName]				= [j].[name],

			[StepId]				= [h].[step_id],
			[StepName]				= [h].[step_name],
			[StepStatus]			= [h].[run_status],
			[StepSeverity]			= [h].[sql_severity],
			[StepMessage]			= [h].[message],

			[JobBeginDate]			= CONVERT(DATE, CONVERT(VARCHAR(8), [h].[run_date]), 112),
			[JobBeginTime]			= CONVERT(TIME, STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CONVERT(VARCHAR(6), [h].[run_time]), 6), 5, 0, ':'), 3, 0, ':'), 120),
			[Duration]				= STUFF(STUFF(STUFF(RIGHT(REPLICATE('0', 8) + CONVERT(VARCHAR(8), [h].[run_duration]), 8), 3, 0, ':'), 6, 0, ':'), 9, 0, ':')

		FROM
			[msdb].[dbo].[sysjobs]						[j]
		INNER JOIN
			sys.servers									[v]
				ON	([j].[originating_server_id]	=	[v].[server_id])
		INNER JOIN
			[msdb].[dbo].[sysjobhistory]				[h]
				ON	([j].[job_id]					=	[h].[job_id])
				AND	([h].[step_id]					>	0)
		) [t]
	) [t];
GO

EXECUTE sp_addextendedproperty
	@name		= 'MS_Description',		@value		= 'SQL Agent execution report',
	@level0type	= 'schema',				@level0name	= 'track',
	@level1type	= 'view',				@level1name	= 'SqlAgentHistory';