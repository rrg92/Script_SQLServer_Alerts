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
					,('Language',NULL,'Default language in all text','en-us')
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
					,Enabled			bit DEFAULT 0
					,AlertOnly			bit DEFAULT 0
			)

		-- Load default configurations
		INSERT INTO dbo.Alerts(AlertName,ProcedureName,Frequency,Description)
		SELECT 
			*
		FROM
			(
				VALUES 
					('DebugAlert','core.DebugAlert',NULL,'Debugging alert')
			) N(Name,ProcName,Freq,Description)
		WHERE NOT EXISTS (
			SELECT * FROM dbo.Alerts A WHERE A.AlertName = N.Name
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

		/*
			Alert logging!
		*/
		IF OBJECT_ID('dbo.StringText') IS NULL
				CREATE TABLE dbo.StringText (
						 StringID	varchar(100)
						,Lang		varchar(10)
						,StringText		nvarchar(3000)
				)

		-- Load default configurations
		INSERT INTO dbo.StringText(StringID,Lang,StringText)
		SELECT 
			*
		FROM
			(
				VALUES 
					 ('ALERT','en-us','ALERT: %s')
					,('CLEAR','en-us','CLEAR')
					,('SERVER','en-us','SERVER')
			) N(StringID,Lang,StringText)
		WHERE NOT EXISTS (
			SELECT * FROM dbo.StringText S WHERE S.StringID = N.StringID
			)


	COMMIT;
		