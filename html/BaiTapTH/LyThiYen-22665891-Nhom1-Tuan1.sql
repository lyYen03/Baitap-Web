-- 1. Sử dụng T-SQL tạo một cơ sở dữ liệu mới tên SmallWorks, với 2 file group tên
--SWUserData1 và SWUserData2
USE master
CREATE DATABASE SmallWorks
ON PRIMARY
	(
	NAME = 'SmallWorksPrimary',
	FILENAME = 'E:\LyThiYen\SmallWorks.mdf',
	SIZE = 10MB,
	FILEGROWTH = 20%,
	MAXSIZE  = 50MB
	),

FILEGROUP SWUserData1
	(
	NAME = 'SmallWorksData1',
	FILENAME = 'E:\LyThiYen\SmallWorksData1.ndf',
	SIZE = 10MB,
	FILEGROWTH = 20%,
	MAXSIZE  = 50MB
	),

FILEGROUP SWUserData2
	(
	NAME = 'SmallWorksData2',
	FILENAME = 'E:\LyThiYen\SmallWorksData2.ndf',
	SIZE = 10MB,
	FILEGROWTH = 20%,
	MAXSIZE  = 50MB
	)

LOG ON
	(
	NAME = 'SmallWorks_log',
	FILENAME = 'E:\LyThiYen\SmallWorks_log.ldf',
	SIZE = 10MB,
	FILEGROWTH = 10%,
	MAXSIZE  = 20MB
	)


--3. Dùng SSMS để xem kết quả: Click phải trên tên của CSDL vừa tạo
--a. Chọn filegroups, quan sát kết quả:
-- Có bao nhiêu filegroup, liệt kê tên các filegroup hiện tại
--Có 3 filegroup là : PRIMARY,SWUserData1 và SWUserData2
-- Filegroup mặc định là gì?
--filegroup mặc định là : PRIMARY
--b. Chọn Files, quan sát có bao nhiêu database file?
--có 4 database file 

--4. Dùng T-SQL tạo thêm một filegroup tên Test1FG1 trong SmallWorks, 
ALTER DATABASE SmallWorks
ADD FILEGROUP Test1FG1
GO 

--sau đó add thêm 2 file filedat1.ndf và filedat2.ndf dung lượng 5MB vào filegroup Test1FG1.
ALTER DATABASE SmallWorks
ADD FILE
(
	NAME = 'Data1',
	FILENAME = 'E:\LyThiYen\filedat1.ndf',
	SIZE = 5MB
),
(
	NAME = 'Data2',
	FILENAME = 'E:\LyThiYen\filedat2.ndf',
	SIZE = 5MB
)
TO FILEGROUP Test1FG1


--5. Dùng T-SQL tạo thêm một một file thứ cấp filedat3.ndf dung lượng 3MB trong
--filegroup Test1FG1
ALTER DATABASE SmallWorks
ADD FILE
(
	NAME = 'Data3',
	FILENAME = 'E:\LyThiYen\filedat3.ndf',
	SIZE = 3MB
)
TO FILEGROUP Test1FG1

--Sau đó sửa kích thước tập tin này lên 5MB
ALTER DATABASE SmallWorks
MODIFY FILE
(
	NAME = 'Data3',
	SIZE = 5MB
)

--Dùng T-SQL xóa file thứ cấp filedat3.nd
ALTER DATABASE SmallWorks
REMOVE FILE Data3
GO

--6.Xóa filegroup Test1FG1? 
ALTER DATABASE SmallWorks
REMOVE FILEGROUP Test1FG1

--Bạn có xóa được không? Nếu không giải thích? Muốn xóa được bạn phải làm gì?
-- KHÔNG XOÁ ĐƯỢC DO FILEGOUP ĐÓ KH RỖNG, CẦN PHẢI XOÁ CÁC FILE TRONG FILEGROUP TRƯỚC 

ALTER DATABASE SmallWorks
REMOVE FILE Data1

ALTER DATABASE SmallWorks
REMOVE FILE Data2


ALTER DATABASE SmallWorks
REMOVE FILEGROUP Test1FG1
GO

--7. Xem lại thuộc tính (properties) của CSDL SmallWorks bằng cửa sổ thuộc tính
--properties và bằng thủ tục hệ thống sp_helpDb, sp_spaceUsed, sp_helpFile

sp_helpDb SmallWorks
GO 
--Hiển thị thông tin tổng quan về cơ sở dữ liệu như tên, kích thước, tình trạng, owner, v.v.


sp_spaceUsed 
GO
--Hiển thị thông tin về không gian sử dụng trong cơ sở dữ liệu.


