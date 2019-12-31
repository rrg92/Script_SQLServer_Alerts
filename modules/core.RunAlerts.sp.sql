/*
	Main alert procedure core!
	This get alerts and run it.
	TODO:
		- Alert last run!
*/
ALTER PROCEDURE core.RunAlerts(
	@SleepInterval varchar(15) = NULL
	,@Debug bit = 0
)
AS
	-- Iterate over alert list and run it!
	DECLARE
		@NextAlertNum bigint = 0
		,@RowCount int = 0
		,@AlertID	int
		,@AlertName varchar(200)
		,@AlertProc sysname
		,@AlertFreq varchar(100)
		,@AlertLastRun varchar(100)
		,@AlertLastResult int

		,@AlertFreqSec int

		,@TmpQuery nvarchar(2000)
		,@TmpString nvarchar(max)
		,@AlertResult int
		,@AlertOutput nvarchar(max)
		,@ErrorXML nvarchar(max)
	;

	WHILE 1 = 1
	BEGIN
		SET @NextAlertNum = 0;

		WHILE 1 = 1
		BEGIN
			SET @NextAlertNum += 1;
			SET @AlertID		= NULL
			SET @AlertProc		= NULL
			SET @AlertResult	= NULL

			-- Get next Alert!
			SELECT TOP 1 
				@AlertID	= A.AlertID
				,@AlertName	= A.AlertName
				,@AlertProc	= A.ProcedureName
				,@AlertFreq = A.Frequency
			FROM
				dbo.Alerts A WHERE AlertID >= @NextAlertNum ORDER BY AlertID;

			-- No more alerts, end loop!
			IF @AlertID IS NULL BREAK;

			-- Setting up alert configuration information!
				SET @AlertFreqSec = CONVERT(int,@AlertFreq)

			-- Get execution information!
			SELECT 
				@AlertLastRun = AEC.LastRun
				,@AlertLastResult = AEC.LastResult
			FROM 
				core.AlertExecutionControl AEC
			WHERE
				AEC.AlertID = @AlertID

			-- If alert nevers runs, then insert a entry to it on AlertExecutionControl table!
			IF @AlertLastRun IS NULL
			BEGIN

				SET @AlertLastRun = GETDATE()
				INSERT INTO core.AlertExecutionControl(AlertID,LastRun) VALUES(@AlertID,@AlertLastRun)
			
			END ELSE
				-- If last run not expired... 
				IF DATEDIFF(SS,@AlertLastRun,GETDATE()) <= @AlertFreqSec
				BEGIN
					IF @Debug = 1 RAISERROR('Skiping execution of alert %s because frequency. LastRun: %s , FreqSec: %s',0,1,@AlertName,@AlertLastRun,@AlertFreqSec)
					CONTINUE;
				END

			-- Time to Execute the Alert procedure!!!

				--	First, update the last run timestamp!
				UPDATE core.AlertExecutionControl SET LastRun = GETDATE() WHERE AlertID = @AlertID;
				
				BEGIN TRY
					-- Now, let procedure take control over the execution!!!!!
					EXEC @AlertResult = @AlertProc @AlertOutput OUTPUT
				END TRY
				BEGIN CATCH
					-- If some error ocurred, store in out control table...
					SET @ErrorXML = (
							SELECT
									 Number			= ERROR_NUMBER()
									,Message		= ERROR_MESSAGE()
									,ProcedureName	= ERROR_PROCEDURE()
									,Timestamp		= CURRENT_TIMESTAMP
									,ErrorLine		= ERROR_LINE()
							FOR XML RAW('error'),ELEMENTS
					)

					-- update the control table with the error data!
					UPDATE 
						core.AlertExecutionControl
					SET
						LastError = @ErrorXML
					WHERE
						AlertID = @AlertID;

					CONTINUE;
				END CATCH

			-- Lets do some logging, if debug enabled!
			IF @Debug = 1
			BEGIN
				SET @TmpString = 'Alert '+ISNULL(@AlertName,'?')+' run successfuly. Proc = '+ISNULL(@AlertProc,'?')+' Result = '+ISNULL(CONVERT(varchar,@AlertResult),'?')
						+CHAR(13)+CHAR(10)+'Last Result:'+ISNULL(CONVERT(varchar,@AlertLastResult),'?')
						+CHAR(13)+CHAR(10)+'Output:'
						+CHAR(13)+CHAR(10)+ISNULL(@AlertOutput,'-- NULL OUTPUT --')
				RAISERROR(@TmpString,0,1) WITH NOWAIT;
			END



			-- No alert exists, and procedure resulted in a alert!
			IF ISNULL(@AlertLastResult,0) = 0 AND @AlertResult = 1
			BEGIN
				UPDATE core.AlertExecutionControl
				SET LastResult = @AlertResult,LastResultChange = GETDATE()
				WHERE AlertID = @AlertID
			END

			-- Alert triggered, and was cleared!
			IF @AlertLastResult = 1 AND @AlertResult = 0
			BEGIN
				UPDATE core.AlertExecutionControl
				SET LastResult = @AlertResult,LastResultChange = GETDATE()
				WHERE AlertID = @AlertID
			END




		END

		-- Sleep or ends loop!
		IF @SleepInterval IS NULL
			BREAK;
		ELSE BEGIN
			WAITFOR DELAY @SleepInterval	

			IF @@ERROR != 0 BREAK;
		END
	END




	


