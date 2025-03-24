alter table orders add is_external tinyint(1) not null default 0;

create table external_orders_logs (
id int(11) not null auto_increment,
api_key_id varchar(100) not null,
order_uuid varchar(50),
req longtext,
resp longtext,
create_ts timestamp not null default CURRENT_TIMESTAMP,
primary key(id)
)Engine=MyISAM default charset=utf8;

alter table order_items modify comewiths longtext;
alter table order_items modify additionalfees mediumtext;
alter table order_items modify promotion mediumtext;

alter table orders add x_forwarded_for varchar(255);

create table order_kyc_info (
    order_id int(11) NOT null,
    kyc_uid varchar(50) NOT null,
    kyc_resp longtext,
    kyc_ts timestamp,
    kyc_status varchar(50),
    primary key (`order_id`,`kyc_uid`)
)Engine=MyISAM default charset=utf8;

INSERT INTO order_kyc_info (order_id, kyc_uid, kyc_resp, kyc_ts, kyc_status)
SELECT id, kyc_uid, kyc_resp, kyc_ts, kyc_status
FROM orders
WHERE kyc_uid IS NOT NULL AND kyc_uid <> '';

alter table orders 
drop column kyc_uid,
drop column kyc_resp,
drop column kyc_ts,
drop column kyc_status;



alter table orders add cart_id int(11) not null;

alter table orders add delivery_date date;
alter table orders add delivery_start_hour int(2);
alter table orders add delivery_start_min int(2);
alter table orders add delivery_end_hour int(2);
alter table orders add delivery_end_min int(2);

insert into field_names (screenName, fieldName, displayName, isLabel, `section`, sectionDisplaySeq, fieldDisplaySeq, fieldType, tab, tabDisplaySeq, tabId, tableName, input_type)
values ('CUSTOMER_EDIT','delivery_date','Preferred date', 0, 'Home delivery', 6, 1, 'text', 'Customer Information', 1, '', '', 'text');
insert into field_names (screenName, fieldName, displayName, isLabel, `section`, sectionDisplaySeq, fieldDisplaySeq, fieldType, tab, tabDisplaySeq, tabId, tableName, input_type)
values ('CUSTOMER_EDIT','delivery_slot','Preferred slot', 0, 'Home delivery', 6, 2, 'text', 'Customer Information', 1, '', '', 'text');
