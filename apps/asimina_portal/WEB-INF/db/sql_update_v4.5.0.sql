
ALTER TABLE cart Add column keepPhone varchar(64);

CREATE TABLE `bloc_viewers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bloc_id` int(11) unsigned NOT NULL,
  `page_uuid` varchar(36) NOT NULL,
  `client_id` varchar(50) DEFAULT NULL,
  `session_j` varchar(100) DEFAULT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

alter table idcheck_configurations add email varchar(500) not null;
alter table idcheck_configurations add password varchar(500) not null;
alter table idcheck_configurations add bloc_uuid varchar(100) default null;
