CREATE TABLE `dbversion` (
  `dbv_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Database version id',
  `dbv_name` varchar(50) DEFAULT NULL COMMENT 'Database version name',
  `dbv_description` varchar(260) DEFAULT NULL COMMENT 'Database version description',
  `dbv_time_create` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Database version apply time',
  PRIMARY KEY (`dbv_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='Database version'