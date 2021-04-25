CREATE SCHEMA [dajet];
GO

IF NOT EXISTS(SELECT 1 FROM sys.schemas WHERE [name] = 'dajet')
BEGIN
	EXECUTE('CREATE SCHEMA [dajet];');
END;
GO