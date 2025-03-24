----------Start Ahsan 20 Dec 2022-----------------
insert into config (code,val) values("EXPORT_LIMIT",50);

create table partoo_services_details(
    id   int(11) AUTO_INCREMENT NOT null,
	partoo_work_id int(11),
	partoo_id varchar(50),
	category  varchar(100),
	service_name  varchar(100),
	service_id  int(11) not null,
	service text,
	site_id   int(11) not null,
	created_on  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_on  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(),
    primary key(id),
	UNIQUE Key `service_idx` (partoo_id,service_id,site_id)
)ENGINE=MyISAM CHARSET=UTF8;

create table partoo_services_details_deleted(
    id   int(11) AUTO_INCREMENT NOT null,
	partoo_work_id int(11),
	partoo_id varchar(50),
	category  varchar(100),
	service_name  varchar(100),
	service_id  int(11) not null,
	service text,
	site_id   int(11) not null,
	created_on  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_on  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(),
    primary key(id)
)ENGINE=MyISAM CHARSET=UTF8;

create table partoo_services_work(
    id   int(11) AUTO_INCREMENT NOT null,
	services_id int(11),
	partoo_id varchar(50),
	method enum('post','delete'),
	request_json text,
	status	enum('pending','error','success') default "pending",
	error_msg text,
	attempt	int(11) default 0,
	site_id int(11) not null,
	created_on  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_on  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(),
    primary key(id)
)ENGINE=MyISAM CHARSET=UTF8;

create table partoo_services(
    id   int(11) AUTO_INCREMENT NOT null,
	category  varchar(100) not null,
	service_name  varchar(100) not null,
	price  double,
	description  varchar(320),
	site_id   int(11) not null,
	to_delete tinyInt(1) default 0,
	created_on  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	created_by  int(11),
	updated_on  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(),
	updated_by  int(11),
    primary key(id),
    UNIQUE Key `service_idx` (category,service_name,site_id)
)ENGINE=MyISAM CHARSET=UTF8;

create table partoo_services_deleted(
    id   int(11) AUTO_INCREMENT NOT null,
	category  varchar(100) not null,
	service_name  varchar(100) not null,
	price  double,
	description  varchar(320),
	site_id   int(11) not null,
	created_on  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	created_by  int(11),
	updated_on  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(),
	updated_by  int(11),
    primary key(id)
)ENGINE=MyISAM CHARSET=UTF8;

----------End Ahsan 12 Jan 2022-----------------