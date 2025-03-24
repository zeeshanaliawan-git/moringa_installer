<%@page import="com.etn.beans.Contexte"%>
<%@page import="com.etn.lang.Xml.Rs2Xml"%>
<%@page import="com.etn.sql.escape"%>

<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>

<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
int screenNumber = 2;
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape"%>
<%@ page import="java.util.*"%>
<%@ page import="org.json.*"%>
<%@ include file="../common2.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head> 
<title>Orange -  NOE</title>


<link type="text/css" rel="stylesheet" href="<%=request.getContextPath()%>/css/jquery.min.css">
<link type="text/css" rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap.min.css">

<!-- Resource style -->
<script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
<script type="text/javascript" src="js/bootstrap.min.js"></script>
<script type="text/javascript" src="js/html_form_template.js"></script>

<script src="<%=request.getContextPath()%>/js/flatpickr.min.js"></script>

<script type="text/javascript">
  
  function move_selected_form_field(){

    $.ajax({
      url : "ajax/backendAjaxCallHandler.jsp",
      type: 'POST',
      data : {
        action : "getMappedFormFields", 
        form_id : $("#form_id").val(),
        rule_id : $("#rule_id").val(),
        selectedFields : $("#selected_fields").val()
      },
      dataType : 'HTML',
      success : function(response)
      {
        window.location = "mappingFields.jsp?form_id="+$("#form_id").val()+"&rule_id="+$("#rule_id").val();
      },
      error : function()
      {
        alert("Some error occurred while communicating with the server");
      }
    });
    
  }

  function deleteMappedFormFields(mappedFieldId){

    if(!confirm("Are you sure to remove the mapped field?")) return false;

    $.ajax({
      url : "ajax/backendAjaxCallHandler.jsp",
      type: 'POST',
      data : {
      action : "deleteMappedFormField", 
      mapped_field_id : mappedFieldId
    },
    dataType : 'HTML',
    success : function(response)
    {   
      window.location = "mappingFields.jsp?form_id="+$("#form_id").val()+"&rule_id="+$("#rule_id").val();
    },
    error : function()
    {
      alert("Some error occurred while communicating with the server");
    }
    });
  }


  function updateFieldValue(element){

    if($(element).prop("checked")) $(element).siblings().val("1");
    else $(element).siblings().val("0");
  }

  function select_mapping_date_caldr(element){

    if($(element).val()=='s'){

      $(element).next().children(":first-child").attr("value","");
      $(element).next().css("display","block");
      $(element).next().children(":first-child").attr("type","text");

    } else if($(element).val()=='today'){

      $(element).next().children(":first-child").attr("type","hidden");
      $(element).next().css("display","none");
      $(element).next().children(":first-child").attr("value","today");
//      $(elementId).next().children().attr("value","today");

    } else {

      $(element).next().attr("type","hidden");
      $(element).next().next().css("display","none");
      $(element).next().children(":first-child").attr("value","");
//      $(elementId).next().children().attr("value","");
    }
  }

  function select_datetime_caldr(element){

    if($(element).val()=='s'){

      $(element).next().children(":first-child").attr("value","");
      $(element).siblings().css("display","block");

    } else if($(element).val()=='today'){

      $(element).next().children(":first-child").attr("value","today");
      $(element).siblings().css("display","none");
  
    }else {

      $(element).next().children(":first-child").attr("value","");
      $(element).siblings().css("display","none");
    }
  }

  function update_mapping_form_field(){

    $('.dropdown-menu').each(function(){

      var options = "";
      var values = "";
      i = 0;

      $(this).find('a input').each(function(){

        if($(this).is(":checked")){
          
          values += "\"" + $(this).val().trim() + "\",";
          options += "\"" + $(this).parent().attr("data-value").trim() + "\",";
        } 

      });

      options = options.substring(0, options.length-1);
      values = values.substring(0, values.length-1);
      console.log("{\"val\":[" + values + "],\"txt\":[" + options + "]}");
      $(this).next().val("{\"val\":[" + values + "],\"txt\":[" + options + "]}");

    });

    $("#mappedFields").submit();
  }

  $(document).ready(function(){

    $('#mapped_fields tbody.sortable').sortable({
      
      axis : "y",
      forcePlaceholderSize: true,
      helper : function(event,element){

      var clone = element.clone(true);

      var origTdList = $(element).find('>td');
      var cloneTdList = $(clone).find('>td');

      for (var i = 0; i < cloneTdList.length; i++) {
        $(cloneTdList[i]).outerWidth($(origTdList[i]).outerWidth());
      }

      // alert(origTdList.length + " " + cloneTdList.length);

      return clone;
      },
      update : function(event,ui){
      setRowOrder();
      orderingchanged = true;
      },
    });

    setRowOrder = function(){

      $('#mapped_fields tbody tr').each(function(i,tr){
      
        $(tr).find('.order_seq').prop('readonly',false);
        $(tr).find('.order_seq').val(i+1);
        $(tr).find('.order_seq').prop('readonly',true);
      });
    };
  });

  setTimeout(function(){
    
    update_default_time = function (fid){

      flatpickr("#" + fid + "_default_time", {
          enableTime: true,
          noCalendar: true,
          dateFormat: "H:i",
          defaultDate: "00:00",
          time_24hr: true,
          minuteIncrement: parseInt($("#" + fid + "_time_slice").val()),
          minTime: $("#" + fid + "_start_time").val(),
          maxTime: $("#" + fid + "_end_time").val()
      });

    }
    
    flatpickr("._daterange", {
        mode: "range",
        dateFormat: "Y-m-d"
    });

    flatpickr("._timerange", {
        enableTime: true,
        noCalendar: true,
        dateFormat: "H:i",
        time_24hr: true
    });


    flatpickr("._starttime", {
        enableTime: true,
        noCalendar: true,
        dateFormat: "H:i",
        defaultDate: "00:00",
        time_24hr: true,
        minuteIncrement: 60
    });


    flatpickr("._endtime", {
        enableTime: true,
        noCalendar: true,
        dateFormat: "H:i",
        defaultDate: "23:00",
        time_24hr: true,
        minuteIncrement: 60,
        minTime: jQuery('._starttime').val()?jQuery('._starttime').val():false
    });


  }, 1000);

