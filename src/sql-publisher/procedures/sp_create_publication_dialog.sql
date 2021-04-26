CREATE PROCEDURE [dbo].[sp_create_publication_dialog]
	@article_name nvarchar(128),
	@publication_name nvarchar(128)
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS(SELECT 1 FROM [publication_dialogs]
			   WHERE [article_name] = @article_name
			     AND [publication_name] = @publication_name) RETURN 0;

	DECLARE @dialog_handle uniqueidentifier;

	--DECLARE @dialog_handle uniqueidentifier;
	--SELECT @dialog_handle = conversation_handle
	--FROM sys.conversation_endpoints AS e
	--INNER JOIN sys.services AS s ON e.service_id = s.service_id
	--INNER JOIN sys.service_contracts AS c ON e.service_contract_id = c.service_contract_id
	--WHERE
	--e.is_initiator = 1
	--AND e.state IN ('SO', 'CO')
	--AND c.name = 'contract_name'
	--AND s.name = 'publication_service'
	--AND e.far_service = 'publication_service'
	--AND e.far_broker_instance = 'CURRENT DATABASE UUID';

	DECLARE @sql AS nvarchar(1024) = N'
	BEGIN DIALOG @handle_out
	FROM SERVICE [publication_service]
	  TO SERVICE ''publication_service'', ''CURRENT DATABASE''
	 ON CONTRACT [' + @publication_name + N'] WITH ENCRYPTION = OFF;';
	
	EXECUTE sp_executesql @sql, N'@handle_out uniqueidentifier OUTPUT', @handle_out = @dialog_handle OUTPUT;

	INSERT [publication_dialogs] ([article_name], [publication_name], [dialog_handle])
	VALUES (@article_name, @publication_name, @dialog_handle);

END;