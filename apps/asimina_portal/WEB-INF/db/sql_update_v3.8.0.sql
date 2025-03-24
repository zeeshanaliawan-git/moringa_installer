ALter table client_reactions add column field_id int(11), add column session_id varchar(50), modify column source_type enum('page','product','forum','form');

alter table stat_log add index `idxDateL` (`date_l`);
alter table stat_log add index `idx2` (`date_l`,`page_c`);

alter table cart add cart_step varchar(50) default null;
