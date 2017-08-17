CREATE DEFINER=`root`@`%` PROCEDURE `deprecate_table`( TABLE_NAME_VALUE TEXT(200), DB_VERSION TEXT(200) )
    READS SQL DATA
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
END
