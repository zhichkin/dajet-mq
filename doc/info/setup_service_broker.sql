USE [dajet_agent];
GO

CREATE TABLE [dajet_publications]
(
	[id] int identity(1,1) primary key,
	[name] nvarchar(128),
	[table] nvarchar(128),
	[queue] nvarchar(128),
	[dialog] uniqueidentifier
);
GO

CREATE TABLE [dajet_subscribers]
(
	[id]    int identity(1,1) primary key,
	[name]  nvarchar(128),
	[node]  uniqueidentifier,
	[queue] nvarchar(128)
);
GO

CREATE TABLE [dajet_subscriptions]
(
	id int identity(1,1) primary key,
	subscriber_id int,
	publication_id int,
	dialog_handle uniqueidentifier
);
GO

DECLARE @message_type nvarchar(128);
DECLARE @dialog_handle AS uniqueidentifier;

SET @message_type = N'Справочник.Номенклатура';

BEGIN TRANSACTION;

BEGIN DIALOG @dialog_handle
FROM SERVICE [_Reference79_Service]
  TO SERVICE '_Reference79_Service', 'CURRENT DATABASE'
 ON CONTRACT [DEFAULT] WITH ENCRYPTION = OFF;

INSERT [dajet_subscriptions] ([subscriber_id], [publication_id], [dialog_handle])
VALUES (@message_type, @dialog_handle);

COMMIT TRANSACTION;
GO


