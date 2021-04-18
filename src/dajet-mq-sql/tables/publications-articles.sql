CREATE TABLE [dbo].[dajet_publications_articles]
(
	[article_id] int NOT NULL,
	[publication_id] int NOT NULL
);
GO
CREATE UNIQUE CLUSTERED INDEX [ix_publications_articles_1] ON [dbo].[dajet_publications_articles] ([article_id] ASC, [publication_id] ASC);
GO
CREATE NONCLUSTERED INDEX [ix_publications_articles_2] ON [dbo].[dajet_publications_articles] ([publication_id] ASC);
GO