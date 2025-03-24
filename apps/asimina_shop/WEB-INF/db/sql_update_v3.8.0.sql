insert into field_names (screenName, fieldName, displayName, isLabel, `section`, sectionDisplaySeq, fieldDisplaySeq, fieldType, tab, tabDisplaySeq, tabId, tableName, input_type)
values ('CUSTOMER_EDIT','remaining_promo_value','Remaining Promo Value','1','Payment Info','2','4','','Order Information','2','','orders','text');

alter table orders add user_agent varchar(500);
alter table orders add payment_ref_total_amount varchar(32);
alter table orders add cart_type varchar(50);

insert into osql (id, nextOnErr, sqltext) values ('validatePaymentAmount',1,'select case when spaymentmean = ''cash_on_delivery'' or spaymentmean = ''cash_on_pickup'' then 0 when COALESCE(cast(total_price as double),0) = COALESCE(cast(payment_ref_total_amount as double),0) then 0 else 19 end from orders where id = $clid');

insert into dev_commons.config (code, val) values ("sms.smpp.country.code", "");

alter table has_action modify action varchar(255);

alter table rules modify action varchar(255);
