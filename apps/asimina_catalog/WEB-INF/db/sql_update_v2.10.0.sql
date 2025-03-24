-- START 29-07-2021 --
update dev_commons.config set val = '2.10' where code = 'APP_VERSION';
update dev_commons.config set val = '2.10.0.1' where code = 'CSS_JS_VERSION';
-- START 29-07-2021 --

-- START 25-08-2021 --
CREATE TABLE user_block_config (
  type enum('user','ip') NOT NULL,
  number_of_tries varchar(50) NOT NULL DEFAULT '3',
  block_time varchar(50) NOT NULL DEFAULT '15',
  block_time_unit enum('minutes','hours','days','weeks') NOT NULL DEFAULT 'minutes'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO user_block_config VALUES("user","3","15","minutes");
INSERT INTO user_block_config VALUES("ip","3","15","minutes");

CREATE TABLE user_login_tries (
  username varchar(50) NOT NULL,
  tm timestamp NOT NULL DEFAULT current_timestamp(),
  attempt int(10) NOT NULL DEFAULT 1,
  PRIMARY KEY (username)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

insert into page VALUES("Accounts Blocking","/dev_catalog/admin/blockedUserConfig.jsp", "System",613,0,"chevron-right","settings",0);
-- START 25-08-2021 --
