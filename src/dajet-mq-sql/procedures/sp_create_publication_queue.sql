CREATE PROCEDURE [dbo].[sp_create_publication_queue]
    @name nvarchar(80)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @user_name AS nvarchar(128) = [dbo].[fn_default_user_name]();
    DECLARE @queue_name AS nvarchar(128) = [dbo].[fn_create_queue_name](@name);
    DECLARE @service_name AS nvarchar(128) = [dbo].[fn_create_service_name](@name);

    IF NOT EXISTS(SELECT 1 FROM sys.service_queues WHERE [name] = @queue_name)
    BEGIN
        EXECUTE('CREATE QUEUE [' + @queue_name + '] WITH POISON_MESSAGE_HANDLING (STATUS = OFF);');
    END;

    IF NOT EXISTS(SELECT 1 FROM sys.services WHERE [name] = @service_name)
    BEGIN
        EXECUTE('CREATE SERVICE [' + @service_name + '] ON QUEUE [' + @queue_name + '] ([DEFAULT]);
		         GRANT CONTROL ON SERVICE::[' + @service_name + '] TO [' + @user_name + '];
		         GRANT SEND ON SERVICE::[' + @service_name + '] TO [PUBLIC];');
    END;

  --  DECLARE @handle AS UNIQUEIDENTIFIER = [dbo].[fn_get_dialog_handle](@queue_name);
  --  DECLARE @broker_guid AS NVARCHAR (36) = CAST ([dbo].[fn_service_broker_guid]() AS NVARCHAR (36));
  --  IF (@handle IS NULL
  --      OR @handle = CAST ('00000000-0000-0000-0000-000000000000' AS UNIQUEIDENTIFIER))
  --      BEGIN
  --          DECLARE @sql AS NVARCHAR (1024) = 'BEGIN DIALOG @handle_out
		--FROM SERVICE [' + @default_service_name + ']
		--TO SERVICE ''' + @service_name + ''', ''' + @broker_guid + '''
		--ON CONTRACT [DEFAULT]
		--WITH ENCRYPTION = OFF;';
  --          EXECUTE sp_executesql @sql, N'@handle_out uniqueidentifier OUTPUT', @handle_out = @handle OUTPUT;
  --      END
END;