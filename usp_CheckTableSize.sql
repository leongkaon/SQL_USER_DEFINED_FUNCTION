CREATE TABLE [dbo].[CheckTableSize](
	[object_id] [int] NOT NULL,
	[schema_name] [sysname] NOT NULL,
	[table_name] [sysname] NOT NULL,
	[type] [char](2) NULL,
	[type_desc] [nvarchar](60) NULL,
	[rows] [bigint] NULL,
	[used_mb] [float] NULL,
	[create_dtm] [datetime] DEFAULT GETDATE(),
 CONSTRAINT [PK_CheckTableSize] PRIMARY KEY CLUSTERED 
(
	[object_id] ASC,
	[create_dtm] DESC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE PROCEDURE [dbo].[usp_CheckTableSize] AS

INSERT INTO dbo.CheckTableSize (object_id, schema_name, table_name, type, type_desc, rows, used_mb)
SELECT	o.object_id,   
		s.name AS schema_name,   
		o.name AS table_name,   
		o.type,  
		o.type_desc,  
		p.rows,  
		CAST(ROUND((SUM(a.used_pages) * 8.00 / 1024.00), 2) AS NUMERIC(36, 2)) AS used_mb				--+ added on 2022-12-15
FROM sys.objects o  
INNER JOIN sys.schemas s  ON o.schema_id = s.schema_id  
INNER JOIN sys.indexes i ON o.object_id = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE o.type = 'U'  
GROUP BY o.object_id, s.name, o.name, o.type, o.type_desc, p.rows