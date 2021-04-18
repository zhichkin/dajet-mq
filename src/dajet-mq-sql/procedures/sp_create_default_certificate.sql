CREATE PROCEDURE [dbo].[sp_create_default_certificate]
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @certificate_name AS nvarchar(128) = (SELECT [dbo].[fn_default_certificate_name]());
    IF NOT EXISTS(SELECT 1 FROM sys.certificates WHERE [name] = @certificate_name)
    BEGIN
        DECLARE @user_name AS NVARCHAR (128) = (SELECT [dbo].[fn_default_user_name]());
        EXECUTE ('CREATE CERTIFICATE [' + @certificate_name + '] AUTHORIZATION [' + @user_name + ']
                  WITH SUBJECT = ''Default service broker user certificate'',
                  START_DATE = ''20210101'',
                  EXPIRY_DATE = ''20310101'';');
    END;
END;