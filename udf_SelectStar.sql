CREATE FUNCTION [dbo].[udf_SelectStar] (
	@object_name nvarchar(128)
)
RETURNS nvarchar(4000) 
AS 
BEGIN

	IF (PARSENAME(@object_name, 3) IS NOT NULL)
	BEGIN
		RETURN 'function not accept database name, please use 2 parts name'
	END
	
	DECLARE @schema_name nvarchar(10) = (SELECT ISNULL(PARSENAME(@object_name, 2), 'dbo'))
	DECLARE @table_name nvarchar(128) = (SELECT PARSENAME(@object_name, 1))
	
	DECLARE @column_name nvarchar(4000) = (
		SELECT STRING_AGG(COLUMN_NAME, ', ')
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = @table_name
		AND TABLE_SCHEMA = @schema_name
	)
	
	RETURN CONCAT('SELECT ', @column_name, CHAR(13), 'FROM ', @object_name)

	/*
	Example(1):
		SELECT dbo.udf_SelectStar('dbo.tableA');
	
	Example(2), place in keyboard shortcut:
		EXEC sp_executesql N'SELECT dbo.udf_SelectStar(@object_name)', N'@object_name nvarchar(128)', @object_name = 
	*/
END