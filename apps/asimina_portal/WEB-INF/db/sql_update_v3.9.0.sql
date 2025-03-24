--------------Start Ahsan 19 Dec 2022 -------------------
Insert into config (code,val) values('qrcodes_dir','/home/etn/pjt/dev_engines/selfcare/qrcodes/');

create table stat_log_page_info(
	page_c VARCHAR(255),
	title VARCHAR(255),
	eletype varchar(100),
	eleid int(11),
	site_uuid varchar(50),
	lang varchar(20),
	creation_date datetime not null default current_timestamp,
	update_date datetime not null default current_timestamp on update current_timestamp(),
	primary key(page_c, site_uuid)
)ENGINE=MyISAM CHARSET=utf8;
--------------End Ahsan 27 jan 2023 -------------------

alter table sites drop extra_cart_info_impl_cls;

alter table cart add uuid varchar(50) not null default uuid() after id;
alter table cart add additional_info MEDIUMTEXT;

CREATE TABLE `checkout_add_info_sections` (
id int(11) not null auto_increment,
site_id int(11) not null,
name VARCHAR(255) not null comment 'This must be lower case, without french characters or any special charactes and no white spaces. This column is important to be used in the email templates later',
display_name VARCHAR(255) not null,
PRIMARY KEY (id),
unique key (site_id, name)
) ENGINE=myisam DEFAULT CHARSET=utf8;

CREATE TABLE `checkout_add_info_fields` (
id int(11) not null auto_increment,
section_id varchar(50) not null,
name VARCHAR(255) not null comment 'This must be lower case, without french characters or any special charactes and no white spaces. This column is important to be used in the email templates later',
display_name VARCHAR(255) not null,
ftype enum ('hidden','text','file') not null default 'text',
file_allowed_types VARCHAR(500) comment 'Provide semi-colon sepearate content types allowed if field is a file',
PRIMARY KEY (id),
unique key (section_id, name)
) ENGINE=myisam DEFAULT CHARSET=utf8;


insert into config (code, val) values ('funnel_documents_base_dir','/home/etn/tomcat/webapps/dev_shop/uploads/');
insert into config (code, val) values ('funnel_documents_base_url','/dev_shop/uploads/');


-- script 
-- mv uploads to dev_shop uploads

alter table sites add open_only_in_iframe tinyint(1) not null default 0;

alter table cart modify cart_type enum('normal','topup','card2wallet') not null default 'normal';
