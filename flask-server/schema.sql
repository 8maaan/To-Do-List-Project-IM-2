-- TABLES --

CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB;

CREATE TABLE `tasks` (
  `task_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `category_id` int DEFAULT NULL,
  `task_name` varchar(255) NOT NULL,
  `description` text,
  `due_date` date DEFAULT NULL,
  `is_completed` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`task_id`),
  KEY `user_id` (`user_id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `tasks_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `tasks_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `task_categories` (`category_id`)
) ENGINE=InnoDB;

CREATE TABLE `task_categories` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `category_name` varchar(50) NOT NULL,
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB;

-----------------------------------------

-- STORED PROCEDURES --

-- Creating a user
DELIMITER $$$

CREATE PROCEDURE `create_user`(
    IN p_username VARCHAR(50),
    IN p_password VARCHAR(255),
    IN p_email VARCHAR(100)
)
insertUser:BEGIN
	DECLARE user_exists INT DEFAULT 0;

    -- Check if any parameter is empty
    IF LENGTH(p_username) = 0 OR LENGTH(p_password) = 0 OR LENGTH(p_email) = 0 THEN
        SELECT 'All fields must be provided.' AS message;
        LEAVE insertUser;
    END IF;

    -- Check if the username already exists
    SELECT COUNT(*) INTO user_exists
    FROM users
    WHERE username = p_username;

    -- If the username exists, set the message and exit
    IF user_exists > 0 THEN
        SELECT 'Username already exists. Please choose a different username.' AS message;
    ELSE
        -- If the username does not exist, insert the new user
        INSERT INTO users (username, password, email)
        VALUES (p_username, p_password, p_email);
        SELECT 'User created successfully.' AS message;
    END IF;
END $$$

DELIMITER ;

-- Creating a task
DELIMITER $$$

CREATE PROCEDURE create_task(
    IN p_user_id INT,
    IN p_category_id INT,
    IN p_task_name VARCHAR(255),
    IN p_description TEXT,
    IN p_due_date DATE,
)
BEGIN
    -- Insert the new task
    INSERT INTO tasks (user_id, category_id, task_name, description, due_date)
    VALUES (p_user_id, p_category_id, p_task_name, p_description, p_due_date);

    -- Set success message
    SELECT 'User created successfully.' AS message;
END $$$

DELIMITER ;

-- Read/View tasks
CREATE VIEW task_view AS
SELECT
    t.task_id,
    t.user_id,
    t.category_id,
    t.task_name,
    t.description,
    t.due_date,
    t.status,
    u.username AS user_username,
    c.category_name
FROM
    tasks t
    JOIN users u ON t.user_id = u.user_id
    JOIN task_categories c ON t.category_id = c.category_id;

-- 

DELIMITER $$$

CREATE PROCEDURE user_authenticate(
    IN p_username VARCHAR(50),
    IN p_password VARCHAR(255)
)
BEGIN
    DECLARE hashed_password VARCHAR(255);
    
    -- Retrieve the hashed password for the given username
    SELECT password INTO hashed_password
    FROM users
    WHERE username = p_username;

    -- Check if the username exists and the password matches
    IF hashed_password IS NOT NULL AND hashed_password = p_password THEN
        -- Authentication successful, return the user_id and message
        SELECT user_id AS id, 'Authentication successful.' AS message
        FROM users
        WHERE username = p_username;
    ELSE
        -- Invalid username or password, return null and error message
        SELECT NULL AS id, 'Invalid username or password.' AS message;
    END IF;
END $$$

DELIMITER ;