--Tuần 8
--Module 6. ROLE - PERMISSION\


EXEC sp_helplogins
EXEC sp_helplogins 'sa'
--1)  Đăng nhập vào  SQL  bằng SQL  Server authentication, tài khoản sa.  Sử dụng T-SQL.

--2)  Tạo hai login SQL server Authentication User2 và  User3
create login User2 with password ='@user2',
default_database = AdventureWorks2008R2

create login User3 with password ='@user3',
default_database = AdventureWorks2008R2

--3)  Tạo một database user User2 ứng với login User2 và một database user   User3
--ứng với login User3 trên CSDL AdventureWorks2008.
use AdventureWorks2008R2 --phai cao CSDL, tao user tren CSDL nay
create user User2 for login User2 --Tên login phải trùng với tên 
create user User3 for login User3

EXEC sp_helpuser 'dbo'
EXEC sp_helpuser

--4) Tạo 2 kết nối đến server thông qua login User2 và User3, sau đó thực hiện các
--thao tác truy cập CSDL của 2 user tương ứng (VD: thực hiện câu Select). Có thực
--hiện được không?
select * from HumanResources.Employee

--Thực hiện không được, Lỗi
--The SELECT permission was denied on the object 'Employee', database 'AdventureWorks2008R2', schema 'HumanResources'.

--5) Gán quyền select trên Employee cho User2, kiểm tra kết quả. Xóa quyền select
--trên Employee cho User2. Ngắt 2 kết nối của User2 và User3

--Gán quyền select trên Employee cho User2
grant select on HumanResources.Employee to User2

--kiểm tra kết quả trên cửa sổ của của user (đã thưc thi được)
--Xóa quyền select trên Employee cho User2
revoke select on HumanResources.Employee to User2
--kiểm tra kết quả trên cửa sổ của của user

--Ngắt 2 kết nối của User2 và User3

--6) Trở lại kết nối của sa, tạo một user-defined database Role tên Employee_Role trên
--CSDL AdventureWorks2008, sau đó gán các quyền Select, Update, Delete cho
--Employee_Role.

--CREATE ROLE role_name 
create Role Employee_Role

--sau đó gán các quyền Select, Update, Delete cho Employee_Role.
grant Select, Update, Delete on HumanResources.Employee to Employee_Role

--7) Thêm các User2 và User3 vào Employee_Role. Tạo lại 2 kết nối đến server thông
--qua login User2 và User3 thực hiện các thao tác sau:
EXEC sp_addrolemember Employee_Role, User2
EXEC sp_addrolemember Employee_Role, User3
--a) Tại kết nối với User2, thực hiện câu lệnh Select để xem thông tin của bảng
--Employee
select * from HumanResources.Employee
--b) Tại kết nối của User3, thực hiện cập nhật JobTitle=’Sale Manager’ của nhân
--viên có BusinessEntityID=1
update HumanResources.Employee
set JobTitle='Sale Maager'
where BusinessEntityID=1
--ktra
select * from HumanResources.Employee where BusinessEntityID=1
--cập nhật được
--c) Tại kết nối User2, dùng câu lệnh Select xem lại kết quả.
select * from HumanResources.Employee
--d) Xóa role Employee_Role, (quá trình xóa role ra sao?)
 drop role Employee_Role -- không xoá được

 --cần xoá các user trước
 exec sp_droprolemember Employee_Role, User2
 exec sp_droprolemember Employee_Role, User3
 --ktra (đã xoá)

 --thực hiện lại
  drop role Employee_Role --đã xoá


  --***************************************************************************************
  --Module 7. TRANSACTION
--  I. SINGLE TRANSACTION
--Autocommit mode là chế độ quản lý giao dịch mặc định của SQL Server Database
--Engine. Mỗi lệnh Transact-SQL được Commit hoặc Rollback khi nó hoàn thành.
--1) Thêm vào bảng Department một dòng dữ liệu tùy ý bằng câu lệnh
--INSERT..VALUES…
select *
from HumanResources.Department--18 phòng ban

insert into HumanResources.Department(DepartmentID,Name,GroupName,ModifiedDate)
values(25,'Cust Care',N'Chăm sóc khách hàng',getdate())

