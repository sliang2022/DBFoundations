--*************************************************************************--
-- Title: Assignment06
-- Author: YourNameHere
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-11-18,Shuhua Liang,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_SLiang')
	 Begin 
	  Alter Database [Assignment06DB_SLiang] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_SLiang;
	 End
	Create Database Assignment06DB_SLiang;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_SLiang;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!


go

Create View vCategories
WITH SCHEMABINDING
As
Select 
   CategoryID,
   CategoryName
From dbo.Categories;
go
Create View vProducts
WITH SCHEMABINDING
As
Select 
   ProductID,
   ProductName,
   CategoryID,
   UnitPrice
From dbo.Products;
go
Create View vEmployees
WITH SCHEMABINDING
As
Select 
   EmployeeID,
   EmployeeFirstName,
   EmployeeLastName,
   ManagerID
From dbo.Employees;
go
Create View vInventories
WITH SCHEMABINDING
As
Select 
   InventoryID,
   InventoryDate,
   EmployeeID,
   ProductID,
   Count
From dbo.Inventories;
go

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
Deny Select On dbo.Categories To Public;
Deny Select On dbo.Products To Public;
Deny Select On dbo.Employees To Public;
Go

Grant Select On dbo.vCategories To Public;
Grant Select On dbo.vProducts To Public;
Grant Select On dbo.vEmployees To Public;
Go

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
Create View vProductsByCategories
WITH SCHEMABINDING
As
Select Top 100000
   CategoryName, ProductName, UnitPrice
From dbo.Categories 
Inner Join dbo.Products 
   on Categories.CategoryID = Products.CategoryID
Order by CategoryName, ProductName;
go



-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
Create View vInventoriesByProductsByDates
WITH SCHEMABINDING
As
Select  Top 100000
	InventoryDate, ProductName, [Count]
	from dbo.Inventories
	Inner Join dbo.Products 
		on Inventories.ProductID = Products.ProductID
Order By  ProductName, InventoryDate, [Count];
go



-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

Create View vInventoriesByEmployeesByDates
WITH SCHEMABINDING
As
Select TOP 100000
   InventoryDate, 
   [Employee Name] = E.EmployeeFirstName + ' ' + E.EmployeeLastName
From dbo.Inventories as I
Inner Join dbo.Employees as E
   on I.EmployeeID = E.EmployeeID
Group By InventoryDate, E.EmployeeFirstName, E.EmployeeLastName
Order by InventoryDate
go

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
Create View vInventoriesByProductsByCategories
WITH SCHEMABINDING
As
Select TOP 100000
	CategoryName, ProductName, InventoryDate, [Count]
	from dbo.Categories  as C
	Inner Join dbo.Products as P
		on C.CategoryID = P.CategoryID
	Inner Join dbo.Inventories as I
		on P.ProductID = I.ProductID
		Order by InventoryDate,CategoryName,ProductName
go

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
Create View vInventoriesByProductsByEmployees
WITH SCHEMABINDING
As
Select TOP 100000
	CategoryName, ProductName, InventoryDate, [Count], [Employee Name] = E.EmployeeFirstName +' '+ E.EmployeeLastName
	from dbo.Categories  as C
	Inner Join dbo.Products as P
		on C.CategoryID = P.CategoryID
	Inner Join dbo.Inventories as I
		on P.ProductID = I.ProductID
	Inner Join dbo.Employees as E
		on I.EmployeeID = E.EmployeeID
		Order by InventoryDate,CategoryName,ProductName, [Employee Name]
go

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
Create View vInventoriesForChaiAndChangByEmployees
WITH SCHEMABINDING
As
Select TOP 100000
	CategoryName, ProductName, InventoryDate, [Count], [Employee Name] = E.EmployeeFirstName +' '+ E.EmployeeLastName
	from dbo.Categories  as C
	Inner Join dbo.Products as P
		on C.CategoryID = P.CategoryID
	Inner Join dbo.Inventories as I
		on P.ProductID = I.ProductID
	Inner Join dbo.Employees as E
		on I.EmployeeID = E.EmployeeID		
		Where P.ProductID In (Select ProductID 
								from dbo.Products
								where ProductName in ('Chai', 'Chang')) 
		Order by InventoryDate,CategoryName,ProductName, [Employee Name]
go

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
Create View vEmployeesByManager
WITH SCHEMABINDING
As
Select TOP 100000
	[Employee Name] = E1.EmployeeFirstName +' '+ E1.EmployeeLastName, [Manager Name] = E2.EmployeeFirstName +' '+ E2.EmployeeLastName
	from dbo.Employees as E1, dbo.Employees as E2
		where E1.ManagerID = E2.EmployeeID
		Order by [Manager Name]
go
-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

Create View vInventoriesByProductsByCategoriesByEmployees
WITH SCHEMABINDING
As
Select TOP 100000
	C.CategoryID, 
	C.CategoryName, 
	P.ProductID, 
	P.ProductName, 
	P.UnitPrice,
	I.InventoryID,
	I.InventoryDate, 
	I.[Count], 
	E.EmployeeID,
	[Employee Name] = E.EmployeeFirstName +' '+ E.EmployeeLastName,
	[Manager Name] = E2.EmployeeFirstName +' '+ E2.EmployeeLastName
	from dbo.Categories  as C
	Inner Join dbo.Products as P
		on C.CategoryID = P.CategoryID
	Inner Join dbo.Inventories as I
		on P.ProductID = I.ProductID
	Inner Join dbo.Employees as E
		on I.EmployeeID = E.EmployeeID
	Inner Join dbo.Employees as E2
		on E.ManagerID = E2.EmployeeID
	Order by InventoryDate,CategoryName,ProductName, [Employee Name]
go

-- Test your Views (NOTE: You must change the your view names to match what I have below!)


Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/