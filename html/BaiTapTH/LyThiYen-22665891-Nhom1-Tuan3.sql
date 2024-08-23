--1)  Tạo hai bảng mới trong cơ sở dữ liệu AdventureWorks2008 theo cấu trúc  sau:
create table 
MyDepartment (
				DepID smallint not null primary 
				key, DepName nvarchar(50),
				GrpName 
				nvarchar(50))
create table MyEmployee (
				EmpID int not null primary 
				key, FrstName nvarchar(50),
				MidName
				nvarchar(50), 
				LstName 
				nvarchar(50),
				DepID smallint not null foreign key 
				references MyDepartment(DepID))

--2)  Dùng  lệnh  insert  <TableName1>  select  <fieldList>  from 
--<TableName2>   chèn  dữ  liệu  cho  bảng  MyDepartment,  lấy  dữ  liệu  từ 
--bảng [HumanResources].[Department].
insert MyDepartment
select DepartmentID,Name,GroupName
from [HumanResources].[Department]

select * from MyDepartment 

--3)  Tương tự câu 2, chèn 20 dòng dữ liệu cho bảng MyEmployee  lấy  dữ liệu 
--từ 2 bảng
--[Person].[Person] và 
--[HumanResources].[EmployeeDepartmentHistory]
insert MyEmployee
select top 20 P.BusinessEntityID,P.FirstName,P.MiddleName,P.LastName,E.DepartmentID
from Person.Person P join HumanResources.EmployeeDepartmentHistory E on P.BusinessEntityID = E.BusinessEntityID

--order by P.BusinessEntityID


--4)  Dùng  lệnh  delete  xóa  1  record  trong  bảng  MyDepartment  với  DepID=1,
--có  thực hiện được không? Vì sao?

delete
from MyDepartment
where DepID = 1

-- có thể delete được vì bảng myDepartment không có tham chiếu đến bảng khác

--5)  Thêm một default constraint vào field DepID trong bảng MyEmployee, 
--với giá trị mặc định là 1.

alter table MyEmployee
add constraint def_MyEmployee default 1 for DepID
select * from MyEmployee


--6)  Nhập thêm một record mới trong bảng MyEmployee, theo cú pháp sau: 
--insert into MyEmployee (EmpID, FrstName, MidName, 
--LstName) values(1, 'Nguyen','Nhat','Nam'). Quan sát giá trị 
--trong field depID của record mới  thêm

-- thêm recode 
insert MyDepartment
select D.DepartmentID, D.Name, D.GroupName
from HumanResources.Department as D
where D.DepartmentID = 1

-- xoá recode EmpID = 1
DELETE FROM MyEmployee 
WHERE EmpID = 1

insert into MyEmployee (EmpID, FrstName, MidName, LstName) 
values(1, 'Nguyen','Nhat','Nam')

-- kiểm tra kết quả
SELECT *
from MyEmployee

SELECT *
from MyDepartment

--7)  Xóa foreign key constraint trong bảng MyEmployee, thiết lập lại khóa ngoại 
--DepID tham chiếu đến DepID của bảng MyDepartment với thuộc  tính  on
--delete set default.


-- xoá foreign key của bảng MyEmployee
alter table MyEmployee
drop constraint [FK__MyEmploye__DepID__3B95D2F1]

-- thiết lập lại khoá ngoại on delete sets default
alter table MyEmployee
add constraint FK_MyEmployee_DepID foreign key (DepID) references MyDepartment(DepID)
on delete set default 

--8)  Xóa một record  trong  bảng MyDepartment có DepID=7, quan sát  kết quả 
--trong hai bảng MyEmployee và  MyDepartmen
select * from MyDepartment where DepID=7
select * from MyEmployee where DepID=7

--xoa
delete from MyDepartment where DepID=7


--quan sat ket qua
select * from MyDepartment
select * from MyEmployee
where EmpID in (27,28,29)

--9) Xóa foreign key trong bảng MyEmployee. Hiệu chỉnh ràng buộc khóa
--ngoại DepID trong bảng MyEmployee, thiết lập thuộc tính on delete
--cascade và on update cascade

--Xóa foreign key trong bảng MyEmployee.
alter table MyEmployee
drop constraint [FK_MyEmployee_DepID]

-- thiết lập lại khoá ngoại on delete cascade on update cascade
alter table MyEmployee
add constraint FK_MyEmployee_DepID foreign key (DepID) references MyDepartment(DepID)
on delete cascade on update cascade

--10)Thực hiện xóa một record trong bảng MyDepartment với DepID =3, có
--thực hiện được không?
delete from MyDepartment
where DepID = 3

-- kiểm tra kết quả
SELECT *
from MyEmployee

SELECT *
from MyDepartment

--11)Thêm ràng buộc check vào bảng MyDepartment tại field GrpName, chỉ cho
--phép nhận thêm những Department thuộc group Manufacturing

select * from MyDepartment

alter table MyDepartment
with nocheck add constraint CK_MyDepartment check (GrpName = 'Manufacturing')

--12)Thêm ràng buộc check vào bảng [HumanResources].[Employee], tại cột
--BirthDate, chỉ cho phép nhập thêm nhân viên mới có tuổi từ 18 đến 60


alter table [HumanResources].[Employee]
with nocheck add constraint ck_Employee check ((year(getdate())-year(BirthDate)>=18) and (year(getdate())-year(BirthDate)<=60))