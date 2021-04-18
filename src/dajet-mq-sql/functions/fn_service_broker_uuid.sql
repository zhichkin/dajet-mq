CREATE FUNCTION [dbo].[fn_service_broker_uuid]
(
    @database_name nvarchar(128) = NULL
)
RETURNS uniqueidentifier
AS
BEGIN
    DECLARE @uuid AS uniqueidentifier = CAST ('00000000-0000-0000-0000-000000000000' AS uniqueidentifier);
    IF (@database_name IS NULL)
    BEGIN
        SELECT @uuid = service_broker_guid FROM sys.databases WHERE database_id = DB_ID();
    END;
    ELSE
    BEGIN
        SELECT @uuid = service_broker_guid FROM sys.databases WHERE database_id = DB_ID(@database_name);
    END;
    RETURN @uuid;
END;