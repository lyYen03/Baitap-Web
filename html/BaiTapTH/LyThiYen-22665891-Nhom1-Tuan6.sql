
USE AdventureWorks2008R2
go

--Mẫu 
CREATE FUNCTION Ten_ham(@bien_kieu)
return table --kết quả trả về là bảng (danh sách)
as
return
	(SELECT
	FROM
	WHERE
	GROUP BY
	HAVING)
GO

--gọi hàm
select * from Ten_ham(gia_tri_thuc) --Tên hàm trả về bảng thì đặt sau from
go

--  In-line Table Valued Functions: 
--4)  Viết hàm SumOfOrder  với hai tham số @thang và @nam trả về danh sách các 
--hóa đơn (SalesOrderID) lập trong tháng và năm được truyền vào từ    2 tham số
--@thang và @nam, có tổng tiền >70000, thông tin gồm SalesOrderID, OrderDate,
--SubTotal, trong đó SubTotal =sum(OrderQty*UnitPrice).

create function SumOfOrder (@thang int, @nam int)
returns table
as
return
	(select oh.SalesOrderID, oh.OrderDate, SubTotal =sum(od.OrderQty*od.UnitPrice)
	from Sales.SalesOrderHeader oh join Sales.SalesOrderDetail od on oh.SalesOrderID = od.SalesOrderID
	where MONTH(oh.OrderDate) = @thang and YEAR(oh.OrderDate) = @nam
	group by oh.SalesOrderID, oh.OrderDate
	having sum(od.OrderQty*od.UnitPrice) > 70000
	)
go

--Xem số liệu
select oh.SalesOrderID, oh.OrderDate, SubTotal =sum(od.OrderQty*od.UnitPrice)
from Sales.SalesOrderHeader oh join Sales.SalesOrderDetail od on oh.SalesOrderID = od.SalesOrderID
group by oh.SalesOrderID, oh.OrderDate
having sum(od.OrderQty*od.UnitPrice) > 70000

--gọi hàm
select * from SumOfOrder (9,2005)
go

--5)  Viết hàm tên  NewBonus  tính lại tiền thưởng (Bonus) cho nhân viên bán hàng 
--(SalesPerson), dựa trên tổng doanh thu của mỗi nhân viên, mức thưởng mới bằng 
--mức  thưởng  hiện  tại  tăng  thêm  1%  tổng  doanh  thu,  thông  tin  bao  gồm 
--[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:
--  SumOfSubTotal  =sum(SubTotal),
--  NewBonus = Bonus+ sum(SubTotal)*0.01
create function NewBonus ()
returns table
as
	return
		(
		select oh.SalesPersonID, NewBonus = sp.Bonus+ sum(SubTotal)*0.01,SumOfSubTotal  =sum(oh.SubTotal)
		from Sales.SalesPerson sp join Sales.SalesOrderHeader oh on sp.BusinessEntityID = oh.SalesPersonID 
		group by oh.SalesPersonID,sp.Bonus
		)
go

select * from NewBonus() 
go

drop function NewBonus
go
--6)  Viết  hàm  tên  SumOfProduct  với  tham  số  đầu  vào  là  @MaNCC  (VendorID), 
--hàm dùng để tính tổng số lượng (SumOfQty) và tổng trị giá (SumOfSubTotal) 
--của  các  sản  phẩm  do  nhà  cung  cấp  @MaNCC  cung  cấp,  thông  tin  gồm 
--ProductID, SumOfProduct, SumOfSubTotal
create function SumOfProduct (@MaNCC int)
returns table
as
	return
		(
		select ProductID, SumOfProduct = sum(od.OrderQty), SumOfSubTotal = sum(oh.SubTotal)
		from Purchasing.Vendor pv join Purchasing.PurchaseOrderHeader oh on pv.BusinessEntityID = oh.VendorID join Purchasing.PurchaseOrderDetail od on oh.PurchaseOrderID = od.PurchaseOrderID
		where oh.VendorID = @MaNCC
		group by ProductID
		)
