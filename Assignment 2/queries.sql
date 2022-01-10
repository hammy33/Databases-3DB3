connect to SE3DB3;

------------------------------------------------
--  Query Statement for q1
--  customers who are age 18+ placing an order on july22,2020
--  2 Records
------------------------------------------------
SELECT Order.FirstName, Order.LastName, Order.DateOfBirth FROM Order WHERE Order.DateOfBirth <= '2003-11-05' AND Order.Date = '2020-07-22';

------------------------------------------------
--  Query Statement for q2
--  products bought by ppl between 20-35
--  1906 Records, however since products can belong to multiple categories, there is an entry for every category that a product belongs to
------------------------------------------------
SELECT DISTINCT Product.ProductID, ProductCategory.Name FROM Order, Product, OrderContains, ProductCategory, BelongsTo WHERE Order.DateOfBirth <= '2001-11-05' AND Order.DateOfBirth >= '1985-11-04' AND OrderContains.OrderID = Order.OrderID AND OrderContains.ProductID = Product.ProductID AND BelongsTo.ProductCategoryID = ProductCategory.ProductCategoryID AND BelongsTo.ProductID = Product.ProductID;

------------------------------------------------
--  Query Statement for q3
--  most reviews written
--  should be leandra, lilli, leandra and gieuseppe
------------------------------------------------
SELECT WriteReview.FirstName, WriteReview.LastName, WriteReview.DateOfBirth, Person.Country, Person.City FROM WriteReview, Person WHERE WriteReview.FirstName = Person.FirstName AND WriteReview.LastName = Person.LastName AND WriteReview.DateOfBirth = Person.DateOfBirth GROUP BY WriteReview.FirstName, WriteReview.LastName, WriteReview.DateOfBirth, Person.Country, Person.City HAVING COUNT(WriteReview.FirstName) = (SELECT MAX("count") FROM (SELECT FirstName, LastName, DateOfBirth, COUNT(FirstName) as "count" FROM WriteReview GROUP BY FirstName, LastName, DateOfBirth));

------------------------------------------------
--  Query Statement for q4a
--  NUMBER OF SHIPMENTS WITH ONE+ ORDER
--  i got 546
------------------------------------------------
SELECT COUNT(TrackingNumber) FROM (SELECT TrackingNumber FROM HasShipment GROUP BY TrackingNumber HAVING COUNT(TrackingNumber) > 1);

------------------------------------------------
--  Query Statement for q4b
--  shipments from A delivered to toronto (M postal code)
--  i got 26 records
------------------------------------------------
SELECT DISTINCT a.TrackingNumber FROM Person, Order, HasShipment, (SELECT TrackingNumber FROM HasShipment GROUP BY TrackingNumber HAVING COUNT(TrackingNumber) > 1) AS a WHERE a.TrackingNumber = hasShipment.TrackingNumber AND hasShipment.OrderID = Order.OrderID AND Order.FirstName = Person.FirstName AND Order.LastName = Person.LastName AND Order.DateOfBirth = Person.DateOfBirth AND Person.PostalCode LIKE 'M%';

------------------------------------------------
--  Query Statement for q5 
--  products that only belong to one category
--  i got 344 diff products
------------------------------------------------
SELECT ProductID FROM (SELECT ProductID, COUNT(ProductID) FROM BelongsTo GROUP BY ProductID HAVING COUNT(ProductID) = 1);

------------------------------------------------
--  Query Statement for q6 a
--  brands that only sell one product
--  i got 5 brands that are unique and only sell one product
------------------------------------------------
SELECT Product.ProductID, Product.Name, Product.Brand FROM Product, (SELECT Brand FROM Product GROUP BY Brand HAVING COUNT(Name) = 1)A WHERE A.Brand = Product.Brand;

------------------------------------------------
--  Query Statement for q6 b
--  not sure but might be most expensive order?
--  if so, the order id with the greatest cost (1844) is 006979103
------------------------------------------------

SELECT OrderContains.OrderID FROM OrderContains, Product WHERE Product.ProductID = OrderContains.ProductID GROUP BY OrderContains.OrderID HAVING SUM(Product.Price*OrderContains.Quantity) = (SELECT MAX("salesAmount") FROM (SELECT OrderContains.OrderID, SUM(Product.Price*OrderContains.Quantity) as "salesAmount" FROM Product, OrderContains WHERE OrderContains.ProductID = Product.ProductID GROUP BY OrderContains.OrderID));

------------------------------------------------
--  Query Statement for q7 
--  747 for store 103 and 7849 for store 102
------------------------------------------------

SELECT Store.StoreID, Store.Description, Store.StartDate, SUM(Product.Price*OrderContains.Quantity) as "Revenue" 
FROM Store, Product, OrderContains, Order 
WHERE OrderContains.ProductID = Product.ProductID AND Store.StoreID = Product.StoreID AND Order.OrderID = OrderContains.OrderID 
AND Order.Date BETWEEN '2020-07-01' AND '2020-07-31' 
GROUP BY Store.StoreID, Store.Description, Store.StartDate 
ORDER BY "Revenue" ASC;

SELECT s.StoreID, s.Description, s.StartDate, SUM(oc.Quantity*p.Price) rev FROM Store s INNER JOIN Product p ON s.StoreID = p.StoreID INNER JOIN (
  SELECT *
  FROM OrderContains oc
  WHERE oc.OrderID IN (
    SELECT o.OrderID
    FROM Order o
    WHERE (
      o.Date LIKE '2020-07%'
    )
  )
) oc ON p.ProductID = oc.ProductID
GROUP BY (s.StoreID, s.Description, s.StartDate)
ORDER BY rev ASC;
------------------------------------------------
--  Query Statement for q8 a
--  products never purchased
--  product IDs from 991-1000 have all not been ordered
------------------------------------------------

