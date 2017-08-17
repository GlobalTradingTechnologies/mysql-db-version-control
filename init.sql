CREATE TABLE `dbversion` (
  `dbv_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Database version id',
  `dbv_name` varchar(50) DEFAULT NULL COMMENT 'Database version name',
  `dbv_description` varchar(260) DEFAULT NULL COMMENT 'Database version description',
  `dbv_time_create` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Database version apply time',
  PRIMARY KEY (`dbv_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='Database version';

DELIMITER $$ $$

CREATE DEFINER=`root`@`%` FUNCTION `db_version_increment`(type_of_patch ENUM('MAJOR','MINOR','PATCH')) RETURNS varchar(50) CHARSET utf8
    READS SQL DATA
    COMMENT 'Return increment for current dbversion number'
BEGIN
  DECLARE patch VARCHAR(50);
  SET patch = (SELECT `dbv_name` FROM `dbversion`  WHERE 1 order by `dbv_id` DESC limit 1);

  RETURN CASE type_of_patch
    WHEN 'MAJOR' THEN CONCAT(SUBSTRING_INDEX(patch, '.', 1)+1, '.0.0')
    WHEN 'MINOR' THEN CONCAT(SUBSTRING_INDEX(patch, '.', 1),'.', SUBSTRING_INDEX(SUBSTRING_INDEX(patch, '.', 2), '.', -1)+1, '.0')
    WHEN 'PATCH' THEN CONCAT(SUBSTRING_INDEX(patch, '.', 2), '.', (SUBSTRING_INDEX(patch, '.', -1) +1))
    ELSE CONCAT(SUBSTRING_INDEX(patch, '.', 2), '.', (SUBSTRING_INDEX(patch, '.', -1) +1))
  END;
END

$$

CREATE PROCEDURE deprecate_column( TABLE_NAME_VALUE TEXT(200), COLUMN_NAME_VALUE TEXT(200), DB_VERSION TEXT(200) )
  NOT DETERMINISTIC
  READS SQL DATA
  SQL SECURITY DEFINER
COMMENT 'ALTER TABLE CHANGE COMMENT TO DEPRECATED COLUMN'
BEGIN

SET @column_comment := (select `COLUMN_COMMENT` from `information_schema`.columns
where
	`TABLE_SCHEMA` = database()
	AND `TABLE_NAME` = TABLE_NAME_VALUE
	AND `COLUMN_NAME` = COLUMN_NAME_VALUE
LIMIT 1
) ;
SET @column_definition := (select CONCAT(
' ',`COLUMN_TYPE`
)
from `information_schema`.columns
where
	`TABLE_SCHEMA` = database()
	AND `TABLE_NAME` = TABLE_NAME_VALUE
	AND `COLUMN_NAME` = COLUMN_NAME_VALUE
LIMIT 1
) ;

SET @comment := CONCAT('[Deprecated since ', DB_VERSION, '], ', @column_comment);
SET @sql := CONCAT('ALTER TABLE ',TABLE_NAME_VALUE,' CHANGE `',COLUMN_NAME_VALUE, '` `',COLUMN_NAME_VALUE, '` ',@column_definition,' COMMENT \'', @comment, '\'');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END;
$$

DELIMITER ;
DROP PROCEDURE IF EXISTS deprecate_table;
DELIMITER $$
CREATE PROCEDURE deprecate_table( TABLE_NAME_VALUE TEXT(200), DB_VERSION TEXT(200) )
  NOT DETERMINISTIC
  READS SQL DATA
  SQL SECURITY DEFINER
COMMENT 'ALTER TABLE CHANGE COMMENT TO DEPRECATED TABLE'
BEGIN

SET @column_comment := (select `TABLE_COMMENT` from `information_schema`.TABLES
WHERE `TABLE_SCHEMA` = database()
AND `TABLE_NAME` = TABLE_NAME_VALUE
limit 1
) ;

SET @comment := CONCAT('[Deprecated since ', DB_VERSION, '], ', @column_comment);
SET @sql := CONCAT('ALTER TABLE ',TABLE_NAME_VALUE,' COMMENT \'', @comment, '\'');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END;
$$

DELIMITER ; ;
