--------------- Started 3 Oct 22 Ahsan--------------

------ only for prod_portal
CREATE TABLE `publish_content`(
	id INT(11) AUTO_INCREMENT,
	cid	VARCHAR(36) NOT NULL,
	site_id INT(11) NOT NULL,
	publication_type ENUM('publish','unpublish'),
	ctype ENUM('page', 'structuredcontent','structuredpage','store','catalog','product','forum'),
	status TINYINT(1) DEFAULT 0 NOT null,
	priority TIMESTAMP NOT null, 
	attempt INT(11) DEFAULT 0,
	err_msg VARCHAR(100),
	created_on timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP(),
	created_by varchar(36),
	updated_on timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
	updated_by varchar(36),
	PRIMARY KEY (id)
)ENGINE=InnoDB DEFAULT CHARSET=UTF8;

--------------- Endeed 3 Oct 22 Ahsan--------------