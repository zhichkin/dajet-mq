CREATE FUNCTION [dbo].[fn_publication_dialog_handle]
(
    @table_name nvarchar(128)
)
RETURNS uniqueidentifier
AS
BEGIN
    DECLARE @handle AS uniqueidentifier;

    --SELECT @handle = conversation_handle
    --  FROM sys.conversation_endpoints AS e
    --       INNER JOIN sys.services AS s
    --       ON e.service_id = s.service_id
    --          AND e.is_initiator = 1
    --          AND e.state IN ('SO', 'CO')
    --          AND s.name = @source_service_name
    --          AND e.far_service = @target_service_name
    --          AND e.far_broker_instance = @target_broker_guid;



    IF (@handle IS NULL) SET @handle = CAST('00000000-0000-0000-0000-000000000000' AS uniqueidentifier);

    RETURN @handle;
END;

--DECLARE @counter SMALLINT;  
--SET @counter = 1;  
--WHILE @counter < 5  
--   BEGIN  
--      SELECT floor(rand()*(@max_integer - @min_integer + 1) + @min_integer) Random_Number  
--      SET @counter = @counter + 1  
--   END;  
--GO