------------ Ahsan Start 26 Sep 2024 ------------
create table bloc_field_selected_templates(
    id int(11) auto_increment not null,
    template_id int(11) not null,
    field_id int(11) not null,
    selected_template_id int(11) not null,
    created_ts timestamp not null default CURRENT_TIMESTAMP,
    updated_ts timestamp not null default CURRENT_TIMESTAMP on UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY `uk_templates` (`template_id`,`selected_template_id`)
);
------------ Ahsan End 26 Sep 2024 ------------