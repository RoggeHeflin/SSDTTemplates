CREATE VIEW [track].[SsisCatalogTasks]
WITH VIEW_METADATA
AS
SELECT
		[ServerName]				= [e].[server_name],
		[MachineName]				= [e].[machine_name],

		[FolderName]				= COALESCE([f].[name], [e].[folder_name]),

		[ProjectName]				= [j].[name],

		[ProjectDeployed]			= CONVERT(DATETIME, [j].[last_deployed_time]),
		[ProjectDeployedDate]		= CONVERT(DATE, [j].[last_deployed_time]),
		[ProjectDeployedTime]		= CONVERT(TIME, [j].[last_deployed_time]),
		[ProjectDeployedOffset]		= [j].[last_deployed_time],

		[Package]					= REPLACE([p].[name], '.dtsx', ' (') + CONVERT(VARCHAR(5), [p].[version_major]) + '.' + CONVERT(VARCHAR(5), [p].[version_minor]) + '.' + CONVERT(VARCHAR(5), [p].[version_build]) + ')',
		[PackageName]				= REPLACE([p].[name], '.dtsx', ''),
		[PackageVersion]			= CONVERT(VARCHAR(5), [p].[version_major]) + '.' + CONVERT(VARCHAR(5), [p].[version_minor]) + '.' + CONVERT(VARCHAR(5), [p].[version_build]),
		[PackageVersionComments]	= [p].[version_comments],
		[PackageDescription]		= [p].[description],

		[ExecutedByCaller]			= [e].[caller_name],
		[ExecutedAs]				= [e].[executed_as_name],
		[EnvironmentName]			= [n].[name],

		[ObjectType]				= CASE [e].[object_type]
										WHEN	20	THEN 'Project'
										WHEN	30	THEN 'Package'
										END,

		[ExecutionBits]				= CASE [e].[use32bitruntime]
										WHEN 1	THEN 32
										ELSE 64
										END,

		[ExecutionType]				= CASE [e].[operation_type]
										WHEN	1		THEN 'Integration Services initialization'
										WHEN	2		THEN 'Retention window'
										WHEN	3		THEN 'Max Project Version'
										WHEN	101		THEN 'Deploy project'
										WHEN	106		THEN 'Restore project'
										WHEN	200		THEN 'Create and Start execution'
										WHEN	202		THEN 'Stop operation'
										WHEN	300		THEN 'Validate project'
										WHEN	301		THEN 'Validate package'
										WHEN	1000	THEN 'Configure catalog'
										END,

		[ExecutionStatus]			= CASE [e].[status]
										WHEN	1	THEN 'Created'
										WHEN	2	THEN 'Running'
										WHEN	3	THEN 'Canceled'
										WHEN	4	THEN 'Failed'
										WHEN	5	THEN 'Pending'
										WHEN	6	THEN 'Ended unexpectedly'
										WHEN	7	THEN 'Succeeded'
										WHEN	8	THEN 'Stopping'
										WHEN	9	THEN 'Completed'
										END,

		[AvailableMemoryKb]			= [e].[available_physical_memory_kb],
		[AvailablePagefileKb]		= [e].[available_page_file_kb],

		[PackageBegin]				= CONVERT(DATETIME, [e].[start_time]),
		[PackageBeginDate]			= CONVERT(DATE, [e].[start_time]),
		[PackageBeginTime]			= CONVERT(TIME, [e].[start_time]),
		[PackageBeginZone]			= [e].[start_time],

		[PackageEnd]				= CONVERT(DATETIME, [e].[end_time]),
		[PackageEndDate]			= CONVERT(DATE, [e].[end_time]),
		[PackageEndTime]			= CONVERT(TIME, [e].[end_time]),
		[PackageEndZone]			= [e].[end_time],

		[PackageDurationDays]		= DATEDIFF(SECOND, [e].[start_time], IIF(([e].[status] IN (3, 4, 6, 7, 9)), [e].[end_time], IIF(([e].[status] = 2), SYSDATETIMEOFFSET(), NULL))) / 86400.0,
		[PackageDurationMinutes]	= DATEDIFF(SECOND, [e].[start_time], IIF(([e].[status] IN (3, 4, 6, 7, 9)), [e].[end_time], IIF(([e].[status] = 2), SYSDATETIMEOFFSET(), NULL))) / 60.0,
		[PackageDurationSeconds]	= DATEDIFF(SECOND, [e].[start_time], IIF(([e].[status] IN (3, 4, 6, 7, 9)), [e].[end_time], IIF(([e].[status] = 2), SYSDATETIMEOFFSET(), NULL))),

	[m].[TaskName],

		[TaskBegin]					= CONVERT(DATETIME, [m].[TaskBegin]),
		[TaskBeginDate]				= CONVERT(DATE, [m].[TaskBegin]),
		[TaskBeginTime]				= CONVERT(TIME, [m].[TaskBegin]),
		[TaskBeginOffset]			= [m].[TaskBegin],

		[TaskEnd]					= CONVERT(DATETIME, [m].[TaskEnd]),
		[TaskEndDate]				= CONVERT(DATE, [m].[TaskEnd]),
		[TaskEndTime]				= CONVERT(TIME, [m].[TaskEnd]),
		[TaskEndOffset]				= [m].[TaskEnd],

		[TaskDurationSeconds]		= DATEDIFF(SECOND, [m].[TaskBegin],
												COALESCE([m].[TaskEnd], IIF(([e].[status] = 2), SYSDATETIMEOFFSET(), NULL))
												),
		[TaskDurationMinutes]		= DATEDIFF(SECOND, [m].[TaskBegin],
												COALESCE([m].[TaskEnd], IIF(([e].[status] = 2), SYSDATETIMEOFFSET(), NULL))
												) / 60.0,
		[TaskDurationDays]			= DATEDIFF(SECOND, [m].[TaskBegin],
												COALESCE([m].[TaskEnd], IIF(([e].[status] = 2), SYSDATETIMEOFFSET(), NULL))
												) / 86400.0,

	[s].[created_time],
	[s].[dataflow_path_name],
	[s].[source_component_name],
	[s].[destination_component_name],
	[s].[rows_sent],

	[m].[TaskFailsCount],
	[m].[TaskErrorsCount],
	[m].[TaskWarningsCount],
	[m].[TaskInformationCount],
	[m].[TaskCount],

	[m].[MessageFails],
	[m].[MessageErrors],
	[m].[MessageWarnings]
