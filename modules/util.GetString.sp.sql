
ALTER PROCEDURE util.GetString (
	@Id		varchar(100)
	,@Text	nvarchar(3000) OUTPUT
	,@Var0	nvarchar(3000)	= ''
	,@Var1	nvarchar(3000)	= ''
	,@Var2	nvarchar(3000)	= ''
	,@Var3	nvarchar(3000)	= ''
	,@Var4	nvarchar(3000)	= ''
	,@Var5	nvarchar(3000)	= ''
	,@Var6	nvarchar(3000)	= ''
	,@Var7	nvarchar(3000)	= ''
	,@Var8	nvarchar(3000) = ''
	,@var9  nvarchar(3000) = ''
	,@Lang	varchar(10) = ''
)
AS
	
	IF @Lang IS NULL
		SELECT @Lang = EffectiveValue FROM core.Params WHERE Name = 'Language'
		
	
	SELECT @Text = ST.StringText  FROM dbo.StringText ST WHERE ST.Lang = @Lang AND ST.StringID = @Id;

	-- Replace %s
	;WITH Rep AS (
		SELECT DISTINCT
			n = CHARINDEX('%',@text,n)
		FROM
			util.n
		WHERE
			n <= len(@text)
			AND
			 CHARINDEX('%',@text,n) > 0
	)
	SELECT
		@text = STUFF(@Text,StartPos,2,VarName)
	FROM (
		SELECT
			StartPos = n + 5 * (ROW_NUMBER() OVER( ORDER BY n )-1)
			,VarName	 = '@Var'+CONVERT(varchar,ROW_NUMBER() OVER( ORDER BY n )-1)+'+'''
		FROM
			Rep
	) V
	OPTION(MAXDOP 1)


	DECLARE @sql nvarchar(max) = N'SET @o = '''+REPLACE(@text,'@Var','''+@Var')+'''  ',@o nvarchar(max) 
	
	exec sp_Executesql @sql,N'	@o nvarchar(3000) OUTPUT
		,@Var0	nvarchar(3000)	= ''''
		,@Var1	nvarchar(3000)	= ''''
		,@Var2	nvarchar(3000)	= ''''
		,@Var3	nvarchar(3000)	= ''''
		,@Var4	nvarchar(3000)	= ''''
		,@Var5	nvarchar(3000)	= ''''
		,@Var6	nvarchar(3000)	= ''''
		,@Var7	nvarchar(3000)	= ''''
		,@Var8	nvarchar(3000) = ''''
		,@var9  nvarchar(3000) = ''''',@text OUTPUT,@Var0
								   ,@Var1
								   ,@Var2
								   ,@Var3
								   ,@Var4
								   ,@Var5
								   ,@Var6
								   ,@Var7
								   ,@Var8
								   ,@var9




