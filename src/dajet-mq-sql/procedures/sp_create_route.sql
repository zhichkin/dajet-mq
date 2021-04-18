CREATE PROCEDURE [dbo].[sp_create_route]
    @remote_queue_name nvarchar(128),
    @remote_server_address nvarchar(128),
    @remote_broker_port_number int
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @sql AS nvarchar(1024);
    DECLARE @local_broker_guid AS nvarchar(36) = CAST ([dbo].[fn_service_broker_uuid]() AS nvarchar(36));
    DECLARE @default_service_name AS nvarchar(128) = [dbo].[fn_default_service_name]();
    DECLARE @remote_broker_guid AS nvarchar(128) = SUBSTRING(@remote_queue_name, 1, 36);
    DECLARE @route_name AS nvarchar(128) = REPLACE(@remote_queue_name, N'/queue/', N'/route/');
    DECLARE @remote_user AS nvarchar(128) = @remote_broker_guid + N'/user';
    DECLARE @binding_name AS nvarchar(128) = REPLACE(@remote_queue_name, N'/queue/', N'/binding/');
    DECLARE @remote_service_name AS nvarchar(128) = REPLACE(@remote_queue_name, N'/queue/', N'/service/');

    IF (@local_broker_guid = @remote_broker_guid) THROW 50001, N'Invalid operation: there is no meaning to create route to the local queue.', 1;

    IF NOT EXISTS(SELECT 1 FROM sys.routes WHERE [name] = @route_name)
    BEGIN
            SET @sql = N'CREATE ROUTE [' + @route_name + N'] WITH
			SERVICE_NAME = ''' + @remote_service_name + N''',
			BROKER_INSTANCE = ''' + @remote_broker_guid + ''',
			ADDRESS = ''TCP://' + @remote_server_address + N':' + CAST (@remote_broker_port_number AS nvarchar(5)) + N'''' + N';';
            EXECUTE (@sql);
    END;

    IF NOT EXISTS (SELECT 1 FROM sys.remote_service_bindings WHERE [name] = @binding_name)
    BEGIN
        SET @sql = N'CREATE REMOTE SERVICE BINDING [' + @binding_name + N']
		             TO SERVICE ''' + @remote_service_name + N'''
			         WITH USER = [' + @remote_user + N'], ANONYMOUS = ON;';
        EXECUTE (@sql);
    END;

    DECLARE @handle AS UNIQUEIDENTIFIER = [dbo].[fn_get_dialog_handle](@remote_queue_name);
    IF (@handle IS NULL
        OR @handle = CAST ('00000000-0000-0000-0000-000000000000' AS UNIQUEIDENTIFIER))
        BEGIN
            SET @sql = N'BEGIN DIALOG @handle_out
		FROM SERVICE [' + @default_service_name + N']
		TO SERVICE ''' + @remote_service_name + N''', ''' + @remote_broker_guid + N'''
		ON CONTRACT [DEFAULT]
		WITH ENCRYPTION = OFF;';
            EXECUTE sp_executesql @sql, N'@handle_out uniqueidentifier OUTPUT', @handle_out = @handle OUTPUT;
        END
END