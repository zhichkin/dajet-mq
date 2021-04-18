CREATE PROCEDURE [dbo].[sp_delete_queue]
    @name nvarchar(128)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @queue_name AS nvarchar(128) = [dbo].[fn_create_queue_name](@name);
    DECLARE @service_name AS nvarchar(128) = [dbo].[fn_create_service_name](@name);
    DECLARE @default_service_name AS nvarchar(128) = [dbo].[fn_default_service_name]();

    IF (@default_service_name = @queue_name) THROW 50001, N'The default queue can not be droped!', 1;

    IF EXISTS(SELECT 1 FROM sys.services WHERE [name] = @service_name)
    BEGIN
        EXECUTE (N'DROP SERVICE [' + @service_name + N'];');
    END;

    IF EXISTS(SELECT 1 FROM sys.service_queues WHERE [name] = @queue_name)
    BEGIN
        EXECUTE (N'DROP QUEUE [dbo].[' + @queue_name + N'];');
    END;

    DECLARE @handle AS uniqueidentifier = [dbo].[fn_get_dialog_handle](@queue_name);
    IF (@handle IS NOT NULL) AND (@handle != CAST ('00000000-0000-0000-0000-000000000000' AS uniqueidentifier))
    BEGIN
        END CONVERSATION @handle;
    END;
END;