USE lab09
GO

DROP VIEW IF EXISTS index_view_unique_clustered; 
DROP VIEW IF EXISTS v_product;
GO

DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Brands;

CREATE TABLE Categories
(
	category_id nvarchar(5) primary key
	,category_name nvarchar(25)
);

GO
CREATE TABLE Brands
(
	brand_id nvarchar(5) primary key
	,brand_name nvarchar(25)
);
GO
CREATE TABLE Products
(
	product_id nvarchar(5) primary key
	,product_name nvarchar(25)
	,brand_id nvarchar(5)
	,category_id nvarchar(5)
	,model_year int
	,list_price int
	,foreign key (brand_id) references Brands
	,foreign key (category_id) references categories
);

INSERT INTO Categories(category_id, category_name) VALUES
('CA01','Clothes'),
('CA02','Car'),
('CA03','Bike'),
('CA04','TV'),
('CA05','Shoes'),
('CA06','Phone'),
('CA07','Computer'),
('CA08','Hat'),
('CA09','Tablet'),
('CA10','Entertainment');


GO


INSERT INTO Brands(brand_id, brand_name) VALUES
('BR01','LV'),
('BR02','Yamaha'),
('BR03','LG'),
('BR04','Sony'),
('BR05','Adidas');


GO
INSERT INTO Products(product_id,product_name,brand_id,category_id,model_year ,list_price) VALUES
('PRO01','Ao','BR01','CA01',2019,100000),
('PRO02','Quan','BR01','CA01',2022,200000),
('PRO03','Ao Ngan','BR05','CA01',2019,90000),
('PRO04','Giay','BR05','CA05',2020,1000000),
('PRO05','Ao Son Tung','BR05','CA01',2020,90000),
('PRO06','Quan Au','BR01','CA05',2021,250000),
('PRO07','UNIQLO','BR02','CA02',2020,100000000),
('PRO08','May tinh cam tay','BR03','CA07',2022,15000000),
('PRO09','TV man hinh mong','BR04','CA04',2021,20000000),
('PRO10','Giay cao got','BR01','CA05',2020,300000),
('PRO11','O to dien','BR02','CA02',2019,500000000),
('PRO12','Boot','BR03','CA06',2022,180000),
('PRO13','Laptop','BR04','CA07',2020,19000000),
('PRO14','Giay the thao','BR05','CA05',2021,80000),
('PRO15','Xe dia hinh','BR02','CA03',2022,100000),
('PRO16','TV 52 inch','BR04','CA04',2020,8000000),
('PRO17','Oto 16 cho','BR03','CA02',2019,600000000),
('PRO18','Mu luoi trai','BR01','CA08',2022,85000),
('PRO19','Giay nu tinh','BR05','CA05',2019,90000),
('PRO20','Xe the thao','BR02','CA03',2020,100000);

GO
CREATE VIEW v_product AS
	SELECT product_id, product_name, model_year, list_price, brand_name, category_name
	FROM brands, categories, products
	WHERE brands.brand_id = products.brand_id AND categories.category_id = products.category_id;
go 
-- Sử dụng view vừa tạo cho biết thông tin các sản phẩm có năm sản xuất là 2022
SELECT * FROM v_product
WHERE model_year = 2022;

-- Sửa đổi view v_product với điều kiện list_price>100000
GO
ALTER VIEW v_product AS
SELECT product_id, product_name, model_year, list_price, brand_name, category_name
	FROM brands, categories, products
	WHERE brands.brand_id = products.brand_id 
	AND categories.category_id = products.category_id
	AND list_price > 100000;
GO
SELECT * FROM v_product;

-- Tạo index view cho 2 trường hợp: sử dụng unique clusted indexvà non-clusted index trên cột product_name sau đó so sánh hiệu năng của việc sử dụng cho 2 trường hợp này.

GO
CREATE VIEW index_view_unique_clustered WITH SCHEMABINDING AS
SELECT product_id, product_name, model_year, list_price, brand_name, category_name
	FROM dbo.brands, dbo.categories, dbo.products
	WHERE brands.brand_id = products.brand_id 
	AND categories.category_id = products.category_id;
GO
CREATE UNIQUE CLUSTERED INDEX idx_product_name_2 ON index_view_unique_clustered(product_name);
SELECT * FROM index_view_unique_clustered;

GO

CREATE NONCLUSTERED INDEX ix_name_3 ON index_view_unique_clustered(product_name);
SELECT * FROM index_view_unique_clustered;

-- c. Sử dụng Transaction cho các nội dung:
--Tạo transaction có tên Viết câu lệnh đưa ra danh sách các khách hàng ở một cơ quan nào đó.

BEGIN TRANSACTION;
BEGIN TRY

	UPDATE Products
	SET list_price = list_price + 100000
	WHERE product_name='UNIQLO';
	COMMIT;

END TRY
BEGIN CATCH

   --if an exception occurs execute your rollback, also test that you have had some successful transactions
   --IF @@TRANCOUNT > 0 ROLLBACK;  

END CATCH

SELECT * FROM Products;