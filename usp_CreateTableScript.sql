CREATE TABLE [dbo].[CreateTableScript](
	[check_id] [int] IDENTITY(1,1) PRIMARY KEY,
	[object_id] [varchar](20) NOT NULL,
	[table_name] [varchar](128) NOT NULL,
	[definition] [nvarchar](max) NULL,
	[create_dtm] [datetime] DEFAULT GETDATE(),
) 
GO


CREATE PROCEDURE [dbo].[sp_CreateTableScript] AS 

SET NOCOUNT ON
--============================================================================================================================
/*This procedure is for simply generate CREATE TABLE script, incase accidentally drop table and for emergency use*/
--============================================================================================================================
/*
version: 1.0

Not consider yet or to be done in the ultimate future:
* PRIMARY KEY
* FOREIGN KEY
* CHECK CONSTRAINT
* IDENTITY
* INDEX
* TRIGGER
* data type precision (float, numeric, decimal, datetime2)
*/
--============================================================================================================================

/*First, find the column information similar to INFORMATION_SCHEMA.COLUMNS*/
DROP TABLE IF EXISTS #column_info;
SELECT o.object_id, SCHEMA_NAME(o.schema_id) AS schema_name, o.name AS object_name, 
	o.type, o.create_date, o.modify_date,
	c.name AS column_name, c.column_id, 
	IIF(c.is_nullable = 1, 'NULL', 'NOT NULL') AS is_nullable,
	('DEFAULT ' + OBJECT_DEFINITION(c.default_object_id)) AS column_default,
	t.name AS data_type,
	CONVERT(varchar, COLUMNPROPERTY(c.object_id, c.name, 'charmaxlen'))	AS character_maximum_length
INTO #column_info
FROM sys.objects o
INNER JOIN sys.columns c
ON o.object_id = c.object_id
LEFT JOIN sys.types t
ON c.user_type_id = t.user_type_id
WHERE o.type = 'U';

/*Second, Get RowNumber for WHILE LOOP*/
DROP TABLE IF EXISTS #i
;WITH x AS (
	SELECT DISTINCT object_id FROM #column_info
) 
SELECT *, ROW_NUMBER() OVER (ORDER BY object_id) AS RowNo 
INTO #i
FROM x ORDER BY RowNo;

DROP TABLE IF EXISTS #column_info2
SELECT a.*, #i.RowNo
INTO #column_info2
FROM #column_info a
LEFT JOIN #i
ON a.object_id = #i.object_id;

/*Third, prepare WHILE LOOP parameters*/
DECLARE @i int = 1;
DECLARE @maxi int = (SELECT MAX(RowNo) FROM #i)
DECLARE @column_list nvarchar(4000);
DECLARE @object_id varchar(20);
DECLARE @table_name varchar(128);

WHILE (@i <= @maxi)				-- Start WHILE LOOP
BEGIN

	SET @object_id = (SELECT TOP 1 object_id FROM #column_info2 WHERE RowNo = @i);
	SET @table_name = (SELECT TOP 1 CONCAT(schema_name,'.',object_name) FROM #column_info2 WHERE RowNo = @i);
	PRINT CONCAT(@i, '; ', @object_id, '; ', @table_name, '; ')

	;WITH c0 AS (
		SELECT ('[' + column_name + '] ' + data_type
				+ (IIF(character_maximum_length IS NULL, ISNULL(character_maximum_length,' '), CONCAT('(', character_maximum_length, ') ')))
				+ ISNULL(column_default, is_nullable)
				) AS column_list
		FROM #column_info2
		WHERE RowNo = @i
	)
	SELECT @column_list = STRING_AGG(CONCAT(CHAR(9), column_list), CONCAT(',', CHAR(13)))				-- CHAR(9): </t>; CHAR(13): </n>
	FROM c0;
	
	INSERT INTO dbo.CreateTableScript (object_id, table_name, definition)
	SELECT 
		OBJECT_ID(@table_name)			AS object_id,
		@table_name						AS table_name, 
		(SELECT 'CREATE TABLE ' + @table_name + ' (' + CHAR(13)
		+ @column_list + CHAR(13)
		+ ')')							AS definition;

	SET @i = @i + 1;

END

GO
