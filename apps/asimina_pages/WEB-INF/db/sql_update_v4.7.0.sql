alter table freemarker_pages_tbl add crt_by_webmaster VARCHAR(500);
alter table freemarker_pages_tbl add upd_by_webmaster VARCHAR(500);
alter table freemarker_pages_tbl add upd_on_by_webmaster datetime default null; 

drop view freemarker_pages;
create view freemarker_pages as select * from freemarker_pages_tbl where is_deleted = 0;

alter table structured_contents_tbl add crt_by_webmaster VARCHAR(500);
alter table structured_contents_tbl add upd_by_webmaster VARCHAR(500);
alter table structured_contents_tbl add upd_on_by_webmaster datetime default null; 

drop view structured_contents;
create view structured_contents as select * from structured_contents_tbl where is_deleted = 0;

alter table structured_contents_published add crt_by_webmaster VARCHAR(500);
alter table structured_contents_published add upd_by_webmaster VARCHAR(500);
alter table structured_contents_published add upd_on_by_webmaster datetime default null; 