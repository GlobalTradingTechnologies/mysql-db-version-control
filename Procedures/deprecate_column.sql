CREATE DEFINER=`root`@`%` PROCEDURE `deprecate_column`( TABLE_NAME_VALUE TEXT(200), COLUMN_NAME_VALUE TEXT(200), DB_VERSION TEXT(200) )
    READS SQL DATA
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
END
