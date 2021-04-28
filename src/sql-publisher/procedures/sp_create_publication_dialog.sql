CREATE PROCEDURE [dbo].[sp_create_publication_dialog]
	@article_id int,
	@publication_id int
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS(SELECT 1 FROM [publication_article_usages] WHERE [article_id] = @article_id AND [publication_id] = @publication_id) RETURN 0;

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
	 ON CONTRACT [DEFAULT] WITH ENCRYPTION = OFF;';
	
	EXECUTE sp_executesql @sql, N'@handle_out uniqueidentifier OUTPUT', @handle_out = @dialog_handle OUTPUT;

	INSERT [publication_article_usages] ([article_id], [publication_id], [dialog_handle])
	VALUES (@article_id, @publication_id, @dialog_handle);

END;