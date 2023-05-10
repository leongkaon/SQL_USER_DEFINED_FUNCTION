CREATE TABLE [dbo].[ObjectChangeLog](
	[object_id] [int] NOT NULL,
	[schema_name] [sysname] NOT NULL,
	[object_name] [sysname] NOT NULL,
	[definition] [nvarchar](max) NULL,
	[type] [char](2) NULL,
	[type_desc] [nvarchar](60) NULL,
	[create_date] [datetime] NOT NULL,
	[modify_date] [datetime] NOT NULL,
	[drop_date_around] [datetime] NULL,
	[create_dtm] [datetime] DEFAULT GETDATE(),
 CONSTRAINT [PK_ObjectChangeLog] PRIMARY KEY CLUSTERED 
(
	[object_id] ASC,
	[modify_date] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


CREATE PROCEDURE [dbo].[usp_ObjectChangeLog] AS

-- system table at this moment
SELECT o.object_id
	  ,o.modify_date
INTO #sys
FROM sys.objects o;

-- known existing table, find the last modify date of each object
SELECT x.object_id,
	   x.modify_date
INTO #exist
FROM dbo.ObjectChangeLog x
INNER JOIN (
	SELECT object_id,
		   MAX(modify_date) as modify_date
	FROM dbo.ObjectChangeLog
	WHERE drop_date_around IS NULL
	GROUP BY object_id
) y
ON x.object_id = y.object_id
	AND x.modify_date = y.modify_date;


-- new or altered table
SELECT object_id 
INTO #new
FROM (
	SELECT * FROM #sys
	EXCEPT
	SELECT * FROM #exist
) new;

-- dropped table
SELECT object_id
INTO #dropped
FROM (
	SELECT object_id FROM #exist
	EXCEPT
	SELECT object_id FROM #sys
) dropped;

-- INSERT new or alter log
IF EXISTS (SELECT * FROM #new)
BEGIN
	INSERT INTO dbo.ObjectChangeLog
	SELECT o.object_id
		  ,s.name AS [schema_name]
		  ,o.name AS [object_name]
		  ,m.definition
		  ,o.type
		  ,o.type_desc
		  ,o.create_date
		  ,o.modify_date
		  ,NULL as drop_date_around
		  ,GETDATE() as create_dtm
	FROM sys.objects o
	INNER JOIN sys.schemas s
	ON o.schema_id = s.schema_id
	LEFT JOIN sys.sql_modules m
	ON o.object_id = m.object_id
	WHERE o.object_id IN (SELECT object_id FROM #new)
END;

-- update column if dropped table
IF EXISTS (SELECT * FROM #dropped)
BEGIN
	UPDATE dbo.ObjectChangeLog
	SET drop_date_around = GETDATE()
	WHERE object_id IN (SELECT * FROM #dropped);
	
	UPDATE dbo.ObjectChangeLog
	SET create_dtm = GETDATE()
	WHERE object_id IN (SELECT * FROM #dropped);
END
