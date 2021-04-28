CREATE PROCEDURE [dbo].[sp_create_publication]
	@name nvarchar(128),
	@articles udt_articles READONLY 
AS
BEGIN
	SET NOCOUNT ON;

	SET XACT_ABORT ON;

	BEGIN TRY
	BEGIN TRANSACTION;

		-- create new publication
		DECLARE @publication_id int;
		DECLARE @publications TABLE(id int);
		INSERT [publications] ([name]) OUTPUT inserted.id INTO @publications VALUES (@name);
		SELECT TOP 1 @publication_id = id FROM @publications;

		-- create new articles
		INSERT [articles] ([name], [table_name])
		SELECT a.[name], a.[table_name] FROM @articles AS a LEFT JOIN [articles] AS t ON a.[name] = t.[name]
		 WHERE t.[name] IS NULL;

		-- create publication to articles relations
		INSERT [publication_article_usages] ([publication_id], [article_id], [dialog_handle])
		SELECT @publication_id, t.[id], NULL FROM @articles AS a INNER JOIN [articles] AS t ON a.[name] = t.[name];

		DECLARE @id int = 0;
		DECLARE @article_id int;
		DECLARE @table_name nvarchar(128);
		DECLARE @count int = (SELECT COUNT(*) FROM @articles);
		WHILE (@id < @count) -- articles loop
		BEGIN
			
			-- get next article
			SET @id = @id + 1;
			SELECT @article_id = t.[id], @table_name = t.[table_name] FROM @articles AS a INNER JOIN [articles] AS t ON a.[name] = t.[name] WHERE a.[id] = @id;

			-- create publication dialog
			EXECUTE sp_create_publication_dialog @article_id, @publication_id;

			-- create publication trigger
			EXECUTE sp_create_publication_trigger @table_name;

		END; -- articles loop

	COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;
		THROW;
	END CATCH;

END;