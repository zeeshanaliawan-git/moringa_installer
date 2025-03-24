alter table sites add column authentication_type enum('default','orange') not null default 'default';
alter table sites add column orange_authentication_api_url varchar(500);
alter table sites add column orange_token_api_url varchar(500);
alter table sites add column orange_authorization_code varchar(500);

-- start 03-02-2021 --
-- only in portal
insert into config (code, val) values ('PUBLISH_RESOURCES_FOLDER_SCRIPT', '/home/etn/pjt/dev_engines/portal/copyresources.sh');
-- end 03-02-2021 --

-- START 01-03-2021 -- 

ALTER TABLE `cart_items`
ADD COLUMN `delivery_fee_per_item`  varchar(32) NULL DEFAULT '' AFTER `comewith_excluded`;

-- END 01-03-2021 -- 