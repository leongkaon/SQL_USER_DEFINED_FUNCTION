CREATE FUNCTION dbo.udf_CharIndex (
  @TargetString nvarchar(100),
  @SearchedString nvarchar(4000),
  @Occurrence int
)
RETURNS int
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
  
  /*example:*/
  -- SELECT dbo.udf_CharIndex('a','abbabba',0)
  -- SELECT dbo.udf_CharIndex('a','abbabba',1)
  -- SELECT dbo.udf_CharIndex('a','abbabba',2)
  -- SELECT dbo.udf_CharIndex('a','abbabba',3)
  -- SELECT dbo.udf_CharIndex('a','abbabba',4)
  -- SELECT dbo.udf_CharIndex('a','abbabba',5)
  
END
