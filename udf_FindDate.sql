CREATE FUNCTION dbo.udf_FindDate (
  @date date,             -- the date you input
  @interval varchar(30),  -- Year/Quarter/Month/Week
  @end int = 0            -- 0: Start of @interval; 1: End of @interval
)
RETURNS date
AS BEGIN

  DECLARE @result date
  
  IF @interval IN ('year','yyyy','yy')
  BEGIN
    IF @end = 0
    BEGIN
      SET @result = (SELECT DATEADD(YEAR, DATEDIFF(YEAR, 0, @date), 0))
    END
    ELSE IF @end = 1
    BEGIN
      SET @result = (SELECT DATEADD(DAY, -1, DATEADD(YEAR, DATEDIFF(YEAR, 0, @date)+1, 0)))
    END
  END
  ELSE IF @interval IN ('quarter','qq','q')
  BEGIN
    IF @end = 0
    BEGIN
      SET @result = (SELECT DATEADD(QUARTER, DATEDIFF(QUARTER, 0, @date), 0))
    END
    ELSE IF @end = 1
    BEGIN
      SET @result = (SELECT DATEADD(DAY, -1, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, @date)+1, 0)))
    END
  END
  ELSE IF @interval IN ('month','mm','m')
  BEGIN
    IF @end = 0
    BEGIN
      SET @result = (SELECT DATEADD(MONTH, DATEDIFF(MONTH, 0, @date), 0))
    END
    ELSE IF @end = 1
    BEGIN
      SET @result = (SELECT DATEADD(DAY, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, @date)+1, 0)))
    END
  END
  ELSE IF @interval IN ('week','ww','wk')
  BEGIN
    IF @end = 0
    BEGIN
      SET @result = (SELECT DATEADD(WEEK, DATEDIFF(WEEK, 0, @date), 0))
    END
    ELSE IF @end = 1
    BEGIN
      SET @result = (SELECT DATEADD(DAY, -1, DATEADD(WEEK, DATEDIFF(WEEK, 0, @date)+1, 0)))
    END
  END
  
  RETURN @result
  
END

GO
