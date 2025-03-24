--------------------- Start Ahsan 18 Oct 2023 ---------------------
insert into query_types (query_name,query_type) values('deliveryfees','Delivery Fee');

SET @new_id = LAST_INSERT_ID();

insert into es_queries (name,query_type_id,pagination_col,query,distinct_keys_query) values('deliveryfees',@new_id,'id',"SELECT l.langue_id,l.langue_code,df.id,df.uuid, 
df.name, df.order_seq, df.created_on,df.visible_to, df.dep_type as zone, df.dep_value as zone_value, df.fee, df.applicable_per_item,
lm.LANGUE_1,lm.LANGUE_2,lm.LANGUE_3,lm.LANGUE_4,lm.LANGUE_5, df.lang_1_description, 
df.lang_2_description, df.lang_3_description, df.lang_4_description,df.lang_5_description, df.version, df.delivery_type,
CONCAT(dfr.deliveryfee_id,'-',dfr.applied_to_type,CASE When COALESCE(dfr.applied_to_value,'')!='' 
then CONCAT('-',dfr.applied_to_value) ELSE '' END)  as rule_id, dfr.applied_to_type, dfr.applied_to_value ,s.suid
FROM ##CATALOG_DB##.deliveryfees df
INNER JOIN ##COMMONS_DB##.sites_langs sl ON sl.site_id=df.site_id
JOIN ##CATALOG_DB##.language l ON l.langue_id = sl.langue_id
INNER JOIN ##CATALOG_DB##.shop_parameters sp ON sp.site_id=df.site_id
LEFT JOIN ##CATALOG_DB##.langue_msg lm ON lm.LANGUE_REF=sp.lang_1_currency
LEFT JOIN ##CATALOG_DB##.deliveryfees_rules dfr ON dfr.deliveryfee_id=df.id
LEFT JOIN ##PORTAL_DB##.sites s ON s.id=df.site_id
where df.site_id=##site_id## AND df.id = CASE WHEN LOWER(##delivery_fee_id##) = 'all' THEN df.id ELSE ##delivery_fee_id## END",
"select id from ##CATALOG_DB##.deliveryfees where site_id=##site_id## and id = CASE WHEN LOWER(##delivery_fee_id##) = 'all' THEN id ELSE ##delivery_fee_id## END");

INSERT INTO es_query_levels (query_name, parent_level_id, j_object, j_object_key, j_object_columns)
VALUES ('deliveryfees', NULL, 'deliveryfees', 'id', 'uuid,name,site_uuid:suid,order_seq,created_on,visible_to,zone,zone_value,fee,applicable_per_item,version,delivery_type');

SET @new_id = LAST_INSERT_ID();

INSERT INTO es_query_levels (query_name, parent_level_id, j_object, j_object_key, j_object_columns)
VALUES ('deliveryfees', @new_id, 'language', 'langue_id', 'langue_code,description:lang_<key>_description,currency:LANGUE_<key>');

INSERT INTO es_query_levels (query_name, parent_level_id, j_object, j_object_key, j_object_columns)
VALUES ('deliveryfees', @new_id, 'deliveryfee_rule', 'rule_id', 'applied_to_type,applied_to_value');

INSERT INTO es_query_col_mapping VALUES ('deliveryfees', 'description', 'lang_1_description,lang_2_description,lang_3_description,lang_4_description,lang_5_description');
INSERT INTO es_query_col_mapping VALUES ('deliveryfees', 'currency', 'LANGUE_1,LANGUE_2,LANGUE_3,LANGUE_4,LANGUE_5');

--------------------- End Ahsan 18 Oct 2023 ---------------------