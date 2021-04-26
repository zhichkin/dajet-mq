CREATE PROCEDURE [dbo].[sp_create_message_type]
	@name nvarchar(128)
AS
BEGIN
	SET NOCOUNT ON;

	EXECUTE(N'IF NOT EXISTS(SELECT 1 FROM sys.service_message_types WHERE [name] = N''' + @name + N''')
	CREATE MESSAGE TYPE [' + @name + N'] VALIDATION = NONE;');

END;