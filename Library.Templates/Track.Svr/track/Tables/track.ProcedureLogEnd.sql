CREATE TABLE [track].[ProcedureLogEnd]
(
	[ProcedureLogId]				BIGINT				NOT	NULL	CONSTRAINT	[FK_ProcedureLogEnd_ProcedureLogBegin]	FOREIGN KEY ([ProcedureLogId]) REFERENCES [track].[ProcedureLogBegin]([ProcedureLogId]),

	[txInserted]					DATETIMEOFFSET(7)	NOT	NULL	CONSTRAINT	[DF_ProcedureLogEnd_txInserted]			DEFAULT(SYSDATETIMEOFFSET()),
	[txRowReplication]				UNIQUEIDENTIFIER	NOT	NULL	CONSTRAINT	[DF_ProcedureLogEnd_txRowReplication]	DEFAULT(NEWSEQUENTIALID())	ROWGUIDCOL,

	CONSTRAINT [PK_ProcedureLogEnd]		PRIMARY KEY CLUSTERED([ProcedureLogId]	ASC)
);
GO

EXECUTE sp_addextendedproperty
	@name		= 'MS_Description',		@value		= 'Procedure end meta data',
	@level0type	= 'schema',				@level0name	= 'track',
	@level1type	= 'table',				@level1name	= 'ProcedureLogEnd';