CREATE FUNCTION [dbo].[udf_StringSplit] (
	@SearchedString nvarchar(4000),	
	@Split nvarchar(100),
	@Position int
)
RETURNS nvarchar(4000)
AS 
BEGIN
	DECLARE @result nvarchar(4000)
	
	/*@Split not in @SearchedString*/
	IF CHARINDEX(@Split, @SearchedString) = 0 
		BEGIN 
			SET @result = @SearchedString
			RETURN @result
		END
	
	/*@Split in @SearchedString but not in N-1 th occurrence*/
	IF (dbo.udf_CharIndex(@Split, @SearchedString, @Position-1) = 0)
		BEGIN
			SET @result = ''
			RETURN @result
		END

	IF @Position = 1
	BEGIN
		SET @result = SUBSTRING(
			@SearchedString, 
			1, 
			CASE WHEN CHARINDEX(@Split, @SearchedString) - 1 > 0
				 THEN CHARINDEX(@Split, @SearchedString) - 1
			ELSE LEN(@SearchedString) END
		)
	END
	ELSE IF @Position > 1
	BEGIN
		SET @result = SUBSTRING(
			@SearchedString, 
			dbo.udf_CharIndex(@Split, @SearchedString, @Position - 1) + LEN(@Split), 
			CASE WHEN dbo.udf_CharIndex(@Split, @SearchedString, @Position) - dbo.udf_CharIndex(@Split, @SearchedString, @Position - 1) - LEN(@Split) > 0 
				 THEN dbo.udf_CharIndex(@Split, @SearchedString, @Position) - dbo.udf_CharIndex(@Split, @SearchedString, @Position - 1) - LEN(@Split) 
			ELSE 0 END
		)
	END

	IF @result = '' 
	BEGIN
		SET @result = SUBSTRING(
			@SearchedString,
			dbo.udf_CharIndex(@Split, @SearchedString, @Position - 1) + LEN(@Split),
			LEN(@SearchedString) - dbo.udf_CharIndex(@Split, @SearchedString, @Position - 1)
		)
	END

	RETURN @result


	/*Example*/
	--SELECT dbo.udf_StringSplit('a;bb;ccc',';',-1)	-- NULL
	--SELECT dbo.udf_StringSplit('a;bb;ccc',';',0)		-- NULL
	--SELECT dbo.udf_StringSplit('a;bb;ccc',';',1)		-- a
	--SELECT dbo.udf_StringSplit('a;bb;ccc',';',2)		-- bb
	--SELECT dbo.udf_StringSplit('a;bb;ccc',';',3)		-- ccc
	--SELECT dbo.udf_StringSplit('a;bb;ccc',';',4)		-- ''
													
	--SELECT dbo.udf_StringSplit('a;bb;ccc',',',1)		-- a;bb;ccc
	--SELECT dbo.udf_StringSplit('a,bb;ccc',',',1)		-- a

	--SELECT dbo.udf_StringSplit('a;bb;ccc;;',';',4)	-- ; ,it is bug, should be return '' , hasn't fixed

END