go



select * from SumOfProduct(1658)
go

drop function dbo.SumOfProduct
go

--7)  Viết hàm tên Discount_Func tính số tiền giảm trên các hóa đơn  (SalesOrderID), 
--thông  tin gồm  SalesOrderID,  [SubTotal],  Discount;  trong  đó  Discount  được  tính 
--như sau:
--Nếu [SubTotal]<1000 thì Discount=0 
--Nếu 1000<=[SubTotal]<5000 thì Discount = 5%[SubTotal]
--Nếu 5000<=[SubTotal]<10000 thì Discount = 10%[SubTotal] 
--Nếu [SubTotal>=10000 thì Discount = 15%[SubTotal]
create function Discount_Func ()
returns table
as
	return 
		(
		select ssoh.SalesOrderID, ssoh.SubTotal, Discount=
			(
			case
				when ssoh.SubTotal < 1000 then 0
				when ssoh.SubTotal between 1000 and 5000 then ssoh.SubTotal * 0.05
				when ssoh.SubTotal between 5000 and 10000 then ssoh.SubTotal * 0.1
				else ssoh.SubTotal * 0.15
			end
			)
		from Sales.SalesOrderHeader ssoh
		)
go

select * from Discount_Func()
go

drop function Discount_Func
go


--8) Viết hàm TotalOfEmp với tham số @MonthOrder, @YearOrder để tính tổng
--doanh thu của các nhân viên bán hàng (SalePerson) trong tháng và năm được
--truyền vào 2 tham số, thông tin gồm [SalesPersonID], Total, với
--Total=Sum([SubTotal])
create function TotalOfEmp (@MonthOrder int, @YearOrder int)
returns table
as
	return
		(
		select ssoh.SalesPersonID, Total=Sum(ssoh.SubTotal)
		from Sales.SalesOrderHeader ssoh
		where Month(ssoh.OrderDate) = @MonthOrder and Year(ssoh.OrderDate) = @YearOrder
		group by ssoh.SalesPersonID
		)
go

---xem dữ liệu
select ssoh.SalesPersonID, Total=Sum(ssoh.SubTotal),ssoh.OrderDate
from Sales.SalesOrderHeader ssoh
group by ssoh.SalesPersonID,ssoh.OrderDate

select * from TotalOfEmp(9,2006)
go


-- Multi-statement Table Valued Functions:
--9) Viết lại các câu 5,6,7,8 bằng Multi-statement table valued 
--Mẫu
CREATE FUNCTION Ten_Ham(@bien kieu)
returns @bang table(cot1 kieu, cot2 kieu)--khai báo cấu trúc @bang
as
begin
	INSERT @bang -- biến kiểu table
	SELECT cot1, cot2
		FROM cac_bang
		WHERE
		GROUP BY
		HAVING

    return -- phải có
end
go

--cau4
create function SumOfOrder_Multi (@thang int, @nam int)
returns @bang table(SalesOrderID int,OrderDate datetime, SubTotal money)
as
begin
	insert @bang
	select ssoh.SalesOrderID, ssoh.OrderDate, SubTotal = Sum(ssod.OrderQty*ssod.UnitPrice)
		from Sales.SalesOrderHeader ssoh join Sales.SalesOrderDetail ssod on ssoh.SalesOrderID = ssod.SalesOrderID
		where MONTH(ssoh.OrderDate) = @thang and year(ssoh.OrderDate) = @nam
		group by ssoh.SalesOrderID, ssoh.OrderDate
		having Sum(ssod.OrderQty*ssod.UnitPrice) > 70000
	return
end
go

select * from SumOfOrder_Multi(8,2005) go


