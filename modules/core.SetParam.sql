/*
	Change value of a system param!
*/
ALTER PROCEDURE core.SetParam (
	 @Name	varchar(200)
	,@Value nvarchar(1000)
)
AS
	SET NOCOUNT ON;

	UPDATE 
		core.Params
	SET
		Value = @Value
	WHERE
		Name = @Name

	IF @@ROWCOUNT = 0
		PRINT 'Parameter '+@Name+' not exists. Nothing updated.'