sp_helpFile 
GO
--Hiển thị thông tin về các tập tin dữ liệu và log của cơ sở dữ liệu, bao gồm tên file, vị trí, kích thước, v.v.

--8. Tại cửa sổ properties của CSDL SmallWorks, chọn thuộc tính ReadOnly, sau đó
--đóng cửa sổ properties. Quan sát màu sắc của CSDL. 


--Dùng lệnh T-SQL gỡ bỏ thuộc tính ReadOnly 
ALTER DATABASE SmallWorks
SET READ_WRITE 
GO

--Đặt thuộc tính cho phép nhiều người sử dụng CSDL SmallWorks.
ALTER DATABASE SmallWorks
SET MULTI_USER
GO

--9. Trong CSDL SmallWorks, tạo 2 bảng mới
USE SmallWorks -- PHẢI CÓ TRƯỚC KHI TẠO 2 BẢNG
CREATE TABLE dbo.Person
(
PersonID int NOT NULL,
FirstName varchar(50) NOT NULL,
MiddleName varchar(50) NULL,
LastName varchar(50) NOT NULL,
EmailAddress nvarchar(50) NULL
) ON SWUserData1

CREATE TABLE dbo.Product
(
ProductID int NOT NULL,
ProductName varchar(75) NOT NULL,
ProductNumber nvarchar(25) NOT NULL,
StandardCost money NOT NULL,
ListPrice money NOT NULL
) ON SWUserData2

--10. Chèn dữ liệu vào 2 bảng trên, lấy dữ liệu từ bảng Person và bảng Product trong
--AdventureWorks2008 (lưu ý: chỉ rõ tên cơ sở dữ liệu và lược đồ), dùng lệnh
--Insert…Select... 
INSERT INTO Person(PersonID,FirstName,MiddleName,LastName,EmailAddress)
SELECT P.BusinessEntityID,P.FirstName,P.MiddleName,P.LastName,E.EmailAddress
FROM AdventureWorks2008R2.Person.Person AS P INNER JOIN
     AdventureWorks2008R2.Person.EmailAddress AS E 
	 ON P.BusinessEntityID = E.BusinessEntityID

--và bảng Product trong AdventureWorks2008
INSERT Product(ProductID,ProductName,ProductNumber,StandardCost,ListPrice)
SELECT ProductID,Name,ProductNumber,StandardCost,ListPrice
FROM AdventureWorks2008R2.Production.Product

--Dùng lệnh Select * để xem dữ liệu trong 2 bảng Person và bảng Product trong SmallWorks
SELECT *
FROM Person

SELECT *
FROM Product

--11. Dùng SSMS, Detach cơ sở dữ liệu SmallWorks ra khỏi phiên làm việc của SQL
--12. Dùng SSMS, Attach cơ sở dữ liệu SmallWorks vào SQL





--BÀI TẬP VỀ NHÀ:
USE master

CREATE DATABASE Sales

--1. Tạo các kiểu dữ liệu người dùng 
USE Sales 
EXEC sp_addtype 'Mota', 'NVARCHAR(40)'
EXEC sp_addtype 'IDKH', 'CHAR(10)', 'NOT NULL'
EXEC sp_addtype 'DT', 'CHAR(12)'


--2. Tạo các bảng 
CREATE TABLE SanPham
(
	Masp CHAR(6) NOT NULL,
	Tensp VARCHAR(20) NOT NULL,
	NgayNhap DATE,
	DVT CHAR(10) NOT NULL,
	SoLuongTon INT,
	DonGiaNhap MONEY
)


CREATE TABLE HoaDon
(
	MaHD CHAR(10) NOT NULL,
	NgayLap DATE,
	NgayGiao DATE,
	Makh IDKH,
	DienGiai Mota,
)

CREATE TABLE KhachHang
(
	MaKH IDKH,
	TenKH NVARCHAR(30)  NOT NULL,
	Diachi NVARCHAR(40),
	Dienthoai DT,
)

CREATE TABLE ChiTietHD
(
	MaHD CHAR(10) NOT NULL,
	Masp CHAR(6) NOT NULL,
	Soluong int
)

--3. Trong Table HoaDon, sửa cột DienGiai thành nvarchar(100)
ALTER TABLE HoaDon
ALTER COLUMN DienGiai NVARCHAR(100)

--4. Thêm vào bảng SanPham cột TyLeHoaHong float
ALTER TABLE SanPham
ADD TyLeHoaHong FLOAT

--5. Xóa cột NgayNhap trong bảng SanPham
ALTER TABLE SanPham
DROP COLUMN NgayNhap

