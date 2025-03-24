-- START 12-11-2020 --
alter table login add puid varchar(36) not null;
update login set puid = uuid();
alter table login add unique key (puid);
-- END 12-11-2020 --

-- START 02-12-2020 -- 
UPDATE `page` SET `url`='/dev_shop/dashboard.jsp' WHERE (`name`='Dashboard');
-- END 02-12-2020 -- 