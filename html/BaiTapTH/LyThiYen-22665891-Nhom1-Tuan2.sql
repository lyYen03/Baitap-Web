
----------------HAVING

--1)  Liệt kê danh sách các hóa đơn (SalesOrderID) lập trong tháng  6  năm 2008  có 
--tổng tiền >70000, thông tin gồm SalesOrderID, Orderdate,  SubTotal,  trong đó 
--SubTotal  =SUM(OrderQty*UnitPrice).

--Dung cac bang [Sales].[SalesOrderHeader], [Sales].[SalesOrderDetail]

--Lay du cac thuoc tinh
SELECT H.SalesOrderID,OrderDate, OrderQty,UnitPrice
FROM Sales.SalesOrderHeader AS H INNER JOIN 
     Sales.SalesOrderDetail AS D ON H.SalesOrderID = D.SalesOrderID
WHERE MONTH(OrderDate) = 6 AND YEAR(OrderDate)= 2008
GO

--Them cac menh de cho hoan chinh
SELECT H.SalesOrderID,OrderDate, SUM(OrderQty*UnitPrice) AS SubTotal
FROM Sales.SalesOrderHeader AS H INNER JOIN 
     Sales.SalesOrderDetail AS D ON H.SalesOrderID = D.SalesOrderID
WHERE MONTH(OrderDate) = 6 AND YEAR(OrderDate)= 2008
GROUP BY H.SalesOrderID,OrderDate
HAVING SUM(OrderQty*UnitPrice) > 70000
GO


--2)  Đếm tổng số khách hàng và tổng tiền của những khách hàng thuộc các quốc gia 
--có  mã  vùng  là  US  (lấy  thông  tin  từ  các  bảng  Sales.SalesTerritory, 
--Sales.Customer,  Sales.SalesOrderHeader,  Sales.SalesOrderDetail).  Thông  tin 
--bao  gồm  TerritoryID,  tổng  số  khách  hàng  (CountOfCust),  tổng  tiền 
--(SubTotal) với  SubTotal = SUM(OrderQty*UnitPrice)

--Dung cac bang [Sales].[SalesTerritory], [Sales].[SalesOrderDetail],[Sales].[SalesOrderHeader],[Sales].[Customer]

SELECT T.TerritoryID,COUNT( C.CustomerID) AS CountOfCust ,SUM(D.OrderQty*D.UnitPrice) AS SubTotal
FROM Sales.Customer  C JOIN
 Sales.SalesTerritory  T ON  C.TerritoryID = T.TerritoryID JOIN
  Sales.SalesOrderHeader  H ON C.CustomerID = H.CustomerID  JOIN
  Sales.SalesOrderDetail  D ON D.SalesOrderID = H.SalesOrderID
WHERE T.CountryRegionCode = 'US'
GROUP BY T.TerritoryID
ORDER BY T.TerritoryID
GO


--3)  Tính  tổng  trị  giá  của  những  hóa  đơn  với  Mã  theo  dõi  giao  hàng
--(CarrierTrackingNumber)  có  3  ký  tự  đầu  là  4BD,  thông  tin  bao  gồm 
--SalesOrderID, CarrierTrackingNumber,  SubTotal=SUM(OrderQty*UnitPrice)

--Dung cac bang [Sales].[SalesOrderHeader],[Sales].[SalesOrderDetail]

SELECT H.SalesOrderID,D.CarrierTrackingNumber, SUM(OrderQty*UnitPrice) AS SubTotal
FROM Sales.SalesOrderHeader H JOIN Sales.SalesOrderDetail D ON H.SalesOrderID = D.SalesOrderID
WHERE D.CarrierTrackingNumber LIKE '4BD%'
GROUP BY H.SalesOrderID,D.CarrierTrackingNumber


--4)  Liệt  kê  các  sản  phẩm  (Product)  có  đơn  giá  (UnitPrice)<25  và  số  lượng  bán 
--trung bình >5, thông tin gồm ProductID, Name,  AverageOfQty

