CREATE FUNCTION [dbo].[fn_has_updated_columns]
(
	@columns_updated varbinary(128)
)
RETURNS bit
AS
BEGIN
	
	DECLARE @changed bit = 0x00;
	
	DECLARE @chunk_number int = 0;
	DECLARE @chunks_count int = LEN(@columns_updated);
		
	WHILE (@chunk_number < @chunks_count)
	BEGIN
		SET @chunk_number = @chunk_number + 1;
		IF (SUBSTRING(@columns_updated, @chunk_number, 1) & 255 > 0)
		BEGIN
			SET @changed = 0x01;
			BREAK;
		END;
	END;

	RETURN @changed;
END;