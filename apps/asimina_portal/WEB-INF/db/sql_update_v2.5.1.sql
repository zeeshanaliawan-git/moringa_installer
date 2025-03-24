
-- START 30-12-2020 --

drop view dev_portal.login;
create view dev_portal.login as select * from dev_catalog.login;

drop view dev_prod_portal.login;
create view dev_prod_portal.login as select * from dev_catalog.login;



update dev_portal.config set val = 'tadmin00$#t0' where code = 'PREPROD_AUTH_PASSWD';
update dev_portal.config set val = 'padmin00$#p0' where code = 'PROD_AUTH_PASSWD';

-- END 30-12-2020 --
