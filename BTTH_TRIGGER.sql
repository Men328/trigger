CREATE DATABASE InventoryManagement;

CREATE TABLE products(
	productID INT PRIMARY KEY AUTO_INCREMENT,
    productName VARCHAR(100),
    quantity INT
);

CREATE TABLE InventoryChanges(
	changeID INT PRIMARY KEY AUTO_INCREMENT,
    productID INT, 
    FOREIGN KEY (productID) REFERENCES products(productID),
    oldQuantity INT,
    newQuantity INT,
    changeDate DATETIME
);

INSERT INTO products(productID, productName, quantity) VALUES 
(1, 'lenovo', 7),
(2, 'asus', 8),
(3, 'dell', 9);

DELIMITER $$
CREATE TRIGGER AfterProductUpdate
AFTER UPDATE
ON products
FOR EACH ROW 
BEGIN
	INSERT INTO inventorychanges(productID, oldQuantity, newQuantity, changeDate)
    VALUES (OLD.productID, OLD.quantity, NEW.quantity, NOW());
END$$

DELIMITER ;

DROP TRIGGER AfterProductUpdate;

UPDATE products
SET quantity = 25
WHERE productID = 1;

UPDATE products
SET quantity = 19
WHERE productID = 3;

DELIMITER $$
CREATE TRIGGER BeforeProductDelete
BEFORE DELETE 
ON products
FOR EACH ROW
BEGIN
	IF OLD.quantity > 10 THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Are you sure want to delete?';
    END IF;
END$$

DELIMITER ;
drop trigger BeforeProductDelete;
DELETE FROM products WHERE productID = 3;

-- Bài3
ALTER TABLE products
ADD LastUpdate DATETIME;

DELIMITER $$

CREATE TRIGGER AfterProductUpdateSetDate
BEFORE UPDATE ON products
FOR EACH ROW
BEGIN 
    SET NEW.LastUpdate = NOW();
END$$

DELIMITER ;

DROP TRIGGER AfterProductUpdateSetDate;

UPDATE products
SET quantity = 100
WHERE productID = 2;

-- Bài4
CREATE TABLE ProductSummary(
	sumaryID INT PRIMARY KEY AUTO_INCREMENT,
    totalQuantity INT
);

INSERT INTO ProductSummary(sumaryID, totalQuantity) VALUES (1, 0);

DELIMITER $$
CREATE TRIGGER AfterProductUpdateSummary
AFTER UPDATE
ON products
FOR EACH ROW
BEGIN
    DECLARE total INT DEFAULT 0;

    SELECT SUM(quantity)
    INTO total
    FROM products;

    UPDATE ProductSummary SET TotalQuantity = total;
END$$
DELIMITER ;

DROP TRIGGER AfterProductUpdateSummary;

UPDATE products
SET quantity = 200
WHERE productID = 3;

UPDATE products
SET quantity = 150
WHERE productID = 3;

-- Bài5

CREATE TABLE inventoryChangeHistory(
	historyID INT PRIMARY KEY AUTO_INCREMENT,
    productID INT,
    FOREIGN KEY(productID) REFERENCES products(productID),
    oldQuantity INT,
    newQuantity INT,
    changeType ENUM('INCREASE', 'DESCREASE'),
    changeDate DATETIME
)

DELIMITER $$
CREATE TRIGGER AfterProductUpdateHistory
AFTER UPDATE 
ON Products
FOR EACH ROW
BEGIN
    DECLARE change_type ENUM('INCREASE', 'DECREASE');
    IF NEW.quantity > OLD.quantity THEN
        SET change_type = 'INCREASE';
    ELSE 
		SET change_type = 'DECREASE';
    END IF;

    INSERT INTO InventoryChangeHistory (productID, oldQuantity, newQuantity, change_Type, ChangeDate)
    VALUES (OLD.ProductID, OLD.Quantity, NEW.Quantity, change_type, NOW());
END $$
DELIMITER ;

DROP TRIGGER AfterProductUpdateHistory;

UPDATE products SET quantity = 40 WHERE productID = 3;








