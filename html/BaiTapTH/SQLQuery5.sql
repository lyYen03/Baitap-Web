------------------------------------------------
--Câu 3
--Client B
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
--ktra
DBCC useroptions
go 
--Client B
begin tran -- gồm bước 1,3,5
waitfor delay '00:00:15'
--B1: Client A, client B: cùng thực hiện lệnh SELECT trên bảng Accounts với AccountID =101
select * from Accounts where AccountID = 101
--B3: Client B cập nhật account trên AccountID =101, balance =1000-500
update Accounts
set balance =1000-500
where AccountID =101
--B5: Client B: SELECT trên Accounts với AccountID =101; COMMIT;
select * from Accounts where AccountID =101
commit tran

--Quan sát kết quả hiển thị và giải thích.

-----------------------------------------------------
--câu 4
--trả acctID về gtri ban đầu cho dễ nhớ
update Accounts
set balance = 1000
where AccountID = 101

select * from Accounts

--Client B
SET ISOLATION LEVEL REPEATABLE READ
--ktra
DBCC useroptions
go 
--Client B
begin tran -- gồm bước 1,3
waitfor delay '00:00:15'
--B1: Client A, client B: cùng thực hiện lệnh SELECT trên bảng Accounts với AccountID =101
select * from Accounts where AccountID = 101
--B3: Client B cập nhật account trên AccountID =101, balance =1000-500
update Accounts
set balance =1000-500
where AccountID =101
--Quan sát kết quả hiển thị và giải thích.