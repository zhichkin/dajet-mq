CREATE PROCEDURE [dbo].[sp_create_publication_trigger]
	@table_name nvarchar(128)
AS
BEGIN
	SET NOCOUNT ON;

	-- TODO: create insert, update and delete triggers separately

	DECLARE @trigger_name nvarchar(128) = @table_name + N'_after_all';

	EXECUTE(N'IF EXISTS(SELECT 1 FROM sys.triggers WHERE [name] = N''' + @trigger_name + N''') DROP TRIGGER [' + @trigger_name + N'];');

	EXECUTE(N'CREATE TRIGGER [' + @trigger_name + N'] ON [' + @table_name + N'] AFTER INSERT, UPDATE, DELETE NOT FOR REPLICATION AS DECLARE @empty_body int;');

	EXECUTE(N'DISABLE TRIGGER [' + @trigger_name + N'] ON [' + @table_name + N'];');

	EXECUTE(N'ALTER TRIGGER [' + @trigger_name + N'] ON [' + @table_name + N'] AFTER INSERT, UPDATE, DELETE NOT FOR REPLICATION AS
	
	IF (ROWCOUNT_BIG() = 0) RETURN;
	
	DECLARE @deleted int = (SELECT COUNT(*) FROM deleted);
	DECLARE @inserted int = (SELECT COUNT(*) FROM inserted);
	
	DECLARE @message xml;
	IF (@inserted > 0)
		IF (@deleted > 0)
			SELECT @message = (SELECT * FROM inserted FOR XML RAW(N''row''), ROOT(N''update''), TYPE, BINARY BASE64);
		ELSE
			SELECT @message = (SELECT * FROM inserted FOR XML RAW(N''row''), ROOT(N''insert''), TYPE, BINARY BASE64);
	ELSE
		SELECT @message = (SELECT * FROM deleted FOR XML RAW(N''row''), ROOT(N''delete''), TYPE, BINARY BASE64);
	
	EXECUTE sp_publish_message N''' + @table_name + N''', @message;');

	EXECUTE(N'ENABLE TRIGGER [' + @trigger_name + N'] ON [' + @table_name + N'];');
END;

--DECLARE @message xml =
--(SELECT
--  N'Справочник.Номенклатура' AS [type],
--	N'delete' AS [operation],
--	(SELECT
--		number AS num,
--		bin    AS bin
--	FROM @numbers FOR XML RAW(N'row'), TYPE, BINARY BASE64) AS rows
--FOR XML RAW(N'message'), TYPE);