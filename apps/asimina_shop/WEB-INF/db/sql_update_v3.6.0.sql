-- adding these from 3.5 just to make sure any country was missing running this manually will be updated in 3.6 --
alter table payments_ref add column return_url varchar(255);
alter table payments_ref add column cancel_url varchar(255);

insert into config (code, val, comments) values ('use_process_as_order_type','','This flag determines if we have to use order type in shop as process names or fixed as Order. For all asimina shops it must be fixed as Orders so we dont have to change this. This was added for some orange requirement where they wanted process names loaded as order type in mail config screen drop down');


insert into dev_commons.config (code, val) values ('sms.smpp.host','');
insert into dev_commons.config (code, val) values ('sms.smpp.port','');
insert into dev_commons.config (code, val) values ('sms.smpp.user','');
insert into dev_commons.config (code, val) values ('sms.smpp.password','');
insert into dev_commons.config (code, val, comments) values ('sms.smpp.sender','', 'Name of country/vendor or short code');

insert into actions (name, className) values ('smpp','SmsSmpp');