--SELECT COUNT(Product.StoreID) FROM Product, BelongsTo, ProductCategory WHERE BelongsTo.ProductID = Product.ProductID AND ProductCategory.ProductCategoryID = BelongsTo.ProductCategoryID AND BelongsTo.ProductCategoryID = '2' GROUP BY Product.StoreID
--SELECT COUNT(BelongsTo.ProductID) FROM BelongsTo WHERE BelongsTo.ProductCategoryID = '2'


--SELECT Product.StoreID 
--FROM Product, BelongsTo, 
--    (SELECT ProductCategory.ProductCategoryID 
--     FROM ProductCategory, HasWarranty, BelongsTo 
--     WHERE ProductCategory.ProductCategoryID = BelongsTo.ProductCategoryID AND HasWarranty.ProductID = BelongsTo.ProductID AND ProductCategory.ProductCategoryID NOT IN (
--         SELECT DISTINCT BelongsTo.ProductCategoryID FROM BelongsTo WHERE BelongsTo.ProductID NOT IN (
--             SELECT DISTINCT ProductID FROM HasWarranty)))A
--WHERE BelongsTo.ProductID = Product.ProductID AND BelongsTo.ProductCategoryID = A.ProductCategoryID
--GROUP BY A.ProductCategoryID
--HAVING COUNT(A.ProductCategoryID) = 

--SELECT DISTINCT Product.StoreID FROM Product, BelongsTo, (SELECT ProductCategory.ProductCategoryID FROM ProductCategory, HasWarranty, BelongsTo WHERE ProductCategory.ProductCategoryID = BelongsTo.ProductCategoryID AND HasWarranty.ProductID = BelongsTo.ProductID AND ProductCategory.ProductCategoryID NOT IN (SELECT DISTINCT BelongsTo.ProductCategoryID FROM BelongsTo WHERE BelongsTo.ProductID NOT IN (SELECT DISTINCT ProductID FROM HasWarranty)))A WHERE BelongsTo.ProductID = Product.ProductID AND BelongsTo.ProductCategoryID = A.ProductCategoryID

--(SELECT ProductCategory.ProductCategoryID FROM ProductCategory, HasWarranty, BelongsTo WHERE ProductCategory.ProductCategoryID = '6' AND ProductCategory.ProductCategoryID = BelongsTo.ProductCategoryID AND HasWarranty.ProductID = BelongsTo.ProductID AND ProductCategory.ProductCategoryID NOT IN (SELECT DISTINCT BelongsTo.ProductCategoryID FROM BelongsTo WHERE BelongsTo.ProductID NOT IN (SELECT DISTINCT ProductID FROM HasWarranty)))