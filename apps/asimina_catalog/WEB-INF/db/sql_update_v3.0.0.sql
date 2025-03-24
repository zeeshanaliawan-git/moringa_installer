update dev_commons.config set val = '3.0.0' where code = 'APP_VERSION';
update dev_commons.config set val = '3.0.0.1' where code = 'CSS_JS_VERSION';

delete from dev_catalog.page where name = 'landing pages';
delete from dev_catalog.page where name = 'URL Generator test';
delete from dev_catalog.page where name = 'URL Generator Prod';
delete from dev_catalog.page where name = 'Backup';

update dev_catalog.page set name = 'Redirections' where name = 'URL Redirections';


alter table shop_parameters add stock_alert_email_id_test int(11) default null;

alter table shop_parameters add stock_alert_email_id_prod int(11) default null;

update shop_parameters set stock_alert_email_id_test = (select val from dev_shop.config where code = 'STOCK_ALERT_MAIL_ID');
update shop_parameters set stock_alert_email_id_prod = (select val from dev_prod_shop.config where code = 'STOCK_ALERT_MAIL_ID');


alter table shop_parameters add lang_1_save_cart_text text;
alter table shop_parameters add lang_2_save_cart_text text;
alter table shop_parameters add lang_3_save_cart_text text;
alter table shop_parameters add lang_4_save_cart_text text;
alter table shop_parameters add lang_5_save_cart_text text;


update page set rang = rang - 300 where parent = 'Navigation';
update page set rang = rang + 2 where parent = 'Navigation' and rang > 201;
update page set parent = 'Navigation', rang= 202 where name ='Menus (new)';
update page set parent = 'Navigation', rang= 203 where name ='Menu js';

update page set rang = 10, name='Clear Cache', parent = '', icon = 'refresh-cw', parent_icon = '' where name = 'Cache';