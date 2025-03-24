-------------- Ahsan start 10 jan 2024 ----------------
alter table algolia_indexation add column is_failed tinyint(1) not null default 0;
-------------- Ahsan end 10 jan 2024 ----------------

alter table cart modify cart_type enum('normal','topup','card2wallet') not null default 'normal';
