<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>
<%@ page import="com.etn.util.Base64"%>
<%@ page import="java.io.File"%>
<%@ include file="../../common2.jsp"%>

<%
    String formId = parseNull(request.getParameter("formId"));
    String formNewName = parseNull(request.getParameter("formNewName"));
    String query = "";
    String status = "SUCCESS";
    String message = "";
    String newFormId = "";
    String columnQuery = "";
    String columnName = "";
    String columnType = "";

    String tableNewName = parseNull(request.getParameter("tableNewName")).replaceAll(" ", "_").toLowerCase();
	tableNewName = com.etn.asimina.util.UrlHelper.removeAccents(tableNewName);

    try{

        newFormId = UUID.randomUUID().toString();

        query = "INSERT INTO process_forms_unpublished (form_id, process_name, table_name, is_email_cust, is_email_bk_ofc, site_id, variant, template, meta_description, meta_keywords, form_class, html_form_id, form_method, form_enctype, form_autocomplete, redirect_url, btn_align, label_display, form_width, form_js) SELECT " + escape.cote(newFormId) + "," + escape.cote(formNewName) + "," + escape.cote(tableNewName) + ", is_email_cust, is_email_bk_ofc, site_id, variant, template, meta_description, meta_keywords, form_class, html_form_id, form_method, form_enctype, form_autocomplete, redirect_url, btn_align, label_display, form_width, form_js FROM process_forms_unpublished WHERE form_id = " + escape.cote(formId);

        int rowId = Etn.executeCmd(query);

        if(rowId > 0){
        
            query = "INSERT INTO process_form_descriptions_unpublished(form_id, langue_id, page_path, title, success_msg, submit_btn_lbl, cancel_btn_lbl) SELECT " + escape.cote(newFormId) + ", langue_id, " + escape.cote("forms/" + formNewName.toLowerCase().replaceAll("\\s","")) + ", title, success_msg, submit_btn_lbl, cancel_btn_lbl from process_form_descriptions_unpublished WHERE form_id = " + escape.cote(formId);

            Etn.executeCmd(query);

            Set rs = Etn.execute("select * from process_form_lines_unpublished where form_id = " + escape.cote(formId));
            String newFieldId = "";
            String newLineId = "";
            Set frmrs = null;

            while(rs.next()){

                newLineId = UUID.randomUUID().toString();

                Etn.execute("insert into process_form_lines_unpublished(id, form_id, line_id, line_class, line_width, line_seq) select " + escape.cote(newLineId) + ", " + escape.cote(newFormId) + ", line_id, line_class, line_width, line_seq from process_form_lines_unpublished where form_id = " + escape.cote(formId) + " and id = " + escape.cote(parseNull(rs.value("id"))));

				//order by is very important to keep fields in same position
                frmrs = Etn.execute("select * from process_form_fields_unpublished where form_id = " + escape.cote(formId) + " and line_id = " + escape.cote(parseNull(rs.value("id"))) + " order by id ");

                while(frmrs.next()){

                    newFieldId = UUID.randomUUID().toString();
                    Etn.execute("insert into process_form_fields_unpublished (form_id,field_id,seq_order,label_id,field_type,db_column_name,font_weight,font_size,color,name,maxlength,required,rule_field,add_no_of_days,start_time,end_time,time_slice,default_time_value,autocomplete_char_after,element_autocomplete_query,element_trigger,element_id,type,element_option_class,element_option_others,element_option_query,resizable_col_class,always_visible,regx_exp,group_of_fields,file_extension,img_width,img_height,img_alt,img_murl,href_chckbx,href_target,img_href_url,btn_id,container_bkcolor,text_align,text_border,site_key,theme,recaptcha_data_size,custom_css,line_id,min_range,max_range,step_range) select " + escape.cote(newFormId) + ", " + escape.cote(newFieldId) + ",seq_order,label_id,field_type,db_column_name,font_weight,font_size,color,name,maxlength,required,rule_field,add_no_of_days,start_time,end_time,time_slice,default_time_value,autocomplete_char_after,element_autocomplete_query,element_trigger,element_id,type,element_option_class,element_option_others,element_option_query,resizable_col_class,always_visible,regx_exp,group_of_fields,file_extension,img_width,img_height,img_alt,img_murl,href_chckbx,href_target,img_href_url,btn_id,container_bkcolor,text_align,text_border,site_key,theme,recaptcha_data_size,custom_css," + escape.cote(newLineId) + ",min_range,max_range,step_range from process_form_fields_unpublished where form_id = " + escape.cote(formId) + " and field_id = " + escape.cote(parseNull(frmrs.value("field_id"))));

                    Etn.execute("insert into process_form_field_descriptions_unpublished (form_id, field_id, langue_id, label, placeholder, err_msg, value, options, option_query) select " + escape.cote(newFormId) + ", " + escape.cote(newFieldId) + ", langue_id, label, placeholder, err_msg, value, options, option_query from process_form_field_descriptions_unpublished where form_id = " + escape.cote(formId) + " and field_id = " + escape.cote(parseNull(frmrs.value("field_id"))));

                    columnType = parseNull(frmrs.value("type"));

                    if(columnType.equals("textdate"))
                        columnName += "\t" + parseNull(frmrs.value("db_column_name")) + " date DEFAULT NULL,\n";
                    else if(columnType.equals("textdatetime"))
                        columnName += "\t" + parseNull(frmrs.value("db_column_name")) + " datetime DEFAULT NULL,\n";
                    else if(columnType.equals("email"))
                        columnName += "\t" + parseNull(frmrs.value("db_column_name")) + " VARCHAR(255) DEFAULT NULL,\n";
                    else if(!(columnType.equals("hr_line") || columnType.equals("label") || columnType.equals("button")))
                        columnName += "\t" + parseNull(frmrs.value("db_column_name")) + " TEXT DEFAULT NULL,\n";

                }
            }
        }

    } catch(Exception e){

        status = "ERROR";
        message = e.getMessage();
    }

    out.write("{\"status\":\""+status+"\",\"message\":\""+message+"\"}");
%>
