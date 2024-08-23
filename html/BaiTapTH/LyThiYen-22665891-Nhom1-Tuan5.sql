--Tuan 5
--1)  Viết  một  thủ  tục  tính  tổng  tiền  thu  (TotalDue)  của  mỗi  khách  hàng  trong  một 
--tháng bất kỳ của  một năm bất kỳ (tham số tháng và năm) được nhập từ bàn phím, 
--thông tin gồm: CustomerID, SumOfTotalDue  =Sum(TotalDue)
create proc TongThuTien
			@thang int,
			@nam int
as
			begin
				select c.CustomerID, SumOfTotalDue  =Sum(h.TotalDue)
				from [Sales].[Customer] c join [Sales].[SalesOrderHeader] h on c.CustomerID = h.CustomerID
				where year(h.OrderDate) = @nam and MONTH(h.OrderDate) = @thang
				group by c.CustomerID
			end
go

--Tìm kiểu dữ liệu
		select c.CustomerID, h.OrderDate, SumOfTotalDue  =Sum(h.TotalDue)
		from Sales.Customer c join Sales.SalesOrderHeader h on c.CustomerID = h.CustomerID
		group by c.CustomerID, h.OrderDate

exec [dbo].[TongThuTien] 6,2008
go

drop proc TongThuTien
go


--2)  Viết  một  thủ  tục  dùng  để  xem  doanh  thu  từ  đầu  năm  cho  đến  ngày  hiện  tại 
--(SalesYTD)  của một nhân viên bất kỳ, với một tham số đầu vào và một tham số 
--đầu ra. Tham số @SalesPerson nhận giá trị đầu vào theo chỉ định khi gọi thủ tục, 
--tham số @SalesYTD được sử dụng để chứa giá trị trả về của thủ tục. 
create proc DoanhThu @SalesPerson int, @SalesYTD int output
as
	begin
		select @SalesYTD = SalesYTD
		from [Sales].[SalesPerson]
		where BusinessEntityID = @SalesPerson
	end
go

--tìm số liệu
select *
from [Sales].[SalesPerson]

--gọi thủ tục bằng BATCH
declare @DoanhThuNam money-- biến nhận kết quả của tham số đầu ra
exec DoanhThu 290,@DoanhThuNam out
select @DoanhThuNam as [Doanh Thu Năm] -- in trị đầu ra của thủ tục
go



--3)  Viết một thủ tục trả về một danh sách ProductID, ListPrice của các sản phẩm có 
--giá bán không vượt quá một giá trị chỉ định (tham số input @MaxPrice).
create proc DanhSach @MaxPrice money
as
			begin
				select p.ProductID, p.ListPrice
				from Production.Product p
				where p.ListPrice <= @MaxPrice
			end
go

exec DanhSach 5
go


--4)  Viết thủ tục tên NewBonus cập nhật lại tiền thưởng (Bonus) cho 1 nhân viên bán 
--hàng (SalesPerson), dựa trên tổng doanh thu của nhân viên  đó. Mức thưởng mới 
--bằng mức thưởng hiện tại cộng thêm 1% tổng doanh thu. Thông tin bao gồm 
--[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó: 
--SumOfSubTotal =sum(SubTotal) 
--NewBonus = Bonus+ sum(SubTotal)*0.01

-- view
create view v_newBonus
as
    select ssoh.SalesPersonID, ssp.Bonus, ssoh.SubTotal
    from Sales.SalesPerson as ssp join Sales.SalesOrderHeader ssoh
        on ssp.BusinessEntityID = ssoh.SalesPersonID
    GROUP by ssoh.SalesPersonID, ssp.Bonus, ssoh.SubTotal
go

select *
from v_newBonus
where SalesPersonID = 280
go

-- function
create proc NewBonus
    @maNV int
AS
BEGIN
    select v.SalesPersonID, 'New Bonus' = v.Bonus+ sum(v.SubTotal) * 0.01, SumOfSubTotal =sum(v.SubTotal)
    from v_newBonus as v
    where v.SalesPersonID = @maNV
    group by v.SalesPersonID, v.Bonus, v.SubTotal
end
go

EXEC NewBonus 280

drop view v_newBonus
drop function NewBonus
go
--5) Viết một thủ tục dùng để xem thông tin của nhóm sản phẩm (ProductCategory)
--có tổng số lượng (OrderQty) đặt hàng cao nhất trong một năm tùy ý (tham số
--input), thông tin gồm: ProductCategoryID, Name, SumOfQty. Dữ liệu từ bảng
--ProductCategory, ProductSubCategory, Product và SalesOrderDetail.
--(Lưu ý: dùng Sub Query)

--view
create view v_NhomSanPham 
as
		select pc.ProductCategoryID, pc.Name, SumOfQty = sum(od.OrderQty), year(oh.OrderDate) 
		from Sales.SalesOrderHeader as oh join Sales.SalesOrderDetail as od
				on oh.SalesOrderID = od.SalesOrderID join Production.Product p
				on od.ProductID = p.ProductID join Production.ProductSubCategory as ps
				on p.ProductSubcategoryID = ps.ProductSubCategoryID join Production.ProductCategory as pc
				on ps.ProductCategoryID = pc.ProductCategoryID
		group by  pc.ProductCategoryID, pc.Name,year(oh.OrderDate)
go

select*
from v_NhomSanPham
go

create proc cau_5 @nam int
as
	begin
	select v.ProductCategoryID, v.Name, v.SumOfQty
	from v_NhomSanPham as v
	where v.SumOfQty = (
						select max(a.SumOfQty)
						from v_NhomSanPham as a
						where year(a.OrderDate) = @nam
						)
	end
