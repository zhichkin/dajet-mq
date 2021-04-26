CREATE TABLE [dbo].[publication_dialogs]
(
	[article_name] nvarchar(128) NOT NULL,
	[publication_name] nvarchar(128) NOT NULL,
	[dialog_handle] uniqueidentifier NOT NULL
);
GO