--1. Create 2 tables : Customer and Customer profile. They have a One to One relationship.

--a)A customer can have only one profile, and a profile belongs to only one customer
--b)The Customer table should have the columns : id, first_name, last_name NOT NULL
--c)The Customer profile table should have the columns : id, isLoggedIn DEFAULT false (a Boolean), customer_id (a reference to the Customer table)

CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL
);

CREATE TABLE customer_profile (
    id SERIAL PRIMARY KEY,
    isLoggedIn BOOLEAN DEFAULT false,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

--2. Insert those customers

--a)John, Doe
--b)Jerome, Lalu
--c)Lea, Rive


INSERT INTO customer (first_name, last_name)
    VALUES
        ('Jean', 'Biche'),
        ('Jérôme', 'Lalu'),
        ('Léa', 'Rive');


--3

INSERT INTO customer_profile (isLoggedIn, customer_id)
    VALUES
        ((SELECT CASE WHEN EXISTS (SELECT 1 FROM customer WHERE first_name = 'Jean') THEN true ELSE false END), (SELECT customer_id FROM customer WHERE first_name = 'Jean')),
        ((SELECT CASE WHEN EXISTS (SELECT 1 FROM customer WHERE first_name = 'Jérôme') THEN false ELSE true END), (SELECT customer_id FROM customer WHERE first_name = 'Jérôme'));


--4 Use the relevant types of Joins to display:

--a)The first_name of the LoggedIn customers
--b)All the customers first_name and isLoggedIn columns - even the customers those who don’t have a profile.
--c)The number of customers that are not LoggedIn

--To display the first_name of the LoggedIn customers:
SELECT customer.first_name
    FROM customer
    INNER JOIN customer_profile ON customer.customer_id = customer_profile.customer_id
    WHERE customer_profile.isLoggedIn = true;

--To display all the customers first_name and isLoggedIn columns, including those who don't have a profile:

SELECT customer.first_name, customer_profile.isLoggedIn
    FROM customer
    LEFT JOIN customer_profile ON customer.customer_id = customer_profile.customer_id;

--To display the number of customers that are not LoggedIn:

SELECT COUNT(customer.customer_id)
    FROM customer
    LEFT JOIN customer_profile ON customer.customer_id = customer_profile.customer_id
    WHERE customer_profile.isLoggedIn = false OR customer_profile.isLoggedIn IS NULL;


--1. Create a table named Book, with the columns : book_id SERIAL PRIMARY KEY, title NOT NULL, author NOT NULL

CREATE TABLE book (
    book_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    author TEXT NOT NULL
);

--2. Insert those books :
--a)Alice In Wonderland, Lewis Carroll
--b)Harry Potter, J.K Rowling
--c)To kill a mockingbird, Harper Lee

INSERT INTO book (title, author)
VALUES ('Alice In Wonderland', 'Lewis Carroll'),
       ('Harry Potter', 'J.K Rowling'),
       ('To kill a mockingbird', 'Harper Lee');


--Create a table named Student, with the columns : student_id SERIAL PRIMARY KEY, name NOT NULL UNIQUE, age. Make sure that the age is never bigger than 15 (Find an SQL method);

CREATE TABLE student (
    student_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    age INTEGER CHECK (age <= 15)
);

--Insert those students:
--a)John, 12
--b)Lera, 11
--c)Patrick, 10
--d)Bob, 14

INSERT INTO student (name, age)
VALUES ('John', 12),
       ('Lera', 11),
       ('Patrick', 10),
       ('Bob', 14);


--Create a table named Library, with the columns :
	--a)book_fk_id ON DELETE CASCADE ON UPDATE CASCADE student_id ON DELETE CASCADE ON UPDATE CASCADE borrowed_date
	--This table, is a junction table for a Many to Many relationship with the Book and Student tables : A student can borrow many books, and a book can be borrowed by many children
	--book_fk_id is a Foreign Key representing the column book_id from the Book table
	--student_fk_id is a Foreign Key representing the column student_id from the Student table
	--The pair of Foreign Keys is the Primary Key of the Junction Table

CREATE TABLE library (
    book_fk_id INTEGER REFERENCES book(book_id) ON DELETE CASCADE ON UPDATE CASCADE,
    student_fk_id INTEGER REFERENCES student(student_id) ON DELETE CASCADE ON UPDATE CASCADE,
    borrowed_date DATE,
    PRIMARY KEY (book_fk_id, student_fk_id)
);

--Add 4 records in the junction table, use subqueries.
	--a)the student named John, borrowed the book Alice In Wonderland on the 15/02/2022
	--b)the student named Bob, borrowed the book To kill a mockingbird on the 03/03/2021
	--c)the student named Lera, borrowed the book Alice In Wonderland on the 23/05/2021
	--d)the student named Bob, borrowed the book Harry Potter the on 12/08/2021

INSERT INTO library (book_fk_id, student_fk_id, borrowed_date)
    VALUES ((SELECT book_id FROM book WHERE title = 'Alice In Wonderland'), (SELECT student_id FROM student WHERE name = 'John'), '2022-02-15'),
        ((SELECT book_id FROM book WHERE title = 'To kill a mockingbird'), (SELECT student_id FROM student WHERE name = 'Bob'), '2021-03-03'),
        ((SELECT book_id FROM book WHERE title = 'Alice In Wonderland'), (SELECT student_id FROM student WHERE name = 'Lera'), '2021-05-23'),
        ((SELECT book_id FROM book WHERE title = 'Harry Potter'), (SELECT student_id FROM student WHERE name = 'Bob'), '2021-08-12');


--Display the data
	--a)Select all the columns from the junction table
	SELECT * FROM library;

	--b)Select the name of the student and the title of the borrowed books
	SELECT student.name, book.title 
        FROM library 
        JOIN student ON library.student_fk_id = student.student_id 
        JOIN book ON library.book_fk_id = book.book_id;

	--c)Select the average age of the children, that borrowed the book Alice in Wonderland
	SELECT AVG(Student.age) 
        FROM library 
        JOIN student ON library.student_fk_id = student.student_id 
        JOIN book ON library.book_fk_id = book.book_id 
        WHERE book.title = 'Alice In Wonderland';

	--d)Delete a student from the Student table, what happened in the junction table ?
	DELETE FROM student WHERE name = 'Patrick';