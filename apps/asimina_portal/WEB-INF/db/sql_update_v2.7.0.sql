-- START 22-03-2021 --
drop TABLE `cached_pages_indexation`;
CREATE TABLE `cached_pages_indexation` (
  `cached_page_id` int(11) NOT NULL,
  `menu_id` int(11) NOT NULL,
  `page_type` enum('offer','product','general'),
  `is_active` tinyint(1) not null default 1,
  `algolia_id` varchar(25) default null,
  `algolia_index` varchar(255) default null,
  `applicable_algolia_index` varchar(255),
  `algolia_json` varchar(2000),
  PRIMARY KEY (`cached_page_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

drop TABLE `del_indexation`;
CREATE TABLE `del_indexation` (
  `cached_page_id` int(11) NOT NULL,
  `menu_id` int(11) NOT NULL,
  `algolia_id` varchar(25) default null,
  `algolia_index` varchar(255) default null,
  PRIMARY KEY (`cached_page_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- END 22-03-2021 --

-- START 22-03-2021 --
alter table sites add datalayer_moringa_perimeter varchar(75) default null;

-- END 22-03-2021 --