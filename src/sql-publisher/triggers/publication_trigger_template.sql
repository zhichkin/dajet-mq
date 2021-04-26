CREATE TRIGGER [_Reference79] ON [_Reference79]
AFTER INSERT, UPDATE, DELETE
NOT FOR REPLICATION
AS
	IF (ROWCOUNT_BIG() = 0) RETURN; -- There is no rows affected by the command

	-- check if this is import data session
	--IF (ORIGINAL_LOGIN() = 'DaJetDataLoaderUser') RETURN;
	--IF (SESSIONPROPERTY('replication_agent') = 1) RETURN; -- This is import data action

	DECLARE @deleted int = (SELECT COUNT(*) FROM deleted);
	DECLARE @inserted int = (SELECT COUNT(*) FROM inserted);

	-- check for data changes
	IF (@deleted > 0 AND @inserted > 0 AND NOT fn_has_updated_columns(COLUMNS_UPDATED())) RETURN;

	-- serialize data to xml, json or binary format
	DECLARE @message xml;
	IF (@inserted > 0)
		IF (@deleted > 0)
			SELECT @message = (SELECT * FROM inserted FOR XML RAW(N'row'), ROOT(N'update'), TYPE, BINARY BASE64);
		ELSE
			SELECT @message = (SELECT * FROM inserted FOR XML RAW(N'row'), ROOT(N'insert'), TYPE, BINARY BASE64);
	ELSE
		SELECT @message = (SELECT * FROM deleted FOR XML RAW(N'row'), ROOT(N'delete'), TYPE, BINARY BASE64);

	EXECUTE sp_publish_message @message, N'_Reference79';
GO

--DECLARE @sql nvarchar(max) = N'
--SELECT @message_out = (SELECT
--[_IDRRef] AS [Ссылка],
--[_Version] AS [ВерсияДанных],
--[_Marked] AS [ПометкаУдаления],
--[_PredefinedID] AS [Предопределённый],
--[_Code] AS [Код],
--[_Description] AS [Наименование]
--FROM _Reference79 FOR XML RAW(N''row''), ROOT(N''update''), TYPE, BINARY BASE64);';
--EXECUTE sp_executesql @sql, N'@message_out xml OUTPUT', @message_out = @message OUTPUT;