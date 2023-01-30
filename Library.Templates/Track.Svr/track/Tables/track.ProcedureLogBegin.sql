CREATE TABLE [track].[ProcedureLogBegin]
(
	[ProcedureLogId]				BIGINT				NOT	NULL	IDENTITY(1, 1)	NOT FOR REPLICATION,

	[database_id]					INT					NOT	NULL,
	[schema_id]						INT					NOT	NULL,
	[object_id]						INT					NOT	NULL,

	[NameDatabase]					NVARCHAR(128)		NOT	NULL	CONSTRAINT	[CL_ProcedureLogBegin_NameDatabase]				CHECK([NameDatabase] <> ''),
	[NameSchema]					NVARCHAR(128)		NOT	NULL	CONSTRAINT	[CL_ProcedureLogBegin_NameSchema]				CHECK([NameSchema]	<> ''),
	[NameObject]					NVARCHAR(128)		NOT	NULL	CONSTRAINT	[CL_ProcedureLogBegin_NameObject]				CHECK([NameObject] <> ''),
	[NameQualified]					AS N'[' + [NameSchema] + N'].[' + [NameObject] + N']'
									PERSISTED			NOT	NULL,

	[SPID]							SMALLINT			NOT	NULL,
	[NestLevel]						INT					NOT	NULL,
	[TransactionCount]				INT					NOT	NULL,

	[txInserted]					DATETIMEOFFSET(7)	NOT	NULL	CONSTRAINT	[DF_ProcedureLogBegin_txInserted]				DEFAULT(SYSDATETIMEOFFSET()),
	[txInsertedSID]					VARBINARY(85)		NOT	NULL	CONSTRAINT	[DF_ProcedureLogBegin_txInsertedSID]			DEFAULT(SUSER_SID()),
	[txInsertedUserExecuted]		NVARCHAR(128)		NOT	NULL	CONSTRAINT	[DF_ProcedureLogBegin_txInsertedUserExecuted]	DEFAULT(SUSER_SNAME()),
	[txInsertedUserOriginal]		NVARCHAR(128)		NOT	NULL	CONSTRAINT	[DF_ProcedureLogBegin_txInsertedUserOriginal]	DEFAULT(ORIGINAL_LOGIN()),
	[txInsertedHost]				NVARCHAR(128)		NOT	NULL	CONSTRAINT	[DF_ProcedureLogBegin_txInsertedHost]			DEFAULT(HOST_NAME()),
	[txInsertedApplication]			NVARCHAR(128)		NOT	NULL	CONSTRAINT	[DF_ProcedureLogBegin_txInsertedApplication]	DEFAULT(APP_NAME()),
	[txInsertedProcedure]			NVARCHAR(517)			NULL	CONSTRAINT	[DF_ProcedureLogBegin_txInsertedProcedure]		DEFAULT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID))),

	[txRowReplication]				UNIQUEIDENTIFIER	NOT	NULL	CONSTRAINT	[DF_ProcedureLogBegin_txRowReplication]			DEFAULT(NEWSEQUENTIALID())	ROWGUIDCOL,

	CONSTRAINT	[PK_ProcedureLogBegin]	PRIMARY KEY CLUSTERED([ProcedureLogId] ASC)
);
GO

EXECUTE sp_addextendedproperty
	@name		= 'MS_Description',		@value		= 'Procedure begin meta data',
	@level0type	= 'schema',				@level0name	= 'track',
	@level1type	= 'table',				@level1name	= 'ProcedureLogBegin';