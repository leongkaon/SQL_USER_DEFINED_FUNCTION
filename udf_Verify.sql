CREATE FUNCTION [dbo].[udf_Verify] (
	@table_name VARCHAR(128)
)
RETURNS NVARCHAR(MAX) AS
BEGIN
	DECLARE @result NVARCHAR(MAX);

	DECLARE @database_name VARCHAR(20) = PARSENAME(@table_name, 3);
	IF @database_name IS NOT NULL RETURN 'Error: This function only support 2 parts object name'

	DECLARE @schema VARCHAR(20) = PARSENAME(@table_name, 2);
	IF @schema IS NULL SET @schema = 'dbo';
	DECLARE @table_name VARCHAR(128) = PARSENAME(@table_name, 1);

	DECLARE @column_agg NVARCHAR(MAX) = (
			SELECT STRING_AGG(COLUMN_NAME, ', ')
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE TABLE_SCHEMA = @schema
			AND TABLE_NAME = @table_name
			AND COLUMN_NAME != 'dss_update_time'
	);

	SET @result = 'SELECT COUNT(*) FROM ' + @schema + '.' + @table_name + ' WITH (NOLOCK)' + ';' + CHAR(10)
				+ 'SELECT COUNT(*) FROM ' + '' + ';' + CHAR(10)
				+ CHAR(10)
				+ 'SELECT ' + @column_agg + CHAR(10)
				+ 'FROM '
				+ @schema + '.' + @table_name + ' WITH (NOLOCK)' + CHAR(10)
				+ 'EXCEPT' + CHAR(10)
				+ 'SELECT ' + @column_agg + CHAR(10)
				+ 'FROM '
				+ ';' + CHAR(10)
				+ CHAR(10)
				+ 'SELECT ' + @column_agg + CHAR(10)
				+ 'FROM '
				+ CHAR(10)
				+ 'EXCEPT' + CHAR(10)
				+ 'SELECT ' + @column_agg + CHAR(10)
				+ 'FROM '
				+ @schema + '.' + @table_name + ' WITH (NOLOCK)' + ';' + CHAR(10)
	RETURN @result;