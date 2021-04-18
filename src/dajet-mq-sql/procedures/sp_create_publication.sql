CREATE PROCEDURE [dbo].[sp_create_publication]
	@name nvarchar(128)
AS
BEGIN

	INSERT [dajet_publications] ([name]) OUTPUT inserted.[id] VALUES (@name);

END;