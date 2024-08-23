--Tuần 4
USE AdventureWorks2008R2
--I) Batch
--1) Viết một batch khai báo biến @tongsoHD chứa tổng số hóa đơn của sản phẩm
--có ProductID=’778’; nếu @tongsoHD>500 thì in ra chuỗi “Sản phẩm 778 có
--trên 500 đơn hàng”, ngược lại thì in ra chuỗi “Sản phẩm 778 có ít đơn đặt
--hàng”
DECLARE @tongsoHD int, @masp int
set @masp = 778
Select @tongsoHD = count(od.OrderQty) 
					from Sales.SalesOrderDetail as od 
					where od.ProductID = @masp
if(@tongsoHD > 500)
print N'Sản phẩm ' + convert(nvarchar(20),@masp) + N' có trên 500 đơn đặt hàng'
else
print N'Sản phẩm ' + convert(nvarchar(20),@masp) + N' có ít đơn đặt hàng'
go

select [SalesOrderID], [ProductID]
from [Sales].[SalesOrderDetail] as ssod
where ssod.ProductID = 778
order by ssod.[ProductID]

--2) Viết một đoạn Batch với tham số @makh và @n chứa số hóa đơn của khách
--hàng @makh, tham số @nam chứa năm lập hóa đơn (ví dụ @nam=2008), nếu
--@n>0 thì in ra chuỗi: “Khách hàng @makh có @n hóa đơn trong năm 2008”
--ngược lại nếu @n=0 thì in ra chuỗi “Khách hàng @makh không có hóa đơn nào
--trong năm 2008”

select *
from Sales.Customer c
go

DECLARE @makh int, @n int, @nam int
set @nam = 2008
set @makh = 123
select @n = count(*) 
			from Sales.SalesOrderHeader oh 
			where oh.CustomerID = @makh and YEAR(oh.OrderDate) = @nam

if(@n > 0)
        print N'Khách hàng ' + convert(nvarchar(20),@makh) + N' có ' + convert(nvarchar(20),@n) + N' hoá đơn trong năm ' + convert(nvarchar(20),@nam)
else if (@n = 0)
        print N'Khách hàng ' + convert(nvarchar(20),@makh) + N' không có hoá đơn nào trong năm ' + convert(nvarchar(20),@nam)
go


--3) Viết một batch tính số tiền giảm cho những hóa đơn (SalesOrderID) có tổng
--tiền>100000, thông tin gồm [SalesOrderID], SubTotal=SUM([LineTotal]),
--Discount (tiền giảm), với Discount được tính như sau:
-- Những hóa đơn có SubTotal<100000 thì không giảm,
-- SubTotal từ 100000 đến <120000 thì giảm 5% của SubTotal
-- SubTotal từ 120000 đến <150000 thì giảm 10% của SubTotal
-- SubTotal từ 150000 trở lên thì giảm 15% của SubTotal
--(Gợi ý: Dùng cấu trúc Case… When …Then …)
select oh.SalesOrderID, SubTotal = sum(od.LineTotal), Discount = (
	case
		when sum(od.LineTotal) < 100000 then sum(od.LineTotal)
		when sum(od.LineTotal) between 10000 and 120000 then sum(od.LineTotal) * 0.05
		when sum(od.LineTotal) between 120000 and 150000 then sum(od.LineTotal) * 0.1
		when sum(od.LineTotal) > 150000 then sum(od.LineTotal) * 0.15
	end
	)
from [Sales].[SalesOrderDetail] od inner join [Sales].[SalesOrderHeader] oh on od.SalesOrderID = oh.SalesOrderID
group by oh.SalesOrderID
having sum(od.LineTotal) > 100000
go

-- kiểm tra lại kết quả
select ssod.SalesOrderID, SubTotal=SUM(ssod.LineTotal)
from Sales.SalesOrderDetail as ssod
group by ssod.SalesOrderID
HAVING SUM(ssod.LineTotal) > 100000


--4) Viết một Batch với 3 tham số: @masp, @mancc, @soluongcc, chứa giá trị của
--các field [ProductID],[BusinessEntityID],[OnOrderQty], với giá trị truyền cho
--các biến @mancc, @masp (vd: @mancc=1650, @masp=4), thì chương trình sẽ
--gán giá trị tương ứng của field [OnOrderQty] cho biến @soluongcc, nếu
--@soluongcc trả về giá trị là null thì in ra chuỗi “Nhà cung cấp 1650 không cung
--cấp sản phẩm 4”, ngược lại (vd: @soluongcc=5) thì in chuỗi “Nhà cung cấp 1650
--cung cấp sản phẩm 4 với số lượng là 5”

select v.ProductID,v.BusinessEntityID, v.OnOrderQty
from [Purchasing].[ProductVendor] v
go

declare @masp int, @mancc int, @soluongcc int
set @mancc = 1578
set @masp = 317
set @soluongcc = (
				select v.OnOrderQty 
				from [Purchasing].[ProductVendor] v 
				where v.ProductID = @masp and v.BusinessEntityID = @mancc
                  )

if @soluongcc is null
    print N'Nhà cung cấp ' + convert(nvarchar(5), @mancc) + N' không cung cấp sản phẩm ' + convert(varchar(5), @masp)
else
    print N'Nhà cung cấp ' + convert(nvarchar(5), @mancc) + N' cấp sản phẩm ' + convert(varchar(5), @masp) + N' với số lượng là ' + convert(varchar(5), @soluongcc)
go

--5) Viết một batch thực hiện tăng lương giờ (Rate) của nhân viên trong
--[HumanResources].[EmployeePayHistory] theo điều kiện sau: Khi tổng lương
--giờ của tất cả nhân viên Sum(Rate)<6000 thì cập nhật tăng lương giờ lên 10%,
--nếu sau khi cập nhật mà lương giờ cao nhất của nhân viên >150 thì dừng.

WHILE (SELECT SUM(rate) FROM
[HumanResources].[EmployeePayHistory])<6000
BEGIN
		UPDATE [HumanResources].[EmployeePayHistory]
		SET rate = rate*1.1
		IF (SELECT MAX(rate)FROM
		[HumanResources].[EmployeePayHistory]) > 150
		  BREAK
		ELSE
		  CONTINUE
END