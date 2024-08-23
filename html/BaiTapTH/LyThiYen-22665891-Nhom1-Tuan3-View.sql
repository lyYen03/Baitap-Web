--Tuần  3 (Tiếp)
--1) Tạo view dbo.vw_Products hiển thị danh sách các sản phẩm từ bảng
--Production.Product và bảng Production.ProductCostHistory. Thông tin bao gồm
--ProductID, Name, Color, Size, Style, StandardCost, EndDate, StartDate
Create View dbo.vw_Products
AS
SELECT P.ProductID, Name,Color, Size, Style, P.StandardCost, EndDate, StartDate
FROM Production.Product AS P INNER JOIN Production.ProductCostHistory AS H ON P.ProductID = H.ProductID
GO
select * from dbo.vw_Products


--2) Tạo view List_Product_View chứa danh sách các sản phẩm có trên 500 đơn đặt
--hàng trong quí 1 năm 2008 và có tổng trị giá >10000, thông tin gồm ProductID,
--Product_Name, CountOfOrderID và SubTotal
Create View List_Product_View
AS
	SELECT  P.ProductID, p.Name as 'Product_Name', CountOfOrderID = COUNT(OD.SalesOrderID), SubTotal = sum(OrderQty * UnitPrice)
	FROM Production.Product AS P INNER JOIN Sales.SalesOrderDetail AS  OD ON P.ProductID = OD.ProductID INNER JOIN Sales.SalesOrderHeader as OH on OD.SalesOrderID = OH.SalesOrderID
	WHERE Datepart(q,oh.OrderDate) = 1 and Year(OH.OrderDate) = 2008
	GROUP BY P.ProductID, p.Name
	HAVING COUNT(OD.SalesOrderID) > 500 AND sum(OrderQty * UnitPrice) > 10000
GO

select * from List_Product_View

--DROP VIEW List_Product_View
--GO

--3) Tạo view dbo.vw_CustomerTotals hiển thị tổng tiền bán được (total sales) từ cột
--TotalDue của mỗi khách hàng (customer) theo tháng và theo năm. Thông tin gồm
--CustomerID, YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS
--OrderMonth, SUM(TotalDue).
h.
create view dbo.vw_CustomerTotals
as
	select oh.CustomerID, year(oh.OrderDate) AS OrderYear, MONTH(oh.OrderDate) AS OrderMonth, SUM(oh.TotalDue) as TotalDue
	from Sales.SalesOrderHeader as oh 
	group by oh.CustomerID, year(oh.OrderDate), MONTH(oh.OrderDate) 
go

select * from dbo.vw_CustomerTotals


--4) Tạo view trả về tổng số lượng sản phẩm (Total Quantity) bán được của mỗi nhân
--viên theo từng năm. Thông tin gồm SalesPersonID, OrderYear, sumOfOrderQty
create view  view_TotalQuantity
as 
	select h.SalesPersonID, YEAR(h.OrderDate) as 'OrderYear', sumOfOrderQty = Sum(d.OrderQty)
	from Sales.SalesOrderHeader as h inner join Sales.SalesOrderDetail as d on h.SalesOrderID = d.SalesOrderID
	group by h.SalesPersonID, YEAR(h.OrderDate)
go

select * from view_TotalQuantity


--5) Tạo view ListCustomer_view chứa danh sách các khách hàng có trên 25 hóa đơn
--đặt hàng từ năm 2007 đến 2008, thông tin gồm mã khách (PersonID) , họ tên
--(FirstName +' '+ LastName as FullName), Số hóa đơn (CountOfOrders).

create view ListCustomer_view
as
	select h.CustomerID as PersonID, FirstName +' '+ LastName as FullName, CountOfOrders = count(h.SalesOrderID)
	from  Person.Person as p inner join Sales.SalesOrderHeader as h on p.BusinessEntityID = h.CustomerID
	where year(h.OrderDate) between 2007 and 2008 
	group by h.CustomerID, FirstName, LastName
	having count(h.SalesOrderID) > 25
go

select * from ListCustomer_view

