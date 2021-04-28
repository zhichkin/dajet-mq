CREATE FUNCTION [dbo].[fn_sql_to_1c_uuid] (@uuid_sql binary(16))
RETURNS nvarchar(36)
AS
BEGIN
	DECLARE @uuid_1c binary(16) = CAST(REVERSE(SUBSTRING(@uuid_sql, 9, 8)) AS binary(8)) + SUBSTRING(@uuid_sql, 1, 8);
	
	RETURN CAST(CAST(@uuid_1c AS uniqueidentifier) AS nvarchar(36));
END;