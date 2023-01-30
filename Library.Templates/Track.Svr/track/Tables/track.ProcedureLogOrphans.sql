CREATE TABLE [track].[ProcedureLogOrphans]
(
	[ProcedureLogId]				BIGINT				NOT	NULL	CONSTRAINT	[FK_ProcedureLogOrphans_ProcedureLogBegin]		FOREIGN KEY ([ProcedureLogId]) REFERENCES [track].[ProcedureLogBegin]([ProcedureLogId]),

	[txInserted]					DATETIMEOFFSET(7)	NOT	NULL	CONSTRAINT	[DF_ProcedureLogOrphans_txInserted]				DEFAULT(SYSDATETIMEOFFSET()),
	[txInsertedSID]					VARBINARY(85)		NOT	NULL	CONSTRAINT	[DF_ProcedureLogOrphans_txInsertedSID]			DEFAULT(SUSER_SID()),
	[txInsertedUserExecuted]		NVARCHAR(128)		NOT	NULL	CONSTRAINT	[DF_ProcedureLogOrphans_txInsertedUserExecuted]	DEFAULT(SUSER_SNAME()),
	[txInsertedUserOriginal]		NVARCHAR(128)		NOT	NULL	CONSTRAINT	[DF_ProcedureLogOrphans_txInsertedUserOriginal]	DEFAULT(ORIGINAL_LOGIN()),
	[txInsertedHost]				NVARCHAR(128)		NOT	NULL	CONSTRAINT	[DF_ProcedureLogOrphans_txInsertedHost]			DEFAULT(HOST_NAME()),
	[txInsertedApplication]			NVARCHAR(128)		NOT	NULL	CONSTRAINT	[DF_ProcedureLogOrphans_txInsertedApplication]	DEFAULT(APP_NAME()),
	[txInsertedProcedure]			NVARCHAR(517)			NULL	CONSTRAINT	[DF_ProcedureLogOrphans_txInsertedProcedure]	DEFAULT(QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID))),

	[txRowReplication]				UNIQUEIDENTIFIER	NOT	NULL	CONSTRAINT	[DF_ProcedureLogOrphans_txRowReplication]		DEFAULT(NEWSEQUENTIALID())	ROWGUIDCOL,

	CONSTRAINT	[PK_ProcedureLogOrphans]		PRIMARY KEY CLUSTERED([ProcedureLogId] ASC)
);
GO

EXECUTE sp_addextendedproperty
	@name		= 'MS_Description',		@value		= 'Procedure error meta data',
	@level0type	= 'schema',				@level0name	= 'track',
	@level1type	= 'table',				@level1name	= 'ProcedureLogOrphans';