create database library;
use library;

create table user (
user_id int primary key,
user_name varchar(40) not null,
user_type enum('Teacher','Student') not null,
contact varchar(60));


insert into user (user_id, user_name, user_type, contact) 
values 
(001, "JohnDoe", "Teacher", "555-1234"),
(002, "JaneSmith", "student", "555-5678"),
(003, "MikeJohnson", "student", "555-8765"),
(004, "EmilyBrown", "student", "555-4321"),
(005, "ChrisDavis", "teacher", "555-2345"),
(006, "SarahMiller", "teacher", "555-3456"),
(007, "DavidWilson", "student", "555-4567"),
(008, "LauraTaylor", "teacher", "555-5670"),
(009, "DanielAnderson", "student", "555-6789"),
(010, "SophiaMartinez", "student", "555-7890");

-- This Procedure is used to view all the users(Teacher/Students)
delimiter &&
create procedure users()
begin
	select * from user;
end &&
delimiter ;



create table books (
book_id int primary key,
book_name varchar(50) not null,
category varchar (30) not null,
author varchar (50) not null,
year_published date not null);


insert into books (book_id, book_name, category, author, year_published)
values 
(101, "To Kill a Mockingbird", "Fiction", "Harper Lee", '1960-07-11'),
(102, "1984", "Dystopian", "George Orwell", '1949-06-08'),
(103, "The Great Gatsby", "Fiction", "F. Scott Fitzgerald", '1925-04-10'),
(104, "The Catcher in the Rye", "Fiction", "J.D. Salinger", '1951-07-16'),
(105, "Pride and Prejudice", "Romance", "Jane Austen", '1813-01-28'),
(106, "Moby-Dick", "Adventure", "Herman Melville", '1851-10-18'),
(107, "War and Peace", "Historical Fiction", "Leo Tolstoy", '1869-03-01'),
(108, "The Odyssey", "Epic", "Homer", '1964-01-01'),
(109, "The Brothers Karamazov", "Philosophical Fiction", "Fyodor Dostoevsky", '1880-11-01'),
(110, "Brave New World", "Dystopian", "Aldous Huxley", '1932-08-30'),
(111, "Jane Eyre", "Romance", "Charlotte Brontë", '1847-10-16'),
(112, "Crime and Punishment", "Psychological Fiction", "Fyodor Dostoevsky", '1866-01-15'),
(113, "The Divine Comedy", "Epic", "Dante Alighieri", '1320-09-14'),
(114, "The Hobbit", "Fantasy", "J.R.R. Tolkien", '1937-09-21'),
(115, "Wuthering Heights", "Gothic Fiction", "Emily Brontë", '1847-12-17');

-- This Procedure is used to view all the books available in the library.
delimiter &&
create procedure books()
begin
	select * from books;
end &&
delimiter ;



create table transactions (
transaction_id int auto_increment primary key,
user_id int,
book_id int,
issue_date date NOT NULL,
due_date date NOT NULL,
return_date date,
fine_amount decimal (10,2) default 0.00,
FOREIGN KEY (user_id) REFERENCES user(user_id),
FOREIGN KEY (book_id) REFERENCES books(book_id)
);



-- This Procedure is used to view all the transactions.
delimiter &&
create procedure Transactions()
begin
	select * from Transactions;
end &&
delimiter ;



-- This Procedure is used for issue books.
delimiter && 
create procedure issue_book( in x_user_id int , in x_book_id int)
begin
	declare	y_duedate date;
    declare y_today date;
    declare y_usertype enum('Student', 'Teacher');
    
    set y_today = curdate(); -- To get today's date.
    
    select user_type into y_usertype from user where user_id = x_user_id; -- To get user type (student/Teacher)
    
    if y_usertype = 'Teacher' then
		set y_duedate = date_add(y_today, interval (30) day);
	else
		set y_duedate = date_add(y_today, interval (14) day);
	end if;
    
	insert into transactions (user_id, book_id, issue_date, due_date) -- we don't need to add transaction ID because we are set that in auto increment.
	values(x_user_id, x_book_id, y_today, y_duedate);
end &&
delimiter ;


-- This Procedure is used to calculate the fine amount.
delimiter &&
create procedure return_book(p_transaction_id int, p_returndate date)
begin
	declare q_duedate date;
    declare q_fineamount decimal (10,2);
    
    select due_date into q_duedate from transactions where transaction_id = P_transaction_id;
    
    if p_returndate > q_duedate then
		set q_fineamount = datediff(p_returndate, q_duedate) * 10; -- fine will be 10rs per day
    else
		set q_fineamount = 0.00;
	end if;
    
    update transactions
    set return_date = p_returndate, fine_amount = q_fineamount 
    where transaction_id = p_transaction_id;
    
end &&
delimiter ;


call users(); -- Use this to view all the users.

call books(); -- Use this to view all the available books.

call Transactions(); -- Use this to view all the transactions.

call issue_book(7,111); -- use this to issue a book (user_Id, book_Id)

call return_book(10,'2024-9-30'); -- use this to calculate fine amount (Transaction Id, Return_date)
