CREATE TYPE [dbo].[udt_articles] AS TABLE
(
	[id] int NOT NULL PRIMARY KEY IDENTITY(1,1),
	[name] nvarchar(128) NOT NULL UNIQUE,
	[table_name] nvarchar(128) NOT NULL
);
GO