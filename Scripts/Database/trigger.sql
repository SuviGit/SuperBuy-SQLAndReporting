USE [SuperBuy]
GO

/****** Object:  Trigger [dbo].[t_InsertProduct]    Script Date: 7/6/2023 8:08:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   TRIGGER [dbo].[t_InsertProduct]
ON [dbo].[Product] 
AFTER INSERT
AS
BEGIN
	
	SET NOCOUNT ON;

	INSERT INTO Audit_Products(ProductId, ProductCategoryId,[Name], [Description],
								Price, QuantityAvailable, CreatedBy, CreatedOn, UpdatedBy, UpdatedOn)

	SELECT i.ProductId, i.ProductCategoryId, i.[Name], i.[Description], i.Price, i.QuantityAvailable, 
		 i.CreatedBy, i.CreatedOn, i.UpdatedBy, i.UpdatedOn
	FROM inserted i

END
GO

ALTER TABLE [dbo].[Product] ENABLE TRIGGER [t_InsertProduct]
GO


/****** Object:  Trigger [dbo].[t_UpdateProduct]    Script Date: 7/6/2023 8:08:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   TRIGGER [dbo].[t_UpdateProduct]
ON [dbo].[Product] 
AFTER UPDATE
AS
BEGIN
	
	SET NOCOUNT ON;

	INSERT INTO Audit_Products(ProductId, ProductId_Old, ProductCategoryId, ProductCategoryId_Old, [Name], Name_Old, [Description], Description_Old,
								Price, Price_Old, QuantityAvailable, QuantityAvailable_Old, CreatedBy, CreatedBy_Old, CreatedOn, CreatedOn_Old, 
								UpdatedBy, UpdatedBy_Old, UpdatedOn, UpdatedOn_Old)

	SELECT i.ProductId, d.ProductId, i.ProductCategoryId, d.ProductCategoryId, i.[Name], d.[Name], i.[Description], d.[Description], 
		 i.Price, d.Price, i.QuantityAvailable, d.QuantityAvailable, 
		 i.CreatedBy, d.CreatedBy, i.CreatedOn, d.CreatedOn, i.UpdatedBy, d.UpdatedBy, i.UpdatedOn, d.UpdatedOn
	FROM inserted i
		 INNER JOIN deleted d ON i.ProductId = d.ProductId

END
GO

ALTER TABLE [dbo].[Product] ENABLE TRIGGER [t_UpdateProduct]
GO

/****** Object:  Trigger [dbo].[t_DeleteProduct]    Script Date: 7/6/2023 8:08:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   TRIGGER [dbo].[t_DeleteProduct]
ON [dbo].[Product] 
AFTER DELETE
AS
BEGIN
	
	SET NOCOUNT ON;

	INSERT INTO Audit_Products(ProductId_Old,ProductCategoryId_Old, Name_Old, Description_Old,
								Price_Old, QuantityAvailable_Old, CreatedBy_Old, CreatedOn_Old, UpdatedBy_Old, UpdatedOn_Old)

	SELECT d.ProductId, d.ProductCategoryId, d.[Name], d.[Description], d.Price, d.QuantityAvailable, 
		 d.CreatedBy, d.CreatedOn, d.UpdatedBy, d.UpdatedOn
	FROM deleted d

END
GO

ALTER TABLE [dbo].[Product] ENABLE TRIGGER [t_DeleteProduct]
GO

