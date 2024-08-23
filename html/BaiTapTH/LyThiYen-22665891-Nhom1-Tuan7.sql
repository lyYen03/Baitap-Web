--Trigger on an INSERT, UPDATE, or DELETE statement to a table or view (DML Trigger)
--CREATE TRIGGER [schema_name .] Jtrigger_name
--ON { table | view } 
--{ FOR | AFTER | INSTEAD OF }
--{ [INSERT ] [, ] [ UPDATE ] [, ] [ DELETE ] }
--AS {sq1 statement [;]}
--FOR | AFTER: trigger chay noi dung ghi bên trong nó SAU khi cập nhat CSDL 
--INSTEAD OF: trigger chạy noi dung ghi bên trong nó THAY CHO việc cap nhat CSDL


--***1. Tạo một Instead of trigger thực hiện trên view. Thực hiện theo các bước sau:
-- Tạo mới 2 bảng M_Employees và M_Department theo cấu trúc sau:
create table M_Department
	(
	DepartmentID int not null primary key,
	Name nvarchar(50),
	GroupName nvarchar(50)
	)

create table M_Employees
	(
	EmployeeID int not null primary key,
	Firstname nvarchar(50),
	MiddleName nvarchar(50),
	LastName nvarchar(50),
	DepartmentID int foreign key references M_Department(DepartmentID)
	)
go
--Tạo một view tên EmpDepart_View bao gồm các field: EmployeeID,
--FirstName, MiddleName, LastName, DepartmentID, Name, GroupName, dựa
--trên 2 bảng M_Employees và M_Department
create view EmpDepart_View
as
select EmployeeID, FirstName, MiddleName, LastName, d.DepartmentID, Name, GroupName
from M_Department D join M_Employees E on d.DepartmentID = e.DepartmentID
go
--Tạo một trigger tên InsteadOf_Trigger thực hiện trên view
--EmpDepart_View, dùng để chèn dữ liệu vào các bảng M_Employees và
--M_Department khi chèn một record mới thông qua view EmpDepart_View.
create trigger InsteadOf_Trigger
on EmpDepart_View
instead of insert  -- trigger chạy thay chi việc cập nhật csdl
as
	begin
	if exists (select * from inserted) -- có dùng trigger để chèn dữ liệu
		begin raiserror (N' chèn dữ liệu vào 2 bảng',11,1)
		--Chèn dữ liệu vào bảng M_Department
		insert M_Department
		select DepartmentID,Name, GroupName
		from inserted

		--Chèn dữ liệu vào bảng M_Employees
		insert M_Employees
		select EmployeeID, FirstName, MiddleName, LastName, DepartmentID
		from inserted
		end
	else
	     raiserror (N'Không có dữ liệu trong inserted',11,2)
	end
go

--Kiểm tra trigger
insert EmpDepart_view values(1, 'Nguyen','Hoang','Huy', 11,'Marketing','Sales')

select * from M_Employees
select * from M_Department
select * from EmpDepart_view
go

--**2. Tạo một trigger thực hiện trên bảng MSalesOrders có chức năng thiết lập độ ưu
--tiên của khách hàng (CustPriority) khi người dùng thực hiện các thao tác Insert,
--Update và Delete trên bảng MSalesOrders theo điều kiện như sau:
-- Nếu tổng tiền Sum(SubTotal) của khách hàng dưới 10,000 $ thì độ ưu tiên của
--khách hàng (CustPriority) là 3
-- Nếu tổng tiền Sum(SubTotal) của khách hàng từ 10,000 $ đến dưới 50000 $
--thì độ ưu tiên của khách hàng (CustPriority) là 2
-- Nếu tổng tiền Sum(SubTotal) của khách hàng từ 50000 $ trở lên thì độ ưu tiên
--của khách hàng (CustPriority) là 1
--Các bước thực hiện:
-- Tạo bảng MCustomers và MSalesOrders theo cấu trúc
create table MCustomer
	(
	CustomerID int not null primary key,
	CustPriority int
	)

create table MSalesOrders
	(
	SalesOrderID int not null primary key,
	OrderDate date,
	SubTotal money,
	CustomerID int foreign key references MCustomer(CustomerID) 
	)
go
--Chèn dữ liệu cho bảng MCustomers, lấy dữ liệu từ bảng Sales.Customer,
--nhưng chỉ lấy CustomerID>30100 và CustomerID<30118, cột CustPriority cho
--giá trị null.

