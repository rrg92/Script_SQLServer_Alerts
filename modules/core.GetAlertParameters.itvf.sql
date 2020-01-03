/*
	Get effective values for parameters of a alert!
	Columns:
		name	- The name of parameter
		value	- The value of parameter
		source	- source of parameter vaue. 
					Can be: 
						ALERT, when source comes from AlertParameter table!
						GLOBAL, when value comes from gllobal value set
						GLOBAL_DEFAULT, when value comes from global default
						
*/
ALTER FUNCTION core.GetAlertParameters (
	 @AlertID int = NULL
	,@AlertName varchar(100) = NULL
)
RETURNS TABLE
AS
RETURN (

	SELECT
		 name	= ISNULL(AP.paramName,GP.Name)
		,value	= COALESCE(AP.paramValue,GP.EffectiveValue)
		,source	= CASE
					WHEN AP.paramValue IS NOT NULL THEN 'ALERT'
					WHEN AP.paramName IS NOT NULL AND GP.Name IS NULL THEN 'ALERT'
					WHEN GP.Value IS NOT NULL THEN 'GLOBAL'
					ELSE 'GLOBAL_DEFAULT'
				  END
	FROM
		(
			SELECT
				AP.paramName
				,AP.paramValue
			FROM
				dbo.AlertParameter AP
			WHERE
				AP.AlertID = ISNULL(
								@AlertID
								,(SELECT
									A.AlertID
								FROM
									dbo.Alerts A 
								WHERE 
									A.AlertName = @AlertName
								)
				)
		) AP
		FULL JOIN
		core.Params GP
			ON GP.Name = AP.paramName
)