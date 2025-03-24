<%
  response.setCharacterEncoding("utf-8");
  request.setCharacterEncoding("utf-8");
%>
<%@page import="com.etn.lang.Xml.Rs2Xml"%>
<%@page import="com.etn.sql.escape"%>
<%@page contentType="text/html; charset=UTF-8" %>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="java.util.*"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.Map.Entry"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.LinkedHashMap"%>
<%@ page import="java.util.Arrays"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.LinkedList"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Enumeration"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.Calendar"%>
<%@ page import="javax.servlet.http.Cookie"%>
<%@ page import="com.etn.datatables.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.util.FormDataFilter"%>
<%@ page import="java.io.FileOutputStream"%>
<%@ page import="java.io.File"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm, Logjava.util.*,org.apache.commons.fileupload.*, org.apache.commons.fileupload.servlet.*, org.apache.commons.fileupload.disk.*, com.etn.util.ItsDate, org.apache.tika.*"%>
<%@ page import="java.util.regex.Pattern"%>
<%@ page import="java.util.regex.Matcher"%>
<%@ page import="com.etn.asimina.data.LanguageFactory, com.etn.asimina.beans.Language" %>
<%@ page import="com.etn.util.XSSHandler" %>

<%@ include file="../../common2.jsp" %>

<%!

    String getGroupActionResponse(Set rs, String groupId){

      StringBuffer html = new StringBuffer();

      html.append("<div class='class='col-xs-12 col-sm-12 col-md-12 col-lg-12' style='text-align: center;'> <h2>Actions</h2> </div>");
      html.append("<table class='table table-striped'>");
      html.append("<tr>");

      html.append("<th style='text-align: center;'>Group id</th>");
      html.append("<th style='text-align: center;'>Action type</th>");
      html.append("<th style='text-align: center;'>Equipement</th>");
      html.append("<th style='text-align: center;'>Test todo</th>");
      html.append("<th style='text-align: center;'>idmodel</th>");
      html.append("<th style='text-align: center;'>ident</th>");
      html.append("<th style='text-align: center;'>Delete</th>");
      html.append("</tr>");

      if(rs.rs.Rows == 0){

        html.append("<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>No action found.</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>");
      }

      while(rs.next()){

        html.append("<tr>");
        html.append("<td>" + parseNull(rs.value("group_id")) + "</td>");
        html.append("<td>" + parseNull(rs.value("type_action")) + "</td>");
        html.append("<td>" + parseNull(rs.value("equipement")) + "</td>");
        html.append("<td>" + parseNull(rs.value("test_todo")) + "</td>");
        html.append("<td>" + parseNull(rs.value("idmodel")) + "</td>");
        html.append("<td>" + parseNull(rs.value("ident")) + "</td>");
        html.append("<td><span onclick='deleteDemandAction(this.id)' style='cursor: pointer;' id='" + parseNull(rs.value("action_id")) + "' class='glyphicon glyphicon-remove'></span></td>");
        html.append("</tr>");
      }

      html.append("<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td><button id='" + groupId + "' onclick='addAction(this.id)' type='button' class='btn btn-primary'>Add action</button></td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>");

      html.append("</table>");

      return html.toString();

    }

%>

