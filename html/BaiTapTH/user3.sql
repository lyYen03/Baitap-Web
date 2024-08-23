--Cửa sổ user3
--thực hiện câu Select
select * from HumanResources.Employee

--b) Tại kết nối của User3, thực hiện cập nhật JobTitle=’Sale Manager’ của nhân
--viên có BusinessEntityID=1
update HumanResources.Employee
set JobTitle='Sale Maager'
where BusinessEntityID=1
--ktra
select * from HumanResources.Employee where BusinessEntityID=1
--cập nhật được