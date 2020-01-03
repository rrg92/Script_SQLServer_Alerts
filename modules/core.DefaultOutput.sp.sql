/*
	Defines the output procedure!

	This define the default output procedure.
	Also, use it as template to write own output procedures!
*/
ALTER PROCEDURE core.DefaultOutput (
	@AlertID int
	,@Result int
	,@Output nvarchar(max)
)
AS
BEGIN

	-- Get the profile!
	DECLARE 
		 @MailProfile	nvarchar(1000)
		,@MailAddr		nvarchar(1000)	
		,@AlertName		varchar(100)
		,@Subject		nvarchar(1000)
	;

	SELECT 
		 @MailProfile	= CASE WHEN name = 'MailProfile' THEN  value ELSE @MailProfile END
		,@MailAddr		= CASE WHEN name = 'AlertEmail' THEN  value ELSE @MailAddr END
	FROM 
		core.GetAlertParameters(@AlertID,NULl)

	SELECT @AlertName = AlertName FROM dbo.Alerts A WHERE A.AlertID = @AlertID;

	SET @Subject = CASE @Result
						WHEN 1 THEN 'ALERT'
						ELSE 'CLEAR'
					END+':['+CONVERT(varchar,@AlertID)+'] '+@AlertName

	EXEC msdb..sp_send_dbmail @MailProfile,@MailAddr,@subject = @Subject, @body = @Output, @body_format = 'HTML';
END
