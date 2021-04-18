CREATE FUNCTION [dbo].[fn_service_broker_port]()
RETURNS int
AS
BEGIN
    DECLARE @broker_port AS int;
    SELECT @broker_port = [tcp].[port] FROM sys.tcp_endpoints AS [tcp]
    INNER JOIN sys.service_broker_endpoints AS [sbe] ON [sbe].[endpoint_id] = [tcp].[endpoint_id]
    WHERE  [sbe].[type] = 3;
    IF (@broker_port IS NULL) SET @broker_port = 0;
    RETURN @broker_port;
END