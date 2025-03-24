insert into osql (id,nextOnErr,sqltext) values ('CheckPayment',1,"select case when spaymentmean in ('cash_on_pickup','cash_on_delivery') then 0 when payment_status = 'SUCCESS' then 0 when payment_status = 'verify_payment' then 15 else 19 end from orders where id = $clid");

alter table orders change transaction_code transaction_code varchar(255);