-- START 30-12-2020 --
alter table dev_shop.login change pass pass varchar(75) not null;
alter table dev_shop.login add pass_expiry date not null;

update dev_shop.login set pass_expiry = adddate(now(), interval 90 day);

update dev_shop.login l, dev_commons.config c set pass = sha2(concat(c.val,'$', 'welcome021', '$', puid), 256) where c.code = 'ADMIN_PASS_SALT';

alter table dev_shop.order_items change product_snapshot product_snapshot mediumtext ;


alter table dev_prod_shop.login change pass pass varchar(75) not null;
alter table dev_prod_shop.login add pass_expiry date not null;

update dev_prod_shop.login set pass_expiry = adddate(now(), interval 90 day);

update dev_prod_shop.login l, dev_commons.config c set pass = sha2(concat(c.val,'$', 'welcome021', '$', puid), 256) where c.code = 'ADMIN_PASS_SALT';

alter table dev_prod_shop.order_items change product_snapshot product_snapshot mediumtext ;


-- END 30-12-2020 -- 