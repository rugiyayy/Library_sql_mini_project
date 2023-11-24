create database Library_DB
use library_db

create table Books (
ID int identity(100,1) PRIMARY KEY ,
NAME nvarchar(100) check(LEN(Name) >= 2 AND LEN(Name) <= 100) not null,
PageCount int check(PageCount>=10) not null
)


create table Authors (
ID int identity(50,1) PRIMARY KEY ,
NAME nvarchar(250) not null,
Surname  nvarchar(250) not null
)

create table Book_Author(
ID int identity(200,1) PRIMARY KEY ,
BookID int FOREIGN KEY references Books(ID) not null,
AuthorID int FOREIGN KEY references Authors(ID) not null
)



INSERT INTO Books VALUES 
    ('To Kill a Mockingbird', 281),
    ('1984', 328),
    ('Pride and Prejudice', 279),
    ('The Great Gatsby', 180),
    ('One Hundred Years of Solitude', 417),
    ('War and Peace', 1225),
    ('The Lord of the Rings', 1178),
    ('Crime and Punishment', 671),
	('Beyond the End of the World by',200),
	('The Monarchs',400),
	('The Idiot',300),
	('Emma',340);


INSERT INTO Authors (NAME, Surname) VALUES
    ('Harper', 'Lee'),
    ('George', 'Orwell'),
    ('Jane', 'Austen'),
    ('F. Scott', 'Fitzgerald'),
    ('Herman', 'Melville'),
    ('J.D.', 'Salinger'),
    ('Gabriel', 'García Márquez'),
    ('Leo', 'Tolstoy'),
    ('J.R.R.', 'Tolkien'),
    ('Fyodor', 'Dostoevsky'),
	('Amie', 'Kaufman'),
	('Meagan','Spooner'),
	('Kass', 'Morgan'),
	('Danielle', 'Paige');


INSERT INTO Book_Author VALUES (100, 50),  
    (102, 52),   
    (103, 53),  
    (104, 54),  
    (105, 55),   
    (106, 56),  
    (107, 57),   
    (108, 58),   
    (108, 59),
	(109, 60),  
    (109, 61),
    (110, 60),
    (110, 61),
    (111, 59),
    (112, 52);


	


select*from Books
select*from Authors
select*from Book_Author


--- 1.  Id, Name, PageCount ve AuthorFullName columnlarinin valuelarini qaytaran bir view yaradin

create View Book_Details_view 
as select Book_Author.Id,
		  Books.Name,
		  Books.PageCount,
		  concat(Authors.Name, ' ',Authors.Surname)  AS AuthorFullName
from Book_Author
join Books on Books.ID=Book_Author.BookID
join Authors on Authors.ID=Book_Author.AuthorID

select*from Book_Details_view




--- 2.  Gonderilmis Author-in adina gore (adi parameter kimi gonderilmelidi) olan Book-lari Id, Name, PageCount, AuthorFullName columnlari seklinde gosteren procedure yazin

CREATE PROCEDURE GetBooksByAuthorName @AuthorName NVARCHAR(100)
AS
BEGIN
    IF (LEN(@AuthorName) < 2 OR LEN(@AuthorName) > 100)
       BEGIN
           RAISERROR('AuthorName must be between 2 and 100 characters.',16,1);
           RETURN;
        END

     SELECT
        Books.Name,
        Books.PageCount,
        CONCAT(Authors.Name, ' ', Authors.Surname) AS AuthorFullName
    FROM
        Book_Author
    JOIN
        Books ON Books.Id = Book_Author.BookId
    JOIN
        Authors ON Book_Author.AuthorId = Authors.Id
    WHERE
        Authors.Name = @AuthorName;
END;

exec GetBooksByAuthorName 'Harper'




--- 3.  Authors tableinin insert, update ve deleti ucun (her biri ucun ayrica) procedure yaradin (yene lazimli parameterlar ile)

-------------INSERT:
CREATE PROCEDURE InsertAuthor
		@AuthorName NVARCHAR(250),
		@AuthoSurname NVARCHAR(250)
AS
INSERT INTO Authors VALUES (@AuthorName, @AuthoSurname);

--exec
EXEC InsertAuthor 'Erich', 'Remark';
select*from Authors



--------------------UPDATE:
CREATE PROCEDURE UpdateAuthor
    @AuthorID INT,
    @Name NVARCHAR(250),
    @Surname NVARCHAR(250)
AS
BEGIN
    IF NOT EXISTS (SELECT 'SMTHNG' FROM Authors WHERE ID = @AuthorID)
    BEGIN
        RAISERROR('Author with ID %d does not exist.', 16, 1, @AuthorID);
        RETURN;
    END

UPDATE Authors
SET NAME = @Name,
    Surname = @Surname
WHERE ID = @AuthorID;
END;

--exec
EXEC UpdateAuthor 64, 'Erich M.', 'Remark';
select*from Authors

--------------DELETE:
CREATE PROCEDURE DeleteAuthor
       @AuthorID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 'SMTHNG' FROM Authors WHERE ID = @AuthorID)
		BEGIN
			 RAISERROR('Author with ID %d does not exist.', 16, 1, @AuthorID);
			 RETURN;
		END

    DELETE FROM Authors
    WHERE ID = @AuthorID;
END;

--exec
EXEC DeleteAuthor 64;
select*from Authors


--- 4.  Authors-lari Id,FullName,BooksCount,MaxPageCount seklinde qaytaran view yaradirsiniz
CREATE VIEW AuthorsInfo
AS select Authors.ID ,
         concat(Authors.Name, ' ',Authors.Surname)  AS AuthorFullName,
		 count(Book_Author.BookID) as BooksCount,
         MAX(Books.PageCount) as MaxPageCount,
		 SUM(Books.PageCount) AS OverallPageCount
from Authors
left join Book_Author on  Authors.ID = Book_Author.AuthorID
left join Books ON Book_Author.BookID = Books.ID
group by
    Authors.ID, concat(Authors.Name, ' ',Authors.Surname) 


select*from AuthorsInfo