set IDENTITY_INSERT HumanResources.Department on
--a) Thực hiện lệnh chèn thêm vào bảng Department một dòng dữ liệu tùy ý bằng
--cách thực hiện lệnh Begin tran và Rollback, dùng câu lệnh Select * From
--Department xem kết quả.
begin tran T1
insert into HumanResources.Department(DepartmentID,Name,GroupName,ModifiedDate)--phải có danh sách thuộc tính
values(20,'Cust Care',N'Chăm sóc khách hàng',getdate())
rollback tran T1

--xem lại kết quả 
select *
from HumanResources.Department

--b) Thực hiện câu lệnh trên với lệnh Commit và kiểm tra kết quả.
begin tran T1
insert into HumanResources.Department(DepartmentID,Name,GroupName,ModifiedDate)--phải có danh sách thuộc tính
values(20,'Cust Care2',N'Chăm sóc khách hàng',getdate())
commit

--xem lại kết quả 
select *
from HumanResources.Department

--2) Tắt chế độ autocommit của SQL Server (SET IMPLICIT_TRANSACTIONS
--ON). 
SET IMPLICIT_TRANSACTIONS ON
--Tạo đoạn batch gồm các thao tác:
begin tran 
-- Thêm một dòng vào bảng Department
insert into HumanResources.Department(DepartmentID,Name,GroupName,ModifiedDate)--phải có danh sách thuộc tính
values(17,'Inverstment & Development',N'Đầu tư và phát triển',getdate())
-- Tạo một bảng Test (ID int, Name nvarchar(10))
create table Test(ID int primary key, Name nvarchar(10))
-- Thêm một dòng vào Test
insert into Test values (1,'Test')
rollback 
go
-- Xem dữ liệu ở bảng Department và Test để kiểm tra dữ liệu, giải thích kết
select *
from HumanResources.Department --không có dòng 17


--3) Viết đoạn batch thực hiện các thao tác sau (lưu ý thực hiện lệnh SET
--XACT_ABORT ON: nếu câu lệnh T-SQL làm phát sinh lỗi run-time, toàn bộ giao
--dịch được chấm dứt và Rollback)
SET XACT_ABORT ON
begin tran
-- Câu lệnh SELECT với phép chia 0 :SELECT 1/0 as Dummy
SELECT 1/0 as Dummy
-- Cập nhật một dòng trên bảng Department với DepartmentID=’9’ (id này
--không tồn tại)
update HumanResources.Department
set Name = 'New Department'
where DepartmentID='9'
-- Xóa một dòng không tồn tại trên bảng Department (DepartmentID =’66’)
delete
from HumanResources.Department
where DepartmentID ='66'
-- Thêm một dòng bất kỳ vào bảng Department
insert into HumanResources.Department(DepartmentID,Name,GroupName,ModifiedDate)--phải có danh sách thuộc tính
values(21,'Inverstment & Development',N'Đầu tư và phát triển',getdate())
-- COMMIT;
commit 
go
--Thực thi đoạn batch, quan sát kết quả và các thông báo lỗi và giải thích kết quả.
--ktra 
select *
from HumanResources.Department --không có dòng 21 do lỗi run-tỉme ở câu 1 nên toàn bộ giao
--dịch được chấm dứt và Rollback

--4) Thực hiện lệnh SET XACT_ABORT OFF (những câu lệnh lỗi sẽ rollback,
--transaction vẫn tiếp tục) sau đó thực thi lại các thao tác của đoạn batch ở câu 3. Quan
--sát kết quả và giải thích kết quả?
SET XACT_ABORT OFF

begin tran
-- Câu lệnh SELECT với phép chia 0 :SELECT 1/0 as Dummy
SELECT 1/0 as Dummy
-- Cập nhật một dòng trên bảng Department với DepartmentID=’9’ (id này
--không tồn tại)
update HumanResources.Department
set Name = 'New Department'
where DepartmentID='9'
-- Xóa một dòng không tồn tại trên bảng Department (DepartmentID =’66’)
delete
from HumanResources.Department
where DepartmentID ='66'
-- Thêm một dòng bất kỳ vào bảng Department
insert into HumanResources.Department(DepartmentID,Name,GroupName,ModifiedDate)--phải có danh sách thuộc tính
values(21,'Inverstment & Development',N'Đầu tư và phát triển',getdate())
-- COMMIT;
commit 
go
--Thực thi đoạn batch, quan sát kết quả và các thông báo lỗi và giải thích kết quả.
--ktra 
select *
from HumanResources.Department --- có dòng 21 câu 1 lỗi thì được bỏ qua các dòng khác vẫn được thực thi
