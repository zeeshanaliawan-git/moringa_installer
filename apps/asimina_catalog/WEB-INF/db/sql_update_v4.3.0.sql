update dev_commons.config set val = '4.3.0' where code = 'APP_VERSION';
update dev_commons.config set val = '4.3.0.1' where code = 'CSS_JS_VERSION';

--------------- Ahsan start 21 July 2023 ---------------
create table shortcuts (
    id int(11) AUTO_INCREMENT NOT NULL,
    name VARCHAR(100) NOT NULL,
	url VARCHAR(255) NOT NULL,
    created_by INT(11) NOT NULL,
    site_id INT(11) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_shrt_cut` (`name`,`site_id`,`created_by`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

            ----- in every db
CREATE VIEW shortcuts AS SELECT * FROM dev_catalog.shortcuts;

--------------- Ahsan end 21 July 2023 ---------------