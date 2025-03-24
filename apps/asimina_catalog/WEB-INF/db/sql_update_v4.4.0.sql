update dev_commons.config set val = '3.2.0' where code = 'APP_VERSION';
update dev_commons.config set val = '4.4.0.1' where code = 'CSS_JS_VERSION';

------------- Started 27 Sep 2023 Ahsan -------------
--only for catalog
DELETE FROM additionalfee_rules WHERE add_fee_id not IN (SELECT id FROM additionalfees_tbl);

update config set val=0 where code ='MAX_TAG_FOLDER_LEVEL';
INSERT INTO tags_folders (uuid,folder_id,name,site_id) select uuid(),'default-folder','Default Folder',id from dev_portal.sites;

-- for catalog
ALTER TABLE deliveryfees_tbl ADD COLUMN UUID VARCHAR(36) DEFAULT UUID() NOT NULL,ADD UNIQUE KEY (UUID);
DROP VIEW if exists deliveryfees;
CREATE VIEW deliveryfees AS SELECT * FROM deliveryfees_tbl WHERE is_deleted=0;

-- for prod catalog
ALTER TABLE deliveryfees ADD COLUMN UUID VARCHAR(36) DEFAULT UUID() NOT NULL,ADD UNIQUE KEY (UUID);

------------- End 27 Sep 2023 Ahsan -------------

alter table login add allowed_ips varchar(255);

drop view dev_pages.login;
create view dev_pages.login as select * from dev_catalog.login;

drop view dev_forms.login;
create view dev_forms.login as select * from dev_catalog.login;

drop view dev_expert_system.login;
create view dev_expert_system.login as select * from dev_catalog.login;

drop view dev_portal.login;
create view dev_portal.login as select * from dev_catalog.login;

------------- End 27 Sep 2023 Ahsan -------------------------- End 27 Sep 2023 Ahsan -------------


ALTER TABLE product_variants ADD COLUMN stock_thresh INT (11) UNSIGNED NOT NULL DEFAULT 0;

CREATE TABLE dev_commons.inventory_mail (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `email_test` varchar(255) NOT NULL,
  `email_prod` varchar(255) NOT NULL,
  `test_email_sent_ts` TIMESTAMP,
  `prod_email_sent_ts` TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `s_id` (`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