--6) Tạo view ListProduct_view chứa danh sách những sản phẩm có tên bắt đầu với
--‘Bike’ và ‘Sport’ có tổng số lượng bán trong mỗi năm trên 50 sản phẩm, thông
--tin gồm ProductID, Name, SumOfOrderQty, Year
create view ListProduct_view
as
	select p.ProductID,p.Name, SumOfOrderQty = sum(d.OrderQty), Year(h.OrderDate) as 'year'
	from Production.Product as p inner join Sales.SalesOrderDetail as d on p.ProductID = d.ProductID inner join Sales.SalesOrderHeader as h on d.SalesOrderID = h.SalesOrderID
	where p.Name like 'Bike%' or p.Name like 'Sport%'
	group by p.ProductID,p.Name,Year(h.OrderDate)
	having sum(d.OrderQty) > 50
go 

select * from ListProduct_view


--7) Tạo view List_department_View chứa danh sách các phòng ban có lương (Rate:
--lương theo giờ) trung bình >30, thông tin gồm Mã phòng ban (DepartmentID),
--tên phòng ban (Name), Lương trung bình (AvgOfRate).
create view List_department_View
as
	select d.DepartmentID, d.Name, avg(ep.Rate) as AvgOfRate
	from HumanResources.EmployeePayHistory as ep inner join HumanResources.EmployeeDepartmentHistory as ed on ep.BusinessEntityID = ed.BusinessEntityID inner join HumanResources.Department as d on ed.DepartmentID = d.DepartmentID
	group by d.DepartmentID, d.Name
	having avg(ep.Rate) > 30
go 

select * from List_department_View


--8) Tạo view Sales.vw_OrderSummary với từ khóa WITH ENCRYPTION gồm
--OrderYear (năm của ngày lập), OrderMonth (tháng của ngày lập), OrderTotal
--(tổng tiền). Sau đó xem thông tin và trợ giúp về mã lệnh của view này
create view Sales.vw_OrderSummary 
WITH SCHEMABINDING
as
	select year(OrderDate) as OrderYear, MONTH(OrderDate) as OrderMonth, SubTotal as OrderTotal
	from Sales.SalesOrderHeader 
go 


-- Kiểm tra kết quả
EXEC sp_helptext [List_Product_view]
EXEC sp_helptext 'Sales.vw_OrderSummary' 

select * from Sales.vw_OrderSummary 


--9) Tạo view Production.vwProducts với từ khóa WITH SCHEMABINDING
--gồm ProductID, Name, StartDate,EndDate,ListPrice của bảng Product và bảng
--ProductCostHistory. Xem thông tin của View. Xóa cột ListPrice của bảng
--Product. Có xóa được không? Vì sao?
create view Production.vwProducts
WITH SCHEMABINDING
as
	select p.ProductID, p.Name, p.SellStartDate, h.EndDate,p.ListPrice
	from [Production].[Product] as p inner join [Production].[ProductCostHistory] as h on p.ProductID = h.ProductID
go


--xem thông tin của view
EXEC sp_helptext 'Production.vwProducts'

--Hiện thực view
select * from Production.vwProducts

 --Xóa cột ListPrice của bảng Product.
 alter table [Production].[Product]
 drop column ListPrice

 -- không xoá được, lỗi The object 'vwProducts' is dependent on column 'ListPrice'.


-- 10) Tạo view view_Department với từ khóa WITH CHECK OPTION chỉ chứa các
--phòng thuộc nhóm có tên (GroupName) là “Manufacturing” và “Quality
--Assurance”, thông tin gồm: DepartmentID, Name, GroupName.
create view view_Department
as
	select DepartmentID, Name, GroupName
	from [HumanResources].[Department] 
	where GroupName like 'Manufacturing' or GroupName like 'Quality Assurance'
	WITH CHECK OPTION
go 

select * from view_Department

--a. Chèn thêm một phòng ban mới thuộc nhóm không thuộc hai nhóm
--“Manufacturing” và “Quality Assurance” thông qua view vừa tạo. Có
--chèn được không? Giải thích.
insert view_Department values ('nhan su','a')
--Không chèn được vì WITH CHECK OPTION kiểm tra không cho chèn
select *  from [HumanResources].[Department] 

--b. Chèn thêm một phòng mới thuộc nhóm “Manufacturing” và một
--phòng thuộc nhóm “Quality Assurance”.
insert view_Department values ('nhan su 1','Manufacturing'), 
                              ('nhan su 2','Quality Assurance')


--c. Dùng câu lệnh Select xem kết quả trong bảng Department
select *  from [HumanResources].[Department] 