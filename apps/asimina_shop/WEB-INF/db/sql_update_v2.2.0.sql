-- START 25-02-2020 --
create table sms
(
	sms_id int auto_increment,
	nom varchar(50),
	texte text, 
	where_clause varchar(255),
	primary key (sms_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
-- END 25-02-2020 --