<%

  String action = parseNull(request.getParameter("action"));
  String siteId = getSelectedSiteId(session);
  System.out.println("action =="+action);
  System.out.println("siteId =="+siteId);
  Language firstLanguage = getLangs(Etn,siteId).get(0);
  if(action.equals("deleteAllForms")){

    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;
    int status = STATUS_ERROR;
    String message = "";
    String q = "";
    Set rs = null;

    try{
        String formIds =  parseNull(request.getParameter("ids"));
        ArrayList<String> formIdList = new ArrayList<String>();
        int fid = Etn.getId();

        for(String formId : formIds.split(",")){

            if(formId.length() > 0){

                q = " SELECT form_id,type FROM process_forms_unpublished "
                    + " WHERE form_id = " + escape.cote(""+formId)
                    + " AND site_id = " + escape.cote(siteId);

                rs = Etn.execute(q);

                if(rs.next()){
                    if(parseNull(rs.value("type")).equals("simple"))
                        formIdList.add(formId);
                }
            }
        }
        if(formIdList.size() == 0){
            message = "Error: No valid form ids found";
        }
        int publishCount = 0;
        for(String formId : formIdList){
            try{
                Set publishRs =  Etn.execute("select * from process_forms where form_id = "+escape.cote(formId));
                if(publishRs.rs.Rows>0){
                    continue;
                }
                Set deleteProcessRs = Etn.execute("SELECT table_name, process_name FROM process_forms_unpublished WHERE form_id = " + escape.cote(formId) + " and site_id = " + escape.cote(siteId));

                String tblName = "";

                if(deleteProcessRs.next()) {

                    tblName = parseNull(deleteProcessRs.value("table_name"));
                }

                Etn.execute("DELETE FROM coordinates where process = " + escape.cote(tblName));
                Etn.execute("DELETE FROM rules WHERE start_proc = " + escape.cote(tblName) + " AND next_proc = " + escape.cote(tblName));
                Etn.execute("DELETE FROM phases WHERE process = " + escape.cote(tblName));
                Etn.execute("DELETE FROM has_action WHERE start_proc = " + escape.cote(tblName));

                Etn.execute("DELETE m FROM mails_unpublished m INNER JOIN mail_config_unpublished mc ON m.id = mc.id INNER JOIN process_forms_unpublished pf ON mc.ordertype = pf.table_name WHERE pf.form_id = " + escape.cote(formId));
                Etn.execute("DELETE mc FROM mail_config_unpublished mc INNER JOIN process_forms_unpublished pf ON mc.ordertype = pf.table_name WHERE pf.form_id = " + escape.cote(formId));
                Etn.execute("DELETE fr FROM freq_rules_unpublished fr INNER JOIN process_forms_unpublished pf ON fr.form_id = pf.form_id WHERE pf.form_id = " + escape.cote(formId));
                Etn.execute("DELETE FROM process_form_field_descriptions_unpublished WHERE form_id = " + escape.cote(formId));
                Etn.execute("DELETE FROM process_form_fields_unpublished WHERE form_id = " + escape.cote(formId));
                Etn.execute("DELETE FROM process_form_lines_unpublished WHERE form_id = " + escape.cote(formId));
                Etn.execute("DELETE FROM process_form_fields_unpublished WHERE form_id = " + escape.cote(formId));
                Etn.execute("DELETE FROM process_forms_unpublished WHERE form_id = " + escape.cote(formId));
                publishCount++;
            //      Etn.execute("DROP TABLE IF EXISTS " + tblName);

            }
            catch(Exception ex){
                ex.printStackTrace();
            }
        }
        //ActivityLog.addLog(Etn,request,parseNull((String)session.getAttribute("LOGIN")),formId,"DELETED","Form",parseNull(deleteProcessRs.value("process_name")),siteId);
        if(formIdList.size() >0){
            status = STATUS_SUCCESS;
            message = publishCount + " form(s) deleted.";
        }
    }//try
    catch(Exception ex){
        throw new Exception("Error in unpublishing form(s). Please try again.",ex);
    }

    JSONObject jsonResponse = new JSONObject();
    jsonResponse.put("status",status);
    jsonResponse.put("message",message);
    out.write(jsonResponse.toString());
  }
	else if(action.equals("add_rule_field")){

      String formId = parseNull(request.getParameter("form_id"));
      String fieldId = parseNull(request.getParameter("field_id"));
      String frequency = parseNull(request.getParameter("frequency"));
      String period = parseNull(request.getParameter("period"));

      Set ruleRs = Etn.execute("SELECT * FROM freq_rules_unpublished WHERE form_id = " + escape.cote(formId) + " AND field_id = " + escape.cote(fieldId) + " AND period = " + escape.cote(period));

      if(ruleRs.rs.Rows > 0){

        out.write("{\"response\":\"error\",\"msg\":\"This rule is already exists.\"}");

      } else {

        String insertQuery = "INSERT INTO freq_rules_unpublished (form_id, field_id, frequency, period) VALUES(" + escape.cote(formId) + "," + escape.cote(fieldId) + "," + escape.cote(frequency) + "," + escape.cote(period) + ")";

        int rowId = Etn.executeCmd(insertQuery);
        updateVersionForm(Etn, formId);

        if(rowId > 0) out.write("{\"response\":\"success\",\"msg\":\"Rule added\"}");
        else out.write("{\"response\":\"error\",\"msg\":\"Error, something wrong\"}");
      }


  } else if(action.equals("delete_rule_field")){

      String formId = parseNull(request.getParameter("form_id"));
      String id = parseNull(request.getParameter("id"));
      Etn.execute("DELETE FROM freq_rules_unpublished WHERE id = " + escape.cote(id));
      updateVersionForm(Etn, formId);

  } else if(action.equals("update_rule_field")){

      String formId = parseNull(request.getParameter("form_id"));
      String fieldId = parseNull(request.getParameter("field_id"));
      String frequency = parseNull(request.getParameter("frequency"));
      String period = parseNull(request.getParameter("period"));
      String id = parseNull(request.getParameter("id"));

      String updateQuery = "UPDATE freq_rules_unpublished SET frequency = " + escape.cote(frequency) + ", period = " + escape.cote(period) + " WHERE form_id = " + escape.cote(formId) + " AND field_id = " + escape.cote(fieldId) + " AND id = " + escape.cote(id);

      Etn.executeCmd(updateQuery);
      updateVersionForm(Etn, formId);

  } 
  else {
	out.write("{\"response\":\"error\",\"msg\":\"Method not supported.\"}");
  }

%>

