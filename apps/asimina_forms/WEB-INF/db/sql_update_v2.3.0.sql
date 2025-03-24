-- START 30-06-2020 --

ALTER TABLE process_form_field_descriptions ADD COLUMN option_query TEXT;
ALTER TABLE process_form_descriptions MODIFY success_msg text DEFAULT '';
ALTER TABLE process_form_field_descriptions MODIFY label text DEFAULT '';

-- END 30-06-2020 --

-- START 06-07-2020 --

ALTER TABLE process_form_lines MODIFY line_seq int(10);

-- END 06-07-2020 --

-- START 15-07-2020 --
insert into config (code,val) values ('SMTP_DEBUG','true');
-- END 15-07-2020 --