CREATE TRIGGER [tr_Reference79] ON [_Reference79]
AFTER INSERT, UPDATE, DELETE
NOT FOR REPLICATION
AS
	IF (ROWCOUNT_BIG() = 0) RETURN; -- There is no rows affected by the command

	--IF (ORIGINAL_LOGIN() = 'ZHICHKIN\Zhichkin') RETURN;
	--IF (SESSIONPROPERTY('replication_agent') = 1) RETURN; -- This is import data action

	-- check if this is UPDATE
	IF EXISTS(SELECT COUNT(*) FROM deleted) AND EXISTS(SELECT COUNT(*) FROM inserted)
	BEGIN
		DECLARE @COLUMNS_UPDATED varbinary(1) = COLUMNS_UPDATED(); -- The table has from 1 to 8 columns
		IF ((SUBSTRING(@COLUMNS_UPDATED, 1, 1) & 255 = 0)) RETURN; -- There is no changes
	END;

	-- get subscribers and their dialog handles
	IF NOT EXISTS(SELECT 1 FROM [dajet_subscriptions] WHERE [table] = N'_Reference79') RETURN;

	-- find dialog handle to send message on the publication queue
	DECLARE @dialog_handle uniqueidentifier;
	SELECT @dialog_handle = [dialog] FROM [dajet_publications] WHERE [table] = '_Reference79';
	IF (@dialog_handle IS NULL) RETURN; -- this might be setup error

	-- serialize data to xml, json or binary format
	DECLARE @message xml;
	IF EXISTS(SELECT COUNT(*) FROM inserted) -- insert or update
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
			FOR XML RAW(N'Row'), ROOT(N'Справочник.Номенклатура'), TYPE, BINARY BASE64
		);
	END;
	ELSE -- delete
	BEGIN
		SELECT @message =
		(
			SELECT [_IDRRef] AS [Ссылка]
			FROM deleted
			FOR XML RAW(N'Delete'), ROOT(N'Справочник.Номенклатура'), TYPE, BINARY BASE64
		);
	END;

	-- use try...catch with logging errors ?
	-- or unavailable dialog handle send will end up to sys.transmission_queue ?
	-- what if multiple conversations are used and fail to be sent ?
	IF (@dialog_handle IS NOT NULL) SEND ON CONVERSATION (@dialog_handle) MESSAGE TYPE [DEFAULT] (@message);
GO

--ALTER TABLE [_Reference79] ENABLE TRIGGER [tr_Reference79];
--GO

--DISABLE TRIGGER [tr_Reference79] ON [_Reference79];
--GO

--begin tran
--go
--create trigger t_i on t after insert as begin /* trigger body */ end
--go
--disable trigger t_i on t
--commit
--go

--SELECT SESSIONPROPERTY('replication_agent');
--SELECT name, is_not_for_replication FROM sys.triggers;