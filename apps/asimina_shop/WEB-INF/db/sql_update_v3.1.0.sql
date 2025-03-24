-- START 07-02-2022 ---
-- AHSAN 
insert into page (name, url, rang, icon) values ('Incomplete Carts','/dev_shop/admin/pendingCartsInfo.jsp','6','cui-cart');

insert into config (code, val, comments) values ('no_admin_bill_download','0', 'This flag is used in customer edit screen to configure the display of bill download button');

-- END 07-02-2022 ---


update page set rang = 1 where name = 'orders';
update page set rang = 0, icon = 'cui-speedometer' where name = 'Dashboard';