</script>

</head>

<%

    String fieldIds[] = request.getParameterValues("mapped_field_id");
    String requiredFields[] = request.getParameterValues("field_required");
    String defaultValues[] = request.getParameterValues("default_value");
    String optionSelected[] = request.getParameterValues("option_selected");
    String elementTriggerEvent[] = request.getParameterValues("element_trigger_value");
    String elementTriggerEventQuery[] = request.getParameterValues("element_trigger_query_value");
    String elementTriggerEventJs[] = request.getParameterValues("element_trigger_js_value");
    String formId = parseNull(request.getParameter("form_id"));
    String ruleId = parseNull(request.getParameter("rule_id"));
    String updateQuery = "";
    String defaultTime = "";
    String defaultStartTime = "";
    String defaultEndTime = "";
    String defaultTimeSlice = "";
    String adjustDays = "";

    String triggerElementjson = "";
    String triggerElement = "";
    String elementTriggerQuery = "";
    String elementTriggerJs = "";
    String triggerEventValue = "";
    String triggerQueryValue = "";
    String triggerJsValue = "";
    String[] triggerElementToken = null;
    String[] triggerQueryToken = null;
    String[] triggerJsToken = null;

    if(null != fieldIds && fieldIds.length > 0){
      
      for(int i=0; i < requiredFields.length; i++){
        
        defaultTime = parseNull(request.getParameter(fieldIds[i]+"_default_time"));
        defaultStartTime = parseNull(request.getParameter(fieldIds[i]+"_default_start_time"));
        defaultEndTime = parseNull(request.getParameter(fieldIds[i]+"_default_end_time"));
        defaultTimeSlice = parseNull(request.getParameter(fieldIds[i]+"_default_time_slice"));
        adjustDays = parseNull(request.getParameter(fieldIds[i]+"_adjust_days")); 
        triggerElementjson = "";

        triggerElement = elementTriggerEvent[i];
        elementTriggerQuery = elementTriggerEventQuery[i];
        elementTriggerJs = elementTriggerEventJs[i];

        if(triggerElement.length() > 0){

          triggerElementToken = triggerElement.split(",");
          triggerQueryToken = elementTriggerQuery.split("!@##@!");
          triggerJsToken = elementTriggerJs.split("!@##@!");
          
          triggerEventValue = "";
          triggerQueryValue = "";
          triggerJsValue = "";

          for(int j=0; j < triggerElementToken.length; j++){
            
            triggerEventValue += "\"" + triggerElementToken[j] + "\"";
            triggerQueryValue += "\"" + escapeCoteValue(triggerQueryToken[j]) + "\"";
            triggerJsValue += "\"" + escapeCoteValue(triggerJsToken[j]) + "\"";
           
            if(j != (triggerElementToken.length)-1){
              triggerEventValue += ",";
              triggerQueryValue += ",";
              triggerJsValue += ",";
            }
          }

          if(triggerElementToken.length > 0) {

            triggerElementjson = "{";
            triggerElementjson += "\"query\":[" + triggerQueryValue + "],";
            triggerElementjson += "\"js\":[" + triggerJsValue + "],";
            triggerElementjson += "\"event\":[" + triggerEventValue + "]";
            triggerElementjson += "}";
          }
        }

        updateQuery = "UPDATE process_rule_fields SET value = " + escape.cote(defaultValues[i]) + ", required = " + escape.cote(requiredFields[i]) + ", default_time_value = " + escape.cote(defaultTime) + ", start_time = " + escape.cote(defaultStartTime) + ", end_time = " + escape.cote(defaultEndTime) + ", time_slice = " + escape.cote(defaultTimeSlice) + ", add_no_of_days = " + escape.cote(adjustDays) + ", options = " + escape.cote(optionSelected[i]) + ", element_trigger = " + elementTriggerCote(triggerElementjson) + " WHERE rule_id = " + escape.cote(ruleId) + " AND field_id = " + escape.cote(fieldIds[i]) + ";";

        Etn.execute(updateQuery);
      }
    }

    Set genericFormFieldProcessRs = Etn.execute("SELECT label_id, field_id, field_type, label, label_id, rule_field, always_visible FROM process_form_fields WHERE form_id = " + escape.cote(formId) + " AND field_type IN ( " + escape.cote("fs") + ", " + escape.cote("rs") + " ) AND rule_field != " + escape.cote("1") + " AND type NOT IN ('label', 'hr_line') ORDER BY 1;");

    String query = "SELECT prf.*, pff.options as available_options FROM (process_rule_fields prf, process_rules pr) LEFT OUTER JOIN process_form_fields pff ON pff.form_id = pr.form_id AND pff.field_id = prf.field_id WHERE pr.rule_id = prf.rule_id AND pr.rule_id = " + escape.cote(ruleId);

    Set genericFormMappedFieldRs = Etn.execute(query);

    String elementFieldId = "";

    while(genericFormMappedFieldRs.next()){
      
      elementFieldId += genericFormMappedFieldRs.value("field_id") + ",";
    }

    if(elementFieldId.length() > 0) elementFieldId = elementFieldId.substring(0, elementFieldId.length()-1);

