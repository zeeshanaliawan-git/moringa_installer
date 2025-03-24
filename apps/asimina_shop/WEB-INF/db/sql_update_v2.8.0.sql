-- START 06-04-2021 -- 

ALTER TABLE `dashboard_urls` ADD PRIMARY KEY (`url_type`, `url`);

insert into config (code, val) values ('DASHBOARD_PDF_PATH','/home/etn/tomcat/webapps/dev_shop/custom/dashboard_pdfs/');

CREATE TABLE `dashboard_emails` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `email` varchar(100) NOT NULL,
  `subject` varchar(1000) NOT NULL,
  `message` mediumtext NOT NULL,
  `dashboard_pdf` varchar(100) NOT NULL,
  `email_sent` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

insert into config (code, val) values ('DASHBOARD_EXCEL_PATH','/home/etn/tomcat/webapps/dev_shop/custom/dashboard_excels/');

-- END 06-04-2021 -- 