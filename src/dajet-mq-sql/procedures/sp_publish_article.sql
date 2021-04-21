CREATE PROCEDURE [dbo].[sp_publish_article]
	@publication_id int,
	@name nvarchar(128),
	@table_name nvarchar(128)
AS
BEGIN
	
	DECLARE @article_id int;

	SELECT @article_id = [id] FROM [dajet_articles] WHERE [name] = @name;
	IF (@article_id IS NOT NULL) AND EXISTS(SELECT 1 FROM [dajet_publications_articles]
											WHERE [article_id] = @article_id AND [publication_id] = @publication_id)
	BEGIN
		SELECT @article_id;
	END;

	SET XACT_ABORT ON; -- IF ((16384 & @@OPTIONS) = 16384) -- XACT_ABORT IS ON

	BEGIN TRY
		BEGIN TRANSACTION;

		IF (@article_id IS NULL) EXECUTE sp_create_article @name, @table_name, @article_id OUTPUT;

		INSERT [dajet_publications_articles] ([article_id], [publication_id]) VALUES (@article_id, @publication_id);

		EXECUTE sp_create_publication_queue @table_name;

		EXECUTE sp_create_publication_queue_dialogs @article_id, @table_name;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;
		THROW;
	END CATCH;

	SELECT @article_id;
END;