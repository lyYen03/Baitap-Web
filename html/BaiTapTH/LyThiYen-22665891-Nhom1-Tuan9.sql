--II. CONCURRENT TRANSACTIONS (Các giao tác đồng thời)
--1) Tạo bảng Accounts (AccountID int NOT NULL PRIMARY KEY,
--balance int NOT NULL
--CONSTRAINT unloanable_account CHECK (balance >= 0)
--Chèn dữ liệu:
--INSERT INTO Accounts (acctID,balance) VALUES (101,1000);
--INSERT INTO Accounts (acctID,balance) VALUES (202,2000);
create table Accounts (AccountID int NOT NULL PRIMARY KEY,
						balance int NOT NULL
						CONSTRAINT unloanable_account CHECK (balance >= 0))

INSERT INTO Accounts (AccountID,balance) VALUES (101,1000);
INSERT INTO Accounts (AccountID,balance) VALUES (202,2000);

select * from Accounts

--2) SET TRANSACTION ISOLATION LEVEL
--SET TRANSACTION ISOLATION LEVEL
--{ READ UNCOMMITTED
--| READ COMMITTED
--| REPEATABLE READ
--| SNAPSHOT
--| SERIALIZABLE
--}[ ; ]
-- READ UNCOMMITTED: có thể đọc những dòng đang được hiệu chỉnh
--bởi các transaction khác nhưng chưa commit
-- READ COMMITTED: không thể đọc những dòng đang hiệu chỉnh bởi
----những transaction khác mà chưa commit


--3) Mở 2 cửa sổ Query của SQL server, thiết lập SET TRANSACTION ISOLATION
--LEVEL READ COMMITTED ở cả 2 cửa sổ (tạm gọi là client A bên trái, và client B
--bên phải)

--4) Thiết lập ISOLATION LEVEL REPEATABLE READ (không thể đọc được dữ liệu
--đã được hiệu chỉnh nhưng chưa commit bởi các transaction khác và không có
--transaction khác có thể hiệu chỉnh dữ liệu đã được đọc bởi các giao dịch hiện tại cho
--đến transaction hiện tại hoàn thành) ở 2 client. Thực hiện yêu cầu sau:



------------------------------------------------------------------
--Module 8. Bảo trì cơ sở dữ liệu
--Mục tiêu:
-- Backup và Recovery cơ sở dữ liệu
--1. Trong SQL Server, tạo thiết bị backup có tên adv2008back lưu trong thư mục
--T:\backup\adv2008back.bak

exec sp_addumpdevice 'disk', 'adv2008back', 'E:\backup\adv2008back.bak'

--ktra \Server Object\Backup Devices

--2. Attach CSDL AdventureWorks2008, chọn mode recovery cho CSDL này là full, 
alter database AdventureWorks2008R2
set recovery full 

--rồi thực hiện full backup vào thiết bị backup vừa tạo
backup database AdventureWorks2008R2 --file 1
to adv2008back -- tên thiết bị backup
--to disk = 'T:\backup\adv2008back.bak' hoặc ổ đĩa
with description = 'AdventureWorks2008R2 full backup'
go

--3. Mở CSDL AdventureWorks2008, tạo một transaction giảm giá tất cả mặt hàng xe
--đạp trong bảng Product xuống $15 nếu tổng trị giá các mặt hàng xe đạp không thấp
--hơn 60%.
use AdventureWorks2008R2

--Tìm hiểu csdl
select * from Production.ProductCategory
where Name = 'Bikes' -- thuộc ProductCategoryID = 1

select * from Production.ProductSubcategory
where ProductCategoryID = 1 -- có 3 loại xe đạp Mountain Bikes, Road Bikes, Touring Bikes

--lọc các mặt hàng xe đạp
select ProductID,Name,ListPrice
from Production.Product -- 97 dòng
where ProductSubcategoryID in (select ProductSubcategoryID
								from Production.ProductSubcategory
								where ProductCategoryID = 1) -- 749, 3578.27


--tạo một transaction giảm giá tất cả mặt hàng xe
--đạp trong bảng Product xuống $15 nếu tổng trị giá các mặt hàng xe đạp không thấp
--hơn 60%.
begin tran 
	declare @Tongxedap money, @Tong money
		set @Tongxedap = (select sum(ListPrice) 
		from Production.Product
		where ProductSubcategoryID in (select ProductSubcategoryID
										from Production.ProductSubcategory
										where ProductCategoryID = 1))
		set @Tong = (select sum(ListPrice) from Production.Product)

		if (@Tongxedap/@Tong) >=0.6
			begin
				update Production.Product
				set ListPrice = ListPrice -15 -- giảm giá
				where ProductSubcategoryID in (select ProductSubcategoryID
												from Production.ProductSubcategory
												where ProductCategoryID = 1)
				commit tran
			end
		else
		    rollback tran
go

--xem lại kết quả
select ProductID, Name,ListPrice
from Production.Product
where ProductSubcategoryID in (select ProductSubcategoryID
								from Production.ProductSubcategory 
								where ProductCategoryID = 1)-- 749,3563.7 đã giảm giá



--4. Thực hiện các backup sau cho CSDL AdventureWorks2008, tất cả backup đều lưu
--vào thiết bị backup vừa tạo
--a. Tạo 1 differential backup
backup database AdventureWorks2008R2 --file 2
to adv2008back
with differential, description = 'AdventureWorks2008R2 differential backup Lan 1'
go

