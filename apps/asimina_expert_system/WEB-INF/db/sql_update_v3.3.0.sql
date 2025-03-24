drop view page;
create view page as select * from dev_catalog.page;

ALTER TABLE dev_expert_system.query_settings RENAME TO dev_expert_system.query_settings_tbl;
ALTER TABLE dev_expert_system.query_settings_tbl ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;
CREATE VIEW dev_expert_system.query_settings AS SELECT * FROM dev_expert_system.query_settings_tbl WHERE is_deleted =0;

ALTER TABLE dev_expert_system.query_settings_published ADD is_deleted TinyInt(1) NOT NULL DEFAULT 0;


create table es_queries_v3_3 select * from es_queries;
create table es_query_col_mapping_v3_3 select * from es_query_col_mapping;
create table es_query_levels_v3_3 select * from es_query_levels;

drop table es_queries_v3_2;
drop table es_query_col_mapping_v3_2;
drop table es_query_levels_v3_2;

update es_queries set query = 'select date_format(fp.created_ts, ''%Y-%m-%d'') as page_created_date, DATE_FORMAT(fp.created_ts,''%H:%i:%s'') as page_created_time, date_format(fp.updated_ts, ''%Y-%m-%d'') as page_updated_date, DATE_FORMAT(fp.updated_ts,''%H:%i:%s'') as page_updated_time, date_format(fp.published_ts, ''%Y-%m-%d'') as page_published_date, DATE_FORMAT(fp.published_ts,''%H:%i:%s'') as page_published_time, fp.uuid as page_id, fp.name as page_name, pfr.uuid as folder_id, pfr.name as folder_name, l.langue_id, p.uuid as langue_page_id, p.path, p.langue_code, p.variant, p.html_file_path, coalesce(ccnt.published_url,'''') as published_url, p.canonical_url, p.title, p.meta_keywords, p.meta_description, p.dl_page_type, p.dl_sub_level_1, p.dl_sub_level_2, p.package_name, p.class_name, p.layout, p.social_title, p.social_type, p.social_description, p.social_image, p.social_twitter_message, p.social_twitter_hashtags, p.social_email_subject, p.social_email_popin_title, p.social_email_message, p.social_sms_text, p.publish_status, p.row_height, p.item_margin_x, p.item_margin_y, p.container_padding_x, p.container_padding_y, p.dynamic_html, p.layout_data, p.get_html_status, ptags.tag_id tag_id, pmt.meta_name, pmt.meta_content, pb.sort_order bloc_sort_order, date_format(b.created_ts, ''%Y-%m-%d'') as bloc_created_date, DATE_FORMAT(b.created_ts,''%H:%i:%s'') as bloc_created_time, date_format(b.updated_ts, ''%Y-%m-%d'') as bloc_updated_date, DATE_FORMAT(b.updated_ts,''%H:%i:%s'') as bloc_updated_time, b.name bloc_name, b.uuid bloc_id, ptm.uuid as template_id, ptm.name as template_name, ptm.custom_id as template_custom_id, ptm.description as template_description, ptm.template_code as template_code, ptm.is_system as template_is_system, pti.id as item_id, pti.name as item_name, pti.custom_id as item_custom_id, pti.sort_order as item_sort_order, ptib.sort_order as item_bloc_sort_order, ib.uuid as item_bloc_id, ib.name as item_bloc_name, ptid.css_classes as item_detail_css_classes, ptid.css_style item_detail_css_style, pf.form_id as form_id, pf.sort_order page_form_sort_order from ##PAGES_DB##.freemarker_pages fp inner join ##PAGES_DB##.pages p on fp.id = p.parent_page_id and p.type = ''freemarker'' left outer join ##PAGES_DB##.language l on l.langue_code = p.langue_code left outer join ##PAGES_DB##.folders pfr on pfr.id = fp.folder_id left outer join ##PORTAL_DB##.cached_content_view ccnt on ccnt.site_id = p.site_id and ccnt.content_type = ''page'' and ccnt.content_id = p.id and ccnt.lang = l.langue_code left outer join ##PAGES_DB##.pages_tags ptags on ptags.page_id = p.id left outer join ##PAGES_DB##.pages_meta_tags pmt on pmt.page_id = p.id left outer join ##PAGES_DB##.parent_pages_blocs pb on pb.type = ''freemarker'' and pb.page_id = fp.id left outer join ##PAGES_DB##.blocs b on b.id = pb.bloc_id left outer join ##PAGES_DB##.page_templates ptm on ptm.id = p.template_id left outer join ##PAGES_DB##.page_templates_items pti on pti.page_template_id = ptm.id left outer join ##PAGES_DB##.page_templates_items_blocs ptib on ptib.item_id = pti.id and ptib.langue_id = l.langue_id left outer join ##PAGES_DB##.blocs ib on ib.id = ptib.bloc_id left outer join ##PAGES_DB##.page_templates_items_details ptid on ptid.item_id = pti.id and ptid.langue_id = l.langue_id left outer join ##PAGES_DB##.parent_pages_forms pf on pf.type = ''freemarker'' and pf.page_id = fp.id where fp.site_id = ##site_id## and fp.id = ##page_id##', distinct_keys_query = 'select id from ##PAGES_DB##.freemarker_pages where site_id = ##site_id##' where name = 'pages';

update es_query_levels set j_object_key = 'page_id', j_object_columns = 'id:page_id,name:page_name,folder_id,folder_name,created_date:page_created_date,created_time:page_created_time,updated_date:page_updated_date,updated_time:page_updated_time,published_date:page_published_date,published_time:page_published_time' where query_name = 'pages' and j_object = 'pages';

select @qid := id from es_query_levels where query_name = 'pages' and coalesce(parent_level_id,'') = '';

insert into es_query_levels (query_name, parent_level_id, j_object, j_object_key, j_object_columns) values ('pages', @qid, 'language', 'langue_page_id', 'id:langue_page_id,path,langue_code,variant,html_file_path,published_url,canonical_url,title,meta_keywords,meta_description,dl_page_type,dl_sub_level_1,dl_sub_level_2,package_name,class_name,layout,social_title,social_type,social_description,social_image,social_twitter_message,social_twitter_hashtags,social_email_subject,social_email_popin_title,social_email_message,social_sms_text,publish_status,row_height,item_margin_x,item_margin_y,container_padding_x,container_padding_y');

update es_query_levels set parent_level_id = @qid where query_name = 'pages' and j_object = 'blocs' and j_object = 'bloc_id';

update es_query_levels set parent_level_id = @qid where query_name = 'pages' and j_object = 'forms' and j_object = 'form_id';

select @qid := id from es_query_levels where query_name = 'pages' and j_object = 'language';

update es_query_levels set parent_level_id = @qid where query_name = 'pages' and j_object = 'tags';

update es_query_levels set parent_level_id = @qid where query_name = 'pages' and j_object = 'meta';

update es_query_levels set parent_level_id = @qid where query_name = 'pages' and j_object = 'template';

