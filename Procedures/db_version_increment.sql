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
