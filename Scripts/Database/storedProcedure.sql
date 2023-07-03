USE [SuperBuy]
GO
/****** Object:  StoredProcedure [dbo].[DeleteCustomer]    Script Date: 7/3/2023 11:21:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC DeleteCustomer @CustomerId = 1
CREATE   PROCEDURE [dbo].[DeleteCustomer]
	(
	  @CustomerId INT
	)
AS
BEGIN
	UPDATE Customer
	SET DeletedOn = GETDATE()
	WHERE CustomerId = @CustomerId
END


GO
/****** Object:  StoredProcedure [dbo].[GetCustomer]    Script Date: 7/3/2023 11:21:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC GetCustomer @CustomerId = 1
CREATE     PROCEDURE [dbo].[GetCustomer]
	(@CustomerId INT)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT * FROM Customer
	WHERE CustomerId = @CustomerId
		AND DeletedOn IS NULL
END
GO
/****** Object:  StoredProcedure [dbo].[InsertCustomer]    Script Date: 7/3/2023 11:21:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
DECLARE @CustomerId INT
EXEC InsertCustomer
	@FirstName = 'Jack',
	@MiddleName = 'Tim',
	@LastName = 'Murphy',
	@Gender = 'M',
	@CreatedBy = 1,
	@CreatedOn = '05/21/2022',
	@o_CustomerId = @CustomerId OUT

SELECT  @CustomerId
*/
CREATE   PROCEDURE [dbo].[InsertCustomer]
	( @FirstName nvarchar(100),
	  @MiddleName nvarchar(100) = NULL,
	  @LastName nvarchar(200),
	  @Gender nchar(1),
	  @CreatedBy INT,
	  @CreatedOn datetime,
	  @o_CustomerId INT OUT
	)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO Customer(FirstName,MiddleName,LastName,Gender,CreatedBy,CreatedOn)
	VALUES(@FirstName,@MiddleName,@LastName,@Gender,@CreatedBy,@CreatedOn)

	SET @o_CustomerId = Scope_Identity()
END



GO
/****** Object:  StoredProcedure [dbo].[UpdateCustomer]    Script Date: 7/3/2023 11:21:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC UpdateCustomer
	@CustomerId = 12, 
	@FirstName = 'Donald',
	@UpdatedBy = 2
*/
CREATE   PROCEDURE [dbo].[UpdateCustomer]
	(	@CustomerId INT,
		@FirstName nvarchar(100) = NULL,
		@MiddleName nvarchar(100) = NULL,
		@LastName nvarchar(200) = NULL,
		@Gender nchar(1) = NULL,
		@UpdatedBy INT
	)
AS
BEGIN
	SET NOCOUNT ON;

	IF(@MiddleName IS NULL)
	BEGIN
		SELECT @MiddleName = MiddleName 
		FROM Customer
		WHERE CustomerId = @CustomerId
	END
	ELSE IF(LTRIM(@MiddleName) = '')
	BEGIN
		SET	@MiddleName = NULL
	END

	UPDATE Customer
	SET FirstName = ISNULL(@FirstName, FirstName),
		MiddleName = @MiddleName,
		LastName = ISNULL(@LastName, LastName),
		Gender = ISNULL(@Gender, Gender),
		UpdatedBy = @UpdatedBy,
		UpdatedOn = GETDATE()
	WHERE CustomerId = @CustomerId

END

GO
