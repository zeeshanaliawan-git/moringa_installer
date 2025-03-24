update dev_commons.config set val = '3.10.0' where code = 'APP_VERSION';
update dev_commons.config set val = '3.10.0.1' where code = 'CSS_JS_VERSION';

insert into dev_commons.config (code, val) values ("EXP_SYS_EXTERNAL_URL", "/dev_expert_system/");

insert into dev_commons.config (code, val) values ("FORMS_WEBAPP_URL", "/dev_forms/");
