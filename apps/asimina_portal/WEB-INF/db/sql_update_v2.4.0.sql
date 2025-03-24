-- START 04-09-2020 -- 
insert into dev_commons.config(code, val, comments) values ('INCLUDE_CUSTOM_CSS','0','Flag to enable disable inclusion of custom css at time of caching pages');
-- END 04-09-2020 -- 

-- START 16-09-2020 --
INSERT INTO `config` (`code`, `val`) VALUES ('ORANGE_API_MSISDN', '67685696');
INSERT INTO `config` (`code`, `val`) VALUES ('ORANGE_MONEY_API_USERNAME', '');
INSERT INTO `config` (`code`, `val`) VALUES ('ORANGE_MONEY_API_PASSWORD', '');
INSERT INTO `config` (`code`, `val`) VALUES ('ORANGE_MONEY_API_URL', 'https://testom.orange.bf:9008/payment');
INSERT INTO `config` (`code`, `val`) VALUES ('ORANGE_MONEY_API_USSD', '*866*4*6*');
-- END 16-09-2020 --


-- START 25-09-2020 --
delete from config where code = 'ORANGE_API_MSISDN';
delete from config where code = 'ORANGE_MONEY_API_USERNAME';
delete from config where code = 'ORANGE_MONEY_API_PASSWORD';
delete from config where code = 'ORANGE_MONEY_API_URL';
-- END 25-09-2020 --