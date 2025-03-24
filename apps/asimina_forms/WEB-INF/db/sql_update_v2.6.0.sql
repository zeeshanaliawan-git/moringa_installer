-- START 30-12-2020 --

ALTER TABLE actions MODIFY className varchar(32) DEFAULT NULL;
INSERT INTO actions(name, className) VALUES ('forgotpassword','AsiminaClientForgotPassword');

-- END 30-12-2020 --


-- START 25-01-2021 --

ALTER TABLE process_form_field_descriptions MODIFY `value` varchar(1052);

-- END 25-01-2021 --

-- START 28-01-2021 --

INSERT INTO rules (start_proc, start_phase, errcode, next_proc, next_phase, rdv, type, `action`)
SELECT `table_name`, "CreateClient", "30", `table_name`, "Done", "And", "Cancelled", "client:create"
FROM process_forms
WHERE `table_name` like 'sign_up_%';

-- END 28-01-2021 --

-- START 19-02-2021 --

CREATE TABLE `supported_files` (
	`extension` varchar(250) NOT NULL DEFAULT '',
	`type` varchar(250) NOT NULL DEFAULT '',
	PRIMARY KEY (`extension`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO supported_files VALUES
('jpg','image/jpeg'),
('jpeg','image/jpeg'),
('png','image/png'),
('pdf','application/pdf'),
('doc','application/msword'),
('docx','application/vnd.openxmlformats-officedocument.wordprocessingml.document'),
('ppt','application/vnd.ms-powerpoint'),
('pptx','application/vnd.openxmlformats-officedocument.presentationml.presentation'),
('mov','video/quicktime'),
('avi','video/x-msvideo'),
('mp4','video/mp4'),
('3gp','video/3gpp');

ALTER TABLE process_form_fields MODIFY COLUMN file_extension varchar(256) DEFAULT '';

-- END 19-02-2021 --
