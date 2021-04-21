CREATE PROCEDURE [dbo].[sp_create_article]
	@name nvarchar(128),
	@table_name nvarchar(128),
	@article_id int OUTPUT
AS
BEGIN
	
	DECLARE @table TABLE (id int);
		
	INSERT [dajet_articles] ([name], [table_name])
	OUTPUT inserted.[id] INTO @table
	VALUES (@name, @table_name);

	SELECT TOP 1 @article_id = [id] FROM @table;

END;