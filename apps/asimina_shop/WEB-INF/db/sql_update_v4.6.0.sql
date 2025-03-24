CREATE TABLE `profil_banned_phases` (
  `profil_id` int(10) unsigned NOT NULL,
  `site_id` int(11) unsigned not null,
  `phases` text,
  PRIMARY KEY (`profil_id`,`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

alter table profil drop bannedPhases;

insert into page (name, url, parent, rang, icon, parent_icon, menu_badge) value ('Ban rules','/dev_shop/admin/bannedRules.jsp','Admin','10','cui-wrench','cui-settings','NEW');


