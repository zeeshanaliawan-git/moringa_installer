<%@page import="com.etn.beans.Contexte"%>
<%@page import="com.etn.lang.Xml.Rs2Xml"%>
<%@page import="com.etn.sql.escape"%>

<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.*"%>

<%!

  String parseNull(String str) {
    String s = null;
    try {
      s = str.trim();
      if (s.length() == 0)
        s = "";
    } catch (Exception e) {
      s = "";
    }
    return s;
  }

%>
<!DOCTYPE html>
<html>
<head>
  <title></title>

  <meta charset="UTF-8"/>
  <meta http-equiv="X-UA-Compatible" content="IE=edge">

  <link type="text/css" rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap.min.css">

  <script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
  <script src="<%=request.getContextPath()%>/js/flatpickr.min.js"></script>
  <script src="<%=request.getContextPath()%>/js/html_form_template.js"></script>

  <script type="text/javascript">
    
    var value = "";   

    function load_rule_form_template(){
      
      value = $("#rule_form_list").val();
      if(value != ""){

          $.ajax({
              url : 'ajax/backendAjaxCallHandler.jsp',
              type: 'POST',
              dataType: 'JSON',
              data: {
                "action": 'load_rule_selected_form_template',
                "form_id": value
              },
              success : function(response) {

                var ruleColumns = "";

                for(var i=0; i < response.json_generic_process.length; i++){

                  ruleColumns += response.json_generic_process[i];
                  if(i != response.json_generic_process.length-1) ruleColumns += ",";
                }

                $("#list_rule_columns").val(ruleColumns);
                $("#rule_combination_form").css("display", "block");
                $("#selected_form_id").val(value);
            $("#rule_combination_list").html(response.json_combination_rules);
              }
          });
      }
    }

    function add_rule_combination(){

      var flag = false;
      $('#rule_combination_list select[required], input[required]').each(function(){

        if($(this).val().length==0 && !flag){

          alert("kindly fill the required field.");
          $(this).focus();
          flag = true;
        }

      });

      if(!flag) $("#rule_combination_form").submit();
    }

    function formFieldMapping(formId, ruleId){
      
      var propriete = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
      propriete += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
      propriete += ",width=1250" + ",height=800"; 
      win = window.open($("#form_fields_url").val() + "?form_id=" + formId + "&rule_id=" + ruleId, "Mapping the fields", propriete);
      win.focus();
    }

    setTimeout(function(){

      value = $("#rule_form_list").val();
      if(value != "") load_rule_form_template();

    }, 200);

  </script>

</head>
<body>

<%
    
    String groupId = parseNull(request.getParameter("group_id"));

    Set actionRs = Etn.execute("SELECT * FROM action_types ORDER BY 1;");
    Set equipementRs = Etn.execute("SELECT * FROM equipement ORDER BY ordre;");
%>

  <div class="page etn-orange-portal--">    
    <main id="mainFormDiv">
        <div class="container-fluid">
          <div id="create_form_template" class="row">
            <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
              <h1 style="text-align: center;">Action Screen</h1>
            </div>
          </div>

          <form id="action_rule" method="post" class="form-horizontal" role="form">
            <div class="row" style="margin-top: 20px;">
              <div class="col-sm-6">
                <div class="form-group">
                    <label class="col-sm-3 control-label">Action: <span style='color: red;'>*</span></label>      
                    <div class="col-sm-9">
      
                      <select onfocusout="activeShareLink(this);" id="action_type" name="action_type" class="form-control" multiple> 
                      <%  
                          while(actionRs.next()){
                      %>
                              <option value='<%=actionRs.value("action_name")%>'><%=actionRs.value("action_name")%></option>
                      <%
                          }                        
                      %>          
                      </select>
                      
                    </div>
                </div>
              </div>
            </div>
            <div class="row">
              
              <div class="col-sm-6">
                
                <div class="form-group">
      
                    <label class="col-sm-3 control-label">Equipement: <span style='color: red;'>*</span></label>      
      
                    <div class="col-sm-9">
      
                      <select id="equipement" name="equipement" class="form-control"> 
                          <option value="">---select---</option>
                      <%  
                          while(equipementRs.next()){
                      %>
                              <option value='<%=equipementRs.value("libelle")%>'><%=equipementRs.value("libelle")%></option>
                      <%
                          }                        
                      %>          
                      </select>
                      
                    </div>
                </div>

              </div>          

              <div class="col-sm-6">

                <div class="form-group">
                    <label class="col-sm-3 control-label">Idmodel: </label>      
                    <div class="col-sm-9">
                      <input type="textfield" name="idmodel" class="form-control" value="">
                    </div>
                </div>
              </div>
            </div>
            <div class="row">
              
              <div class="col-sm-6">
                
                <div class="form-group">
                    <label class="col-sm-3 control-label">Ident: </label>      
                    <div class="col-sm-9">
                      <input type="textfield" name="ident" class="form-control" value="">
                    </div>
                </div>
              </div> 

              <div class="col-sm-6">

                <div class="form-group">
                    <label class="col-sm-3 control-label">Test todo: </label>      
                    <div class="col-sm-9">
                      <input type="textfield" name="test_todo" class="form-control" value="">
                    </div>
                </div>
              </div>
            </div>

            <div class="row">
              <div class="col-sm-12 text-center">
                    <button type="button" name="save_action" class="btn btn-default" onclick="addActionRule();">Save</button>
                    <input type="hidden" id="group_id" name="group_id" value="<%=groupId%>">            
              </div>
            </div>
          </form>
        </div> 
      </main>


  </div>

</body>
</html>