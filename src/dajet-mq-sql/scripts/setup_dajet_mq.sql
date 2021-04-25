IF NOT EXISTS(SELECT 1 FROM sys.databases WHERE database_id = DB_ID('dajet-mq') AND is_broker_enabled = 0x01)
BEGIN
	ALTER DATABASE [dajet-mq] SET ENABLE_BROKER;
END;
GO

IF NOT EXISTS(SELECT 1 FROM sys.tables WHERE [name] = 'publications')
BEGIN
	CREATE TABLE [dbo].[publications]
	(
		[name] nvarchar(128) NOT NULL
	);
	CREATE UNIQUE CLUSTERED INDEX [ix_publications_1] ON [dbo].[publications] ([name] ASC);
END;
GO

IF NOT EXISTS(SELECT 1 FROM sys.tables WHERE [name] = 'articles')
BEGIN
	CREATE TABLE [dbo].[articles]
	(
		[name] nvarchar(128) NOT NULL,
		[table_name] nvarchar(128) NOT NULL
	);
	CREATE UNIQUE CLUSTERED INDEX [ix_articles_1] ON [dbo].[articles] ([name] ASC);
END;
GO

CREATE TYPE [dbo].[udt_articles] AS TABLE
(
	[id] int NOT NULL PRIMARY KEY IDENTITY(1,1),
	[name] nvarchar(128) NOT NULL UNIQUE,
	[table_name] nvarchar(128) NOT NULL
);
GO

IF NOT EXISTS(SELECT 1 FROM sys.tables WHERE [name] = 'publication_dialogs')
BEGIN
	CREATE TABLE [dbo].[publication_dialogs]
	(
		[article_name] nvarchar(128) NOT NULL,
		[publication_name] nvarchar(128) NOT NULL,
		[dialog_handle] uniqueidentifier NOT NULL
	);
	CREATE UNIQUE CLUSTERED INDEX [ix_publication_dialogs_1] ON [dbo].[publication_dialogs] ([article_name] ASC, [publication_name] ASC);
END;
GO

IF NOT EXISTS(SELECT 1 FROM sys.service_queues WHERE [name] = 'publication_queue')
BEGIN
	CREATE QUEUE [publication_queue] WITH POISON_MESSAGE_HANDLING (STATUS = OFF);
END;
GO

IF NOT EXISTS(SELECT 1 FROM sys.sys.services WHERE [name] = 'publication_service')
BEGIN
	CREATE SERVICE [publication_service] ON QUEUE [publication_queue] ([DEFAULT]);
END;
GO