--6. Tạo các ràng buộc khóa chính và khóa ngoại cho các bảng trên

--KHOA CHINH
ALTER TABLE SanPham ADD CONSTRAINT PK_SanPham
PRIMARY KEY (Masp)

ALTER TABLE HoaDon ADD CONSTRAINT PK_HoaDon
PRIMARY KEY (MaHD)

ALTER TABLE KhachHang ADD CONSTRAINT PK_KhachHang
PRIMARY KEY (MaKH)

ALTER TABLE ChiTietHD ADD CONSTRAINT PK_ChiTietHD
PRIMARY KEY (MaHD,Masp)


--KHOA NGOAI
ALTER TABLE HoaDon ADD CONSTRAINT FK_HoaDon
FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH)
ON DELETE CASCADE ON UPDATE CASCADE

ALTER TABLE ChiTietHD ADD CONSTRAINT FK_ChiTietHD_MaHD
FOREIGN KEY (MaHD) REFERENCES HoaDon(MaHD)
ON DELETE CASCADE ON UPDATE CASCADE


ALTER TABLE ChiTietHD ADD CONSTRAINT FK_ChiTietHD_Masp
FOREIGN KEY (Masp) REFERENCES SanPham(Masp)
ON DELETE CASCADE ON UPDATE CASCADE


--7. Thêm vào bảng HoaDon các ràng buộc sau:
-- NgayGiao >= NgayLap
ALTER TABLE HoaDon ADD CONSTRAINT CK_HoaDon_NgayGiao
CHECK (NgayGiao >= NgayLap)


-- MaHD gồm 6 ký tự, 2 ký tự đầu là chữ, các ký tự còn lại là số
ALTER TABLE HoaDon ADD CONSTRAINT CK_HoaDon_MaHD
 --CHECK (MaHD LIKE '[A-Z]{2}\d{4,}')
 CHECK (MaHD like '[A-Z][A-Z][0-9][0-9][0-9][0-9]')

-- Giá trị mặc định ban đầu cho cột NgayLap luôn luôn là ngày hiện hành
ALTER TABLE HoaDon ADD CONSTRAINT DF_HoaDon_NgayLap
DEFAULT GETDATE() FOR NgayLap


--8. Thêm vào bảng Sản phẩm các ràng buộc sau:
-- SoLuongTon chỉ nhập từ 0 đến 500
ALTER TABLE SanPham ADD CONSTRAINT CK_SanPham_SoLuongTon
CHECK( SoLuongTon BETWEEN 0 AND 500)
--ALTER TABLE SanPham DROP CONSTRAINT CK_SanPham_SoLuongTon

-- DonGiaNhap lớn hơn 0
ALTER TABLE SanPham ADD CONSTRAINT CK_SanPham_DonGiaNhap
CHECK (DonGiaNhap > 0)


-- Giá trị mặc định cho NgayNhap là ngày hiện hành
ALTER TABLE SanPham ADD NgayNhap DATE
ALTER TABLE SanPham ADD CONSTRAINT DF_SanPham_NgayNhap
DEFAULT GETDATE() FOR NgayNhap 


-- DVT chỉ nhập vào các giá trị ‘KG’, ‘Thùng’, ‘Hộp’, ‘Cái’
ALTER TABLE SanPham ADD CONSTRAINT CK_SanPham_DVT
CHECK(DVT IN (N'KG', 'Thùng', 'Hộp', 'Cái'))

--9. Dùng lệnh T-SQL nhập dữ liệu vào 4 table trên, dữ liệu tùy ý, chú ý các ràng
--buộc của mỗi Table
 -- Table SanPham
    INSERT INTO SanPham (MaSP, TenSP, NgayNhap, DVT, SoLuongTon, DonGiaNhap, TyLeHoaHong) 
    VALUES ('SP01', 'Dau Goi', '20210201', N'Cái', 100, 25000, 1),
            ('SP02', 'Dau Xa', '20210201', N'Cái', 120, 27000, 1),
            ('SP03', 'Xa Phong', '20210201', N'Hộp', 300, 20000, 2),
            ('SP04', 'Mi 3 Mien', '20210201', N'Thùng', 500, 3000, 5)

    -- Table Khách hàng
    INSERT INTO KhachHang (MaKH, TenKH, DiaCHi, DienThoai)
    VALUES  ('KH01', N'Lý Thị Yến', N'120 Trường Chinh, Q.12, TP.HCM', '0312345678'),
            ('KH02', N'Diệp Bảo Trân', N'143 Quang Trung, Q.GV, TP.HCM', '0909091234'),
            ('KH03', N'Trương Kiều Nhi', N'23 Nguyễn Thái Bình, Q.GV, TP.HCM', '0707123123'),
            ('KH04', N'Nguyễn Tú Quyên', N'03 Quang Trung, Q.GV, TP.HCM', '0505050505')

    -- Table HoaDon