insert MCustomer
	select CustomerID, null
	from Sales.Customer
	where CustomerID > 30100 and CustomerID < 30118

--kiểm tra
select * from MCustomer go

-- Chèn dữ liệu cho bảng MSalesOrders, lấy dữ liệu từ bảng
--Sales.SalesOrderHeader, chỉ lấy những hóa đơn của khách hàng có trong bảng
--khách hàng.
insert MSalesOrders
	select SalesOrderID,OrderDate,SubTotal,CustomerID
	from Sales.SalesOrderHeader
	where CustomerID in (select CustomerID from MCustomer) AND SalesOrderID NOT IN (SELECT SalesOrderID FROM MSalesOrders)
--chỉ chọn các dòng từ 'SalesOrderHeader' mà không tồn tại trong bảng 'MSalesOrders'. Điều này sẽ ngăn chặn việc chèn dữ liệu trùng lặp vào bảng.

--kiểm tra
select * from MSalesOrders go

--Viết trigger để lấy dữ liệu từ 2 bảng inserted và deleted.
create trigger After_Trigger 
on MSalesOrders
after insert,update,delete -- trigger chạy sau
as
begin
	declare @makh int, @tong money
	if exists (select * from inserted) -- có chèn hoặc cập nhật dữ liệu
		begin
		-- 2 cách xuất thông báo: dùng print hoặc raiserror
		print (N' đang chạy trigger')
		raiserror (N'có chèn dữ liệu',11,3)

		--dùng biến để giữ lại giá trị trong bản inserted
		select @makh = CustomerID, @tong = sum(SubTotal)
		from inserted
		group by CustomerID

		update MCustomer
		set CustPriority = 
		case 
			when @tong < 10000 then 3
			when @tong>=10000 and @tong <50000 then 2
			when @tong>=50000then 1
		end

		raiserror(N'có xoá dữ liệu',11,4)
		select @makh = CustomerID -- giữ lại mã kh bị xoá dữ liệu
		from deleted

		update MCustomer
		set CustPriority = null -- tính đơn giản
		where CustomerID = @makh
		end
end
go

--drop trigger After_Trigger
--tìm hiểu phạm vi dữ liệu
select CustomerID,SalesOrderID,sum(SubTotal) as SumofSubTotal
from MSalesOrders
group by CustomerID,SalesOrderID
order by SumofSubTotal

--trước khi chạy trigger
select * from MSalesOrders --chưa có dòng SalesOrderID = 10000
select * from MCustomer -- CustPriority = null

--chạy trigger bằng insert
insert MSalesOrders values (10000,GETDATE(),60000,30101) -- ưu tiên 1
insert MSalesOrders values (10001,GETDATE()+1,500,30102) -- ưu tiên 3

select * from MSalesOrders --ktra do uu tien
select * from MCustomer 

--chay trigger bang update
update MSalesOrders
set SubTotal = 40000 --uu tien 2
where SalesOrderID = 10000 --CustomerID = 30101

--chay trigger bang delete
delete
from MSalesOrders
where SalesOrderID = 10001 -- xoa CustomerID = 30102, uu tien 3


select * from MSalesOrders -- CustomerID = 30102, uu tien = null
select * from MCustomer 
--3.  Viết  một  trigger  thực  hiện  trên  bảng  MEmployees  sao  cho  khi  người  dùng  thực
--hiện chèn thêm một nhân viên mới vào bảng  MEmployees  thì chương trình cập 
--nhật số nhân viên trong cột  NumOfEmployee của bảng  MDepartment. Nếu tổng 
--số nhân viên của phòng tương ứng <=200 thì cho phép chèn thêm, ngược lại thì 
--hiển thị thông báo “Bộ phận đã đủ nhân viên” và hủy giao tác. Các bước thực  hiện:
--  Tạo mới 2 bảng MEmployees và MDepartment theo cấu trúc  sau:

create table MDepartment 
	(
	DepartmentID int not null primary key, 
	Name nvarchar(50),
	NumOfEmployee int
	)
create table MEmployees 
	(
	EmployeeID int not null, 
	FirstName nvarchar(50), 
	MiddleName nvarchar(50), 
	LastName nvarchar(50),
	DepartmentID int foreign key references MDepartment(DepartmentID), 
	constraint pk_emp_depart primary key(EmployeeID, DepartmentID)
	) 