--b. Tạo 1 transaction log backup
backup log AdventureWorks2008R2 --file 3
to adv2008back
with description = 'AdventureWorks2008R2 tranaction log backup Lan 1'
go

--5. (Lưu ý ở bước 7 thì CSDL AdventureWorks2008 sẽ bị xóa. Hãy lên kế hoạch phục
--hồi cơ sở dữ liệu cho các hoạt động trong câu 5, 6).

select * from Person.EmailAddress -- 19972 dòng

--Xóa mọi bản ghi trong bảng Person.EmailAddress, 
delete from Person.EmailAddress

--tạo 1 transaction log backup
backup log AdventureWorks2008R2 --file 4
to adv2008back
with description = 'AdventureWorks2008R2 tranaction log backup Lan 2'
go

--6. Thực hiện lệnh:
--a. Bổ sung thêm 1 số phone mới cho nhân viên có mã số business là 10000 như
--sau:
--xem dữ liệu
select * from Person.PersonPhone where BusinessEntityID > 9999
--bổ sung
INSERT INTO Person.PersonPhone VALUES (10000,'123-456-7890',1,GETDATE())
--xem dữ liệu
select * from Person.PersonPhone where BusinessEntityID > 9999-- đã có
--b. Sau đó tạo 1 differential backup cho AdventureWorks2008 và lưu vào thiết bị
--backup vừa tạo.
backup database AdventureWorks2008R2 --file 5
to adv2008back
with differential,description = 'AdventureWorks2008R2 differential bakup lan 2'
go
--c. Chú ý giờ hệ thống của máy.
--Đợi 1 phút sau, xóa bảng Sales.ShoppingCartItem

drop table Sales.ShoppingCartItem

select * from Sales.ShoppingCartItem -- không còn bảng này

--7. Xóa CSDL AdventureWorks2008
use master
drop database AdventureWorks2008R2-- giả lập xoá csdl

--8. Để khôi phục lại CSDL:
--kiểm tra file = x để biết restore từ file nào
restore headeronly
from disk = 'E:\backup\adv2008back.bak'
--Backup type = 1 : Database
--Backup type = 2 : log backup
--Backup type = 5 : differential backup


--a. Như lúc ban đầu (trước câu 3) thì phải restore thế nào?
restore database AdventureWorks2008R2
from adv2008back -- tên thiết bị backup
with file = 1,recovery
go

--kiểm tra giá xe đạp
use AdventureWorks2008R2

select ProductID,Name,ListPrice --97 dòng
from Production.Product
where ProductSubcategoryID in (select ProductSubcategoryID 
								from Production.ProductSubcategory 
								where ProductCategoryID = 1)


--b. Ở tình trạng giá xe đạp đã được cập nhật và bảng Person.EmailAddress vẫn
--còn nguyên chưa bị xóa (trước câu 5) thì cần phải restore thế nào?
use master
drop database AdventureWorks2008R2

restore database AdventureWorks2008R2
from adv2008back 
with file = 1, norecovery 
go

restore database AdventureWorks2008R2
from adv2008back 
with file = 2, norecovery
go

restore log AdventureWorks2008R2
from adv2008back 
with file = 3, recovery
go

--khôi phục có đạt yêu cầu?
use AdventureWorks2008R2

--kiểm tra giá
select ProductID,Name,ListPrice --đã giảm
from Production.Product
where ProductSubcategoryID in (select ProductSubcategoryID 
								from Production.ProductSubcategory 
								where ProductCategoryID = 1)
--kiểm tra bảng 
select * from Person.EmailAddress -- chưa bị xoá

--c. Đến thời điểm đã được chú ý trong câu 6c thì thực hiện việc restore lại CSDL
--AdventureWorks2008 ra sao?

--9. Thực hiện đoạn lệnh sau:
CREATE DATABASE Plan2Recover;
USE Plan2Recover;


CREATE TABLE T1 (
PK INT Identity PRIMARY KEY,
Name VARCHAR(15)
);
GO

INSERT T1 VALUES ('Full');
GO

BACKUP DATABASE Plan2Recover
TO DISK = 'E:\P2R.bak'
WITH NAME = 'P2R_Full',
INIT;

--Tiếp tục thực hiện các lệnh sau:
INSERT T1 VALUES ('Log 1');
GO

ALTER DATABASE Plan2Recover SET RECOVERY FULL;


BACKUP Log Plan2Recover
TO DISK ='E:\P2R.bak'
WITH NAME = 'P2R_Log';

--Tiếp tục thực hiện các lệnh sau:
INSERT T1 VALUES ('Log 2');
GO

BACKUP Log Plan2Recover
TO DISK ='E:\P2R.bak'
WITH NAME = 'P2R_Log';

--Xóa CSDL vừa tạo, rồi thực hiện quá trình khôi phục như sau:
Use Master;
drop database Plan2Recover

RESTORE DATABASE Plan2Recover
FROM DISK = 'E:\P2R.bak'
With FILE = 1, NORECOVERY;

RESTORE LOG Plan2Recover
FROM DISK ='E:\P2R.bak'
With FILE = 2, NORECOVERY;

RESTORE LOG Plan2Recover
FROM DISK ='E:\P2R.bak'
With FILE = 3, RECOVERY;

use Plan2Recover

select * from T1