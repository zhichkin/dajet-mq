CREATE FUNCTION [dbo].[fn_create_queue_name]
(
    @name nvarchar(80)
)
RETURNS nvarchar(128)
AS
BEGIN
    DECLARE @broker_guid AS uniqueidentifier = [dbo].[fn_service_broker_uuid]();
    RETURN CAST (@broker_guid AS nvarchar(36)) + N'/queue/' + @name;
END;