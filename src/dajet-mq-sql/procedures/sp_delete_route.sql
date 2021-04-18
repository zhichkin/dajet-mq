CREATE PROCEDURE [dbo].[sp_delete_route]
    @remote_queue_name NVARCHAR (128)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @handle AS UNIQUEIDENTIFIER = [dbo].[fn_get_dialog_handle](@remote_queue_name);
    IF (@handle IS NULL
        OR @handle = CAST ('00000000-0000-0000-0000-000000000000' AS UNIQUEIDENTIFIER))
        BEGIN
            END CONVERSATION @handle;
        END
    WAITFOR DELAY '00:00:10';
    
    DECLARE @sql AS NVARCHAR (1024);
    DECLARE @route_name AS NVARCHAR (128) = REPLACE(@remote_queue_name, N'/queue/', N'/route/');
    DECLARE @binding_name AS NVARCHAR (128) = REPLACE(@remote_queue_name, N'/queue/', N'/binding/');
    IF EXISTS (SELECT 1
               FROM   sys.remote_service_bindings
               WHERE  [name] = @binding_name)
        BEGIN
            SET @sql = N'DROP REMOTE SERVICE BINDING [' + @binding_name + N'];';
            EXECUTE (@sql);
        END

    IF EXISTS (SELECT 1
               FROM   sys.routes
               WHERE  [name] = @route_name)
        BEGIN
            SET @sql = N'DROP ROUTE [' + @route_name + N'];';
            EXECUTE (@sql);
        END
END