try{
%>

<body style="width: 100%;">

  <div class="container" style="width: 1250px;">
    <div class="col-sm-2"> 
      <div style="margin-top: 5px;">
        <table cellspacing=0 cellpadding=0 border=0 class="resultat" width="100%">
          <tr>
            <td>                      
              <input type="hidden" id="form_id" value="<%=escapeCoteValue(formId)%>">
              <input type="hidden" id="rule_id" value="<%=escapeCoteValue(ruleId)%>">
              <span style="font-weight: bold;">Note: Green fields are always visible on the demand screen. </span>
              <select name="selected_fields" id="selected_fields" multiple="" style="margin-top: 43px;height:540px; width: 100%;">
                <%
                    while(genericFormFieldProcessRs.next()){

                        if(!elementFieldId.contains(genericFormFieldProcessRs.value("field_id"))){
                        
                %>
                          <option <% if(parseNull(genericFormFieldProcessRs.value("always_visible")).equals("1")){ %> style="color: #1fb71f; font-weight: bold;" <% } %> value='<%=escapeCoteValue(genericFormFieldProcessRs.value("label_id"))%>'><%=escapeCoteValue(genericFormFieldProcessRs.value("label"))%></option>

                <%
                        }
                      }
                %>
              </select>                 
            </td>
          </tr>
        </table>
      </div>
    </div>
    
    <div style="width: 2%; float: left; margin-top: 290px;" class="col-sm-1">
      <span style="cursor: pointer; font-size: x-large;" class="glyphicon glyphicon-arrow-right" onclick="move_selected_form_field();"></span>
    </div>
    
    <form id="mappedFields" method="POST" action="mappingFields.jsp?form_id=<%=formId%>&rule_id=<%=ruleId%>">

      <div id="selected_fields_rsp" style="margin-top: 10px; border: 1px solid #ccc; display: none; margin-left: 20px;" class="col-sm-9"> </div>

      <div class="col-sm-9" style="text-align: center; margin-top: 5px; font-size: 20px;">
        <label>Mapped Fields</label>
      </div>

      <div id="mapped_fields_rsp" style="margin-top: 10px; border: 1px solid #ccc; margin-left: 20px;" class="col-sm-9">

    <%

        out.write("<div> <table id=\"mapped_fields\" style=\"cursor: move;\" class=\"table table-striped\"> <thead><tr>");
        out.write("<th style=\"font-weight: bold;\"> Field name </th> <th style=\"font-weight: bold;\"> Default value </th> <th style=\"font-weight: bold;\"> Element trigger </th> <th style=\"font-weight: bold;\"> Required </th> <th style=\"font-weight: bold;\"> Delete </th>");
        out.write("</tr></thead><tbody class=\"sortable ui-sortable\">");

        if(genericFormMappedFieldRs.rs.Rows == 0){
          out.write("<tr><td></td><td></td><td></td><td>No mapping found.</td><td></td><td></td></tr>");
        }

        String elementId = "";
        String elementType = "";
        String fieldType = "";
        String label = "";
        String required = "";
        String requiredGenericForm = "";
        String defaultValue = "";
        String startTime = "";
        String endTime = "";
        String sliceTime = "";
        String defaultTimeValue = "";
        String addNoOfDays = "";
        String elementTrigger = "";
        String elementTriggerEnt = "";
        elementTriggerQuery = "";
        elementTriggerJs = "";
        String selectedOptions = "";
        String availableOptions = "";
        String optionQueryValue = "";
        String queryValues = "";
        String queryLabels = "";
        String elementQueryValue = "";
        String elementJsValue = "";

        JSONObject elementTriggerObject = null;
        JSONArray elementTriggerQueryArray = null;
        JSONArray elementTriggerJsArray = null;
        JSONArray elementTriggerEventArray = null;

        JSONObject optionsJson = null;
        JSONArray optionTxtArray = null;

        JSONObject availableOptionsJson = null;
        JSONArray availableOptionTxtArray = null;

        List<Object> list = null;
        Iterator itr = null; 
        Map<String, Object> map = null;

        genericFormMappedFieldRs.moveFirst();
        while(genericFormMappedFieldRs.next()) {
          
          elementId = parseNull(genericFormMappedFieldRs.value("id"));
          elementFieldId = parseNull(genericFormMappedFieldRs.value("field_id"));
          elementType = parseNull(genericFormMappedFieldRs.value("type"));
          fieldType = parseNull(genericFormMappedFieldRs.value("field_type"));
          label = parseNull(genericFormMappedFieldRs.value("label"));
          required = parseNull(genericFormMappedFieldRs.value("required"));
          requiredGenericForm = parseNull(genericFormMappedFieldRs.value("required_generic_form"));
          
          defaultValue = parseNull(genericFormMappedFieldRs.value("value"));
          startTime = parseNull(genericFormMappedFieldRs.value("start_time"));
          endTime = parseNull(genericFormMappedFieldRs.value("end_time"));
          sliceTime = parseNull(genericFormMappedFieldRs.value("time_slice"));
          defaultTimeValue = parseNull(genericFormMappedFieldRs.value("default_time_value"));
          addNoOfDays = parseNull(genericFormMappedFieldRs.value("add_no_of_days"));
          selectedOptions = parseNull(genericFormMappedFieldRs.value("options"));
          availableOptions = parseNull(genericFormMappedFieldRs.value("available_options"));
          optionQueryValue = parseNull(genericFormMappedFieldRs.value("element_option_query_value"));

          elementTrigger = parseNull(genericFormMappedFieldRs.value("element_trigger")); 

          if(elementTrigger.length() > 0){

            elementTriggerObject = new JSONObject(elementTrigger);

            elementTriggerEventArray = elementTriggerObject.getJSONArray("event");
            elementTriggerQueryArray = elementTriggerObject.getJSONArray("query");
            elementTriggerJsArray = elementTriggerObject.getJSONArray("js");

            elementTriggerEnt = "";
            elementTriggerQuery = "";
            elementTriggerJs = "";

            for(int i=0; i < elementTriggerEventArray.length(); i++){
              
              elementQueryValue = "";
              elementJsValue = "";

              if(elementTriggerQueryArray.length() > 0) elementQueryValue = elementTriggerQueryArray.get(i).toString();
              if(elementTriggerJsArray.length() > 0) elementJsValue = elementTriggerJsArray.get(i).toString();

              elementTriggerEnt += elementTriggerEventArray.get(i).toString();
              elementTriggerQuery += elementQueryValue;
              elementTriggerJs += elementJsValue;

              if(i != (elementTriggerEventArray.length()-1)){
                
                elementTriggerEnt += ",";
                elementTriggerQuery += "!@##@!";
                elementTriggerJs += "!@##@!";
              }
            }
          }

          out.write("<tr>");

          out.write("<td>");

          out.write(escapeCoteValue(label));
          
          out.write("</td>");            
          out.write("<td>");

          out.write("<input type=\"hidden\" name=\"mapped_field_id\" value=\"" + escapeCoteValue(elementFieldId) + "\" </td>");

          if(elementType.equals("select-one") || elementType.equals("checkbox") || elementType.equals("radio")){

            out.write("<div id=\"" + escapeCoteValue(label.replaceAll(" ","_")) + "\" name=\"" + escapeCoteValue(label.replaceAll(" ","_")) + "\" class=\"col-lg-12 order_seq\">"); 


            if(availableOptions.equals("null") || availableOptions.length() == 0){

              if(null != optionQueryValue && optionQueryValue.length() > 0){
        
                Set queryRs = Etn.execute(optionQueryValue);

                while(null != queryRs && queryRs.next()){
                    
                    queryValues += "\"" + queryRs.value(0) + "\",";
                    queryLabels += "\"" + queryRs.value(0) + "\",";

                }
                
                if(queryValues.length() > 0) queryValues = queryValues.substring(0, queryValues.length()-1);
                if(queryLabels.length() > 0) queryLabels = queryLabels.substring(0, queryLabels.length()-1);

                availableOptions = "{\"val\":[" + queryValues + "],\"txt\":[" + queryLabels + "]}";
              }
            }



            if(availableOptions.length()>0){

              availableOptionsJson = new JSONObject(availableOptions);
              availableOptionTxtArray = availableOptionsJson.getJSONArray("txt");
              
              if(selectedOptions.length() > 0){

                optionsJson = new JSONObject(selectedOptions);
                optionTxtArray = optionsJson.getJSONArray("txt");
              }

              out.write("<button style=\"width: 100%; margin-left: -15px;\" type=\"button\" class=\"btn btn-default\" data-toggle=\"dropdown\"> <span style=\"float: right; min-height: 15px;\" class=\"caret\"></span>---select---</button>");

              out.write("<ul class=\"dropdown-menu\">");
  
              for(int i=0; i < availableOptionTxtArray.length(); i++){
  
                out.write("<li><a name=\"" + escapeCoteValue(elementFieldId) + "\" class=\"dropdown-item\" href=\"#\" class=\"small\" data-value=\"" + escapeCoteValue(availableOptionTxtArray.get(i).toString().trim()) + "\" tabIndex=\"-1\"><input style=\"max-width: 13px;\" type=\"checkbox\" value=\"" + escapeCoteValue(availableOptionTxtArray.get(i).toString().trim()) +"\"");
                
                if(null != optionTxtArray){

                  for(int j=0; j < optionTxtArray.length(); j++){

                    if(parseNull(optionTxtArray.get(j).toString()).equals(availableOptionTxtArray.get(i).toString().trim())) out.write(" checked ");
                  }

                } else out.write(" checked ");

                out.write("/>&nbsp;" + escapeCoteValue(availableOptionTxtArray.get(i).toString()) + "</a></li>");
              }

              out.write("</ul>");
            }

            out.write("<input type=\"hidden\" name=\"option_selected\" value='" + selectedOptions + "' id=\"" + escapeCoteValue(elementFieldId) + "_dropdown_value\" />");
            out.write("<input type=\"hidden\" name=\"default_value\" value=\"\" />");
            out.write("</div>");
            
          } else if(elementType.equals("textdate") || elementType.equals("textdatetime")){

              out.write("<select name=\"select_date_cal\" ");

              if(elementType.equals("textdate")) out.write("onchange=\"select_mapping_date_caldr(this);\"");
              else if(elementType.equals("textdatetime")) out.write("onchange=\"select_datetime_caldr(this);\"");

              out.write("class=\"form-control\"> <option ");

              if(defaultValue.equals("") || defaultValue.length()==0){

                out.write(" selected ");
              } 

              out.write("value=\"\">No date</option> <option ");

              if(defaultValue.equals("today")) out.write(" selected ");

              out.write("value=\"today\">Today</option> <option ");

              if(defaultValue.length()==10) out.write(" selected ");

              out.write("value=\"s\">Selection</option> </select>");

              if((elementType.equals("textdate") || elementType.equals("textdatetime")) && (defaultValue.length()==0 || defaultValue.equalsIgnoreCase("today"))) 
                out.write("<div style=\"display: none;\">");
              else if(elementType.equals("textdate") || elementType.equals("textdatetime")) 
                out.write("<div>");
 
              out.write("<input style=\"");

              if(elementType.equals("textdatetime")) out.write(" width: 90px; padding: 5px; border: 1px solid #ccc; background-color: #eee;\"");

              out.write("\" name=\"default_value\" class=\"");
              if(elementType.equals("textdatetime")) out.write(" _daterange ");
              else if(elementType.equals("textdate")) out.write(" _daterange form-control");
              else out.write(" form-control ");
 
              out.write("\"");

              if(elementType.equals("textdate") || elementType.equals("textdatetime")) out.write(" readonly ");


              out.write(" type=\"text\" value=\"" + escapeCoteValue(defaultValue) + "\" />");
              
              if(elementType.equals("textdatetime")){


                out.write(" <span>-</span> <input id=\"" + escapeCoteValue(elementFieldId) + "_default_time\" style=\"width: 72px; padding: 5px; border: 1px solid #ccc; background-color: #eee;\" type=\"text\" class=\"_timerange\" readonly name=\"" + escapeCoteValue(elementFieldId) + "_default_time\" placeholder=\"select time\" value=\"" + escapeCoteValue(defaultTimeValue) + "\" onclick=\"update_default_time('" + escapeCoteValue(elementFieldId) + "')\" /> </div>");
                out.write("<div");

                if(elementType.equals("textdatetime") && (defaultValue.length()==0 || defaultValue.equalsIgnoreCase("today")) ) 
                  out.write(" style=\"display: none;\" ");

                out.write("> <input id=\"" + escapeCoteValue(elementFieldId) + "_start_time\" style=\"width: 90px; padding: 5px; border: 1px solid #ccc; background-color: #eee; margin-top: 5px;\" type=\"text\" class=\"_starttime\" readonly value=\"" + escapeCoteValue(startTime) + "\" name=\"" + escapeCoteValue(elementFieldId) + "_default_start_time\" placeholder=\"start time\" />");

                out.write(" <span>-</span> <input id=\"" + escapeCoteValue(elementFieldId) + "_end_time\" style=\"width: 72px; padding: 5px; border: 1px solid #ccc; background-color: #eee; margin-top: 5px;\" type=\"text\" class=\"_endtime\" readonly value=\"" + escapeCoteValue(endTime) + "\" name=\"" + escapeCoteValue(elementFieldId) + "_default_end_time\" placeholder=\"end time\" /> </div>");
                out.write("<select id=\"" + escapeCoteValue(elementFieldId) + "_time_slice\" style=\"margin-top: 5px; ");

                if(elementType.equals("textdatetime") && (defaultValue.length()==0 || defaultValue.equalsIgnoreCase("today")) ) 
                  out.write(" display: none; ");

                out.write(" \" name=\"" + escapeCoteValue(elementFieldId) + "_default_time_slice\" readonly class=\"form-control\"> <option ");
 
                if(sliceTime.equals("15")) out.write(" selected ");
                  out.write("value=\"15\">15</option> <option ");
 
                if(sliceTime.equals("30")) out.write(" selected ");
                  out.write("value=\"30\">30</option> <option ");
                
                if(sliceTime.equals("45")) out.write(" selected ");
                  out.write("value=\"45\">45</option> <option ");
                
                if(sliceTime.equals("60")) out.write(" selected ");
                  out.write("value=\"60\">60</option> </select>");

              }

              out.write("<div");

              if(elementType.equals("textdatetime") && (defaultValue.length()==0 || defaultValue.equalsIgnoreCase("today")) ) 
                out.write(" style=\"display: none;\" ");

              out.write(">Adjust days: <input name=\"" + escapeCoteValue(elementFieldId) + "_adjust_days\" value=\"" + escapeCoteValue(addNoOfDays) + "\" type=\"number\" class=\"form-control\" /></div>");
              out.write("<input type=\"hidden\" name=\"option_selected\" value=\"\" />");

          } else {

              out.write("<input name=\"default_value\" class=\"form-control\" type=\"text\" value=\"" + escapeCoteValue(defaultValue) + "\" />");
              out.write("<input type=\"hidden\" name=\"option_selected\" value=\"\" />");
          }          
          out.write("</td>");
          out.write("<td>"); 
                  
          String[] triggerToken = elementTriggerEnt.split(",");
          String[] triggerQueryValueToken = elementTriggerQuery.split("!@##@!");
          String[] triggerJsValueToken = elementTriggerJs.split("!@##@!");
          
          out.write("<input type=\"hidden\" id=\"element_trigger_value\" name=\"element_trigger_value\" value=\"" + escapeCoteValue(elementTriggerEnt) + "\" />");
          out.write("<input type=\"hidden\" id=\"element_trigger_query_value\" name=\"element_trigger_query_value\" value='" + escapeCoteValue(elementTriggerQuery) + "' />");
          out.write("<input type=\"hidden\" id=\"element_trigger_js_value\" name=\"element_trigger_js_value\" value='" + escapeCoteValue(elementTriggerJs) + "' />");

          for(int i=0; i < triggerToken.length; i++){
            
            elementTrigger = triggerToken[i];

            out.write("<select name=\"element_trigger\" class=\"form-control\" onchange=\"mappingTriggerEventQuery(this,'" + escapeCoteValue(elementFieldId) + "')\" > <option value=\"\"> ---select--- </option> <option ");

            if(elementTrigger.equals("onblur")) out.write(" selected ");
            else out.write("");

            out.write(" value=\"onblur\"> onBlur </option> <option ");

            if(elementTrigger.equals("onchange")) out.write(" selected ");
            else out.write("");

            out.write(" value=\"onchange\"> onChange </option> <option ");

            if(elementTrigger.equals("onclick")) out.write(" selected ");
            else out.write("");

            out.write(" value=\"onclick\"> onClick </option> <option ");

            if(elementTrigger.equals("onkeydown")) out.write(" selected ");
            else out.write("");

            out.write(" value=\"onkeydown\"> onKeyDown </option> <option ");

            if(elementTrigger.equals("onkeypress")) out.write(" selected ");
            else out.write("");

            out.write(" value=\"onkeypress\"> onKeyPress </option> <option ");

            if(elementTrigger.equals("onkeyup")) out.write(" selected ");
            else out.write("");

            out.write(" value=\"onkeyup\"> onKeyUp </option> ");
            out.write(" </select> ");
            if(elementTrigger.length() > 0)
              out.write("<div> <label> Write query: </label> <div> <textarea onfocusout=\"mappingElementTriggerQuery(this);\" id=\"write_query_trigger_event\" name=\"write_query_trigger_event\" class=\"form-control\" style=\"height: 80px;\">" + escapeCoteValue(triggerQueryValueToken[i]) + "</textarea> </div> </div> <div> <label> Write Js: </label> <div> <textarea onfocusout=\"mappingElementTriggerJs(this);\" id=\"write_js_trigger_event\" name=\"write_js_trigger_event\" class=\"form-control\" style=\"height: 80px;\">" + escapeCoteValue(triggerJsValueToken[i]) + "</textarea> </div> </div>");


          }
          
          if(triggerToken.length > 0 && triggerToken[0].length() > 0) {

            out.write("<div id='add_more_events' style='text-align: right; cursor: pointer;' class='o-option-actions'> <a onclick='addMoreEventTrigger(this);' class='o-add o-add-opt'>Add more +</a> </div>");
          }

          out.write("</td>");

          out.write("<td>");
          out.write("<input onclick=\"updateFieldValue(this);\" style=\"min-height: 1px; cursor: pointer;\" type=\"checkbox\" ");

          if(requiredGenericForm.equals("1")) out.write(" checked disabled ");
          if(required.equals("1")) out.write(" checked ");
          if(required.length() == 0) required = "0";

          out.write("/>");
          out.write("<input type=\"hidden\" name=\"field_required\" value=\"" + escapeCoteValue(required) + "\">");
          out.write("</td>");
          out.write("<td>");
          out.write("<span style=\"cursor: pointer;\" onclick=\"deleteMappedFormFields('" + escapeCoteValue(elementId) + "')\" class=\"glyphicon glyphicon-remove\"></span>");
          out.write("</td>");
          out.write("</tr>");

        }

        out.write("</tbody></table></div>");
    %>        

      </div>
      <%
          if(genericFormMappedFieldRs.rs.Rows > 0){
      %>
      <div class="col-sm-9" style="text-align: center; margin-top: 10px;">
        <input type="button" onclick="update_mapping_form_field()" class="btn btn-default" value="Save">
      </div>
      <%
          }
      %>

    </form>

</body>


<%  
}catch(JSONException je){
je.printStackTrace();  
}
%>



</html>
