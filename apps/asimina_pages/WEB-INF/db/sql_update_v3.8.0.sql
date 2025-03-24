------- Start 03 Nov 2022 Ahsan ---------
CREATE TABLE batch_export(
	batch_id varchar(255) not null default UUID(),
	target_ids text,
	lang_ids varchar(255),
	site_id int(10) NOT NULL,
	export_type varchar(255),
	excel_export tinyInt(1) default 0,
	process enum('waiting','processing','exported','export_error'),
	updated_ts timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
	created_ts timestamp NOT NULL DEFAULT current_timestamp(),
	created_by	int(11),
	error_msg varchar(255),
	primary key (batch_id)
)ENGINE=MyISAM DEFAULT CHARSET=UTF8;

ALTER TABLE batch_imports ADD COLUMN updated_items TEXT, ADD COLUMN skipped_items TEXT;

------- End 05 Nov 2022 Ahsan ---------