--cau5
create function NewBonus_Multi()
returns @bang5 table(SalesPersonID int,SumOfSubTotal money,NewBonus money)
as
begin
	insert @bang5
	select oh.SalesPersonID, sum(oh.SubTotal) as SumOfSubTotal, NewBonus = p.Bonus+ sum(oh.SubTotal)*0.01
		from  Sales.SalesPerson p join Sales.SalesOrderHeader oh on p.BusinessEntityID = oh.SalesPersonID
		group by oh.SalesPersonID,p.Bonus
	return
end
go

select * from NewBonus_Multi() go

drop function NewBonus_Multi go

--cau6
create function SumOfProduct_Multi (@MaNCC int)
returns @bang6 table (ProductID int,SumOfQty int,SumOfSubTotal money)
as
begin
	insert @bang6
	select ProductID, SumOfProduct = sum(d.OrderQty), SumOfSubTotal = sum(oh.SubTotal)
		from Purchasing.Vendor pv join Purchasing.PurchaseOrderHeader oh on pv.BusinessEntityID = oh.VendorID
		join Purchasing.PurchaseOrderDetail d on oh.PurchaseOrderID = d.PurchaseOrderID
		where VendorID = @MaNCC
		group by ProductID
	return 
end

drop function SumOfProduct_Multi

select * from SumOfProduct_Multi(1658) go

--cau7
create function Discount_Func_Multi ()
returns @bang7 table (SalesOrderID int, SubTotal money, Discount money)
as
begin
	insert @bang7
	select SalesOrderID, SubTotal, Discount =
			(case
			when SubTotal < 1000 then 0
			when SubTotal between 1000 and 5000 then SubTotal * 0.05
			when SubTotal between 5000 and 10000 then SubTotal * 0.1
			else SubTotal * 0.15
			end
			)
		from Sales.SalesOrderHeader
		group by SalesOrderID, SubTotal
	return
end

select * from Discount_Func_Multi() go

--cau8
create function TotalOfEmp_Multi(@MonthOrder int, @YearOrder int)
returns @bang8 table (SalesPersonID int, Total money)
as
begin
	insert @bang8
	select SalesPersonID, Total=Sum(SubTotal)
		from Sales.SalesOrderHeader
		where year(OrderDate) = @YearOrder and MONTH(OrderDate) = @MonthOrder
		group by SalesPersonID
	return
end

select * from TotalOfEmp_Multi(9,2006) go 


--10)Viết hàm tên SalaryOfEmp trả về kết quả là bảng lương của nhân viên, với tham
--số vào là @MaNV (giá trị của [BusinessEntityID]), thông tin gồm
--BusinessEntityID, FName, LName, Salary (giá trị của cột Rate).
-- Nếu giá trị của tham số truyền vào là Mã nhân viên khác Null thì kết
--quả là bảng lương của nhân viên đó.
--Ví dụ thực thi hàm: select * from SalaryOfEmp(288)
--Kết quả là:
-- Nếu giá trị truyền vào là Null thì kết quả là bảng lương của tất cả nhân
--viên
--Ví dụ: thực thi hàm select * from SalaryOfEmp(Null)
--Kết quả là 316 record

create function SalaryOfEmp (@MaNV int)
returns @bang10 table (BusinessEntityID int, FName nvarchar(50), LName nvarchar(50), Salary money)
as
begin
	if @MaNV is not NULL
		insert @bang10
		select eph.BusinessEntityID, FirstName,LastName,eph.Rate
		from Person.Person p join HumanResources.EmployeePayHistory eph on p.BusinessEntityID = eph.BusinessEntityID
		where eph.BusinessEntityID = @MaNV
	else
	    insert @bang10
		select eph.BusinessEntityID, FirstName,LastName,eph.Rate
		from Person.Person p join HumanResources.EmployeePayHistory eph on p.BusinessEntityID = eph.BusinessEntityID
return
end
go

drop function SalaryOfEmp 

select * from SalaryOfEmp(288) go
select * from SalaryOfEmp(Null) go 