go

exec cau_5 2007
go

--6) Tạo thủ tục đặt tên là TongThu có tham số vào là mã nhân viên, tham số đầu ra
--là tổng trị giá các hóa đơn nhân viên đó bán được. Sử dụng lệnh RETURN để trả
--về trạng thái thành công hay thất bại của thủ tục.
create proc TongThu @maNV int, @TongTriGia money out
as
	begin
		set @TongTriGia = (
							select sum(oh.TotalDue)
							from Sales.SalesPerson sp join [Sales].[SalesOrderHeader] oh on sp.BusinessEntityID = oh.SalesPersonID
							where BusinessEntityID = @maNV
							)
		if @TongTriGia is not null return 0 --đánh dấu giá trị trả về
		else return 1
	end
go

--Tìm dữ liệu
select BusinessEntityID, sum(oh.TotalDue) as tong
from Sales.SalesPerson sp join [Sales].[SalesOrderHeader] oh on sp.BusinessEntityID = oh.SalesPersonID
group by BusinessEntityID
order by BusinessEntityID

--Gọi thủ tục bằng Batch
declare @TongTriGia money, @TriTraVe int --Biến nhận kết quả của tham số đầu ra
exec @TriTraVe =TongThu 274, @TongTriGia out
select @TongTriGia as [Tong Tri Gia],
       @TriTraVe as TriTraVe --in trị đầu ra của thủ tục

if @TriTraVe = 0
	print N'Thủ tục thành công'
else
	print N'Thủ tục thất bại'
go

--7)  Tạo thủ tục hiển thị tên  và số tiền mua của cửa hàng mua nhiều hàng nhất theo 
--năm đã cho.
create proc ThongTinCuaHang
            @nam int
as
			begin
				select top 1 s.Name, MaxOfTotalDue = max(oh.TotalDue)
				from Sales.Store s inner join Sales.Customer c on s.BusinessEntityID = c.StoreID 
								   inner join  Sales.SalesOrderHeader oh on c.CustomerID = oh.CustomerID
				where YEAR(oh.OrderDate) = @nam
				group by s.Name,oh.TotalDue
				order by oh.TotalDue desc
			end
go

exec ThongTinCuaHang 2007
go

drop proc ThongTinCuaHang
go


--III) Function
-- Scalar Function hàm trả về 1 giá trị vô hướng

--1) Viết hàm tên CountOfEmployees (dạng scalar function) với tham số @mapb,
--giá trị truyền vào lấy từ field [DepartmentID], hàm trả về số nhân viên trong
--phòng ban tương ứng. Áp dụng hàm đã viết vào câu truy vấn liệt kê danh sách các
--phòng ban với số nhân viên của mỗi phòng ban, thông tin gồm: [DepartmentID],
--Name, countOfEmp với countOfEmp= CountOfEmployees([DepartmentID]).
create function CountOfEmployees (@mapb int)
returns int 
as
begin
return( select count(DepartmentID)
from [HumanResources].[EmployeeDepartmentHistory] 
where DepartmentID = @mapb
)
end
go

select DepartmentID, Name, countOfEmp= dbo.CountOfEmployees([DepartmentID])
from [HumanResources].[Department]
order by DepartmentID

exec CountOfEmployees 2

--3) Viết hàm tên là InventoryProd (dạng scalar function) với tham số vào là
--@ProductID và @LocationID trả về số lượng tồn kho của sản phẩm trong khu 
--vực tương ứng với giá trị của tham số
create function InventoryProd (@ProductID int, @LocationID int)
returns int
as   
begin
return(
select Quantity
from [Production].[ProductInventory]
where ProductID = @ProductID and LocationID= @LocationID
)
end
go

declare @sl int, @ProductID int, @LocationID int

set @ProductID = 1
set @LocationID = 1
set @sl = dbo.InventoryProd(@ProductID,@LocationID)

print N'Sản phẩm có mã ' + cast(@ProductID as Nvarchar(20)) + 
      N' và LocationID: ' + convert(Nvarchar(20),@LocationID) +
	  N' Có số lượng sản phẩm tồn kho là: ' + cast(@sl as Nvarchar(20))

--3) Viết hàm tên SubTotalOfEmp (dạng scalar function) trả về tổng doanh thu của
--một nhân viên trong một tháng tùy ý trong một năm tùy ý, với tham số vào
--@EmplID, @MonthOrder, @YearOrder
create function SubTotalOfEmp (@EmplID int, @MonthOrder int, @YearOrder int)
returns int
as
begin
return (
select sum(oh.TotalDue)
from [Sales].[SalesOrderHeader] oh
where year(oh.OrderDate) = @YearOrder and month(oh.OrderDate) = @MonthOrder and oh.SalesPersonID = @EmplID
)
end
go

declare @EmplID int, @MonthOrder int, @YearOrder int, @DT int

set @EmplID = 280
set @MonthOrder = 1
set @YearOrder = 2008
set @DT = dbo.SubTotalOfEmp (@EmplID, @MonthOrder, @YearOrder)


print N'Nhân viên có mã ' + cast(@EmplID as Nvarchar(20)) +
      N' trong tháng ' + cast(@MonthOrder as Nvarchar(20)) +
	  N' năm '+ cast(@YearOrder as Nvarchar(20)) +
	  N' có tổng doanh thu là: ' + cast(@DT as Nvarchar(20))

