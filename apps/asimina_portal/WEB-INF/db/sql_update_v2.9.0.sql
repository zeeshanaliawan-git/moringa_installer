-- start 30-06-2021
CREATE INDEX site_n_session on cart (session_id, site_id);
CREATE INDEX cart_id on cart_items (cart_id);

alter table cart add created_on timestamp not null default current_timestamp;
-- end 30-06-2021