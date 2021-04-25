CREATE PROCEDURE [dbo].[sp_create_publication_trigger]
	@table_name nvarchar(128) NOT NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @trigger_name nvarchar(128) = @table_name + N'_after_all';

	EXECUTE(N'IF EXISTS(SELECT 1 FROM sys.triggers WHERE [name] = N''' + @trigger_name + N''') DROP TRIGGER [' + @trigger_name + N'];');

	EXECUTE(N'CREATE TRIGGER [' + @trigger_name + N'] ON [' + @table_name + N'] AFTER INSERT, UPDATE, DELETE NOT FOR REPLICATION AS DECLARE @empty_body int;');

	EXECUTE(N'DISABLE TRIGGER [' + @trigger_name + N'] ON [' + @table_name + N'];');

	-- alter trigger code here

	EXECUTE(N'ENABLE TRIGGER [' + @trigger_name + N'] ON [' + @table_name + N'];');
END;