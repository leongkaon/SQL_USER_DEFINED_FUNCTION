/*https://begincodingnow.com/sql-server-find-the-nth-occurrence-of-a-character-in-a-string/*/
CREATE FUNCTION [dbo].[udf_CharIndex] (
	@TargetString nvarchar(100),
	@SearchedString nvarchar(4000),
	@Occurrence int
)
RETURNS int
AS  
BEGIN
	DECLARE @pos int, @counter int, @ret int
	SET @pos = CHARINDEX(@TargetString, @SearchedString)
	SET @counter = 1

	IF @Occurrence = 1 SET @ret = @pos

	ELSE 
	BEGIN 
		WHILE (@counter < @Occurrence)
		BEGIN 
			SELECT @ret = CHARINDEX(@TargetString, @SearchedString, @pos + 1)
			SET @counter = @counter + 1
			SET @pos = @ret
			IF @pos = 0 BREAK
		END
	END
	RETURN(@ret)

	/*Example*/
	--SELECT dbo.udf_CharIndex('a','abbabba',0)	--NULL
	--SELECT dbo.udf_CharIndex('a','abbabba',1)	--1
	--SELECT dbo.udf_CharIndex('a','abbabba',2)	--4
	--SELECT dbo.udf_CharIndex('a','abbabba',3)	--7
	--SELECT dbo.udf_CharIndex('a','abbabba',4)	--0
	--SELECT dbo.udf_CharIndex('a','abbabba',5)	--0
	--SELECT dbo.udf_CharIndex('b','abbabba',2)	--3
	--SELECT dbo.udf_CharIndex('bb','abbabba',2)	--5
	--SELECT dbo.udf_CharIndex('c','abbabba',1)	--0


END 