--Dung cac bang [Production].[Product],[Sales].[SalesOrderDetail]

SELECT P.ProductID, P.Name, AVG(D.OrderQty) AS AverageOfQty
FROM Production.Product P JOIN Sales.SalesOrderDetail D ON P.ProductID = D.ProductID
WHERE D.UnitPrice < 25 
GROUP BY  P.ProductID, P.Name
HAVING AVG(D.OrderQty) > 5
GO


--5)  Liệt kê các công việc (JobTitle) có tổng số nhân viên >20 người, thông tin gồm 
--JobTitle,  CountOfPerson=Count(*)

--Dung cac bang [HumanResources].[Employee],[Person].[Person]

SELECT E.JobTitle, COUNT(E.BusinessEntityID) AS CountOfPerson
FROM HumanResources.Employee E 
GROUP BY E.JobTitle
HAVING COUNT(E.BusinessEntityID) > 20

--6)  Tính tổng số lượng và tổng trị giá của các sản phẩm do các nhà cung cấp có tên 
--kết  thúc  bằng  ‘Bicycles’  và  tổng  trị  giá  >  800000,  thông  tin  gồm 
--BusinessEntityID, Vendor_Name, ProductID, SumOfQty,  SubTotal

--Dung cac bang [Purchasing].[Vendor],[Purchasing].[PurchaseOrderDetail],[Sales].[SalesOrderHeader]

SELECT V.BusinessEntityID, V.Name, D.ProductID, SUM(D.OrderQty) AS SumOfQty,  SUM(D.OrderQty*D.UnitPrice) AS SubTotal
FROM Purchasing.Vendor V 
     join Purchasing.PurchaseOrderHeader H on H.VendorID = V.BusinessEntityID
	 join Purchasing.PurchaseOrderDetail D on H.PurchaseOrderID = D.PurchaseOrderID
WHERE V.Name LIKE '%Bicycles' 
GROUP BY V.BusinessEntityID, V.Name, D.ProductID
HAVING  SUM(D.OrderQty*D.UnitPrice) > 800000


--7) Liệt kê các sản phẩm có trên 500 đơn đặt hàng trong quí 1 năm 2008 và có tổng
--trị giá >10000, thông tin gồm ProductID, Product_Name, CountOfOrderID và
--SubTotal
SELECT P.ProductID, P.Name, count(D.SalesOrderID) as CountOfOrderID, Sum(D.OrderQty*D.UnitPrice) AS SubTotal
FROM  Production.Product P 
      join Sales.SalesOrderDetail D on P.ProductID= D.ProductID
	  join Sales.SalesOrderHeader H on H.SalesOrderID = D.SalesOrderID
WHERE DATEPART(q,H.OrderDate) = 1 and YEAR(H.OrderDate) = 2008
GROUP BY P.ProductID, P.Name
HAVING Sum(D.OrderQty*D.UnitPrice) > 10000 and count(D.SalesOrderID) > 500

--8) Liệt kê danh sách các khách hàng có trên 25 hóa đơn đặt hàng từ năm 2007 đến
--2008, thông tin gồm mã khách (PersonID) , họ tên (FirstName +' '+ LastName
--as FullName), Số hóa đơn (CountOfOrders)

select C.PersonID, (P.FirstName +' '+ P.LastName) as FullName,  CountOfOrders= count(H.SalesOrderID)
from  Person.Person P
      join Sales.Customer C on P.BusinessEntityID = C.CustomerID
	  join Sales.SalesOrderHeader H on C.CustomerID = H.CustomerID
where year(H.OrderDate) between 2007 and 2008
group by C.PersonID,P.FirstName +' '+ P.LastName
having count(H.SalesOrderID) > 25 

