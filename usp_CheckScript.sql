CREATE TABLE [dbo].[CheckScript](
	[objectname] [nvarchar](128) NULL,
	[text] [nvarchar](4000) NULL,
	[createdtm] [datetime] DEFAULT GETDATE()
)
GO

CREATE PROCEDURE [dbo].[sp_CheckScript] AS 

SET NOCOUNT ON

;WITH t1 AS (
	SELECT CONCAT(s.name,'.', o.name) AS objectname	
	FROM sys.objects o
	INNER JOIN sys.schemas s
	ON o.schema_id = s.schema_id
	WHERE type IN ('V', 'P')		-- V: View; P: Procedure
)
SELECT *,ROW_NUMBER() OVER (ORDER BY objectname) AS RowNo
INTO #object
FROM t1;

CREATE TABLE #script (
	objectname nvarchar(128),
	text nvarchar(4000)
);

DECLARE @objectname nvarchar(128) = '';
DECLARE @maxloop int = (SELECT max(RowNo) FROM #object);
DECLARE @i int = 1;
WHILE (@i <= @maxloop)
BEGIN 
	--PRINT @i
	SET @objectname = (SELECT objectname from #object WHERE RowNo = @i)
	INSERT INTO #script (Text)
	EXEC sp_helptext @objectname
	
	UPDATE #script
	SET objectname = @objectname
	WHERE objectname IS NULL

	SET @i = @i + 1
END;

TRUNCATE TABLE dbo.CheckScript;
INSERT INTO dbo.CheckScript(objectname, text)
SELECT objectname, text
FROM #script;

SELECT 'SELECT * FROM dbo.CheckScript WHERE Text LIKE ''%%'''

GO