create table process_form_lines_v212 select * from process_form_lines;
create table process_form_lines_unpublished_v212 select * from process_form_lines_unpublished;

alter table process_form_lines change line_seq line_seq int(10) not null default 0;
alter table process_form_lines_unpublished change line_seq line_seq int(10) not null default 0;


