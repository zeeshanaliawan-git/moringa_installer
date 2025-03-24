-- START 30-04-2021 --

ALTER TABLE `cart_items`
ADD COLUMN `comewith_variant_id`  varchar(100) NULL DEFAULT '' AFTER `delivery_fee_per_item`;

-- END 30-04-2021 --