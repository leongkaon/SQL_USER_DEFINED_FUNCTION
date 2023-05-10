/*https://stackoverflow.com/questions/16667251/query-to-get-only-numbers-from-a-string*/
Create function [dbo].[udf_GetNumeric]
(
	@strAlphaNumeric VARCHAR(256)
)
RETURNS VARCHAR(256)
AS
BEGIN
	DECLARE @intAlpha INT
	SET @intAlpha = PATINDEX('%[^0-9]%', @strAlphaNumeric)
	BEGIN
		WHILE @intAlpha > 0
		BEGIN 
			SET @strAlphaNumeric = STUFF(@strAlphaNumeric, @intAlpha,1,'')
			SET @intAlpha = PATINDEX('%[^0-9]%', @strAlphaNumeric)
		END
	END
	RETURN ISNULL(@strAlphaNumeric,0)
END
GO