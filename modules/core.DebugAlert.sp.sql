/*
	Debug alert proc
	ALso server as a template for written own alert proc!

	Every alert must be a alert procedure associated with it.
	Alert Platoform will run this proc to give change to the alert run your logic.
	The alert proc will receive following XML data on first parameter (XML type):
		<ap id="AlertID">
			
		</ap>

	It must return in second parameter (XML OUTPUT) following structure

		<ap>
			<output>
				<description>Alert state description</description>
				<html>HTML output to be sent to the output</html>
				<data>Custom XML data specific</data>
			</output>
		</ap>

	Also, you must return 0 (indicating CLEAR, that its, no problem) or
	1, indicating ALERT.
*/
ALTER PROCEDURE core.DebugAlert (
	 @Params XML
	 ,@Output XML OUTPUT
)
AS
	DECLARE
		@AlertID int
		,@OutputHtml nvarchar(max)
		,@SampleResult int = CONVERT(int,RAND()*1000)%2

	-- @Data will contains a XML with useful input data
	-- The principal data is alertID!
	SELECT 
		@AlertID = @Params.value('ap[1]/@id','int')

	-- Prepare output data!

	-- You can use @AlertID in some query to get more data about the alert!
	SET @OutputHtml = (
		SELECT
			A.AlertID			as 'td'
			,A.AlertName		as 'td'
			,A.ProcedureName	as 'td'
		FROM
			dbo.Alerts A
		WHERE
			A.AlertID = @AlertID
		FOR XML RAW('tr'),ROOT('table'),ELEMENTS
	)

	-- You can build OUTPUT XML manually using string concanteation!
	-- In this example, we using a more professonal way, using FOR XML!
	SET @Output = (
		SELECT 
			'Debug alert, sample result!'	as 'output/description'
			,@OutputHtml					as 'output/html'
			,@Params						as 'output/data'
		FOR XML PATH('ap')
	)

	-- This procedure randoms returns 0 or 1.

	-- We must return the status of alet!
	RETURN CONVERT(int,RAND()*1000)%2;