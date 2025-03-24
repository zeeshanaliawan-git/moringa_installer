 ---------------------start 6/7/2022 Ahsan--------------------------
ALTER TABLE process_forms_unpublished_tbl DROP INDEX process_name;
ALTER TABLE process_forms_unpublished_tbl ADD CONSTRAINT process_name UNIQUE (`is_deleted`,`process_name`,`site_id`);
---------------------End 6/7/2022--------------------------