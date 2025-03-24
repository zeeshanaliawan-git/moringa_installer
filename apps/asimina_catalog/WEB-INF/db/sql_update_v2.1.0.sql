-- START 16-12-2019 --
ALTER TABLE comewiths ADD COLUMN title varchar(100);
ALTER TABLE comewiths CHANGE COLUMN element_type applied_to_type varchar(50) DEFAULT NULL;
ALTER TABLE comewiths CHANGE COLUMN element_type_value applied_to_value varchar(255) DEFAULT NULL;
ALTER TABLE comewiths CHANGE COLUMN linked_prod associated_to_type varchar(50) DEFAULT NULL;
ALTER TABLE comewiths CHANGE COLUMN linked_prod_val associated_to_value varchar(255) DEFAULT NULL;
-- END 16-12-2019 --

-- START 23-12-2019 --
DROP TABLE IF EXISTS cart_promotion_rules;

UPDATE cart_promotion SET auto_generate_cc = '1' where auto_generate_cc = 'y';
UPDATE cart_promotion SET auto_generate_cc = '0' where auto_generate_cc = 'n';

ALTER TABLE cart_promotion MODIFY auto_generate_cc TINYINT(1) NOT NULL DEFAULT '0';
ALTER TABLE cart_promotion ADD COLUMN rule_field TINYINT(1) NOT NULL DEFAULT '0';
ALTER TABLE cart_promotion ADD COLUMN rule_type VARCHAR(25) DEFAULT NULL;
ALTER TABLE cart_promotion ADD COLUMN verify_condition VARCHAR(25) DEFAULT NULL;
ALTER TABLE cart_promotion ADD COLUMN rule_condition VARCHAR(12) DEFAULT NULL;
ALTER TABLE cart_promotion ADD COLUMN rule_condition_value VARCHAR(255) DEFAULT NULL;
ALTER TABLE cart_promotion ADD COLUMN discount_type VARCHAR(10) NOT NULL;
ALTER TABLE cart_promotion ADD COLUMN discount_value VARCHAR(10) NOT NULL;
ALTER TABLE cart_promotion ADD COLUMN element_on VARCHAR(20) NOT NULL;
-- END 23-12-2019 --

-- START 01-01-2020 --
-- Ali Adnan
ALTER TABLE product_descriptions
ADD COLUMN seo_title varchar(500) NOT NULL DEFAULT '',
ADD COLUMN seo_canonical_url varchar(1000) NOT NULL DEFAULT '',
ADD COLUMN page_path varchar(500) NOT NULL DEFAULT '';

-- END 01-01-2020 --

-- START 16-01-2020 --
delete from page_sub_urls where url = '/dev_catalog/admin/catalogs/selectcatalog.jsp';
delete from page_sub_urls where url = '/dev_catalog/admin/catalogs/prodcatalogs.jsp';
delete from page_sub_urls where url = '/dev_catalog/admin/catalogs/prodselectcatalog.jsp';
delete from page_sub_urls where url = '/dev_catalog/admin/prodfamilies.jsp';

insert into page_sub_urls (url, sub_url) values ('/dev_catalog/admin/catalogs/catalogs.jsp','/dev_catalog/admin/catalogs/products.jsp');
insert into page_sub_urls (url, sub_url) values ('/dev_catalog/admin/catalogs/catalog.jsp','/dev_catalog/admin/catalogs/products.jsp');
insert into page_sub_urls (url, sub_url) values ('/dev_catalog/admin/catalogs/products.jsp','/dev_catalog/admin/catalogs/product.jsp');

-- END 16-01-2020 --

-- START 28-01-2020 --
update page set url = '/dev_expert_system/pages/screens.jsp', new_tab = 0 where name = 'Expert System';
-- END 28-01-2020 --

-- START 30-01-2020 Ali Adnan --
INSERT INTO page (name, url, new_tab, icon, rang, parent,  parent_icon)
SELECT  'Structured content' as name,
    '/dev_pages/admin/structuredCatalogs.jsp' as url,
    '0' as new_tab,
  'chevron-right' as icon,
MAX(rang)+1 as rang, parent, parent_icon
FROM page
WHERE parent = 'Content'
ORDER BY rang ASC
LIMIT 1;

INSERT INTO page (name, url, new_tab, icon, rang, parent,  parent_icon)
SELECT  'Structured pages' as name,
    '/dev_pages/admin/structuredPageCatalogs.jsp' as url,
    '0' as new_tab,
  'chevron-right' as icon,
MAX(rang)+1 as rang, parent, parent_icon
FROM page
WHERE parent = 'Content'
ORDER BY rang ASC
LIMIT 1;
-- END 30-01-2020

-- START 30-01-2020 --