SELECT Product.ProductID, Product.Name, Product.Brand FROM Product LEFT JOIN OrderContains AS o ON o.ProductID = Product.ProductID WHERE o.ProductID IS NULL;

------------------------------------------------
--  Query Statement for q8 b
--  products never purchased but were under promotion
--  Only 991 and 997 have appeared in promotions out of the ones that havent been ordered
------------------------------------------------

SELECT Promotion.ProductID FROM Promotion, (SELECT Product.ProductID, Product.Name, Product.Brand FROM Product LEFT JOIN OrderContains AS o ON o.ProductID = Product.ProductID WHERE o.ProductID IS NULL)P WHERE Promotion.ProductID = P.ProductID;

------------------------------------------------
--  Query Statement for q9a
--  categories where all products have a warranty
--  categories 2, 3 and 6
------------------------------------------------

SELECT DISTINCT ProductCategory.ProductCategoryID, ProductCategory.Name FROM ProductCategory, HasWarranty, BelongsTo WHERE ProductCategory.ProductCategoryID = BelongsTo.ProductCategoryID AND HasWarranty.ProductID = BelongsTo.ProductID AND ProductCategory.ProductCategoryID NOT IN (SELECT DISTINCT BelongsTo.ProductCategoryID FROM BelongsTo WHERE BelongsTo.ProductID NOT IN (SELECT DISTINCT ProductID FROM HasWarranty));

------------------------------------------------
--  Query Statement for q9b
-- stores that sell every product from a particular category. Note that the only way a store can sell every product from a category is if
-- every product is only sold by one particular store.
--  store 102 sells every product under category 6 
------------------------------------------------

SELECT A."StoreID" FROM (SELECT DISTINCT ProductCategoryID, MAX(StoreID) as "StoreID" FROM (SELECT BelongsTo.ProductCategoryID, Product.StoreID FROM Product, HasWarranty, BelongsTo WHERE Product.ProductID = BelongsTo.ProductID AND HasWarranty.ProductID = BelongsTo.ProductID AND Product.ProductID NOT IN (SELECT DISTINCT BelongsTo.ProductID FROM BelongsTo WHERE BelongsTo.ProductID NOT IN (SELECT DISTINCT ProductID FROM HasWarranty)) GROUP BY BelongsTo.ProductCategoryID, Product.StoreID) GROUP BY ProductCategoryID HAVING SUM(ProductCategoryID) = ProductCategoryID)A;
------------------------------------------------
--  Query Statement for q10a
--  products that have an average rating greater than the average rating of all categories that they are apart of
--  152 records
------------------------------------------------

SELECT DISTINCT Product.ProductID, Product.ModelNumber, Product.Name FROM Product, WriteReview WHERE Product.ProductID = WriteReview.ProductID AND Product.ProductID NOT IN (SELECT DISTINCT B.ProductID FROM (SELECT P.ProductCategoryID, ROUND(AVG(CAST(WriteReview.Star AS FLOAT)), 2) as "avgA" FROM (SELECT ProductCategoryID, ProductID FROM BelongsTo)P, WriteReview WHERE P.ProductID = WriteReview.ProductID GROUP BY P.ProductCategoryID)A JOIN (Select WriteReview.ProductID, BelongsTo.ProductCategoryID, AVG(CAST(WriteReview.Star AS FLOAT)) as "avgB" FROM Product, BelongsTo, WriteReview WHERE Product.ProductID = WriteReview.ProductID AND BelongsTo.ProductID = Product.ProductID AND WriteReview.ProductID = BelongsTo.ProductID GROUP BY WriteReview.ProductID, BelongsTo.ProductCategoryID)B ON A.ProductCategoryID = B.ProductCategoryID WHERE B."avgB" <= A."avgA");

------------------------------------------------
--  Query Statement for q10b
--  get the total sals of every product in A in descending order
--  152 records again, 27 had revenue $6027 whereas 104 only had $31
------------------------------------------------

SELECT B."Revenue" FROM (SELECT A.ProductID, SUM(Product.Price*OrderContains.Quantity) as "Revenue" FROM Product, OrderContains, (SELECT DISTINCT Product.ProductID, Product.ModelNumber, Product.Name FROM Product, WriteReview WHERE Product.ProductID = WriteReview.ProductID AND Product.ProductID NOT IN (SELECT DISTINCT B.ProductID FROM (SELECT P.ProductCategoryID, ROUND(AVG(CAST(WriteReview.Star AS FLOAT)), 2) as "avgA" FROM (SELECT ProductCategoryID, ProductID FROM BelongsTo)P, WriteReview WHERE P.ProductID = WriteReview.ProductID GROUP BY P.ProductCategoryID)A JOIN (Select WriteReview.ProductID, BelongsTo.ProductCategoryID, ROUND(AVG(CAST(WriteReview.Star AS FLOAT)), 2) as "avgB" FROM Product, BelongsTo, WriteReview WHERE Product.ProductID = WriteReview.ProductID AND BelongsTo.ProductID = Product.ProductID GROUP BY WriteReview.ProductID, BelongsTo.ProductCategoryID)B ON A.ProductCategoryID = B.ProductCategoryID WHERE B."avgB" <= A."avgA"))A WHERE OrderContains.ProductID = Product.ProductID AND A.ProductID = OrderContains.ProductID AND Product.ProductID = A.ProductID GROUP BY A.ProductID ORDER BY "Revenue" DESC)B