FROM
	[$(SSISDB)].[catalog].[projects]			[j]
INNER JOIN
	[$(SSISDB)].[catalog].[packages]			[p]
		ON	([j].[project_id]			=	[p].[project_id])
INNER JOIN
	[$(SSISDB)].[catalog].[executions]			[e]
		ON	([j].[project_id]			=	[e].[object_id])
		AND	([j].[name]					=	[e].[project_name])
		AND	([p].[name]					=	[e].[package_name])
LEFT OUTER JOIN
	[$(SSISDB)].[catalog].[folders]			[f]
		ON	([j].[folder_id]			=	[f].[folder_id])
LEFT OUTER JOIN
	[$(SSISDB)].[catalog].[environments]		[n]
		ON	([e].[reference_id]			=	[n].[environment_id])
INNER JOIN (
	SELECT
		[m].[operation_id],
			[operation_message_id]	= MIN([m].[operation_message_id]),

			[TaskName]				= LEFT([m].[message], CHARINDEX(N':', [m].[message]) - 1),

			[TaskBegin]				= MIN(CASE WHEN ([m].[message_type] = 30) THEN [m].[message_time] END),
			[TaskEnd]				= MAX(CASE WHEN ([m].[message_type] = 40) THEN [m].[message_time] END),

			[TaskFailsCount]		= COUNT(CASE WHEN ([m].[message_type] = 130) THEN 1 ELSE NULL END),
			[TaskErrorsCount]		= COUNT(CASE WHEN ([m].[message_type] = 120) THEN 1 ELSE NULL END),
			[TaskWarningsCount]		= COUNT(CASE WHEN ([m].[message_type] = 110) THEN 1 ELSE NULL END),
			[TaskInformationCount]	= COUNT(CASE WHEN ([m].[message_type] =  70) THEN 1 ELSE NULL END),
			[TaskCount]				= COUNT(*),

			[MessageFails]			= STUFF(((
				SELECT N'|' + RTRIM(LTRIM(RIGHT([x].[message], LEN([x].[message]) - CHARINDEX(N':', [x].[message]))))
				FROM [$(SSISDB)].[catalog].[operation_messages] [x]
				WHERE	([x].[message_type]	= 130)
					AND	([x].[operation_id]	= [m].[operation_id])
					AND	([x].[operation_message_id] BETWEEN MIN([m].[operation_message_id]) AND MAX([m].[operation_message_id]))
					AND	(LEFT([x].[message], CHARINDEX(N':', [x].[message]) - 1) = LEFT([m].[message], CHARINDEX(N':', [m].[message]) - 1))
				ORDER BY
					[x].[operation_message_id] DESC
				FOR XML PATH (N''),
				TYPE).value(N'(./text())[1]', N'NVARCHAR(MAX)')), 1, 1, N''),

			[MessageErrors]			= STUFF(((
				SELECT N'|' + RTRIM(LTRIM(RIGHT([x].[message], LEN([x].[message]) - CHARINDEX(N':', [x].[message]))))
				FROM [$(SSISDB)].[catalog].[operation_messages] [x]
				WHERE	([x].[message_type]	= 120)
					AND	([x].[operation_id]	= [m].[operation_id])
					AND	([x].[operation_message_id] BETWEEN MIN([m].[operation_message_id]) AND MAX([m].[operation_message_id]))
					AND	(LEFT([x].[message], CHARINDEX(N':', [x].[message]) - 1) = LEFT([m].[message], CHARINDEX(N':', [m].[message]) - 1))
				ORDER BY
					[x].[operation_message_id] DESC
				FOR XML PATH (N''),
				TYPE).value(N'(./text())[1]', N'NVARCHAR(MAX)')), 1, 1, N''),

			[MessageWarnings]		= STUFF(((
				SELECT N'|' + RTRIM(LTRIM(RIGHT([x].[message], LEN([x].[message]) - CHARINDEX(N':', [x].[message]))))
				FROM [$(SSISDB)].[catalog].[operation_messages] [x]
				WHERE	([x].[message_type]	= 110)
					AND	([x].[operation_id]	= [m].[operation_id])
					AND	([x].[operation_message_id] BETWEEN MIN([m].[operation_message_id]) AND MAX([m].[operation_message_id]))
					AND	(LEFT([x].[message], CHARINDEX(N':', [x].[message]) - 1) = LEFT([m].[message], CHARINDEX(N':', [m].[message]) - 1))
				ORDER BY
					[x].[operation_message_id] DESC
				FOR XML PATH (N''),
				TYPE).value(N'(./text())[1]', N'NVARCHAR(MAX)')), 1, 1, N'')
	FROM
		[$(SSISDB)].[catalog].[operation_messages]	[m]
	WHERE
			([m].[message_source_type]		<>	30)
		AND	([m].[message]					LIKE N'%:%')
		AND	(CHARINDEX(N':', [m].[message]) >	1)
		AND	([m].[message_time]				>	DATEADD(DAY, -15, GETDATE()))
	GROUP BY
		[m].[operation_id],
		LEFT([m].[message], CHARINDEX(N':', [m].[message]) - 1)
	HAVING
		(MIN(CASE WHEN ([m].[message_type] = 30) THEN [m].[message_time] END) IS NOT NULL)
	) [m]
		ON	([e].[execution_id]			=	[m].[operation_id])
LEFT OUTER JOIN
	[$(SSISDB)].[catalog].[execution_data_statistics]	[s]
		ON	([e].[execution_id]			=	[s].[execution_id])
		AND	([m].[TaskName]				=	[s].[task_name]);
GO

EXECUTE sp_addextendedproperty
	@name		= 'MS_Description',		@value		= 'SQL Agent schedule base used by [track].[SqlAgentSchedule]',
	@level0type	= 'schema',				@level0name	= 'track',
	@level1type	= 'view',				@level1name	= 'SsisCatalogTasks';