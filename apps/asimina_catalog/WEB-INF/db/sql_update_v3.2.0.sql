update dev_commons.config set val = '3.2.0' where code = 'APP_VERSION';
update dev_commons.config set val = '3.2.0.1' where code = 'CSS_JS_VERSION';

--Start 3-11-2022 Ahsan--
ALTER TABLE shop_parameters ADD COLUMN lang_1_free_payment_method VARCHAR(255) not null default 'Free' comment 'Text to show when payment method has no charged';
ALTER TABLE shop_parameters ADD COLUMN lang_2_free_payment_method VARCHAR(255) not null default 'Free' comment 'Text to show when payment method has no charged';
ALTER TABLE shop_parameters ADD COLUMN lang_3_free_payment_method VARCHAR(255) not null default 'Free' comment 'Text to show when payment method has no charged';
ALTER TABLE shop_parameters ADD COLUMN lang_4_free_payment_method VARCHAR(255) not null default 'Free' comment 'Text to show when payment method has no charged';
ALTER TABLE shop_parameters ADD COLUMN lang_5_free_payment_method VARCHAR(255) not null default 'Free' comment 'Text to show when payment method has no charged';

ALTER TABLE shop_parameters ADD COLUMN lang_1_free_delivery_method VARCHAR(255) not null default 'Free' comment 'Text to show when delivery method has no charged';
ALTER TABLE shop_parameters ADD COLUMN lang_2_free_delivery_method VARCHAR(255) not null default 'Free' comment 'Text to show when delivery method has no charged';
ALTER TABLE shop_parameters ADD COLUMN lang_3_free_delivery_method VARCHAR(255) not null default 'Free' comment 'Text to show when delivery method has no charged';
ALTER TABLE shop_parameters ADD COLUMN lang_4_free_delivery_method VARCHAR(255) not null default 'Free' comment 'Text to show when delivery method has no charged';
ALTER TABLE shop_parameters ADD COLUMN lang_5_free_delivery_method VARCHAR(255) not null default 'Free' comment 'Text to show when delivery method has no charged';

--End 3-11-2022 Ahsan--


alter table dev_commons.user_sessions add pid int(11);

insert into page (name, url, parent, rang, icon, parent_icon) values ('Forum Tags','/dev_catalog/admin/catalogs/forum_tags.jsp','Content', 310, 'chevron-right','file-text');