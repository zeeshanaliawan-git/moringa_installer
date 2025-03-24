update dev_commons.config set val = '3.7.0' where code = 'APP_VERSION';
update dev_commons.config set val = '3.7.0.1' where code = 'CSS_JS_VERSION';


--------------------- MAHIN 12/10/2022 --------------------------------

update page set rang = rang + 1 where rang > 304;
INSERT INTO page(NAME,url,parent,rang,icon,parent_icon,menu_badge) VALUES("Games","/dev_forms/admin/games.jsp","Content",305,"chevron-right","file-text","BETA"); 

-------------------------------------------------------------------

