IF NOT EXISTS(SELECT 1 FROM sys.databases WHERE database_id = DB_ID() AND is_broker_enabled = 0x01)
BEGIN
	DECLARE @database_name nvarchar(128);
	SELECT @database_name = [name] FROM sys.databases WHERE database_id = DB_ID();
	EXECUTE(N'ALTER DATABASE [' + @database_name + N'] SET ENABLE_BROKER;');
END;
GO