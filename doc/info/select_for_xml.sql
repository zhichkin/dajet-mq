/****** Script for SelectTopNRows command from SSMS  ******/
USE [dajet_agent];
GO

DECLARE @message xml;
SELECT @message =
(
	SELECT
		CAST(CAST(REVERSE(SUBSTRING([_IDRRef], 9, 8)) AS varbinary(8)) + SUBSTRING([_IDRRef], 1, 8) AS uniqueidentifier) AS [Ссылка],
		CAST([_IDRRef] AS uniqueidentifier) AS [Ссылка2],
		[_Version] AS [ВерсияДанных],
		CAST([_Marked] AS bit) AS [ПометкаУдаления],
		[_Code] AS [Код],
		[_Description] AS [Наименование]
	FROM
		[_Reference79]
	FOR XML RAW(N'Row'), ROOT(N'Справочник.Номенклатура'), TYPE, BINARY BASE64
);
SELECT @message;