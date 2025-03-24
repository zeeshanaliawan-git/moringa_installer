alter table payment_actions add revalidation_required tinyint(1) not null default 0;

alter table orders add kyc_uid VARCHAR(50) default null;
alter table orders add kyc_resp mediumtext default null;
alter table orders add kyc_status VARCHAR(50) default null;
alter table orders add kyc_ts datetime default null;

alter table login add allowed_ips varchar(255);





insert into field_names (screenName, fieldName, displayName, isLabel, `section`, sectionDisplaySeq, fieldDisplaySeq, tab, tabDisplaySeq, tableName, input_type)
value ('CUSTOMER_EDIT','kyc_status','KYC Status','0','KYC', 6, 1, 'Customer Information', 1,'orders','text');

insert into field_names (screenName, fieldName, displayName, isLabel, `section`, sectionDisplaySeq, fieldDisplaySeq, tab, tabDisplaySeq, tableName, input_type)
value ('CUSTOMER_EDIT','kyc_resp','KYC response','0','KYC', 6, 2, 'Customer Information', 1,'orders','text');

insert into field_names (screenName, fieldName, displayName, isLabel, `section`, sectionDisplaySeq, fieldDisplaySeq, tab, tabDisplaySeq, tableName, input_type)
value ('CUSTOMER_EDIT','kyc_ts','KYC timestamp','0','KYC', 6, 3, 'Customer Information', 1,'orders','text');

insert into field_settings (process, phase, screenName, fieldName, isMandatory, isHidden, isEditable)
select process, phase, 'CUSTOMER_EDIT', 'kyc_status',0,1,0 from phases;

insert into field_settings (process, phase, screenName, fieldName, isMandatory, isHidden, isEditable)
select process, phase, 'CUSTOMER_EDIT', 'kyc_resp',0,1,0 from phases;

insert into field_settings (process, phase, screenName, fieldName, isMandatory, isHidden, isEditable)
select process, phase, 'CUSTOMER_EDIT', 'kyc_ts',0,1,0 from phases;
