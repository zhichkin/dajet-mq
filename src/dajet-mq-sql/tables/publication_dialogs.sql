CREATE TABLE [dbo].[publication_dialogs]
(
	[article_name] nvarchar(128) NOT NULL,
	[publication_name] nvarchar(128) NOT NULL,
	[dialog_handle] uniqueidentifier NOT NULL
);
GO
CREATE UNIQUE CLUSTERED INDEX [ix_publication_dialogs_1] ON [dbo].[publication_dialogs] ([article_name] ASC, [publication_name] ASC);
GO