--9) Liệt kê những sản phẩm có tên bắt đầu với ‘Bike’ và ‘Sport’ có tổng số lượng
--bán trong mỗi năm trên 500 sản phẩm, thông tin gồm ProductID, Name,
--CountOfOrderQty, Year. 
select P.ProductID, P.Name, CountOfOrderQty = count(D.SalesOrderDetailID), YEAR(H.OrderDate) as Year
from Production.Product P 
     join Sales.SalesOrderDetail D on P.ProductID = D.ProductID
	 join Sales.SalesOrderHeader H on H.SalesOrderID = D.SalesOrderID
where P.Name like 'Bike%' or P.Name like  'Sport%'
group by P.ProductID, P.Name,YEAR(H.OrderDate)
having sum(D.OrderQty) > 500

--10)Liệt kê những phòng ban có lương (Rate: lương theo giờ) trung bình >30, thông
--tin gồm Mã phòng ban (DepartmentID), tên phòng ban (Name), Lương trung
--bình (AvgofRate).
select D.DepartmentID,D.Name, AvgofRate = AVG(PH.Rate)
from HumanResources.Department D 
     join HumanResources.EmployeeDepartmentHistory DH on D.DepartmentID = DH.DepartmentID
	 join HumanResources.EmployeePayHistory PH on DH.BusinessEntityID = PH.BusinessEntityID
group by D.DepartmentID,D.Name
having AVG(PH.Rate) > 30



--------------------SUBQUERY

--1) Liệt kê các sản phẩm gồm các thông tin Product Names và Product ID có
--trên 100 đơn đặt hàng trong tháng 7 năm 2008
select ProductID,Name as [Product Names]
from Production.Product 
where ProductID in (select ProductID as SoDH
                     from Sales.SalesOrderDetail D join Sales.SalesOrderHeader H on H.SalesOrderID = D.SalesOrderID
					 where YEAR(H.OrderDate) = 2008 and MONTH(H.OrderDate) = 7
					 group by ProductID
					 having count(D.SalesOrderID) > 100)
--Cách 2
select ProductID,Name as [Product Names]
from Production.Product P
where exists (select ProductID,count(D.SalesOrderID)
                     from Sales.SalesOrderDetail D join Sales.SalesOrderHeader H on H.SalesOrderID = D.SalesOrderID
					 where YEAR(H.OrderDate) = 2008 and MONTH(H.OrderDate) = 7 and P.ProductID = D.ProductID--kết nối khoá ngoại
					 group by ProductID
					 having count(D.SalesOrderID) > 100)

--2) Liệt kê các sản phẩm (ProductID, Name) có số hóa đơn đặt hàng nhiều nhất
--trong tháng 7/2008
select P.ProductID, P.Name,count(D.SalesOrderID) as CountOfOrder
from Production.Product P 
	join Sales.SalesOrderDetail D on P.ProductID = D.ProductID 
	join Sales.SalesOrderHeader H on H.SalesOrderID = D.SalesOrderID
where MONTH(H.OrderDate) = 7 and YEAR(H.OrderDate) = 2008
group by P.ProductID, P.Name
having count(D.SalesOrderID) >=all (select count(D.SalesOrderID)
                     from Sales.SalesOrderDetail D join Sales.SalesOrderHeader H on H.SalesOrderID = D.SalesOrderID
					 where MONTH(H.OrderDate) = 7 and YEAR(H.OrderDate) = 2008
					 group by ProductID)

--3) Hiển thị thông tin của khách hàng có số đơn đặt hàng nhiều nhất, thông tin gồm:
--CustomerID, Name, CountOfOrder
select C.CustomerID, CountOfOrder = count(H.SalesOrderID)
from Sales.Customer C 
     join Sales.SalesOrderHeader H on C.CustomerID = H.CustomerID 
group by C.CustomerID
having count(H.SalesOrderID) >= all (select count(H.SalesOrderID)
									from Sales.SalesOrderHeader H
									group by H.CustomerID)


