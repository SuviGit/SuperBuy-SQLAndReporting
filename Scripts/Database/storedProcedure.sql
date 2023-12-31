USE [SuperBuy]
GO
/****** Object:  StoredProcedure [dbo].[DeleteCustomer]    Script Date: 7/5/2023 3:18:15 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetCustomer]    Script Date: 7/5/2023 3:18:15 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetOrderDetails]    Script Date: 7/5/2023 3:18:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[GetOrderDetails] 
		(
			@OrderId INT 
		)
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT *, PricePerProduct * Quantity AS 'Total' FROM OrderDetails
	WHERE OrderId = @OrderId

END
GO
/****** Object:  StoredProcedure [dbo].[GetOrders]    Script Date: 7/5/2023 3:18:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC GetOrders @CustomerId = 10
CREATE       PROCEDURE [dbo].[GetOrders] 
		(
			@CustomerId INT 
		)
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT * FROM [Order]
	WHERE CustomerId = @CustomerId

END

GO
/****** Object:  StoredProcedure [dbo].[InsertCustomer]    Script Date: 7/5/2023 3:18:15 PM ******/
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
/****** Object:  StoredProcedure [dbo].[InsertOrderAndOrderDetails]    Script Date: 7/5/2023 3:18:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT * INTO #TempOrder FROM [Order]
--SELECT * INTO #TempOrderDetails FROM OrderDetails
/*
DECLARE @OrderId INT 
EXEC InsertOrderAndOrderDetails 
	@CustomerId = 22,
	@ProductOrdered = '{"products":[{"id":10, "qty": 1}, {"id":20, "qty": 2}, {"id": 30, "qty": 3}]}',
	@o_OrderId = @OrderId OUT
SELECT @OrderId
*/


CREATE     PROCEDURE [dbo].[InsertOrderAndOrderDetails]
		( @CustomerId INT,
		  @ProductOrdered NVARCHAR(MAX),
		  @o_OrderId INT OUT
		)
AS
BEGIN
	SET XACT_ABORT, NOCOUNT ON

	DECLARE @productsOrdered NVARCHAR(MAX)
	DECLARE @orderStatusId INT

	SELECT @orderStatusId = OrderStatusId FROM OrderStatus WHERE [Status] = 'New'

	BEGIN TRAN
	INSERT INTO [Order](CustomerId, OrderedOn, OrderStatusId, CreatedBy, CreatedOn)
	VALUES(@CustomerId, GETDATE(), @orderStatusId, 1, GETDATE())

	SET @o_OrderId = SCOPE_IDENTITY()


	SELECT @productsOrdered = products FROM OPENJSON(@ProductOrdered)WITH(
		products NVARCHAR(MAX) '$.products' AS JSON   
	)	

	INSERT INTO OrderDetails(OrderId, ProductId, PricePerProduct, Quantity)
	SELECT @o_OrderId, ProductsOrdered.ProductId, P.Price, ProductsOrdered.Quantity FROM(
		SELECT * FROM OPENJSON(@productsOrdered) WITH (
			ProductId INT '$.id',
			Quantity INT '$.qty'
		)
	) ProductsOrdered  INNER JOIN Product P ON P.ProductID = ProductsOrdered.ProductId
	COMMIT TRAN

END


GO
/****** Object:  StoredProcedure [dbo].[UpdateCustomer]    Script Date: 7/5/2023 3:18:15 PM ******/
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
