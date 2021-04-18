CREATE PROCEDURE [dbo].[sp_publish_article]
	@publication_id int,
	@name nvarchar(128),
	@table_name nvarchar(128)
AS
BEGIN
	
	DECLARE @article_id int;

	SELECT @article_id = [id] FROM [dajet_articles] WHERE [name] = @name;
	IF (@article_id IS NOT NULL)
	AND EXISTS(SELECT 1 FROM [dajet_publications_articles] WHERE [article_id] = @article_id AND [publication_id] = @publication_id)
	BEGIN
		SELECT @article_id;
	END;

	IF (@article_id IS NULL)
	BEGIN
		DECLARE @table TABLE (id int);
		
		INSERT [dajet_articles] ([name], [table_name])
		OUTPUT inserted.[id] INTO @table
		VALUES (@name, @table_name);

		SELECT TOP 1 @article_id = [id] FROM @table;
	END;

	INSERT [dajet_publications_articles] ([article_id], [publication_id]) VALUES (@article_id, @publication_id);

	EXECUTE sp_create_publication_queue @table_name;

	--EXECUTE sp_create_publication_dialogs @table_name;

	--DECLARE @dialog_handle AS uniqueidentifier;

	--BEGIN DIALOG @dialog_handle
	--FROM SERVICE [dajet-agent-export-service]
	--  TO SERVICE 'dajet-agent-export-service', 'CURRENT DATABASE'
	-- ON CONTRACT [DEFAULT] WITH ENCRYPTION = OFF;

	--INSERT [dajet_dialogs] ([article_id], [dialog_handle]) VALUES (@article_id, @dialog_handle);

	SELECT @article_id;
END;