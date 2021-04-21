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
        EXECUTE('CREATE SERVICE [' + @service_name + '] ON QUEUE [' + @queue_name + '] ([DEFAULT]);');
		         --GRANT CONTROL ON SERVICE::[' + @service_name + '] TO [' + @user_name + '];
		         --GRANT SEND ON SERVICE::[' + @service_name + '] TO [PUBLIC];');
    END;
  
END;