CREATE FUNCTION [dbo].[fn_default_certificate_data]()
RETURNS nvarchar(4000)
AS
BEGIN
    DECLARE @certificate_name AS nvarchar(128) = [dbo].[fn_default_certificate_name]();
    DECLARE @certificate_data AS nvarchar(4000);
    SELECT @certificate_data = CONVERT(nvarchar(4000), CERTENCODED(certificate_id), 1)
    FROM sys.certificates
    WHERE [name] = @certificate_name;
    RETURN @certificate_data;
END;