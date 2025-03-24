insert into config (code, val) value ('export_csv_dir', '/home/etn/tomcat/webapps/dev_forms/admin/tmp/');
insert into config (code, val) value ('export_csv_url', '/dev_forms/admin/tmp/');

alter table games add play_game_column varchar(255) not null default '_etn_phone';
alter table games_unpublished add play_game_column varchar(255) not null default '_etn_phone';

