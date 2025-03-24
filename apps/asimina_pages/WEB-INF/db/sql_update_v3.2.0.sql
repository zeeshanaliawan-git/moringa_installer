-- START 04-02-2021 Ahsan----
CREATE TABLE media_records(
id INT NOT NULL AUTO_INCREMENT,
file_id INT,
file_name VARCHAR(255),
used_at VARCHAR(255),
type VARCHAR(100),
PRIMARY KEY (id)
)ENGINE = MyISAM DEFAULT CHARSET = utf8;

ALTER TABLE dev_pages.files ADD times_used INT NOT NULL DEFAULT 0;

-- END 04-02-2021 Ahsan----



insert into ignore_xss_fields values ('blocsAjax.jsp','detailsJson');