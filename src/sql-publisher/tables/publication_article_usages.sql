CREATE TABLE [dbo].[publication_article_usages]
(
	[article_id] int NOT NULL,
	[publication_id] int NOT NULL,
	[dialog_handle] uniqueidentifier NULL
);
GO