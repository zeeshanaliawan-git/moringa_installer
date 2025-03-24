use dev_shop;
alter table orders add extra_field_1 varchar(255) default null COMMENT 'Countries might some times need extra info to be saved in order from back-office so we can use this field depending on need and configure in field_names table';
alter table orders add extra_field_2 varchar(255) default null COMMENT 'Countries might some times need extra info to be saved in order from back-office so we can use this field depending on need and configure in field_names table';
alter table orders add extra_field_3 varchar(255) default null COMMENT 'Countries might some times need extra info to be saved in order from back-office so we can use this field depending on need and configure in field_names table';
alter table orders add extra_field_4 varchar(255) default null COMMENT 'Countries might some times need extra info to be saved in order from back-office so we can use this field depending on need and configure in field_names table';
alter table orders add extra_field_5 varchar(255) default null COMMENT 'Countries might some times need extra info to be saved in order from back-office so we can use this field depending on need and configure in field_names table';


drop view customer;
CREATE VIEW customer AS select orders.id AS customerid,orders.id AS orderid,
orders.parent_uuid AS parent_uuid,orders.identityId AS identityId,
orders.name AS name,orders.surnames AS surnames,orders.contactPhoneNumber1 AS contactPhoneNumber1,
orders.nationality AS nationality,orders.email AS email,orders.identityType AS IdentityType,
orders.total_price AS total_price,orders.tm AS tm,orders.baline1 AS baline1,orders.baline2 AS baline2,
orders.batowncity AS batowncity,orders.bapostalCode AS bapostalCode,orders.salutation AS salutation,
orders.infoSup1 AS infoSup1,orders.client_id AS client_id,orders.creationDate AS creationDate,
orders.orderRef AS orderRef,orders.lang AS lang,orders.order_snapshot AS order_snapshot,orders.daline1 AS daline1,
orders.daline2 AS daline2,orders.datowncity AS datowncity,orders.dapostalCode AS dapostalCode,
orders.menu_uuid AS menu_uuid,orders.currency AS currency,orders.ip AS ip,
orders.spaymentmean AS spaymentmean,orders.shipping_method_id AS shipping_method_id,orders.payment_ref_id AS payment_ref_id,
orders.payment_id AS payment_id,orders.payment_token AS payment_token,orders.payment_url AS payment_url,
orders.payment_notif_token AS payment_notif_token,orders.payment_status AS payment_status,orders.payment_txn_id AS payment_txn_id,
orders.lastid AS lastid,orders.payment_fees AS payment_fees,orders.delivery_fees AS delivery_fees,
orders.orderType AS orderType,orders.transaction_code AS transaction_code,orders.tracking_number AS tracking_number,
orders.promo_code AS promo_code,orders.courier_name AS courier_name,orders.identityPhoto AS identityPhoto,
orders.newPhoneNumber AS newPhoneNumber,orders.selected_boutique AS selected_boutique,orders.rdv_boutique AS rdv_boutique,
orders.rdv_date AS rdv_date,orders.delivery_type AS delivery_type,orders.site_id AS site_id,orders.country AS country,
orders.newsletter AS newsletter,orders.comments AS comments, orders.extra_field_1 as extra_field_1, orders.extra_field_2 as extra_field_2,
orders.extra_field_3 as extra_field_3, orders.extra_field_4 as extra_field_4, orders.extra_field_5 as extra_field_5
from orders;
