alter table sites add generate_breadcrumbs tinyint(1) not null default 1;

alter table algolia_indexation modify cid varchar(36) default null;
alter table algolia_indexation modify variant_id varchar(36) default null;

drop table if exists algolia_indexation_history;
CREATE TABLE algolia_indexation_history (
menu_id int(11) NOT NULL,
ctype varchar(75)  DEFAULT NULL,
cid varchar(50)  DEFAULT NULL,
algolia_index varchar(255) DEFAULT NULL,
algolia_json mediumtext DEFAULT NULL,
is_active tinyint(1) NOT NULL,
variant_id varchar(50) DEFAULT NULL,
created_ts timestamp not null default current_timestamp
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
