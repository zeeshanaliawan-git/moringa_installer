------------- Ahsan Start 19 Jan 2024  -------------
insert into config (code,val) values ('IMPORT_SEMAPHORE','D010'),('PARTOO_SEMAPHORE','D011');
ALTER TABLE variables ADD CONSTRAINT site_id_name_unique UNIQUE (site_id, name);
------------- Ahsan End 6 Feb 2024  -------------