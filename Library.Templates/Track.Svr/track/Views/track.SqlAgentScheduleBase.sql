CREATE VIEW [track].[SqlAgentScheduleBase]
WITH VIEW_METADATA
AS
SELECT
	[t].[job_id],
	[t].[schedule_uid],

	[t].[ServerName],
	[t].[JobName],
	[t].[JobCategory],
	[t].[JobEnabled],
	[t].[JobModified],
	[t].[JobVersion],
	[t].[JobOwner],
	[t].[StepNumber],
	[t].[StepName],
	[t].[ScheduleName],
	[t].[ScheduleEnabled],
	[t].[ScheduleFrequency],
	[t].[SubFrequencyInterval],
	[t].[SubFrequency],

		[ActiveStart]		= CONVERT(DATETIME, [t].[ActiveStartDate]) + CONVERT(DATETIME, [t].[ActiveStartTime]),
	[t].[ActiveStartDate],
	[t].[ActiveStartTime],

		[ActiveEnd]			= CONVERT(DATETIME, [t].[ActiveEndDate]) + CONVERT(DATETIME, [t].[ActiveEndTime]),
	[t].[ActiveEndDate],
	[t].[ActiveEndTime],

		[NextRun]			= CONVERT(DATETIME, [t].[NextRunDate]) + CONVERT(DATETIME, [t].[NextRunTime]),
	[t].[NextRunDate],
	[t].[NextRunTime]

FROM (
	SELECT
		[j].[job_id],
		[s].[schedule_uid],

			[ServerName]				= [v].[name],
			[JobName]					= [j].[name],
			[JobCategory]				= [c].[name],

			[JobEnabled]				= CASE [j].[enabled]
											WHEN   0	THEN 'Disabled'
											WHEN   1	THEN 'Enabled'
											END,

			[JobModified]				= [j].[date_modified],
			[JobVersion]				= [j].[version_number],
		
			[JobOwner]					= [o].[name],
		
			[StepNumber]				= [e].[step_id],
			[StepName]					= [e].[step_name],
			[ScheduleName]				= [s].[name],

			[ScheduleEnabled]			= CASE [s].[enabled]
											WHEN   0	THEN 'Disabled'
											WHEN   1	THEN 'Enabled'
											END,

			[ScheduleFrequency]			= CASE [s].[freq_type]
											WHEN   1	THEN 'Once'
											WHEN   4	THEN 'Daily'
											WHEN   8	THEN 'Weekly'
											WHEN  16	THEN 'Monthly'
											WHEN  32	THEN 'Monthly, relative to frequency_interval.'
											WHEN  64	THEN 'Run when the SQL Server Agent service starts.'
											WHEN 128	THEN 'Run when the computer is idle.'
											END,

			[SubFrequencyInterval]		= [s].[freq_subday_interval],
			[SubFrequency]				= CASE [s].[freq_subday_type]
											WHEN 0x1	THEN 'At the specified time'
											WHEN 0x2	THEN 'Seconds'
											WHEN 0x4	THEN 'Minutes'
											WHEN 0x8	THEN 'Hours'
											END,

			[ActiveStartDate]		= CONVERT(DATE, RIGHT(REPLICATE('0', 8) + CONVERT(VARCHAR(8), [s].[active_start_date]), 8), 112),
			[ActiveStartTime]		= CONVERT(TIME, STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CONVERT(VARCHAR(6), [s].[active_start_time]), 6), 5, 0, ':'), 3, 0, ':'), 108),

			[ActiveEndDate]			= CONVERT(DATE, RIGHT(REPLICATE('0', 8) + CONVERT(VARCHAR(8), [s].[active_end_date]), 8), 112),
			[ActiveEndTime]			= CONVERT(TIME, STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CONVERT(VARCHAR(6), [s].[active_end_time]), 6), 5, 0, ':'), 3, 0, ':'), 108),

			[NextRunDate]			= CASE WHEN ([i].[next_run_date] <> 0) THEN CONVERT(DATE, RIGHT(REPLICATE('0', 8) + CONVERT(VARCHAR(8), [i].[next_run_date]), 8), 112) END,
			[NextRunTime]			= CONVERT(TIME, STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CONVERT(VARCHAR(6), [i].[next_run_time]), 6), 5, 0, ':'), 3, 0, ':'), 108)

	FROM
		[msdb].[dbo].[sysjobs]						[j]
	INNER JOIN
		[msdb].[dbo].[syscategories]				[c]
			ON	([j].[category_id]				=	[c].[category_id])
	INNER JOIN
		[msdb].[dbo].[sysjobsteps]					[e]
			ON	([j].[job_id]					=	[e].[job_id])
	LEFT OUTER JOIN
		[msdb].[dbo].[sysjobschedules]				[i]
			ON	([j].[job_id]					=	[i].[job_id])
	LEFT OUTER JOIN
		[msdb].[dbo].[sysschedules]					[s]
			ON	([i].[schedule_id]				=	[s].[schedule_id])
	INNER JOIN
		[master].[sys].[servers]					[v]
			ON	([j].[originating_server_id]	=	[v].[server_id])
	LEFT OUTER JOIN
		[master].[sys].[syslogins]					[o]
			ON	([j].[owner_sid]				=	[o].[sid])
	) [t];
GO

EXECUTE sp_addextendedproperty
	@name		= 'MS_Description',		@value		= 'SSIS execution status',
	@level0type	= 'schema',				@level0name	= 'track',
	@level1type	= 'view',				@level1name	= 'SqlAgentScheduleBase';