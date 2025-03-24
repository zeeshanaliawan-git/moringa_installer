create view cached_content_view as select c.*, p.menu_id, m.site_id, m.lang from cached_content c, cached_pages p, site_menus m where c.cached_page_id = p.id and p.menu_id = m.id;

drop table cached_pages_indexation;
drop table algolia_indexation;
CREATE TABLE `algolia_indexation` (
	id int(11) not null auto_increment,
	menu_id int(11) NOT NULL,
	ctype enum('page','structuredpage','structuredcontent','offer','product','store') not null,
	cid varchar(50) not null comment 'for page, product and offer this will contain the cached_page_id, for rest this column contains the content id',
  `algolia_index` varchar(255) DEFAULT NULL,
  `algolia_json` text DEFAULT NULL,
  `is_active` tinyint(1) not null default 1,
  PRIMARY KEY (`id`),  
  unique key (`menu_id`,`ctype`,`cid`,`algolia_index`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

drop table crawler_indexation;
CREATE TABLE `crawler_indexation` (
	id int(11) not null auto_increment,
	menu_id int(11) NOT NULL,
	ctype enum('page','structuredpage','structuredcontent','offer','product','store') not null,
	cid varchar(50) not null comment 'for page, product and offer this will contain the cached_page_id, for rest this column contains the content id',
  `applicable_algolia_index` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

drop table del_indexation;

alter table site_menus add cart_footer_html text;

update site_menus set cart_footer_html = '<section class="row col-12 mt-5"><h3 class="h1">Pourquoi acheter en ligne ?</h3><ul class="col-12 font-weight-bold row"><li class="d-flex align-items-center col-lg-4 mb-3 pl-0"><span class="d-inline-block mr-2" data-svg="/src/assets/icons/icon-fast-delivery-2.svg"></span>Livraison à domicile et <br class="d-none d-lg-block">gratuite sur la boutique</li><li class="d-flex align-items-center col-lg-4 mb-3 pl-0"><span class="d-inline-block mr-2" data-svg="/src/assets/icons/icon-lock.svg"></span>Paiement 100% <br class="d-none d-lg-block">sécurisé</li><li class="d-flex align-items-center col-lg-4 mb-3 pl-0"><span class="d-inline-block mr-2" data-svg="/src/assets/icons/icon-customer-service-2.svg"></span>Service client <br class="d-none d-lg-block">à vos côtés</li></ul></section>';