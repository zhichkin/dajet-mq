CREATE FUNCTION [dbo].[fn_publication_dialog_handle]
(
    @target_queue_name nvarchar(128)
)
RETURNS uniqueidentifier
AS
BEGIN
    IF (@target_queue_name IS NULL) RETURN CAST ('00000000-0000-0000-0000-000000000000' AS uniqueidentifier);

    DECLARE @source_broker_guid AS nvarchar(36) = [dbo].[fn_service_broker_uuid]();
    DECLARE @source_service_name AS nvarchar(128) = [dbo].[fn_default_service_name]();
    
    DECLARE @target_broker_guid AS nvarchar(36) = SUBSTRING(@target_queue_name, 1, 36);
    DECLARE @target_service_name AS nvarchar(128) = REPLACE(@target_queue_name, N'/queue/', N'/service/');

    DECLARE @handle AS uniqueidentifier;
    SELECT @handle = conversation_handle
      FROM sys.conversation_endpoints AS e
           INNER JOIN sys.services AS s
           ON e.service_id = s.service_id
              AND e.is_initiator = 1
              AND e.state IN ('SO', 'CO')
              AND s.name = @source_service_name
              AND e.far_service = @target_service_name
              AND e.far_broker_instance = @target_broker_guid;

    IF (@handle IS NULL) SET @handle = CAST('00000000-0000-0000-0000-000000000000' AS uniqueidentifier);

    RETURN @handle;
END;