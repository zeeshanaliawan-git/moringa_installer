alter table clients add index idx1 (site_id, form_row_id);

-------------Start 27 June 2022 Ahsan--------------------
ALTER TABLE cart ADD COLUMN incomplete_cart_mail_sent TINYINT NOT NULL DEFAULT 0;
-------------End 4 July 2022 Ahsan--------------------

alter table sites add algolia_stores_index varchar(255);

alter table cart add  cart_type enum('normal','topup') not null default 'normal';
alter table cart add  lang varchar(5);
alter table cart_items add  price_per_item double;

