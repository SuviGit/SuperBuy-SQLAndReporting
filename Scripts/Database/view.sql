USE [SuperBuy]
GO
/****** Object:  View [dbo].[OrderDelivered]    Script Date: 7/9/2023 6:37:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT * FROM OrderDelivered

CREATE   VIEW [dbo].[OrderDelivered]
AS

	SELECT O.OrderId, O.CustomerId, O.ShippingId, O.OrderStatusId, OS.[Status], S.FirstName, S.MiddleName, S.LastName, S.AddressLine1, 
		  S.AddressLine2, S.City, S.StateId, S.PostalCode, S.ShippedOn
	FROM [Order] O 
		INNER JOIN OrderStatus OS ON O.OrderStatusId = OS.OrderStatusId
		INNER JOIN Shipping S ON O.ShippingId = S.ShippingId
	WHERE O.OrderStatusId = 4






GO
