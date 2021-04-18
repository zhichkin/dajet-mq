CREATE PROCEDURE [dbo].[sp_create_remote_user]
    @remote_user_name nvarchar(128),
    @remote_certificate_name nvarchar(128),
    @remote_certificate_data nvarchar(max)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF (@remote_user_name IS NULL) THROW 50001, N'Invalid remote user name.', 1;
    IF (@remote_certificate_name IS NULL) THROW 50002, N'Invalid remote certificate name.', 1;
    IF (@remote_certificate_data IS NULL) THROW 50003, N'Invalid remote certificate data.', 1;

    IF NOT EXISTS(SELECT 1 FROM sys.database_principals WHERE [name] = @remote_user_name)
    BEGIN
        EXECUTE(N'CREATE USER [' + @remote_user_name + N'] WITHOUT LOGIN;');
    END;

    IF NOT EXISTS(SELECT 1 FROM sys.certificates WHERE [name] = @remote_certificate_name)
    BEGIN
        EXECUTE(N'CREATE CERTIFICATE [' + @remote_certificate_name + N']
                  AUTHORIZATION [' + @remote_user_name + N']
                  FROM BINARY = ' + @remote_certificate_data + N';');
    END;
END;