-- Chèn dữ liệu cho bảng  MDepartment, lấy  dữ liệu từ bảng  Department, cột 
--NumOfEmployee  gán  giá  trị  NULL,  
insert MDepartment
select DepartmentID, Name, null
from HumanResources.Department

--bảng  MEmployees  lấy  từ  bảng EmployeeDepartmentHistory
insert MEmployees
select ed.BusinessEntityID, FirstName,MiddleName,LastName,DepartmentID
from HumanResources.Employee e join Person.Person p on e.BusinessEntityID = p.BusinessEntityID
     join HumanResources.EmployeeDepartmentHistory ed on ed.BusinessEntityID= p.BusinessEntityID


select * from MEmployees go

--Viết trigger theo yêu cầu trên và viết câu lệnh hiện thực  trigger
create trigger trigger_MEmployees
on MEmployees 
after insert,update,delete 
as
begin
	declare @slnv int, @mapb money
		if exists (select * from inserted) -- có chèn hoặc cập nhật dữ liệu
			begin
			-- 2 cách xuất thông báo: dùng print hoặc raiserror
			print (N' đang chạy trigger')
			raiserror (N'có chèn dữ liệu',11,3)

			select @mapb = DepartmentID
			from inserted

			set @slnv =
				(select count(*)
				from MEmployees
				where DepartmentID = @mapb
				)

			if @slnv > 200
				begin 
					print (N'Bo phan da du nhan vien')
					rollback
				end
			else
				begin
					update MDepartment
					set NumOfEmployee = @slnv
					where DepartmentID = @mapb
				end
		end
end
go


--test trigger
INSERT Memployees
VALUES(291, 'Ly', 'Thi', 'Yen', 1),
	(292, 'Ly', 'Ngoc', 'Yen', 2)

--kiem tra ket qua
SELECT *
FROM MDepartment

select * from MEmployees
go
--4.Bảng  [Purchasing].[Vendor], chứa thông tin của nhà cung cấp, thuộc    tính
--CreditRating hiển thị thông tin đánh giá mức tín dụng, có các giá trị: 
--1 = Superior
--2 = Excellent
--3 = Above average 
--4 = Average
--5 = Below average
--Viết  một  trigger  nhằm  đảm  bảo  khi  chèn  thêm  một  record  mới  vào  bảng 
--[Purchasing].[PurchaseOrderHeader],  nếu  Vender  có  CreditRating=5  thì  hiển  thị 
--thông báo không cho phép chèn và đồng thời hủy giao tác.
--Dữ liệu test
--INSERT  INTO  Purchasing.PurchaseOrderHeader  (RevisionNumber,  Status, 
--EmployeeID,  VendorID,  ShipMethodID,  OrderDate,  ShipDate,  SubTotal,  TaxAmt, 
--Freight) VALUES ( 2 ,3, 261, 1652, 4 ,GETDATE() ,GETDATE() , 44594.55,
--,3567.564, ,1114.8638 );

--CREATE TRIGGER [schema_name .] Jtrigger_name
--ON { table | view } 
--{ FOR | AFTER | INSTEAD OF }
--{ [INSERT ] [, ] [ UPDATE ] [, ] [ DELETE ] }
--AS {sq1 statement [;]}
--FOR | AFTER: trigger chay noi dung ghi bên trong nó SAU khi cập nhat CSDL 
--INSTEAD OF: trigger chạy noi dung ghi bên trong nó THAY CHO việc cap nhat CSDL

create trigger cau4 
on [Purchasing].[PurchaseOrderHeader]
for insert 
as
	if exists(
		select * 
		from Purchasing.PurchaseOrderHeader h 
		join inserted i on h.PurchaseOrderID = i.PurchaseOrderID
		join Purchasing.Vendor v on i.VendorID = v.BusinessEntityID                            
		where v.CreditRating = 5
	)
	begin 
	raiserror ('A vendor''s credit rating is too low to accept new purchase orders.', 16, 1)
	ROLLBACK TRANSACTION
	end
go

