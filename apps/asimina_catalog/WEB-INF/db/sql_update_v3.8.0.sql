update dev_commons.config set val = '3.8.0' where code = 'APP_VERSION';
update dev_commons.config set val = '3.8.0.1' where code = 'CSS_JS_VERSION';

alter table dev_commons.config change val val varchar(500);

update dev_catalog.products_tbl p1 inner join dev_prod_catalog.products p2 on p2.id = p1.id set p1.product_uuid = p2.product_uuid;