update dev_commons.config set val = '3.4.0' where code = 'APP_VERSION';
update dev_commons.config set val = '3.4.0.1' where code = 'CSS_JS_VERSION';

---------------------start 6/6/2022 Ahsan--------------------------
UPDATE dev_catalog.page SET url='/dev_pages/admin/load.jsp' WHERE url='/dev_pages/admin/import.jsp';
---------------------End 6/6/2022--------------------------