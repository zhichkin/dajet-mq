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
		INSERT [publications] ([name]) VALUES (@name);

		-- create new articles
		INSERT [articles] ([name], [table_name])
		SELECT a.[name], a.[table_name]
		  FROM @articles AS a LEFT JOIN [articles] AS t ON a.[name] = t.[name]
		 WHERE t.[name] IS NULL;

		DECLARE @id int = 0;
		DECLARE @table_name nvarchar(128);
		DECLARE @message_type_name nvarchar(128);
		DECLARE @count int = (SELECT COUNT(*) FROM @articles);
		-- message types loop
		WHILE (@id < @count)
		BEGIN
			
			-- get next article
			SET @id = @id + 1;
			SELECT @message_type_name = [name], @table_name = [table_name] FROM @articles WHERE [id] = @id;

			-- create message type
			EXECUTE sp_create_message_type @message_type_name;

			-- create publication trigger
			EXECUTE sp_create_publication_trigger @table_name;

		END; -- message types loop

		-- create contract
		DECLARE @message_types nvarchar(max);
		SELECT @message_types = COALESCE(@message_types + ', [' + [name] + '] SENT BY ANY', '[' + [name] + '] SENT BY ANY') FROM @articles;
		EXECUTE('CREATE CONTRACT [' + @name + '] (' + @message_types + ');');

		-- alter publication service to use new contract
		EXECUTE(N'ALTER SERVICE [publication_service] (ADD CONTRACT [' + @name + N']);');

		SET @id = 0;
		-- message types loop
		WHILE (@id < @count)
		BEGIN
			-- get next article
			SET @id = @id + 1;
			SELECT @message_type_name = [name] FROM @articles WHERE [id] = @id;

			-- create publication dialog
			EXECUTE sp_create_publication_dialog @message_type_name, @name;

		END; -- message types loop

	COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;
		THROW;
	END CATCH;

END;