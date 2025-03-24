-- added by umair 17-sep-21 .. missing script of 2.10
-- adding it for next release so that its added on all countries where its missing as some countries already upgraded
alter table cart add order_uuid varchar(50);

alter table site_menus add extra_js_mjs varchar(255) comment 'Semi colon separated list of extra js files to be loaded with js menu. This will not be required in block system js menu';

insert into config (code, val, comments) values ('BILL_TRACKING_JSP','/cart/defaultTrackingBill.jsp', 'Set appropriate path for each country if required');