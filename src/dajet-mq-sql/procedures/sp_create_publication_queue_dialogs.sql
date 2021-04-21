CREATE PROCEDURE [dbo].[sp_create_publication_queue_dialogs]
	@article_id int,
	@table_name nvarchar(128)
AS
BEGIN
	
	DECLARE @service_name AS nvarchar(128) = [dbo].[fn_create_service_name](@table_name);
	DECLARE @broker_uuid AS nvarchar(36) = LOWER(CAST([dbo].[fn_service_broker_uuid]() AS nvarchar(36)));

	DECLARE @dialog_handle uniqueidentifier;

	DECLARE @sql AS nvarchar(1024) = '
	BEGIN DIALOG @handle_out
	FROM SERVICE [' + @service_name + ']
	TO SERVICE ''' + @service_name + ''', ''' + @broker_uuid + '''
	ON CONTRACT [DEFAULT] WITH ENCRYPTION = OFF;';
	
	EXECUTE sp_executesql @sql, N'@handle_out uniqueidentifier OUTPUT', @handle_out = @dialog_handle OUTPUT;
	
	INSERT [dajet_dialogs] ([article_id], [dialog_handle]) VALUES (@article_id, @dialog_handle);

END;

--DECLARE @counter SMALLINT;  
--SET @counter = 1;  
--WHILE @counter < 5  
--   BEGIN  
--      SELECT floor(rand()*(@max_integer - @min_integer + 1) + @min_integer) Random_Number  
--      SET @counter = @counter + 1  
--   END;  
--GO  