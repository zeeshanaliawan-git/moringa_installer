<%@page import="com.etn.beans.Contexte"%>
<%@page import="com.etn.lang.Xml.Rs2Xml"%>
<%@page import="com.etn.sql.escape"%>

<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape"%>
<%@ page import="java.util.*"%>
<%@ page import="java.util.regex.Pattern"%>
<%@ page import="java.util.regex.Matcher"%>
<%@ page import="com.etn.asimina.data.LanguageFactory, com.etn.asimina.beans.Language" %>
<%@ include file="common2.jsp" %>
<%

  String formId = parseNull(request.getParameter("form_id"));
  String ruleId = parseNull(request.getParameter("rule_id"));
  String tId = parseNull(request.getParameter("tid"));
  String action = parseNull(request.getParameter("update_generic"));
  String postWorkId = parseNull(request.getParameter("post_work_id"));
  boolean alreadyCancelled = false;

  int row = 0;
  String query = "";
  String params = "";
  String values = "";
  String tableName = "";
  String requestParameterValue = "";
  String updateQuery = "";
  Pattern pattern = Pattern.compile("@@(.*)@@");
  Matcher matcher = null;
  int elementGroupOfFields = 1;

  query = "SELECT pf.form_id, table_name, db_column_name, name, pff.type, pff.group_of_fields FROM process_forms pf, process_form_fields pff WHERE pf.form_id = pff.form_id AND pf.form_id = " + escape.cote(formId) + " AND pff.rule_field != 1 AND name != ''";

  Set requestParameterRs = Etn.execute(query);

  if(requestParameterRs.next()) tableName = parseNull(requestParameterRs.value("table_name"));


  if(action.equals("update")){
    
    requestParameterRs.moveFirst();
    while(requestParameterRs.next()){
      
      tableName = parseNull(requestParameterRs.value("table_name"));
      requestParameterValue = "";
      elementGroupOfFields = parseNullInt(requestParameterRs.value("group_of_fields"));
      values = "";
      
      if(null!= request.getParameterValues(requestParameterRs.value("name")) && "multextfield".equalsIgnoreCase(parseNull(requestParameterRs.value("type")))){

        for(int i=0; elementGroupOfFields != 0 && i < request.getParameterValues(requestParameterRs.value("name")).length;){

          for(int j=0; j < elementGroupOfFields; j++){
   
            requestParameterValue += parseNull(request.getParameterValues(requestParameterRs.value("name"))[i++]);

            if( j != elementGroupOfFields-1 ) requestParameterValue += ";";
          }

          requestParameterValue += ",";

        }

        requestParameterValue = requestParameterValue.substring(0, requestParameterValue.length()-1);

      } else if(null != request.getParameterValues(requestParameterRs.value("name")) && request.getParameterValues(requestParameterRs.value("name")).length > 1) {
          
          for(int i=0; i < request.getParameterValues(requestParameterRs.value("name")).length; i++){
            
            requestParameterValue += request.getParameterValues(requestParameterRs.value("name"))[i];
            if( i != request.getParameterValues(requestParameterRs.value("name")).length-1 ) requestParameterValue += ";";
          }
      }
      else{
        requestParameterValue = parseNull(request.getParameter(requestParameterRs.value("name").replaceAll(" ", "_").toLowerCase()));
      }
      
      params = parseNull(requestParameterRs.value("db_column_name"));
      if(requestParameterValue.length() > 0){
        
        values = requestParameterValue;
      
        if("textdate".equalsIgnoreCase(parseNull(requestParameterRs.value("type"))))//its date
        {
            values = ItsDate.stamp(ItsDate.getDate(values)).substring(0,8);
        }
        else if("textdatetime".equalsIgnoreCase(parseNull(requestParameterRs.value("type"))))//its date
        {
            if(values.length() <= 16) values += ":00";
            values = ItsDate.stamp(ItsDate.getDate(values));
        }
      }

      if(parseNull(requestParameterRs.value("type")).equals("texthidden") && requestParameterValue.contains("@@")){

        matcher = pattern.matcher(requestParameterValue);
        if (matcher.find()) {

          values = requestParameterValue.substring(0, requestParameterValue.indexOf("@@")) + parseNull(request.getParameter(matcher.group(1))) + requestParameterValue.substring(requestParameterValue.lastIndexOf("@@")+2, requestParameterValue.length());
        }
      }

      updateQuery = "UPDATE " + tableName + " SET " + params + "=" + escape.cote(values) + " WHERE " + tableName + "_id = " + escape.cote(tId);

      row = Etn.executeCmd(updateQuery);
    }

  }

  String fromDialog = request.getParameter("fromDialog");

  if(fromDialog == null || fromDialog.equals("")) fromDialog = "false";

  Set rsUser = Etn.execute("select u.*, p.bannedPhases, p.profil from login u, profil p, profilperson pp where u.pid = pp.person_id and pp.profil_id = p.profil_id and u.pid = "+escape.cote(""+Etn.getId())+" ");

  rsUser.next();

  String userProfile = rsUser.value("profil");
  Map<String, List<String>> bannedPhases = new HashMap<String, List<String>>();

  boolean isStatusFound = false;

  Set rsStatus = Etn.execute("SELECT DISTINCT p.id, p.proces, p.phase, p.priority, p.attempt, p.errMessage, p.errCode, p.insertion_date,"
  + " p.operador,p.client_key,p.flag,p.nextid, ph.displayName, p.status pw_status, ph.oprType, ct.*"
  + " FROM post_work p, " + tableName + " ct, phases ph "
  + " WHERE p.client_key = ct." + tableName + "_id "
  + " AND p.proces = ph.process "
  + " AND p.phase = ph.phase "
  + " AND p.status in ('0','9') "
  + " AND p.client_key=" + escape.cote(tId)
  + " AND p.id = " + escape.cote(postWorkId)
  + " AND p.form_table_name = " + escape.cote(tableName)
  + " GROUP BY(client_key)");

  if(rsStatus.next()) isStatusFound = true;

  boolean showCancelButton = true;
  Set rsPhase = Etn.execute("select count(0) as c from phases where process = "+escape.cote(rsStatus.value("proces"))+" and phase in ('Cancel','Cancel30') ");

  rsPhase.next();

  if(Integer.parseInt(rsPhase.value("c")) == 0) showCancelButton = false;


  query = "select * from phases where phase = "+escape.cote(rsStatus.value("phase"))+" and process = "+escape.cote(rsStatus.value("proces"))+" ";

  rsPhase = Etn.execute(query);

  boolean showRulesButtons = false;

  if(rsPhase.next() && (rsPhase.value("rulesVisibleTo")).indexOf(userProfile) > -1) showRulesButtons = true;

  if(parseNull(rsPhase.value("oprType")).equals("T"))
  {
    showRulesButtons = false;
    showCancelButton = false;
  }

  if((userProfile).startsWith("SUPER_ADMIN") || (userProfile).equalsIgnoreCase("ADMIN")) showRulesButtons = true;

  Set rsRules = null;

  if(showRulesButtons)
  {
    query = "select distinct ph.phase,  ph.displayName, r.next_proc, r.next_phase, r.next_proc from rules r, phases ph where ph.oprType = 'O' and r.next_proc = ph.process and r.next_phase = ph.phase and start_phase = "+escape.cote(rsStatus.value("phase"))+" and start_proc = "+escape.cote(rsStatus.value("proces"))+" ";
    rsRules = Etn.execute(query);
    System.out.println(query);
  }

    if(rsStatus.value("phase").equalsIgnoreCase("Cancel") || rsStatus.value("phase").equalsIgnoreCase("Cancel30")) 
      alreadyCancelled = true;

  if(row > 0){
%>

    <script type="text/javascript">
      window.opener.location.href = window.opener.location;
      window.close();
    </script>

<%
  }

     query = "SELECT pff.*, pffd.* FROM process_form_fields pff, process_form_field_descriptions pffd, " + tableName + " WHERE pff.form_id = pffd.form_id and pff.field_id = pffd.field_id and pff.form_id = " + tableName + ".form_id AND " + tableName + "." + tableName + "_id = " + escape.cote(tId) + " AND pff.form_id = " + escape.cote(formId) + " AND field_type = ";
  
    String headerSectionQuery = query + escape.cote("hs") + " AND always_visible = " + escape.cote("1") + " AND (rule_field != " + escape.cote("1") + " OR field_type = " + escape.cote("hs") + ") ORDER BY seq_order;";
    String footerSectionQuery = query + escape.cote("fts") + " AND always_visible = " + escape.cote("1") + " AND (rule_field != " + escape.cote("1") + " OR field_type = " + escape.cote("fts") + ") ORDER BY seq_order;";
    
    String ruleSectionQuery = "SELECT name, pffd.label FROM process_form_fields pff, process_form_field_descriptions pffd WHERE pff.form_id = pffd.form_id AND pff.field_id = pffd.field_id AND pff.form_id = " + escape.cote(formId) + " AND field_type = " + escape.cote("rs") + " AND rule_field = " + escape.cote("1") + " ORDER BY seq_order;";


  Set headerSectionRs = Etn.execute(headerSectionQuery);
  Set footerSectionRs = Etn.execute(footerSectionQuery);
  Set ruleSectionRs = Etn.execute(ruleSectionQuery);
  String ruleSectionColumns = "";
  String ruleLabel = "";

  while(ruleSectionRs.next()){
    
    ruleSectionColumns += "COLUMN_GET(rule_combination, " + escape.cote(ruleSectionRs.value("name").replaceAll(" ", "_").toLowerCase()) + " as char) as " + ruleSectionRs.value("name").replaceAll(" ", "_").toLowerCase() + ",";
    ruleLabel += ruleSectionRs.value("label") + ",";
  }

  if(ruleSectionColumns.length() > 0){
    
    ruleSectionColumns = ruleSectionColumns.substring(0, ruleSectionColumns.length()-1);
    ruleLabel = ruleLabel.substring(0, ruleLabel.length()-1);

    ruleSectionRs = Etn.execute("SELECT " + ruleSectionColumns + " FROM process_rules WHERE form_id = " + escape.cote(formId) + " AND rule_id = " + escape.cote(ruleId));
  } 

   

  Set lineRs = Etn.execute("SELECT * FROM process_form_lines WHERE form_id = " + escape.cote(formId) + " ORDER BY CAST(line_seq as UNSIGNED);");
  String lineId = "";
  Set formSectionRs = null;

 

  Set actionsRs = Etn.execute("SELECT * FROM generic_actions ga, process_rules pr WHERE ga.group_id = pr.group_id AND pr.rule_id = " + escape.cote(ruleId) + " AND pr.form_id = " + escape.cote(formId));

  String ruleName = "";

  if(actionsRs.next()) ruleName = parseNull(actionsRs.value("rule_name"));

  String formTitle = "Form";
  String formClass = "";
  String formEnctype = "multipart/form-data charset=utf-8";
  String formWidth = "12";
  String formType = "";
  String langId = "";
  
  Set formRs = Etn.execute("SELECT * FROM process_forms WHERE form_id = " + escape.cote(formId));
  String lang = "";
  if(formRs.next()){
    lang = parseNull(request.getParameter("lang"));
    if(lang.length() == 0) 
      lang = com.etn.asimina.util.SiteHelper.getSiteLangs(Etn,parseNull(formRs.value("site_id"))).get(0).getCode();

    langId = LanguageFactory.instance.getLanguage(lang).getLanguageId(); 
    formTitle = parseNull(formRs.value("title"));
    formClass = parseNull(formRs.value("form_class"));
    formType = parseNull(formRs.value("type"));
    
    if(parseNull(formRs.value("form_enctype")).length() > 0)
      formEnctype = parseNull(formRs.value("form_enctype"));
    
    if(formRs.value("form_width").length() > 0)
      formWidth = formRs.value("form_width");
  } 

  formTitle = libelle_msg(Etn, request, formTitle);

  if(formType.equals("sign_up")) {
%>  
  <div class="row">  
    <div class="col-sm-6">

    <% if(rsStatus.value("pw_status").equals("0")) { %>
<!--         <span class="ml-5" onclick="onReverse('<%=rsStatus.value("client_key")%>','<%=rsStatus.value("client_key")%>',false,'<%=postWorkId%>')"><a href="#">Reverse</a></span>
 -->    <% } %>
    <% if(false && rsStatus.value("pw_status").equals("0")  && (userProfile.equals("ADMIN") || userProfile.startsWith("SUPER_ADMIN"))) { %>
      <% if(showCancelButton && !alreadyCancelled) { %>
        <span class="ml-3" onclick="onManualCancel('<%=rsStatus.value("client_key")%>','<%=rsStatus.value("client_key")%>')"><a href="#">Cancel</a></span>
      <% } %>
    <% } %>
    <% if(userProfile.equals("ADMIN") || userProfile.startsWith("SUPER_ADMIN")) { %>
        <span class="ml-3" onclick="onviewflow('<%=tId%>','<%=tableName%>')"><a href="#">View Process flow</a></span>
    <% } %>                   

    <% if(rsStatus.value("pw_status").equals("0")  && rsRules != null) {
        int index = 0;
        boolean separatorShown = false;
        while(rsRules.next()) {
          List<String> banned = bannedPhases.get(rsRules.value("next_proc"));
          if(banned != null && banned.contains(rsRules.value("next_phase"))) continue;
    %>
        <%  String buttonLabel = rsRules.value("displayName");
          boolean showTooltip = false;
          if( buttonLabel.length() > 30)
          {
            buttonLabel = buttonLabel.substring(0,29) + "..";
            showTooltip = true;
          }
        %>
          <% if(!separatorShown) {
            separatorShown = true;
          %>

            <span class="dropdown show ml-3">
              <a class="btn btn-primary dropdown-toggle" href="#" role="button" id="dropdownMenuLink" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
              Change Phase
              </a>

              <div class="dropdown-menu" aria-labelledby="dropdownMenuLink">
  
          <% } %>

                <a class="dropdown-item" id="<%=index%>_button" <%if(showTooltip){%>onmouseover="showToolTip('<%=index%>_button', '<%=rsRules.value("displayName")%>')" <%}%> onclick="onChangePhaseBtn('<%=rsStatus.value("client_key")%>','<%=rsStatus.value("proces")%>','<%=rsStatus.value("phase")%>','<%=rsRules.value("next_proc")%>','<%=rsRules.value("next_phase")%>','<%=fromDialog%>','<%=postWorkId%>');" href="#"><%=buttonLabel%></a>

    <%
          index++;
        }
                                if(separatorShown) {
                                %>
  </div>
</span>
                                <% }
    }
%>

    </div>
    <div class="col-sm-6">
      <div class="float-right" style="padding-right: 2.0rem;" role="group">
        <button type="button" class="btn btn-danger" id="saveBtn" onclick='deleteReply("<%=tId%>","<%=tableName%>");'>Delete</button>
      </div>    
    </div>
  </div>
  <hr style="width: 95%;" />

<%
  }
