DECLARE @numbers TABLE(number int, bin varbinary);
INSERT @numbers(number, bin)
VALUES (123, 0x00), (456, 0x01), (NULL, 0x02);

SELECT * FROM @numbers;

DECLARE @message xml =
(SELECT
	'delete' AS operation,
	(SELECT
		number AS num,
		bin    AS bin
	FROM @numbers FOR XML RAW('row'), TYPE, BINARY BASE64) AS rows
FOR XML RAW('message'), TYPE);

SELECT @message;

SELECT @message.value('message[1]/@operation', 'char(6)');

INSERT @numbers
SELECT row.value('@num', 'int')       AS [num],
	   row.value('@bin', 'varbinary') AS [bin]
FROM @message.nodes('message/rows/row') AS rows(row);

SELECT * FROM @numbers;