INSERT INTO HoaDon (MaHD, NgayLap, NgayGiao, MaKH, DienGiai)
VALUES 
    ('HD0101', '2024-01-16', '2024-01-17', 'KH01', N'Giao Nhanh'),
    ('HD0102', '2024-01-16', '2024-02-15', 'KH03', N'Giao Thường'),
    ('HD0103', '2024-01-16', '2024-02-03', 'KH02', N'Giao Nhanh'),
    ('HD0104', '2024-01-16', '2024-01-16', 'KH01', N'Giao Thường');


    -- Table ChiTietHD
    INSERT INTO ChiTietHD (MaHD, MaSP, SoLuong)
    VALUES  ('HD0101', 'SP01', 324),
            ('HD0102', 'SP02', 424),
            ('HD0103', 'SP04', 243),
            ('HD0104', 'SP03', 13)


-- 10. Xóa 1 hóa đơn bất kỳ trong bảng HoaDon. Có xóa được không? Tại sao? Nếu
-- vẫn muốn xóa thì phải dùng cách nào?
    -- Không xoá được vì hoa đơn đó có ràng buộc tham chiếu đến bảng ChiTietHD
    -- Nếu Muốn hoá thì trước tiên phải xoá ở bảng ChiTietHD rồi mới xoá ỏ bảng HoaDon

-- 11. Nhập 2 bản ghi mới vào bảng ChiTietHD với MaHD = ‘HD999999999’ và
-- MaHD=’1234567890’. Có nhập được không? Tại sao?
    -- Không thể nhập 2 bản ghi mới vào bảng ChiTietHD
    -- Vì MaHD = ‘HD999999999’ lớn hớn 10 kí tự
    -- MaHD=’1234567890’ không có 2 kí tự đầu tiên là kí tự
    
-- 12. Đổi tên CSDL Sales thành BanHang
USE master;
ALTER DATABASE Sales SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

EXEC SP_RENAMEDB 'Sales', 'BanHang'

USE master;
ALTER DATABASE BanHang SET MULTI_USER;

-- 13. . Tạo thư mục E:\QLBH, chép CSDL BanHang vào thư mục này, bạn có sao
-- chép được không? Tại sao? Muốn sao chép được bạn phải làm gì? Sau khi sao
-- chép, bạn thực hiện Attach CSDL vào lại SQL.
    -- (detach hệ thống sẽ ngắt kết nối tên đã cung cấp và phần còn lại sẽ được giữ nguyên)
    -- Có thể chép được nhưng có khi Attach CSDL có thể bị lỗi vì không Detach CSDL
    -- Để sao chép CSDL cần Detach trước khi chép
    -- database -> Task -> Detach
    -- Vào đường dẫn copy File
    -- C:\Program Files\Microsoft SQL Server\MSSQL11.LIIEN\MSSQL\DATA
	
-- 14. Tạo bản BackUp cho CSDL BanHang
-- Full/Database
    -- Backup database <TEN DATABASE> to disk = '<DUONG DAN FILE BACKUP + TEN FILE>'
-- Differential/Incremental
    -- Backup database <TEN DATABASE> to
    -- disk = '<DUONG DAN FILE BACK UP + TEN FILE>' with differential
-- Transactional Log/Log
    -- Backup log <TEN DATABASE> to disk = '<DUONG DAN FILE BACKUP + TEN FILE>'
-- Tạo bản sao lưu đơn giản
BACKUP DATABASE BanHang TO DISK = 'E:\QLBH\BanHangBackup.bak';

-- Hoặc có thể thêm WITH INIT để ghi đè lên bản sao lưu cũ nếu có
-- BACKUP DATABASE BanHang TO DISK = 'E:\QLBH\BanHangBackup.bak' WITH INIT;


-- 15. Xóa CSDL BanHang
USE master
DROP DATABASE BanHang

--16. Phục hồi lại CSDL BanHang.
-- Phục hồi từ bản backup (đã tạo trước đó)
RESTORE DATABASE BanHang
FROM DISK = 'E:\QLBH\BanHangBackup.bak'
WITH REPLACE; -- Sử dụng REPLACE để ghi đè lên cơ sở dữ liệu hiện tại nếu có

-- Đặt cơ sở dữ liệu trở lại chế độ đa người sử dụng
USE master;
ALTER DATABASE BanHang SET MULTI_USER;