%>

  <div class="fluid-container">

      <form id="demand_form" enctype="<%=formEnctype%>" class="<%=formClass%> col-<%=formWidth%>">

<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12" style="text-align: center; margin-top: 20px;">

  <input type="hidden"  name="update_generic" value="update">
  <input type="hidden" name="form_id" id="form_id" value="<%= formId%>" />
  <input type="hidden" name="table_id" id="table_id" value="<%= tId%>" />
  <input type="hidden" id="appcontext" value="<%=request.getContextPath()%>/" />
  <input type="hidden" id="largeFileMsg" value="<%=escapeCoteValue(libelle_msg(Etn, request, "File is too large. Choose another file."))%>" />
  <input type="hidden" id="largeImageMsg" value="<%=escapeCoteValue(libelle_msg(Etn, request, "Image is too large. Choose another image."))%>" />

</div> 

  <%
      if(headerSectionRs.rs.Rows > 0){
  %>
          <div class="container form-horizontal header_section">
            <div>
              <label style="font-weight: bold;"> Header section </label>
            </div>
            <div style="height: inherit;" class="row first-row">
              <%
                out.write(loadDynamicsSection(Etn, request, headerSectionRs, null, null, null, "header_section", "1", formId, ruleId, "frontendcall", "", langId));
              %>
            </div>
          </div>
  <%
      }

      String[] token = null;
      if(ruleSectionRs.rs.Rows > 0){
  %>

          <div class="container form-horizontal rule_section">
            
            <div>
              <label style="font-weight: bold;"> Rule section </label>
            </div>
            <div class="__apply_rule_screen row"> 
        <%
          token = ruleLabel.split(",");

          if(ruleSectionRs.next()){

            for(int i=0; i < token.length; i++){
              if(ruleSectionRs.value(i).length() > 0){
        %>
                <div class="col-sm-6">
                  <div class="form-group">
                    <label class="col-sm-4 control-label"><%= token[i]%></label>
                    <div class="col-sm-6">
                      <label style="color: black;" class="control-label"><%= ruleSectionRs.value(i)%></label>
                    </div>
                  </div>
                </div>
        <%

              }
            }
          }
        %>
            </div>

          </div>
  <%
      }

        if(ruleName.length() > 0){
      %>
          <label>Rule name:</label> 
          <label id="selected_rule_name" style="font-size: 15px; padding-bottom: 10px; padding-top: 10px; height:60px; font-weight: bold;" >  <%= ruleName%> </label>
      <%
        }

        if(lineRs.rs.Rows > 0){
  %>

<!--           <div class="__apply_dynamic_fields"> 
        
            <div class="row">
 -->

  <%
        while(lineRs.next()){

          lineId = parseNull(lineRs.value("id"));

          query = "SELECT " + tableName + ".*, ( SELECT pf.process_name FROM process_forms pf WHERE pf.form_id = pff.form_id ) as process_name, pff.id as _etn_id, pff.field_id as _etn_field_id, pff.label_id as _etn_label_id, pff.form_id as _etn_form_id, pff.field_type as _etn_field_type, db_column_name as _etn_db_column_name, file_extension as _etn_file_extension, pffd.label as _etn_label, font_weight as _etn_font_weight, font_size as _etn_font_size, color as _etn_color, pffd.placeholder as _etn_placeholder, pff.name as _etn_field_name, COALESCE(prf.value, pffd.value) as _etn_value, pffd.value as default_value, maxlength as _etn_maxlength, COALESCE(prf.required, pff.required) as _etn_required, rule_field as _etn_rule_field, COALESCE(prf.add_no_of_days, pff.add_no_of_days) as _etn_add_no_of_days, COALESCE(prf.start_time, pff.start_time) as _etn_start_time, COALESCE(prf.end_time, pff.end_time) as _etn_end_time, COALESCE(prf.time_slice, pff.time_slice) as _etn_time_slice, COALESCE(prf.default_time_value, pff.default_time_value) as _etn_default_time_value, autocomplete_char_after as _etn_autocomplete_char_after, element_autocomplete_query as _etn_element_autocomplete_query, COALESCE(prf.element_trigger, pff.element_trigger) as _etn_element_trigger, pffd.label as _etn_label_name, element_option_class as _etn_element_option_class, element_option_others as _etn_element_option_others, COALESCE(prf.element_option_query, pff.element_option_query) as _etn_element_option_query, COALESCE(prf.element_option_query_value, pffd.option_query) as _etn_element_option_query_value, pff.group_of_fields as _etn_group_of_fields, pff.type as _etn_type, resizable_col_class as _etn_resizable_col_class, pffd.options as _etn_options, pff.img_width as _etn_img_width, pff.img_height as _etn_img_height, pff.img_alt as _etn_img_alt, pff.img_murl as _etn_img_murl, pff.href_chckbx as _etn_href_chckbx, pffd.err_msg as _etn_err_msg, pff.href_target as _etn_href_target, pff.img_href_url as _etn_img_href_url, pff.site_key as _etn_site_key, pff.theme as _etn_theme, pff.recaptcha_data_size as _etn_recaptcha_data_size, btn_id as _etn_btn_id, container_bkcolor as _etn_container_bkcolor, text_align as _etn_text_align, text_border as _etn_text_border, custom_css as _etn_custom_css, pff.img_url as _etn_img_url, pff.hidden as _etn_hidden_field FROM process_form_fields pff LEFT OUTER JOIN (process_rules pr, process_rule_fields prf) ON pr.form_id = pff.form_id AND pr.rule_id = prf.rule_id AND prf.field_id = pff.field_id AND pr.rule_id = " + escape.cote(ruleId) + ", process_form_field_descriptions pffd, " + tableName + " WHERE pff.form_id = " + tableName + ".form_id AND pff.form_id = " + escape.cote(formId) + " AND " + tableName + "." + tableName + "_id = " + escape.cote(tId) + " AND pff.form_id = pffd.form_id AND pff.field_id = pffd.field_id AND pffd.langue_id = " + escape.cote(langId) + " AND pff.line_id = " + escape.cote(lineId) + " AND pff.type != " + escape.cote("button") + " AND CASE WHEN ISNULL(prf.id) THEN always_visible ELSE 1 END = 1 AND pff.field_type IN ( " + escape.cote("fs") + ", \"\") ORDER BY seq_order, pff.id";

          formSectionRs = Etn.execute(query);
      %>
          <div id='<%=parseNull(lineRs.value("line_id"))%>' class='col-sm-<%=parseNull(lineRs.value("line_width"))%> <%=parseNull(lineRs.value("line_class"))%>'>        

            <div class='row dynamic_line_fields'>
      <%
            if(null != formSectionRs && formSectionRs.rs.Rows > 0) {

              out.write(loadDynamicsSection(Etn, request, formSectionRs, null, null, null, "rule_section", "1", formId, ruleId, "frontendcall", "", langId));

            }
            else out.write("");
      %>

            </div>
          </div>

      <%
        }
      %>                
<!--             </div>
          </div>
 -->  <%
        }

        if(footerSectionRs.rs.Rows > 0){
  %>
          <div class="container form-horizontal footer_section">
            <label style="font-weight: bold;"> Footer section </label>
            <div style="height: inherit;" class="row first-row">
              <%
                out.write(loadDynamicsSection(Etn, request, footerSectionRs, null, null, null, "footer_section", "1", formId, ruleId, "frontendcall", "", langId));
              %>
            </div>
          </div>
  <%
        }

  %>
     
  </div>
  
  <div role="tabpanel" id="Technical_data" class="tab-pane fade d-none">
        
        <label style="font-weight: bold;">Actions</label>  
        <div class="container form-horizontal">
          <table class="table table-striped">
            <tr>
              <th>Equipement</th>
              <th>Action</th>
              <th>N°Swan</th>
              <th>Statut</th>
              <th>Données Techniques</th>
            </tr>
          <%

            String equipement = "";
            String actionType = "";
            String actionStatus = "";
            String swan = "";
            String shareLink = "";

            while(actionsRs.next()){
              
              equipement = parseNull(actionsRs.value("equipement"));
              actionType = parseNull(actionsRs.value("type_action"));
              shareLink = parseNull(actionsRs.value("share_link"));
              
              if(actionType.equals("SWAN")){
  
                swan = parseNull(actionsRs.value("swan_" + equipement.toLowerCase()));
                actionStatus = parseNull(actionsRs.value("status_swan_"+equipement.toLowerCase()));
    
              } else if(actionType.equalsIgnoreCase("email")){

                swan = parseNull(actionsRs.value("mail"));
                actionStatus = "Mail envoyeé :" + parseNull(actionsRs.value("mail_to"));

              } else actionStatus = "Link";
              

          %>
              <tr>
                <td><%= equipement%></td>
                <td><%= actionType%></td>
                <td><%= swan%></td>
                <td><%= actionStatus%></td>
                <td>
                    <%
                        if(shareLink.length()>0){
                          if(!shareLink.contains("https")) shareLink = "https://" + shareLink;
                          if(!shareLink.contains("http")) shareLink = "http://" + shareLink;
                    %>
                          <a style="cursor: pointer;" href="<%=shareLink%>" target="_blank">Do</a>
                    <%
                        }
                    %>
                </td>
              </tr>
          <%
            }
          %>
          </table>
        </div>

        <label style="font-weight: bold;">Rules</label>  
        <div class="container form-horizontal">
        <%

          StringBuffer html = new StringBuffer();
          params = "";
          String ruleColumns = "";
          int ruleColumnCount = 0;
          String elementOptions = "";
          String elementOptionQueryValue = "";
          String elementType = "";
          String elementName = "";
          token = null;
          String[] innerToken = null;

          Set loadRuleFormTemplateRs = Etn.execute("SELECT label_id, name, pffd.label, required, rule_field, pff.type, db_column_name, option_query, options FROM process_forms pf, process_form_fields pff, process_form_field_descriptions pffd WHERE pf.form_id = pff.form_id AND pff.form_id = pffd.form_id AND pff.field_id = pffd.field_id AND pf.form_id = " + escape.cote(formId) + " AND pff.rule_field = " + escape.cote("1") + " ORDER BY 1;");


          String jsonGenericProcess = "";

          while(loadRuleFormTemplateRs.next()){
              
            ruleColumnCount++;
            ruleColumns += parseNull(loadRuleFormTemplateRs.value("db_column_name")) + ",";

            params += "COLUMN_GET(rule_combination, " + escape.cote(parseNull(loadRuleFormTemplateRs.value("name")).replaceAll(" ", "_").toLowerCase()) + " as char) as " + parseNull(loadRuleFormTemplateRs.value("name")).replaceAll(" ", "_").toLowerCase() + ",";
          }

          if(params.length() > 0) params = params.substring(0, params.length()-1);
          if(ruleColumns.length() > 0) ruleColumns = "," + ruleColumns.substring(0, ruleColumns.length()-1);

        %>
              <table class='table table-striped'>
              <tr>
              
              <th style='text-align: center;'>Group id</th>
              <th style='text-align: center;'>Rule name <span style='color: red;'>*</span></th>
        <%
              loadRuleFormTemplateRs.moveFirst();
              while(loadRuleFormTemplateRs.next()){
        %>
                <th style='text-align: center;'> <%= parseNull(loadRuleFormTemplateRs.value("label"))%> </th>
        <%
              }
        %>
              </tr>
        <%              
