/*
	Creates a new alert!
*/
ALTER PROCEDURE core.SetAlert (
	 @Name varchar(100)
	,@Procedure sysname
	,@Frequency varchar(100)
	,@Description nvarchar(2000)
	,@Update bit = 0 
)
AS
	DECLARE
		@RowCount int = 0;

	SET  XACT_ABORT ON;
	BEGIN TRAN;

		UPDATE 
			dbo.Alerts
		SET
			 ProcedureName	= @Procedure
			,Frequency		= @Frequency
			,Description	= @Description
		WHERE
			AlertName = @Name 

		SET @RowCount = @@ROWCOUNT;

		IF @RowCount = 0
		BEGIN
			INSERT dbo.Alerts (AlertName,ProcedureName,Frequency,Description)
			VALUES (@Name,@Procedure,@Frequency,@Description)
			COMMIT;
		END ELSE
			IF @Update = 0
			BEGIN
				RAISERROR('Alert %s already exists. If want update existing, use @Update = 1 paramter.',17,1,@Name);
				ROLLBACK;
				RETURN;
			END ELSE 
				COMMIT;

