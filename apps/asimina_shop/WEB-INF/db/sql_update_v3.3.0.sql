alter table page add menu_badge varchar(25);
update page set menu_badge = 'NEW' where name in ('dashboard');