//              Set ruleCombinationListRs = Etn.execute("SELECT form_id, rule_id, group_id, rule_name, " + params + " FROM process_rules WHERE form_id = " + escape.cote(formId) + " ORDER BY group_id;");

              Set ruleCombinationListRs = Etn.execute("SELECT pr.rule_name, pr.group_id " + ruleColumns + " FROM " + tableName + " dt, process_rules pr WHERE pr.rule_id = dt.rule_id AND pr.form_id = dt.form_id AND " + tableName + "_id = " + escape.cote(tId) + " AND dt.form_id = " + escape.cote(formId) + " AND dt.rule_id = " + escape.cote(ruleId));

              if(ruleCombinationListRs.rs.Rows == 0){
        %>        
                <tr>
        <%
                ruleColumnCount += 2;
                for(int i=0; i < ruleColumnCount; i++){

                  
                  if(((ruleColumnCount)/2) == i) {
        %>
                    <td>No rule found.</td>
        <%
                  }
                  else {
        %>
                    <td>&nbsp;</td>
        <%
                  }
                }
        %>
                </tr>
        <%                
              }

              while(ruleCombinationListRs.next()){
        %>
                <tr>

                <td style='cursor: pointer; text-align: center;'> <%= parseNull(ruleCombinationListRs.value("group_id"))%> </td>
                <td style='text-align: center;'> <%= parseNull(ruleCombinationListRs.value("rule_name"))%> </td>
        <%
                loadRuleFormTemplateRs.moveFirst();
                while(loadRuleFormTemplateRs.next()){
        %>
                    <td style='text-align: center;'>
                    <%= parseNull(ruleCombinationListRs.value(parseNull(loadRuleFormTemplateRs.value("db_column_name"))))%>
                    </td>
        <%                    
                }
        %>
                </tr>
        <%
              }
        %>
              </table>
        </div>


      </form>

    <div id="fw_container" style=""></div>
  </div>

<div id="dialogtextaera" title="" style="font-weight:bold;font-size:11pt;font-family:arial;display: none;"></div>
</div>