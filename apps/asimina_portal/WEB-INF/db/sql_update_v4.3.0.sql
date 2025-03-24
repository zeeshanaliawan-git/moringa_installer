---------- Ahsan start 8 Aug 2023 --------------
alter table stat_log add column site_id int(11);
---------- Ahsan end 8 Aug 2023 --------------


-- umair --
create table algolia_indexation_v43 as select * from algolia_indexation;
delete from algolia_indexation where menu_id not in (select id from site_menus);
-- umair --