-- following three tables are for _commons db
USE dev_commons;
CREATE TABLE algolia_settings (
    site_id int(11) not null,
    activated tinyint(1) not null default 0,
    do_indexation tinyint(1) not null default 0,
    application_id varchar(255),
    api_key varchar(255),
    default_index_type varchar(75),
    exclude_noindex tinyint(1) not null default 0,
    PRIMARY KEY (site_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE algolia_indexes (
    site_id int(11) not null,
    index_type varchar(75) not null,
    index_name varchar(255) not null,
    PRIMARY KEY (site_id, index_type)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE algolia_rules (
    site_id int(11) not null,
    rule_type varchar(75) not null,
    rule_criteria varchar(30) not null,
    rule_value varchar(255) not null,
    index_type varchar(75) not null
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


use dev_catalog;
insert into page (name, url, parent, rang, icon, parent_icon) values ('Module Parameters','/dev_catalog/admin/moduleparameters.jsp','System','608','chevron-right','settings');

insert into catalog_types set name='Videos', value='video', product_type='video';


-- END 30-01-2020 --

-- START 07-02-2020 --
insert into page set name='Client Profils', parent='System', url='/dev_menu/pages/prodprofilhomepage.jsp', rang=609, new_tab=0, icon='chevron-right', parent_icon='settings', requires_ecommerce=0;
insert into page set name='Clients', parent='System', url='/dev_menu/pages/prodclientprofilhomepage.jsp', rang=610, new_tab=0, icon='chevron-right', parent_icon='settings', requires_ecommerce=0;

-- END 07-02-2020


-- START 07-02-2020 AA
-- updated the product title format, removed site name from it.
-- to set values of new columns for existing data
-- NOTE : this query needs to be run for each language id which is in language table, replacing "1" with 2,3,4,5 at appropriate places in whole query
UPDATE product_descriptions pd
JOIN (
    SELECT *, REPLACE(REPLACE(TRIM(temppath),' ','-'),'--','-') AS path,
    IF(TRIM(temppath)='','', CONCAT(REPLACE(REPLACE(TRIM(temppath),' ','-'),'--','-'),'.html') ) AS canonical_url
    FROM (


        SELECT p.*,
            CASE
                WHEN p.catalog_type = 'device' OR p.catalog_type = 'accessory' OR p.catalog_type = 'product'
                    THEN TRIM(
                                CONCAT(
                                    p.brand_name
                                    ,' '
                                    ,p.lang_1_name
                                    ,IF(p.lang_1_heading='','',CONCAT(' | ', p.lang_1_heading))
                                )
                            )
                ELSE TRIM(
                            CONCAT(
                                p.lang_1_name
                                ,IF(p.lang_1_heading='','',CONCAT(' | ', p.lang_1_heading))
                            )
                    )
            END as title ,
            CASE
                WHEN p.catalog_type = 'device' OR p.catalog_type = 'accessory' OR p.catalog_type = 'product'
                    THEN TRIM(
                                CONCAT(
                                    IF( p.brand_name='','', CONCAT(p.brand_name,'-') )
                                    ,p.lang_1_name
                                )
                        )
                ELSE TRIM(p.lang_1_name)
            END as temppath
        FROM (
            SELECT c.id as catalog_id, c.catalog_type, p.id as product_id,
            TRIM(COALESCE(p.lang_1_name,'')) AS lang_1_name,
            TRIM(COALESCE(p.brand_name,'')) AS brand_name,
            TRIM(COALESCE(c.lang_1_heading,'')) AS lang_1_heading
            FROM products p
            JOIN catalogs c ON c.id = p.catalog_id
            order by c.catalog_type
        ) p

    )as tt
) AS ttt ON ttt.product_id = pd.product_id
SET pd.seo_title = ttt.title , pd.page_path = ttt.path , pd.seo_canonical_url = ttt.canonical_url
WHERE pd.langue_id = '1';
-- END 07-02-2020


-- START 18-02-2020 --
delete from profil where profil = 'SITE_ACCESS';
-- END 18-02-2020 --

-- START 20-02-2020 --
insert into dev_commons.config (code, val, comments) values ('AUTO_VERIFY_CLIENT','1', 'Value should be 0 or 1. 0 means we have to send an email to client to verify their email');

alter table catalogs add buy_status enum('all','logged') default 'all';

alter table login add email_verification_code varchar(10);
alter table login add sms_verification_code varchar(10);
<<<<<<< .mine
-- END 20-02-2020 --


=======
-- END 20-02-2020 --

-- START 01-04-2020 --
ALTER TABLE product_variants
DROP INDEX sku;
-- END 01-04-2020 --
>>>>>>> .r1439


-- START 07-05-2020 --
insert into page (name, url, parent, rang, icon, parent_icon) values ('Clients Log','/dev_menu/pages/prodclientslog.jsp','System','611','chevron-right','settings');
update page set rang = 612 where name = 'Search Forms' and parent = 'System';
-- END 07-05-2020 --