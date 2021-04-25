CREATE TRIGGER [_Reference79] ON [_Reference79]
AFTER INSERT, UPDATE, DELETE
NOT FOR REPLICATION
AS
	IF (ROWCOUNT_BIG() = 0) RETURN; -- There is no rows affected by the command

	-- check if this is load data session
	--IF (ORIGINAL_LOGIN() = 'DaJetDataLoaderUser') RETURN;
	--IF (SESSIONPROPERTY('replication_agent') = 1) RETURN; -- This is import data action

	DECLARE @deleted int = (SELECT COUNT(*) FROM deleted);
	DECLARE @inserted int = (SELECT COUNT(*) FROM inserted);

	IF (@deleted > 0 AND @inserted > 0) -- this is UPDATE
	BEGIN
		DECLARE @changed bit = 0x00;
		DECLARE @columns_updated varbinary(128) = COLUMNS_UPDATED();
		DECLARE @chunk_number int = 0;
		DECLARE @chunks_count int = LEN(@columns_updated);
		
		WHILE (@chunk_number < @chunks_count)
		BEGIN
			SET @chunk_number = @chunk_number + 1;
			IF (SUBSTRING(@columns_updated, @chunk_number, 1) & 255 > 0)
			BEGIN
				SET @changed = 0x01;
				BREAK;
			END;
		END;

		IF (@changed = 0x00) RETURN; -- there is no changes
	END; -- check for changes

	--check if any subscriber exists - ? or publish anyway ?
	--IF NOT EXISTS(SELECT 1 FROM sys.routes WHERE [remote_service_name] IS NOT NULL) RETURN;

	-- find dialog handles to send message on the publication queue
	DECLARE @dialogs TABLE([id] int IDENTITY(1,1), [handle] uniqueidentifier);
	INSERT @dialogs ([handle])
	SELECT [dialog_handle] FROM [publication_dialogs] WHERE [article_name] = '_Reference79';
	IF NOT EXISTS(SELECT 1 FROM @dialogs) RETURN; -- this might be setup error

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

	-- serialize data to xml, json or binary format
	DECLARE @message xml;
	IF (@inserted > 0) -- insert or update
	BEGIN
		SELECT @message =
		(
			SELECT [_IDRRef]       AS [Ссылка],
				   [_Version]      AS [ВерсияДанных],
				   [_Marked]       AS [ПометкаУдаления],
				   [_PredefinedID] AS [Предопределённый],
				   [_Code]         AS [Код],
				   [_Description]  AS [Наименование]
			FROM inserted
			FOR XML RAW(N'row'), ROOT(N'upsert'), TYPE, BINARY BASE64
		);
	END;
	ELSE -- delete
	BEGIN
		SELECT @message =
		(
			SELECT [_IDRRef] AS [Ссылка]
			FROM deleted
			FOR XML RAW(N'row'), ROOT(N'delete'), TYPE, BINARY BASE64
		);
	END;

	-- send message on publication dialogs
	DECLARE @id int = 0;
	DECLARE @count int = (SELECT COUNT(*) FROM @dialogs);
	DECLARE @dialog_handle uniqueidentifier;
	-- dialogs loop
	WHILE (@id < @count)
	BEGIN
		-- get next dialog
		SET @id = @id + 1;
		SELECT @dialog_handle = [handle] FROM @dialogs WHERE [id] = @id;
		SEND ON CONVERSATION (@dialog_handle) MESSAGE TYPE [Справочник.Номенклатура] (@message);
	END; -- dialogs loop
GO