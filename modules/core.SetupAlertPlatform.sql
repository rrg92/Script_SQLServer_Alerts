/*
	Contains a list of all supported alert procedures!
*/
ALTER PROCEDURE core.SetupAlertPlatform
AS
	SET XACT_ABORT ON;
	
	BEGIN TRAN;
		IF OBJECT_ID('core.Params') IS NULL
			CREATE TABLE core.Params (
					 Name				varchar(200) UNIQUE
					,Value				nvarchar(1000)
					,Description		nvarchar(2000)
					,DefaultValue		nvarchar(1000)
					,EffectiveValue		AS ISNULL(Value,DefaultValue)
			)
	
		-- Load default configurations
		INSERT INTO core.Params 
		SELECT 
			*
		FROM
			(
				VALUES 
					('AlertEmail',NULL,'Default email address to send alerts',NULL)
					,('MailProfile',NULL,'Default database mail profile to send email',NULL)
					,('OutputProc',NULL,'Output procedure to use when handling alerts','core.DefaultOutput')
			) N(Name,Value,Description,DefaultValue)
		WHERE NOT EXISTS (
			SELECT * FROM core.Params P WHERE P.Name = N.Name
		)	


		/*
			Contains all alerts!
				TODO:
					Optional clear
					Parallel mode (job).
					Strings.

		*/
		IF OBJECT_ID('dbo.Alerts') IS NULL
			CREATE TABLE dbo.Alerts (
					 AlertID			int IDENTITY NOT NULL PRIMARY KEY
					,AlertName			varchar(100)
					,ProcedureName		sysname
					,Frequency			varchar(100)
					,Description		nvarchar(2000)
			)

			
		/*
			Define all custom parameters for alerts!
		*/
		IF OBJECT_ID('dbo.AlertParameter') IS NULL
				CREATE TABLE dbo.AlertParameter  (
						 AlertID	int NOT NULL
						,paramName	varchar(200)
						,paramValue	nvarchar(1000)
						,paramDescription	nvarchar(2000)
				)

		
		/*
			Alert execution control!!
		*/
		IF OBJECT_ID('core.AlertExecutionControl') IS NULL
			CREATE TABLE core.AlertExecutionControl (
					 AlertID		int NOT NULL
					,LastRun		datetime NOT NULL
					,LastError		nvarchar(max)
					,LastResult		int
					,LastResultChange datetime
			)

		/*
			Alert logging!
		*/
		IF OBJECT_ID('core.AlertResultLog') IS NULL
				CREATE TABLE core.AlertResultLog (
						 LogDate		datetime NOT NULL
						,AlertID		int NOT NULL
						,AlertResult	int NOT NULL
						,SummaryText	nvarchar(1000)
				)

		/*
			Alert logging!
		*/
		IF OBJECT_ID('core.DebugOutput') IS NULL
				CREATE TABLE core.DebugOutput (
						 InsertDate		datetime NOT NULL
						,AlertID		int not NULL
						,Result			int
						,ProcOutput		nvarchar(max)
				)


	COMMIT;
		