/*can be improve: use PARSENAME()*/

CREATE FUNCTION [dbo].[udf_tDistinct] (
	@schema VARCHAR(10) = 'dbo', 
	@table_name varchar(128)
)
RETURNS @result TABLE (
		statement varchar(max)
	) AS
BEGIN
	DECLARE @tmp TABLE (
		COLUMN_NAME nvarchar(max),
		RowNo int
	);
	INSERT INTO @tmp
	SELECT COLUMN_NAME, ROW_NUMBER() OVER (ORDER BY ORDINAL_POSITION) as RowNo
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_SCHEMA = @schema
		AND TABLE_NAME = @table_name
		AND DATA_TYPE IN ('nvarchar','varchar','char');
	
	IF NOT EXISTS (SELECT * FROM @tmp) BEGIN RETURN; END;
	
	DECLARE @i int = 1
	DECLARE @statement nvarchar(max)
	
	WHILE @i <= (SELECT MAX(RowNo) FROM @tmp)
		BEGIN
			SET @statement = CONCAT('SELECT DISTINCT ', 
									(SELECT COLUMN_NAME FROM @tmp WHERE RowNo = @i), 
									' FROM ',
									CONCAT(@schema, '.', @table_name),
									' ORDER BY ',
									(SELECT COLUMN_NAME FROM @tmp WHERE RowNo = @i), 
									';')
			INSERT INTO @result VALUES (@statement)
			SET @i = @i + 1	
		END
	RETURN;
END;