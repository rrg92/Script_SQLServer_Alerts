/*
	Create the base start structure to the new alert platform!
*/
DECLARE
	@TmpErroMsg nvarchar(max)
	,@LineBreak nchar(2)	
;
SET @LineBreak = NCHAR(13)+NCHAR(10)

-- Check if current database allow host AlertPlatform!
IF NOT EXISTS (
	SELECT *
	FROM sys.extended_properties 
	WHERE class_desc = 'DATABASE'
		and name = 'AllowAlertPlatform'
)
BEGIN
	SET @TmpErroMsg = 'Database '+DB_NAME()+' not allowed host Alert Platform'
		+@LineBreak+'You must add following extended property in order to ack use of it to install Alert Platform.'
		+@LineBreak+'		Extend Property Name: AllowAlertPlatform'
		+@LineBreak+'		Value: 1'
		+@LineBreak+'If you prefer, use following script:'
		+@LineBreak+''
		+@LineBreak+'	EXEC '+DB_NAME()+'..sp_addextendedproperty ''AllowAlertPlatform'',1' 
	RAISERROR(@TmpErroMsg,16,1);
	RETURN;
END


-- At this point, we are in desired database!

/*
	Core schema holds system objects of Alert Platform!
	Nothing in core schema must be changed by the user!
*/
IF SCHEMA_ID('core') IS NULL
	EXEC('CREATE SCHEMA core');

/*
	Util schema contains useful and auxiliary objects to help users.
	User cannot modify anithing inside this schema, but can implement customizations that uses objects in this schema.
*/
IF SCHEMA_ID('util') IS NULL
	EXEC('CREATE SCHEMA util');