CREATE TABLE [dbo].[dajet_articles]
(
	[id] int NOT NULL PRIMARY KEY,
	[name] nvarchar(128) UNIQUE NOT NULL,
	[table_name] nvarchar(128) NOT NULL
);