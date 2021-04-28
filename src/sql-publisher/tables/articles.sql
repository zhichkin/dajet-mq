CREATE TABLE [dbo].[articles]
(
	[id] int IDENTITY(1,1),
	[name] nvarchar(128) NOT NULL,
	[table_name] nvarchar(128) NOT NULL
);