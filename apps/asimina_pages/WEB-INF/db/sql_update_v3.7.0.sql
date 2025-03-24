-------- 7 Oct 2022 Ahsan -------------------------
DROP VIEW pages;
ALTER TABLE pages_tbl ADD COLUMN attempt INT(11) DEFAULT 0;
UPDATE pages_tbl SET attempt=attempt+1 WHERE published_ts IS NOT NULL;
CREATE VIEW pages as SELECT * FROM pages_tbl WHERE is_deleted=0;
---------7 Oct 2022 Ahsan -------------------------