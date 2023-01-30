CREATE VIEW [track].[SqlAgentSchedule]
WITH VIEW_METADATA
AS
WITH [cte]
(
	[job_id],
	[schedule_uid],
	[idx],

	[SubFrequency],
	[SubFrequencyInterval],
	[IntermediateStartTime],
	[ActiveEndTime]
)
AS
(
	SELECT ALL
		[a].[job_id],
		[a].[schedule_uid],
			[idx]					= 1,
		[a].[SubFrequency],
		[a].[SubFrequencyInterval],
			[IntermediateStartTime]	= [a].[ActiveStartTime],
		[a].[ActiveEndTime]
	FROM
		[track].[SqlAgentScheduleBase]	[a]
	WHERE
		([a].[schedule_uid]	IS NOT NULL)

	UNION ALL

	SELECT ALL
		[c].[job_id],
		[c].[schedule_uid],
			[idx]					= [c].[idx] + 1,
		[c].[SubFrequency],
		[c].[SubFrequencyInterval],
			[IntermediateStartTime]	= CASE [c].[SubFrequency]
										WHEN 'Seconds'	THEN DATEADD(SECOND, [c].[SubFrequencyInterval], [c].[IntermediateStartTime])
										WHEN 'Minutes'	THEN DATEADD(MINUTE, [c].[SubFrequencyInterval], [c].[IntermediateStartTime])
										WHEN 'Hours'	THEN DATEADD(HOUR,   [c].[SubFrequencyInterval], [c].[IntermediateStartTime])
										END,
		[c].[ActiveEndTime]
	FROM
		[cte]	[c]
	WHERE
			([c].[job_id]					=	[c].[job_id])
		AND	([c].[schedule_uid]				=	[c].[schedule_uid])
		AND	([c].[SubFrequencyInterval]		>	0)
		AND	([c].[IntermediateStartTime]	<	[c].[ActiveEndTime])
		AND	([c].[idx]						<=	100)
		AND	NOT ([c].[SubFrequencyInterval] = 1 AND [c].[SubFrequency] = 'Minutes')
)
SELECT
	[b].[ServerName],
	[b].[JobName],
	[b].[JobCategory],
	[b].[JobEnabled],
	[b].[JobModified],
	[b].[JobVersion],
	[b].[JobOwner],
	[b].[StepNumber],
	[b].[StepName],
	[b].[ScheduleName],
	[b].[ScheduleEnabled],
	[b].[ScheduleFrequency],
	[b].[SubFrequencyInterval],
	[b].[SubFrequency],

	--[b].[ActiveStart],
	[b].[ActiveStartDate],
	[b].[ActiveStartTime],

	--[b].[ActiveEnd],
	[b].[ActiveEndDate],
	[b].[ActiveEndTime],

	--[b].[NextRun],
	[b].[NextRunDate],
	[b].[NextRunTime],

	[c].[IntermediateStartTime]
FROM
	[track].[SqlAgentScheduleBase]	[b]	WITH(NOLOCK)
INNER JOIN
	[cte]							[c]
		ON	([b].[schedule_uid]	=	[c].[schedule_uid]);