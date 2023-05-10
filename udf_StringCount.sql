CREATE FUNCTION [dbo].[udf_StringCount] (
	@string nvarchar(4000),	
	@delimiter nvarchar(10)
)
RETURNS int AS 
BEGIN
	DECLARE @result int = (SELECT CONVERT(float,(LEN(@string) - LEN(REPLACE(@string, @delimiter, '')))) / CONVERT(float,LEN(@delimiter)))

RETURN @result

/*example*/
--SELECT dbo.udf_StringCount('a;bb;ccc',';')
--SELECT dbo.udf_StringCount('a;bb;ccc','c')
--SELECT dbo.udf_StringCount('a;bb;ccc','cc')
--SELECT dbo.udf_StringCount('a;bb;ccc','ccc')
--SELECT dbo.udf_StringCount('a;bb;ccc','cccc')

END