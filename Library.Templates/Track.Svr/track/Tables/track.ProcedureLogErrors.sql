CREATE TABLE [track].[ProcedureLogErrors]
(
	[ProcedureLogId]				BIGINT				NOT	NULL	CONSTRAINT	[FK_ProcedureLogErrors_ProcedureLogBegin]	FOREIGN KEY ([ProcedureLogId]) REFERENCES [track].[ProcedureLogBegin]([ProcedureLogId]),

	[ErrorNumber]					INT					NOT	NULL,
	[ErrorSeverity]					INT					NOT	NULL,
	[ErrorState]					INT					NOT	NULL,
	[ErrorProcedure]				NVARCHAR(128)		NOT	NULL,	CONSTRAINT	[CL_ProcedureLogErrors_ErrorProcedure]		CHECK([ErrorProcedure] <> ''),
	[ErrorLine]						INT					NOT	NULL,
	[ErrorMessage]					NVARCHAR(MAX)		NOT	NULL,	CONSTRAINT	[CL_ProcedureLogErrors_ErrorMessage]		CHECK([ErrorMessage] <> ''),

	[txInserted]					DATETIMEOFFSET(7)	NOT	NULL	CONSTRAINT	[DF_ProcedureLogErrors_txInserted]			DEFAULT(SYSDATETIMEOFFSET()),
	[txRowReplication]				UNIQUEIDENTIFIER	NOT	NULL	CONSTRAINT	[DF_ProcedureLogErrors_txRowReplication]	DEFAULT(NEWSEQUENTIALID())	ROWGUIDCOL,

	CONSTRAINT [PK_ProcedureLogErrors]		PRIMARY KEY CLUSTERED([ProcedureLogId]	ASC)
);
GO

EXECUTE sp_addextendedproperty
	@name		= 'MS_Description',		@value		= 'Procedure error meta data',
	@level0type	= 'schema',				@level0name	= 'track',
	@level1type	= 'table',				@level1name	= 'ProcedureLogErrors';