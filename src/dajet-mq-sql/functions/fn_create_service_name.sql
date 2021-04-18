CREATE FUNCTION [dbo].[fn_create_service_name]
(
    @name nvarchar(80)
)
RETURNS nvarchar(128)
AS
BEGIN
    DECLARE @broker_uuid AS uniqueidentifier = [dbo].[fn_service_broker_uuid]();
    RETURN CAST (@broker_uuid AS nvarchar(36)) + N'/service/' + @name;
END;