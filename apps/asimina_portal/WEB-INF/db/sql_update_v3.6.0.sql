--------------Start 12 Aug 2022 Ahsan------------

ALTER TABLE sites_details 
ADD COLUMN error_page_url VARCHAR(2000),
ADD COLUMN fraud_page_url VARCHAR(2000);

--------------End 12 Aug 2022 Ahsan------------

update cart set cart_type = 'normal' where COALESCE(cart_type,'') = '';

--------------Start 18 Aug 2022 Mahin------------

ALTER TABLE sites ADD COLUMN form_boosted_version VARCHAR(10) not null DEFAULT '4.x';

--------------End 18 Aug 2022 Mahin------------