--Dữ liệu test
INSERT  INTO  Purchasing.PurchaseOrderHeader  (RevisionNumber,  Status, EmployeeID,  VendorID,  ShipMethodID,  OrderDate,  ShipDate,  SubTotal,  TaxAmt, Freight) 
VALUES ( 2 ,3, 261, 1652, 4 ,GETDATE() ,GETDATE() , 44594.55,3567.564,1114.8638 );
go
--5.  Viết  một  trigger  điều  chỉnh  số  liệu  trên  bảng  ProductInventory  (lưu  thông  tin  số 
--lượng  sản  phẩm  trong  kho).  Khi 
--chèn  thêm  một  đơn  đặt  hàng  vào 
--bảng  SalesOrderDetail  với  số 
--lượng xác định trong   field
--OrderQty, nếu số lượng trong kho 
--Quantity> OrderQty thì cập nhật 
--lại  số   lượng   trong   kho 
--Quantity=  Quantity-  OrderQty, 
--ngược lại nếu Quantity=0 thì xuất 
--thông báo “Kho hết hàng” và đồng 
--thời hủy giao  tác.

CREATE TRIGGER bai5 ON Sales.SalesOrderDetail
FOR INSERT
AS
BEGIN
	DECLARE @Qty INT, @Quantity INT, @productID INT
	SELECT @qty = i.OrderQty, @productID = i.ProductID
	FROM inserted i

	SELECT @Quantity =  p.Quantity
	FROM Production.ProductInventory p
	WHERE @productID = p.ProductID

	IF(@Quantity > @Qty)
	BEGIN
		UPDATE Production.ProductInventory
				SET quantity = @Quantity - @Qty
				WHERE productID = @productID
	END
	ELSE IF (@Quantity = 0)
	BEGIN
		PRINT N'Kho hết hàng'
		ROLLBACK
	END
END
GO


SELECT*
FROM Sales.SalesOrderDetail
SELECT*
FROM Sales.SalesOrderHeader
SELECT*
FROM Production.ProductInventory
WHERE [ProductID]=708

---thuc thi trigger
DELETE FROM Sales.SalesOrderDetail
INSERT Sales.SalesOrderDetail(SalesOrderID,CarrierTrackingNumber,OrderQty,ProductID,SpecialOfferID,UnitPrice)
VALUES(43661,300,1,708,1,1111.111)
go

--6. Tạo trigger cập nhật tiền thưởng (Bonus) cho nhân viên bán hàng SalesPerson, khi
--người dùng chèn thêm một record mới trên bảng SalesOrderHeader, theo quy định
--như sau: Nếu tổng tiền bán được của nhân viên có hóa đơn mới nhập vào bảng
--SalesOrderHeader có giá trị >10000000 thì tăng tiền thưởng lên 10% của mức
--thưởng hiện tại. Cách thực hiện:
-- Tạo hai bảng mới M_SalesPerson và M_SalesOrderHeader
--create table M_SalesPerson
--(
--SalePSID int not null primary key,
--TerritoryID int,
--BonusPS money
--)
--create table M_SalesOrderHeader
--(
--SalesOrdID int not null primary key,
--OrderDate date,
--SubTotalOrd money,
--SalePSID int foreign key references M_SalesPerson(SalePSID)
--)
-- Chèn dữ liệu cho hai bảng trên lấy từ SalesPerson và SalesOrderHeader chọn
--những field tương ứng với 2 bảng mới tạo.
-- Viết trigger cho thao tác insert trên bảng M_SalesOrderHeader, khi trigger
--thực thi thì dữ liệu trong bảng M_SalesPerson được cập nhật.
create table M_SalesPerson
	(
	SalePSID int not null primary key,
	TerritoryID int,
	BonusPS money
	)
create table M_SalesOrderHeader
	(
	SalesOrdID int not null primary key,
	OrderDate date,
	SubTotalOrd money,
	SalePSID int foreign key references M_SalesPerson(SalePSID)
	)

insert into M_SalesPerson
select BusinessEntityID,TerritoryID,Bonus
from sales.SalesPerson

insert into M_SalesOrderHeader
select SalesOrderID,OrderDate,SubTotal,SalesPersonID
from sales.SalesOrderHeader
go


create trigger cau6
on M_SalesOrderHeader
after insert 
as
	begin
		declare @doanhthu money, @manv int
		select @manv=i.SalePSID
		from inserted i

		set @doanhthu = (select sum(SubTotalOrd)
						from M_SalesOrderHeader
						where SalePSID = @manv)
		if @doanhthu > 10000000
			begin
				update M_SalesPerson
				set BonusPS += BonusPS * 0.1
				where SalePSID = @manv
			end
	end
