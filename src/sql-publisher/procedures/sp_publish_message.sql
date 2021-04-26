CREATE PROCEDURE [dbo].[sp_publish_message]
	@table_name nvarchar(128),
	@message xml
AS
BEGIN
	SET NOCOUNT ON;

	-- get message type to send
	DECLARE @message_type nvarchar(128);
	SELECT @message_type = [name] FROM [articles] WHERE [table_name] = @table_name;
	IF (@message_type IS NULL) RETURN 0; -- this might be setup error

	-- find dialog handles to send message on the publication queue
	DECLARE @dialogs TABLE([id] int IDENTITY(1,1), [handle] uniqueidentifier);
	INSERT @dialogs ([handle]) SELECT [dialog_handle] FROM [publication_dialogs] WHERE [article_name] = @table_name;
	IF NOT EXISTS(SELECT 1 FROM @dialogs) RETURN 0; -- this might be setup error

	-- send message on publication dialogs
	DECLARE @dialogs_list nvarchar(max);
	DECLARE @sql nvarchar(max) = N'SEND ON CONVERSATION (';
	SELECT @dialogs_list = COALESCE(@dialogs_list + ', ''' + CAST([handle] AS nvarchar(36)) + N'''', N'''' + CAST([handle] AS nvarchar(36)) + N'''') FROM @dialogs;
	SET @sql += @dialogs_list + N') MESSAGE TYPE [' + @message_type + '] (@message);';
	EXECUTE sp_executesql @sql, N'@message xml', @message;
END;