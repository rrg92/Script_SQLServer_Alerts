/*
	Set paramter for a alet!
*/
ALTER PROCEDURE core.SetAlertParameter (
	@AlertName varchar(100)
	,@ParamName varchar(200)
	,@ParamValue nvarchar(1000)
	,@ParamDescription nvarchar(2000) = NULL
)
AS

	-- Get the AletID!
	DECLARE @AlertID int;

	SELECT @AlertID = AlertID FROM dbo.Alerts WHERE AlertName = @AlertName;

	IF @AlertID IS NULL
	BEGIN
		RAISERROR('Invalid alert %s',16,1,@AlertName);
		RETURN;
	END

	
	UPDATE
		dbo.AlertParameter
	SET
		paramValue			= @ParamValue
		,paramDescription	= ISNULL(@ParamDescription,paramDescription)
	WHERE
		paramName = @ParamName
		AND	
		AlertID	 = @AlertID

	IF @@ROWCOUNT = 0
		INSERT INTO 
			dbo.AlertParameter (AlertID,paramName,paramValue,paramDescription)
		VALUES
			(@AlertID,@ParamName,@ParamValue,@ParamDescription)