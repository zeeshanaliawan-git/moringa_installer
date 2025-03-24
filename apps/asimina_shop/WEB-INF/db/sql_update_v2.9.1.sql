-- START 13-07-2021 ---

ALTER TABLE person
ADD COLUMN forgot_password  tinyint(1) NOT NULL DEFAULT 0 AFTER home_page,
ADD COLUMN forgot_pass_token  varchar(36) DEFAULT NULL AFTER forgot_password,
ADD COLUMN forgot_pass_token_expiry  datetime DEFAULT NULL AFTER forgot_pass_token;

alter table person add forgot_password_referrer varchar(255);



CREATE TABLE public_urls (
  id  int UNSIGNED NOT NULL AUTO_INCREMENT ,
  url varchar(255) NOT NULL DEFAULT '',
  url_type varchar(20) NOT NULL DEFAULT '',
  PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

insert into public_urls  (url,url_type) values('/login.jsp','endsWith');
insert into public_urls  (url,url_type) values('/logout.jsp','endsWith');
insert into public_urls  (url,url_type) values('/dashboard/','contains'); 
insert into public_urls  (url,url_type) values('/forgotpassword.jsp','endsWith'); 
insert into public_urls  (url,url_type) values('/resetpass.jsp','endsWith'); 
insert into public_urls  (url,url_type) values('/resetpassbackend.jsp','endsWith'); 

alter table public_urls add unique key (url);
-- END 13-07-2021 ---

