update dev_commons.config set val = '4.7.0' where code = 'APP_VERSION';
update dev_commons.config set val = '4.7.0.1' where code = 'CSS_JS_VERSION';

alter table profil add is_webmaster tinyint(1) not null default 0;

use dev_pages;
drop view profil;
create view profil as select * from dev_catalog.profil;

use dev_expert_system;
drop view profil;
create view profil as select * from dev_catalog.profil;

use dev_forms;
drop view profil;
create view profil as select * from dev_catalog.profil;

use dev_portal;
drop view profil;
create view profil as select * from dev_catalog.profil;

use dev_prod_portal;
drop view profil;
create view profil as select * from dev_catalog.profil;

CREATE TABLE person_forms (
    person_id int(11) NOT NULL,
    form_id VARCHAR(36),
    PRIMARY KEY (person_id, form_id)
)ENGINE=MyISAM DEFAULT CHARSET=utf8;


----------------- Added by Awais ------------------
    ALTER TABLE algolia_indexes
    ADD COLUMN test_algolia_index VARCHAR(255) NOT NULL AFTER algolia_index;
----------------- End Awais ------------------
