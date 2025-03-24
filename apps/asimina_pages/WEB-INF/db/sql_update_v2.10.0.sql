-- START 02-08-2021 --
alter table sections_fields add is_indexed tinyint(1) NOT NULL DEFAULT 0;
-- END 02-08-2021 --
-- START 10-08-2021--
ALTER TABLE bloc_templates ADD jsonld_code MEDIUMTEXT NOT NULL AFTER js_code ;
-- END 10-08-2021--

-- START 7-09-2021--

DROP TABLE IF EXISTS ignore_xss_fields;
CREATE TABLE ignore_xss_fields (
  url varchar(200) NOT NULL,
  field varchar(100) NOT NULL,
  PRIMARY KEY (url,field)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


insert into ignore_xss_fields VALUES("blocTemplatesAjax.jsp","js_code");
insert into ignore_xss_fields VALUES("blocTemplatesAjax.jsp","jsonld_code");
insert into ignore_xss_fields VALUES("blocTemplatesAjax.jsp","template_code");
insert into ignore_xss_fields VALUES("blocTemplatesAjax.jsp","css_code");
insert into ignore_xss_fields VALUES("blocTemplatesAjax.jsp","data");

insert into ignore_xss_fields VALUES("pageTemplatesAjax.jsp","data");

insert into ignore_xss_fields VALUES("pagesAjax.jsp","layoutData");

insert into ignore_xss_fields VALUES("blocsAjax.jsp","template_data");

insert into ignore_xss_fields VALUES("structuredContentsAjax.jsp","contentDetailData_1");
insert into ignore_xss_fields VALUES("structuredContentsAjax.jsp","contentDetailData_2");
insert into ignore_xss_fields VALUES("structuredContentsAjax.jsp","contentDetailData_3");
insert into ignore_xss_fields VALUES("structuredContentsAjax.jsp","contentDetailData_4");
insert into ignore_xss_fields VALUES("structuredContentsAjax.jsp","contentDetailData_5");

-- END 7-09-2021--