--4) Liệt kê các sản phẩm (ProductID, Name) thuộc mô hình sản phẩm áo dài tay với
--tên bắt đầu với “Long-Sleeve Logo Jersey”, dùng phép IN và EXISTS
--Cách 1

select P.ProductID,P.Name
from Production.Product P
where P.ProductModelID in (select M.ProductModelID
							from Production.ProductModel M
							where M.Name like 'Long-Sleeve Logo Jersey%')

--Cách 2
select P.ProductID,P.Name
from Production.Product P 
where exists (select M.ProductModelID
							from Production.ProductModel M
							where M.Name like 'Long-Sleeve Logo Jersey%' and P.ProductModelID = M.ProductModelID)

--5) Tìm các mô hình sản phẩm (ProductModelID) mà giá niêm yết (list price) tối
--đa cao hơn giá trung bình của tất cả các mô hình
select M.ProductModelID,M.Name,max(P.ListPrice) as [list price]
from Production.ProductModel M join Production.Product P on P.ProductModelID = M.ProductModelID
group by M.ProductModelID,M.Name
having max(P.ListPrice) >= all (select avg(P.ListPrice)
                                from Production.ProductModel M join Production.Product P on P.ProductModelID = M.ProductModelID)


--6) Liệt kê các sản phẩm gồm các thông tin ProductID, Name, có tổng số lượng
--đặt hàng > 5000 (dùng IN, EXISTS)
--Cách 1
select P.ProductID,P.Name
from Production.Product P 
where P.ProductID in (select D.ProductID
						from Sales.SalesOrderDetail D 
						group by D.ProductID
						having sum(D.OrderQty) > 5000)


--Cách 2
select P.ProductID,P.Name
from Production.Product P 
where exists (select D.ProductID
				from Sales.SalesOrderDetail D 
				where D.ProductID = P.ProductID
				group by D.ProductID
				having sum(D.OrderQty) > 5000)


--7) Liệt kê những sản phẩm (ProductID, UnitPrice) có đơn giá (UnitPrice) cao
--nhất trong bảng Sales.SalesOrderDetail
select distinct d.ProductID,d.UnitPrice
from Sales.SalesOrderDetail d 
where D.UnitPrice >= all (select D.UnitPrice
				from Sales.SalesOrderDetail D )


--8) Liệt kê các sản phẩm không có đơn đặt hàng nào thông tin gồm ProductID,
--Nam; dùng 3 cách Not in, Not exists và Left join
--Dùng Not in
select P.ProductID, P.Name
from Production.Product P 
where P.ProductID Not in (select D.ProductID
                          from Sales.SalesOrderDetail D)

--Dùng Not exists
select P.ProductID,P.Name
from Production.Product P
where not exists (select D.ProductID
				   from Sales.SalesOrderDetail D
				   where D.ProductID = P.ProductID)

--Dùng Left join
select P.ProductID,P.Name
from Production.Product P left join Sales.SalesOrderDetail D on D.ProductID = P.ProductID
where D.ProductID is null


--9) Liệt kê các nhân viên không lập hóa đơn từ sau ngày 1/5/2008, thông tin gồm
--EmployeeID, FirstName, LastName 
select EmployeeID = p.BusinessEntityID, p.LastName,P.FirstName
from Person.Person p
where p.BusinessEntityID not in(select H.SalesPersonID
							from Sales.SalesOrderHeader H
							where H.OrderDate > '2008-05-01')


--10)Liệt kê danh sách các khách hàng (CustomerID, Name) có hóa đơn dặt hàng
--trong năm 2007 nhưng không có hóa đơn đặt hàng trong năm 2008
select distinct H.CustomerID
from Sales.SalesOrderHeader H
where H.CustomerID in( select H.CustomerID
						from Sales.SalesOrderHeader H
						where YEAR(H.OrderDate) = 2007 )
and H.CustomerID not in (select H.CustomerID
						from Sales.SalesOrderHeader H
						where YEAR(H.OrderDate) = 2008)







