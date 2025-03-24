-------------------- MAHIN 08/11/2022 ------------------

ALTER TABLE `games_unpublished`
DROP INDEX `uq_kys`,
ADD UNIQUE INDEX `uq_kys` (`site_id`, `is_deleted`, `name`); 

ALTER TABLE `games`
DROP INDEX `uq_kys`,
ADD UNIQUE INDEX `uq_kys` (`site_id`, `is_deleted`, `name`);

--------------------------------------------------------