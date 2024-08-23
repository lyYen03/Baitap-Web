------------------------------------------------
--Câu 3
--Client A
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
--ktra
DBCC useroptions
go 
--Client A
begin tran -- gồm bước 1,2,4
waitfor delay '00:00:15'
--B1: Client A, client B: cùng thực hiện lệnh SELECT trên bảng Accounts với AccountID =101
select * from Accounts where AccountID = 101
--B2: Client A cập nhật account trên AccountID =101, balance =1000-200
update Accounts
set balance =1000-200 --800
where AccountID =101
--B4: Client A: SELECT trên Accounts với AccountID =101; COMMIT;
select * from Accounts where AccountID =101
commit tran

--Quan sát kết quả hiển thị và giải thích.
------------------------------------------------------
--câu 4
--trả acctID về gtri ban đầu cho dễ nhớ
update Accounts
set balance = 1000
where AccountID = 101

select * from Accounts

--Client A
SET ISOLATION LEVEL REPEATABLE READ
--ktra
DBCC useroptions
go 
--Client A
begin tran --gồm bước 1,2,4
waitfor delay '00:00:15'
--B1: Client A, client B: cùng thực hiện lệnh SELECT trên bảng Accounts với AccountID =101
select * from Accounts
where AccountID = 101
--B2: Client A cập nhật accounts trên AccountID =101, balance =1000-200
update Accounts
set balance =1000-200 --800
where AccountID =101
--B4: Client A: SELECT trên Accounts với AccountID =101; COMMIT;
select * from Accounts where AccountID =101
commit tran

--Quan sát kết quả hiển thị và giải thích.
