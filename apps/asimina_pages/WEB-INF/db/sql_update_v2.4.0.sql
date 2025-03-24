-- START 12-08-2020

ALTER TABLE blocs
ADD FULLTEXT INDEX bloc_data_full_text (template_data) ;

ALTER TABLE bloc_templates
ADD FULLTEXT INDEX template_code_full_text (template_code) ;

ALTER TABLE structured_contents_details
ADD FULLTEXT INDEX struct_content_data_full_text (content_data) ;


DELIMITER $$
CREATE FUNCTION GetFileUseCount(fileName varchar(500)) RETURNS int(11)
BEGIN

    DECLARE retCount int(11) DEFAULT 0;
    DECLARE tempCount int(11) DEFAULT 0;
    DECLARE fileName1 varchar(500) DEFAULT '';
    -- DECLARE fileName2 varchar(500) DEFAULT '';

    SET fileName1 = CONCAT('"',fileName,'"');
    -- SET fileName2 = CONCAT('%',fileName,'%');

    SELECT count(id) AS uses
                INTO tempCount
    FROM blocs b
    WHERE MATCH(template_data) AGAINST(fileName1 IN BOOLEAN MODE );
    -- WHERE template_data LIKE fileName2;

    SET retCount = retCount + tempCount;

    SELECT count(id) AS uses
                INTO tempCount
    FROM structured_contents_details scd
    WHERE MATCH(content_data) AGAINST(fileName1 IN BOOLEAN MODE );
    -- WHERE content_data LIKE fileName2;

    SET retCount = retCount + tempCount;


    SELECT count(id) AS uses
                INTO tempCount
    FROM bloc_templates
    WHERE MATCH(template_code) AGAINST(fileName1 IN BOOLEAN MODE );
    -- WHERE template_code LIKE fileName2;

    SET retCount = retCount + tempCount;

    RETURN retCount;
END$$
DELIMITER ;

-- START 12-08-2020
ALTER TABLE sections_fields
ADD COLUMN is_required tinyint(1) NOT NULL DEFAULT '0',
ADD COLUMN placeholder varchar(500) NOT NULL DEFAULT '';
-- END 12-08-2020

-- START 26-08-2020
ALTER TABLE pages
MODIFY COLUMN layout  enum('react-grid-layout','css-grid') NOT NULL DEFAULT 'react-grid-layout';

ALTER TABLE pages
ADD COLUMN layout_data mediumtext NOT NULL AFTER dynamic_html;

-- START 26-08-2020 --
alter table structured_contents_details add fd_content_data mediumtext as (replace(replace(replace(replace(`content_data`,'#slash#/','/'),'#slash#n',''),'#slash#"','\''),'#slash#','/')) persistent;
alter table structured_contents_details add fd_content_data_2 mediumtext as (replace(replace(replace(`content_data`,'#slash#/','/'),'#slash#"','\\"'),'#slash#','\\')) persistent;

alter table structured_contents_details_published add fd_content_data mediumtext ;
alter table structured_contents_details_published add fd_content_data_2 mediumtext ;

-- END 26-08-2020 --

-- START 01-10-2020
ALTER TABLE files
ADD COLUMN images_generated tinyint(1) NULL DEFAULT 0 COMMENT 'i.e. thumbnail, 4x3, og ' AFTER `file_size`;
-- END 01-10-2020

ALTER TABLE pages
MODIFY COLUMN name varchar(300) NOT NULL;