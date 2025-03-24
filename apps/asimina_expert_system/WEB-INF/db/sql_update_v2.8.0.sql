-- START 04-05-2021 --

CREATE TABLE `es_queries` (
  `id` int(10) NOT NULL,
  `name` varchar(25) DEFAULT NULL,
  `query_type_id` int(11) DEFAULT NULL,
  `pagination_col` varchar(255) DEFAULT NULL,
  `ignore_selectable_col` varchar(255) DEFAULT NULL,
  `query` text DEFAULT NULL,
  `distinct_keys_query` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `es_queries` VALUES (3, 'products', 1, 'product_id', 'spec_attribs', 'select l.langue_id, l.langue_code, pvd.action_button_desktop, pvd.action_button_desktop_url, pvd.action_button_mobile, pvd.action_button_mobile_url, c.name as catalog_name, p.product_type, p.payment_online, p.payment_cash_on_delivery, p.sort_variant, case coalesce(p.sort_variant,\'\')  when \'cu\' then \'Custom\' when \'pa\' then \'Price asc\' when \'pd\' then \'Price desc\' when \'cdd\' then \'Created date desc\' when \'cda\' then \'Created date asc\' else coalesce(p.sort_variant,\'\') end sort_variant_label, p.allow_ratings, p.allow_comments, p.allow_complaints, p.allow_questions, p.is_new, p.show_basket, p.show_quickbuy, p.order_seq product_order_seq, p.brand_name, p.product_uuid as product_id, p.lang_1_name as product_lang_1_name, p.lang_2_name as product_lang_2_name, p.lang_3_name as product_lang_3_name, p.lang_4_name as product_lang_4_name, p.lang_5_name as product_lang_5_name, pv.id as variant_id, pv.price variant_price, pv.sku variant_sku, pv.stock variant_stock, pv.is_active variant_is_active, pv.is_default variant_is_default, pv.is_show_price variant_is_show_price, pv.sticker variant_sticker , pvd.name as variant_name, pd.summary, pd.main_features, pvr.sort_order variant_res_sort_order, pvr.id as variant_res_id, pvr.type as variant_res_type, pvr.path as variant_res_path, pvr.label as variant_res_label, peb.id as essentials_id, peb.block_text essentials_block_text, peb.file_name essentials_file_name, peb.image_label as essentials_image_label, peb.order_seq essentials_order_seq, pvref.cat_attrib_id, cav.attribute_value, ca.name as attribute_name, cav.small_text attribute_small_text, pt.tag_id, tg.label tag_label, ptabs.name as tab_name, ptabs.id as tab_id, ptabs.content as tab_content, ptabs.order_seq as tab_order_seq, st.display_name_1 sticker_label_lang_1, st.display_name_2 sticker_label_lang_2, st.display_name_3 sticker_label_lang_3, st.display_name_4 sticker_label_lang_4, st.display_name_5 sticker_label_lang_5, pi.id as product_img_id, pi.image_file_name product_img_file_name, pi.image_label product_image_label, pi.sort_order product_img_sort_order, (select concat(\'[\',group_concat(concat(\'{\"name\":\"\',replace(specca.name,\'\"\',\'\"\'),\'\",\"value\":\"\',replace(pav.attribute_value,\'\"\',\'\"\'),\'\"}\')),\']\') from ##CATALOG_DB##.product_attribute_values pav inner join ##CATALOG_DB##.catalog_attributes specca on specca.cat_attrib_id = pav.cat_attrib_id where coalesce(pav.attribute_value,\'\') <> \'\' and pav.product_id = p.id group by p.id) spec_attribs from ##CATALOG_DB##.language l inner join ##CATALOG_DB##.products p inner join ##CATALOG_DB##.catalogs c on c.site_id = ##site_id## and c.id = p.catalog_id left outer join ##CATALOG_DB##.product_variants pv on pv.product_id = p.id left outer join ##CATALOG_DB##.product_descriptions pd on pd.product_id = p.id and l.langue_id = pd.langue_id left outer join ##CATALOG_DB##.product_variant_details pvd on pv.id = pvd.product_variant_id and pvd.langue_id = l.langue_id left outer join ##CATALOG_DB##.product_variant_resources pvr on pvr.product_variant_id = pv.id and pvr.langue_id = l.langue_id left outer join ##CATALOG_DB##.product_essential_blocks peb on peb.product_id = p.id and peb.langue_id = l.langue_id left outer join ##CATALOG_DB##.product_variant_ref pvref on pvref.product_variant_id = pv.id left outer join ##CATALOG_DB##.catalog_attribute_values cav on cav.id = pvref.catalog_attribute_value_id left outer join ##CATALOG_DB##.catalog_attributes ca on ca.cat_attrib_id = pvref.cat_attrib_id left outer join ##CATALOG_DB##.product_tags pt on pt.product_id = p.id left outer join ##CATALOG_DB##.tags tg on tg.id = pt.tag_id left outer join ##CATALOG_DB##.product_tabs ptabs on ptabs.product_id = p.id and ptabs.langue_id = l.langue_id left outer join ##CATALOG_DB##.stickers st on c.site_id = st.site_id and st.sname = pv.sticker left outer join ##CATALOG_DB##.product_images pi on pi.product_id = p.id and pi.langue_id = l.langue_id where p.id = ##product_id##', 'select p.id from ##CATALOG_DB##.catalogs c, ##CATALOG_DB##.products p where p.catalog_id = c.id and c.site_id = ##site_id##');
INSERT INTO `es_queries` VALUES (5, 'blocs', 5, 'bloc_id', NULL, 'select b.uuid bloc_id, b.name bloc_name, b.refresh_interval bloc_refresh_interval, b.start_date bloc_start_date, b.end_date bloc_end_date, b.visible_to bloc_visible_to, b.margin_top bloc_margin_top, b.margin_bottom bloc_margin_bottom, b.description bloc_description, b.template_data bloc_template_data, b.rss_feed_ids bloc_rss_feed_ids, b.rss_feed_sort as bloc_rss_feed_sort, bt.id as template_id, bt.name template_name, bt.custom_id template_custom_id, bt.type template_type, bt.description template_description, bt.template_code template_code, bt.css_code template_css_code, bt.js_code template_js_code, bts1.id level_1_section_id, bts1.name level_1_section_name, bts1.custom_id level_1_section_custom_id, bts1.sort_order level_1_section_sort_order, bts1.nb_items level_1_section_nb_items, bts2.id level_2_section_id, bts2.name level_2_section_name, bts2.custom_id level_2_section_custom_id, bts2.sort_order level_2_section_sort_order, bts2.nb_items level_2_section_nb_items, bts3.id level_3_section_id, bts3.name level_3_section_name, bts3.custom_id level_3_section_custom_id, bts3.sort_order level_3_section_sort_order, bts3.nb_items level_3_section_nb_items, sf1.id level_1_field_id, sf1.name level_1_field_name, sf1.custom_id level_1_field_custom_id,  sf1.sort_order level_1_field_sort_order, sf1.nb_items level_1_field_nb_items, sf1.type level_1_field_type, sf1.value level_1_field_value, sf1.default_value level_1_field_default_value, sf1.is_required level_1_field_is_required, sf1.placeholder level_1_field_placeholder, sf2.id level_2_field_id, sf2.name level_2_field_name, sf2.custom_id level_2_field_custom_id,  sf2.sort_order level_2_field_sort_order, sf2.nb_items level_2_field_nb_items, sf2.type level_2_field_type, sf2.value level_2_field_value, sf2.default_value level_2_field_default_value, sf2.is_required level_2_field_is_required, sf2.placeholder level_2_field_placeholder, sf3.id level_3_field_id, sf3.name level_3_field_name, sf3.custom_id level_3_field_custom_id,  sf3.sort_order level_3_field_sort_order, sf3.nb_items level_3_field_nb_items, sf3.type level_3_field_type, sf3.value level_3_field_value, sf3.default_value level_3_field_default_value, sf3.is_required level_3_field_is_required, sf3.placeholder level_3_field_placeholder, lb.id as library_id, lb.name as library_name, fl.id as file_id, fl.file_name file_name, fl.label file_label, fl.type file_type, btags.tag_id as tag_id from ##PAGES_DB##.blocs b left outer join ##PAGES_DB##.bloc_templates bt on b.template_id = bt.id left outer join ##PAGES_DB##.bloc_templates_sections bts1 on bts1.bloc_template_id = bt.id and coalesce(bts1.parent_section_id,\'\') = 0 left outer join ##PAGES_DB##.bloc_templates_sections bts2 on bts2.parent_section_id = bts1.id  left outer join ##PAGES_DB##.bloc_templates_sections bts3 on bts3.parent_section_id = bts2.id left outer join ##PAGES_DB##.sections_fields sf1 on sf1.section_id = bts1.id left outer join ##PAGES_DB##.sections_fields sf2 on sf2.section_id = bts2.id left outer join ##PAGES_DB##.sections_fields sf3 on sf3.section_id = bts3.id left outer join ##PAGES_DB##.bloc_templates_libraries btl on btl.bloc_template_id = bt.id left outer join ##PAGES_DB##.libraries lb on lb.id = btl.library_id left outer join ##PAGES_DB##.libraries_files lf on lf.library_id = lb.id left outer join ##PAGES_DB##.files fl on fl.id = lf.file_id left outer join ##PAGES_DB##.blocs_tags btags on btags.bloc_id = b.id where b.site_id = ##site_id## and b.id = ##bloc_id##', 'select id from ##PAGES_DB##.blocs where site_id = ##site_id##');
INSERT INTO `es_queries` VALUES (6, 'pages', 4, 'page_id', NULL, 'select l.langue_id, p.uuid as page_id, p.name, p.type, p.path, p.langue_code, p.variant, p.html_file_path, p.published_html_file_path, p.canonical_url, p.title, p.meta_keywords, p.meta_description, p.dl_page_type, p.dl_sub_level_1, p.dl_sub_level_2, p.package_name, p.class_name, p.layout, p.social_title, p.social_type, p.social_description, p.social_image, p.social_twitter_message, p.social_twitter_hashtags, p.social_email_subject, p.social_email_popin_title, p.social_email_message, p.social_sms_text, p.publish_status, p.row_height, p.item_margin_x, p.item_margin_y, p.container_padding_x, p.container_padding_y, p.dynamic_html, p.layout_data, p.get_html_status, ptags.tag_id tag_id, pmt.meta_name, pmt.meta_content, pb.sort_order bloc_sort_order, b.name bloc_name, b.uuid bloc_id, ptm.uuid as template_id, ptm.name as template_name, ptm.custom_id as template_custom_id, ptm.description as template_description, ptm.template_code as template_code, ptm.is_system as template_is_system, pti.id as item_id, pti.name as item_name, pti.custom_id as item_custom_id, pti.sort_order as item_sort_order, ptib.sort_order as item_bloc_sort_order, ib.uuid as item_bloc_id, ib.name as item_bloc_name, ptid.css_classes as item_detail_css_classes, ptid.css_style item_detail_css_style, pf.form_id as page_form_id, pf.sort_order page_form_sort_order from ##PAGES_DB##.pages p left outer join ##PAGES_DB##.language l on l.langue_code = p.langue_code left outer join ##PAGES_DB##.pages_tags ptags on ptags.page_id = p.id left outer join ##PAGES_DB##.pages_meta_tags pmt on pmt.page_id = p.id left outer join ##PAGES_DB##.pages_blocs pb on pb.page_id = p.id left outer join ##PAGES_DB##.blocs b on b.id = pb.bloc_id left outer join ##PAGES_DB##.page_templates ptm on ptm.id = p.template_id left outer join ##PAGES_DB##.page_templates_items pti on pti.page_template_id = ptm.id left outer join ##PAGES_DB##.page_templates_items_blocs ptib on ptib.item_id = pti.id and ptib.langue_id = l.langue_id left outer join ##PAGES_DB##.blocs ib on ib.id = ptib.bloc_id left outer join ##PAGES_DB##.page_templates_items_details ptid on ptid.item_id = pti.id and ptid.langue_id = l.langue_id left outer join ##PAGES_DB##.pages_forms pf on pf.page_id = p.id where p.type = \'freemarker\' and p.site_id = ##site_id## and p.id = ##page_id##', 'select id from ##PAGES_DB##.pages where site_id = ##site_id##');
INSERT INTO `es_queries` VALUES (7, 'structured_content', 3, 'catalog_id', 'catalog_id', 'select sc.uuid as catalog_id, sc.name as catalog_name, sc.publish_status catalog_publish_status, bt.id as bloc_template_id, bt.name as bloc_template_name, bt.custom_id as bloc_template_custom_id, bt.type as bloc_template_type, l.langue_code, l.langue_id, scd.path_prefix catalog_detail_path_prefix, scp.id content_id, scp.name content_name, scp.publish_status content_publish_status, scdp.fd_content_data_2 content_detail_content_data from ##PAGES_DB##.language l inner join ##PAGES_DB##.structured_catalogs_published sc left outer join ##PAGES_DB##.bloc_templates bt on bt.id = sc.template_id left outer join ##PAGES_DB##.structured_catalogs_details scd on scd.catalog_id = sc.id and l.langue_id = scd.langue_id left outer join ##PAGES_DB##.structured_contents_published scp on scp.catalog_id = sc.id left outer join ##PAGES_DB##.structured_contents_details_published scdp on scdp.content_id = scp.id and scdp.langue_id = l.langue_id where sc.type = \'content\' and sc.uuid = ##sc_uuid##', NULL);
INSERT INTO `es_queries` VALUES (8, 'structured_page', 2, 'catalog_id', 'catalog_id', 'select sc.uuid as catalog_id, sc.name as catalog_name, sc.publish_status catalog_publish_status, bt.id as bloc_template_id, bt.name as bloc_template_name, bt.custom_id as bloc_template_custom_id, bt.type as bloc_template_type, l.langue_code, l.langue_id, scd.path_prefix catalog_detail_path_prefix, scp.id content_id, scp.name content_name, scp.publish_status content_publish_status, scdp.fd_content_data_2 content_detail_content_data, pg.canonical_url page_canonical_url, pg.uuid as page_id, pg.name as page_name, pg.type as page_type, pg.path as page_path, pg.publish_status as page_publish_status, bc.uuid as page_bloc_id, bc.name as page_bloc_name, bc.template_id as page_bloc_template_id, bc.description page_bloc_description from ##PAGES_DB##.language l inner join ##PAGES_DB##.structured_catalogs sc left outer join ##PAGES_DB##.bloc_templates bt on bt.id = sc.template_id left outer join ##PAGES_DB##.structured_catalogs_details scd on scd.catalog_id = sc.id and l.langue_id = scd.langue_id left outer join ##PAGES_DB##.structured_contents scp on scp.catalog_id = sc.id left outer join ##PAGES_DB##.structured_contents_details scdp on scdp.content_id = scp.id and scdp.langue_id = l.langue_id left outer join ##PAGES_DB##.pages pg on pg.id = scdp.page_id and pg.langue_code = l.langue_code left outer join ##PAGES_DB##.pages_blocs pb on pb.page_id = pg.id left outer join ##PAGES_DB##.blocs bc on bc.id = pb.bloc_id where sc.type = \'page\' and sc.uuid = ##sc_uuid##', NULL);
INSERT INTO `es_queries` VALUES (9, 'forms', 7, 'form_id', NULL, 'select ##SELECTED_COLUMN## from ##FORM_DB##.##FORM_CUSTOM_TABLE##', NULL);


CREATE TABLE `es_query_col_mapping` (
  `query_name` varchar(50)  NOT NULL,
  `col` varchar(25)  NOT NULL,
  `mapped_cols` varchar(500)  NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `es_query_col_mapping` VALUES ('products', 'product_name', 'product_lang_1_name,product_lang_2_name,product_lang_3_name,product_lang_4_name,product_lang_5_name');
INSERT INTO `es_query_col_mapping` VALUES ('blocs', 'section_name', 'level_1_section_name,level_2_section_name,level_3_section_name');
INSERT INTO `es_query_col_mapping` VALUES ('products', 'sticker_label', 'sticker_label_lang_1,sticker_label_lang_2,sticker_label_lang_3,sticker_label_lang_4,sticker_label_lang_5');
INSERT INTO `es_query_col_mapping` VALUES ('blocs', 'section_custom_id', 'level_1_section_custom_id,level_2_section_custom_id,level_3_section_custom_id');
INSERT INTO `es_query_col_mapping` VALUES ('blocs', 'section_sort_order', 'level_1_section_sort_order,level_2_section_sort_order,level_3_section_sort_order');
INSERT INTO `es_query_col_mapping` VALUES ('blocs', 'section_nb_items', 'level_1_section_nb_items,level_2_section_nb_items,level_3_section_nb_items');
INSERT INTO `es_query_col_mapping` VALUES ('blocs', 'field_name', 'level_1_field_name,level_2_field_name,level_3_field_name');
INSERT INTO `es_query_col_mapping` VALUES ('blocs', 'field_custom_id', 'level_1_field_custom_id,level_2_field_custom_id,level_3_field_custom_id');
INSERT INTO `es_query_col_mapping` VALUES ('blocs', 'field_sort_order', 'level_1_field_sort_order,level_2_field_sort_order,level_3_field_sort_order');
INSERT INTO `es_query_col_mapping` VALUES ('blocs', 'field_nb_items', 'level_1_field_nb_items,level_2_field_nb_items,level_3_field_nb_items');
INSERT INTO `es_query_col_mapping` VALUES ('blocs', 'field_type', 'level_1_field_type,level_2_field_type,level_3_field_type');
INSERT INTO `es_query_col_mapping` VALUES ('blocs', 'field_value', 'level_1_field_value,level_2_field_value,level_3_field_value');
INSERT INTO `es_query_col_mapping` VALUES ('blocs', 'field_default_value', 'level_1_field_default_value,level_2_field_default_value,level_3_field_default_value');
INSERT INTO `es_query_col_mapping` VALUES ('blocs', 'field_is_required', 'level_1_field_is_required,level_2_field_is_required,level_3_field_is_required');
INSERT INTO `es_query_col_mapping` VALUES ('blocs', 'field_placeholder', 'level_1_field_placeholder,level_2_field_placeholder,level_3_field_placeholder');
INSERT INTO `es_query_col_mapping` VALUES ('blocs', 'library_file_name', 'file_name');
INSERT INTO `es_query_col_mapping` VALUES ('blocs', 'library_file_label', 'file_label');
INSERT INTO `es_query_col_mapping` VALUES ('blocs', 'library_file_type', 'file_type');
INSERT INTO `es_query_col_mapping` VALUES ('structured_content', 'path_prefix', 'catalog_detail_path_prefix');
INSERT INTO `es_query_col_mapping` VALUES ('structured_content', 'content_data', 'content_detail_content_data');
INSERT INTO `es_query_col_mapping` VALUES ('structured_page', 'content_data', 'content_detail_content_data');
INSERT INTO `es_query_col_mapping` VALUES ('structured_page', 'path_prefix', 'catalog_detail_path_prefix');


CREATE TABLE `es_query_levels` (
  `id` int(11) NOT NULL DEFAULT 0,
  `query_name` varchar(25)  DEFAULT NULL,
  `parent_level_id` int(11) DEFAULT NULL,
  `j_object` varchar(25)  DEFAULT NULL,
  `j_object_key` varchar(25)  DEFAULT NULL,
  `j_object_columns` varchar(500)  DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `es_query_levels` VALUES (16, 'products', 6, 'specs', 'spec_attribs', 'spec_attribs');
INSERT INTO `es_query_levels` VALUES (6, 'products', NULL, 'products', 'product_id', 'product_id,catalog_name,product_type,payment_online,payment_cash_on_delivery,sort_variant,allow_ratings,allow_comments,allow_complaints,allow_questions,is_new,show_basket,show_quickbuy,product_order_seq,brand_name,sort_variant_label');
INSERT INTO `es_query_levels` VALUES (7, 'products', 6, 'variants', 'variant_id', 'price:variant_price,sku:variant_sku,stock:variant_stock,is_active:variant_is_active,is_default:variant_is_default,is_show_price:variant_is_show_price,sticker:variant_sticker');
INSERT INTO `es_query_levels` VALUES (8, 'products', 6, 'language', 'langue_id', 'langue_code,product_name:product_lang_<key>_name,main_features,summary');
INSERT INTO `es_query_levels` VALUES (9, 'products', 7, 'language', 'langue_id', 'langue_code,variant_name,action_button_desktop,action_button_desktop_url,action_button_mobile,action_button_mobile_url,sticker_label:sticker_label_lang_<key>');
INSERT INTO `es_query_levels` VALUES (12, 'products', 9, 'resources', 'variant_res_id', 'type:variant_res_type,path:variant_res_path,sort_order:variant_res_sort_order');
INSERT INTO `es_query_levels` VALUES (11, 'products', 8, 'essentials', 'essentials_id', 'block_text:essentials_block_text,file_name:essentials_file_name,image_label:essentials_image_label,order_seq:essentials_order_seq');
INSERT INTO `es_query_levels` VALUES (17, 'products', 7, 'images', 'product_img_id', 'label:product_image_label,file_name:product_img_file_name,sort_order:product_img_sort_order');
INSERT INTO `es_query_levels` VALUES (13, 'products', 7, 'attributes', 'cat_attrib_id', 'name:attribute_name,value:attribute_value,small_text:attribute_small_text');
INSERT INTO `es_query_levels` VALUES (14, 'products', 6, 'tags', 'tag_id', 'id:tag_id,label:tag_label');
INSERT INTO `es_query_levels` VALUES (15, 'products', 8, 'tabs', 'tab_id', 'name:tab_name,content:tab_content,order_seq:tab_order_seq');
INSERT INTO `es_query_levels` VALUES (18, 'blocs', NULL, 'blocs', 'bloc_id', 'id:bloc_id,name:bloc_name,refresh_interval:bloc_refresh_interval,start_date:bloc_start_date,end_date:bloc_end_date,visible_to:bloc_visible_to,margin_top:bloc_margin_top,margin_bottom:bloc_margin_bottom,description:bloc_description,template_data:bloc_template_data,rss_feed_ids:bloc_rss_feed_ids,rss_feed_sort:bloc_rss_feed_sort');
INSERT INTO `es_query_levels` VALUES (19, 'blocs', 18, 'template', 'template_id', 'name:template_name,custom_id:template_custom_id,type:template_type,description:template_description,template_code,css_code:template_css_code,js_code:template_js_code');
INSERT INTO `es_query_levels` VALUES (20, 'blocs', 18, 'sections', 'level_1_section_id', 'name:level_1_section_name,custom_id:level_1_section_custom_id,sort_order:level_1_section_sort_order,nb_items:level_1_section_nb_items');
INSERT INTO `es_query_levels` VALUES (21, 'blocs', 20, 'sections', 'level_2_section_id', 'name:level_2_section_name,custom_id:level_2_section_custom_id,sort_order:level_2_section_sort_order,nb_items:level_2_section_nb_items');
INSERT INTO `es_query_levels` VALUES (22, 'blocs', 21, 'sections', 'level_3_section_id', 'name:level_3_section_name,custom_id:level_3_section_custom_id,sort_order:level_3_section_sort_order,nb_items:level_3_section_nb_items');
INSERT INTO `es_query_levels` VALUES (23, 'blocs', 20, 'fields', 'level_1_field_id', 'name:level_1_field_name,custom_id:level_1_field_custom_id,sort_order:level_1_field_sort_order,nb_items:level_1_field_nb_items,type:level_1_field_type,value:level_1_field_value,default_value:level_1_field_default_value,is_required:level_1_field_is_required,placeholder:level_1_field_placeholder');
INSERT INTO `es_query_levels` VALUES (24, 'blocs', 21, 'fields', 'level_2_field_id', 'name:level_2_field_name,custom_id:level_2_field_custom_id,sort_order:level_2_field_sort_order,nb_items:level_2_field_nb_items,type:level_2_field_type,value:level_2_field_value,default_value:level_2_field_default_value,is_required:level_2_field_is_required,placeholder:level_2_field_placeholder');
INSERT INTO `es_query_levels` VALUES (25, 'blocs', 22, 'fields', 'level_3_field_id', 'name:level_3_field_name,custom_id:level_3_field_custom_id,sort_order:level_3_field_sort_order,nb_items:level_3_field_nb_items,type:level_3_field_type,value:level_3_field_value,default_value:level_3_field_default_value,is_required:level_3_field_is_required,placeholder:level_3_field_placeholder');
INSERT INTO `es_query_levels` VALUES (26, 'blocs', 18, 'libraries', 'library_id', 'name:library_name');
INSERT INTO `es_query_levels` VALUES (27, 'blocs', 26, 'files', 'file_id', 'name:file_name,type:file_type');
INSERT INTO `es_query_levels` VALUES (28, 'blocs', 18, 'tags', 'tag_id', 'tag_id');
INSERT INTO `es_query_levels` VALUES (29, 'pages', NULL, 'pages', 'page_id', 'id:page_id,name,type,path,langue_code,variant,html_file_path,published_html_file_path,canonical_url,title,meta_keywords,meta_description,dl_page_type,dl_sub_level_1,dl_sub_level_2,package_name,class_name,layout,social_title,social_type,social_description,social_image,social_twitter_message,social_twitter_hashtags,social_email_subject,social_email_popin_title,social_email_message,social_sms_text,publish_status,row_height,item_margin_x,item_margin_y,container_padding_x,container_padding_y,dynamic_');
INSERT INTO `es_query_levels` VALUES (30, 'pages', 29, 'tags', 'tag_id', 'tag_id');
INSERT INTO `es_query_levels` VALUES (31, 'pages', 29, 'meta', 'meta_name', 'meta_name,meta_content');
INSERT INTO `es_query_levels` VALUES (32, 'pages', 29, 'blocs', 'bloc_id', 'id:bloc_id,name:bloc_name');
INSERT INTO `es_query_levels` VALUES (33, 'pages', 29, 'template', 'template_id', 'id:template_id,name:template_name,custom_id:template_custom_id,description:template_description,template_code,is_system:template_is_system');
INSERT INTO `es_query_levels` VALUES (34, 'pages', 33, 'items', 'item_id', 'name:item_name,custom_id:item_custom_id,sort_order:item_sort_order,css_classes:item_detail_css_classes,css_style:item_detail_css_style');
INSERT INTO `es_query_levels` VALUES (35, 'pages', 34, 'blocs', 'item_bloc_id', 'id:item_bloc_id,name:item_bloc_name,sort_order:item_bloc_sort_order');
INSERT INTO `es_query_levels` VALUES (36, 'pages', 29, 'forms', 'form_id', 'id:form_id,sort_order:page_form_sort_order');
INSERT INTO `es_query_levels` VALUES (37, 'structured_content', NULL, 'catalog', 'catalog_id', 'id:catalog_id,name:catalog_name,publish_status:catalog_publish_status');
INSERT INTO `es_query_levels` VALUES (38, 'structured_content', 37, 'bloc_template', 'bloc_template_id', 'name:bloc_template_name,custom_id:bloc_template_custom_id,type:bloc_template_type');
INSERT INTO `es_query_levels` VALUES (39, 'structured_content', 37, 'language', 'langue_id', 'langue_code,path_prefix:catalog_detail_path_prefix');
INSERT INTO `es_query_levels` VALUES (40, 'structured_content', 37, 'contents', 'content_id', 'name:content_name,publish_status:content_publish_status');
INSERT INTO `es_query_levels` VALUES (41, 'structured_content', 40, 'language', 'langue_id', 'langue_code,content_data:content_detail_content_data');
INSERT INTO `es_query_levels` VALUES (42, 'structured_page', NULL, 'catalog', 'catalog_id', 'id:catalog_id,name:catalog_name,publish_status:catalog_publish_status');
INSERT INTO `es_query_levels` VALUES (43, 'structured_page', 42, 'bloc_template', 'bloc_template_id', 'name:bloc_template_name,custom_id:bloc_template_custom_id,type:bloc_template_type');
INSERT INTO `es_query_levels` VALUES (44, 'structured_page', 42, 'language', 'langue_id', 'langue_code,path_prefix:catalog_detail_path_prefix');
INSERT INTO `es_query_levels` VALUES (45, 'structured_page', 42, 'contents', 'content_id', 'name:content_name,publish_status:content_publish_status');
INSERT INTO `es_query_levels` VALUES (46, 'structured_page', 45, 'language', 'langue_id', 'langue_code,content_data:content_detail_content_data');
INSERT INTO `es_query_levels` VALUES (47, 'structured_page', 46, 'page', 'page_id', 'id:page_id,name:page_name,type:page_type,path:page_path,publish_status:page_publish_status,canonical_url:page_canonical_url');
INSERT INTO `es_query_levels` VALUES (48, 'structured_page', 47, 'bloc', 'bloc_id', 'id:page_bloc_id,name:page_bloc_name,description:page_bloc_description');

CREATE TABLE `query_formats` (
  `id` int(11) NOT NULL,
  `type` varchar(32) DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `query_formats` VALUES (1, 'JSON structure');
INSERT INTO `query_formats` VALUES (2, 'JSON array');
INSERT INTO `query_formats` VALUES (3, 'JSON array with labels');
INSERT INTO `query_formats` VALUES (4, 'C3');
INSERT INTO `query_formats` VALUES (5, 'D3');
INSERT INTO `query_formats` VALUES (6, 'D3Map');
INSERT INTO `query_formats` VALUES (7, 'D3MapChl');

CREATE TABLE `query_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `query_name` varchar(50) DEFAULT NULL,
  `query_type` varchar(32) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `query_types` VALUES (1, 'products', 'Commercial catalog');
INSERT INTO `query_types` VALUES (2, 'structured_page', 'Structured catalog');
INSERT INTO `query_types` VALUES (3, 'structured_content', 'Structured Content');
INSERT INTO `query_types` VALUES (4, 'pages', 'Pages');
INSERT INTO `query_types` VALUES (5, 'blocs', 'Blocks');
INSERT INTO `query_types` VALUES (6, 'tags', 'Tags');
INSERT INTO `query_types` VALUES (7, 'forms', 'Forms');

CREATE TABLE `query_settings` (
  `qs_uuid` varchar(100) NOT NULL,
  `name` varchar(32) DEFAULT '',
  `query_id` varchar(32) DEFAULT '',
  `site_id` int(11) NOT NULL,
  `access` enum('private','public') not null DEFAULT 'public',
  `query_key` varchar(32) DEFAULT NULL,
  `query_format` int(11) DEFAULT NULL,
  `paginate` tinyint(4) DEFAULT NULL,
  `items_per_page` int(11) DEFAULT NULL,
  `query_type_id` int(11) DEFAULT NULL,
  `query_sub_type_id` varchar(50) DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `selected_columns` text DEFAULT NULL,
  `filter_settings` text DEFAULT NULL,
  `sorting_settings` text DEFAULT NULL,
  `column_settings` text DEFAULT NULL,
  `publish_ts` datetime DEFAULT NULL,
  `publish_status` enum('unpublished','published') NOT NULL DEFAULT 'unpublished',
  `published_by` int(11) DEFAULT NULL,
  `version` int(10) DEFAULT 1,
  PRIMARY KEY (`qs_uuid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `query_settings_published` (
  `qs_uuid` varchar(100)  NOT NULL,
  `name` varchar(32)  DEFAULT '',
  `query_id` varchar(32)  DEFAULT '',
  `site_id` int(11) NOT NULL,
  `path` varchar(32)  DEFAULT '',
  `access` enum('private','public') not null DEFAULT 'public',
  `query_key` varchar(32)  DEFAULT NULL,
  `query_format` int(11) DEFAULT NULL,
  `paginate` tinyint(4) DEFAULT NULL,
  `items_per_page` int(11) DEFAULT NULL,
  `query_type_id` int(11) DEFAULT NULL,
  `query_sub_type_id` varchar(50)  DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  `selected_columns` text  DEFAULT NULL,
  `filter_settings` text  DEFAULT NULL,
  `sorting_settings` text  DEFAULT NULL,
  `column_settings` text  DEFAULT NULL,
  `publish_ts` datetime DEFAULT NULL,
  `publish_status` enum('unpublished','published')  NOT NULL DEFAULT 'unpublished',
  `published_by` int(11) DEFAULT NULL,
  `version` int(10) DEFAULT 1
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `page` (`name`, url, parent, rang, new_tab, icon, parent_icon, requires_ecommerce) VALUES ("Expert System V2", "/dev_expert_system/pages/v2/queries.jsp", "Tools", 707, 0, "chevron-right", "grid", 0);

INSERT INTO dev_commons.config (code, val, comments) VALUES ("ES_API_V2_URL", "/dev_expert_system/", "");

-- END 04-05-2021 --

-- START 19-05-2021 --

update es_queries set ignore_selectable_col = "" where name = "products";

-- END 19-05-2021 --
