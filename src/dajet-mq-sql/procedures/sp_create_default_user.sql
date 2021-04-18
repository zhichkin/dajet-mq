CREATE PROCEDURE [dbo].[sp_create_default_user]
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @user_name AS nvarchar(128) = (SELECT [dbo].[fn_default_user_name]());
    IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE [name] = @user_name)
    BEGIN
        EXECUTE('CREATE USER [' + @user_name + '] WITHOUT LOGIN;');
    END;
END;