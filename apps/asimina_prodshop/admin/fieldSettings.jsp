<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.*"%>
<%@ include file="../common2.jsp" %>

<%

	String process = parseNull(request.getParameter("process"));


  	String siteId = parseNull((String)session.getAttribute("SELECTED_SITE_ID"));

	String processesQry = "select process_name as process,display_name from processes where site_id="+escape.cote(siteId)+" order by process";
	Map<String, String> processes = new LinkedHashMap<String, String>();

	Set rsProcesses = Etn.execute(processesQry);

	while(rsProcesses.next()){
		processes.put(rsProcesses.value("process"),rsProcesses.value("display_name"));
	}
	
	
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
<title>Field Settings</title>
    <link href="<%=request.getContextPath()%>/css/coreui-icons.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/font-awesome.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/simple-line-icons.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/coreui.css" rel="stylesheet">
<link href="<%=request.getContextPath()%>/css/my.css" rel="stylesheet">

    <%-- <link href="<%=request.getContextPath()%>/css/jquery-ui.min.css" rel="stylesheet"> --%>

    <script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/Sortable.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/popper.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/coreui.min.js"></script>
	<script src="<%=request.getContextPath()%>/js/feather.min.js?v=2.28.0"></script>
    <script type="text/javascript">
        $(function() {
            feather.replace();
        });
    </script>
<script>
	function load()
	{
		jQuery.ajax({
			url : 'phasesajax.jsp',
			type: 'POST',
			data: {process: document.forms[0].processes.value, phase: document.forms[0].phases.value, type: 'field_settings'},
			dataType: 'HTML',
			success : function(resp)
			{ 	
				$(".section").remove();
				$("#field_settings").append(resp);

				Sortable.create(document.querySelector('#field_settings tbody.section'), {
					direction: 'vertical',
					scroll: true,
					scrollSensitivity: 100,
					scrollSpeed: 30,
					forcePlaceholderSize: true,
					filter: '.disabled',
					onMove: function (evt, originalEvent) {
						if (evt.related.className && evt.related.className.indexOf('disabled') !== -1) {
							return false;
						}
					},
					onEnd: function (evt) {
						setRowOrder(evt.item.parentNode);
					}
				});
			},
			error : function(resp)
			{
				alert("Some error occurred while marking field hidden");
			}
		});			
	}
	function updateHiddenInfoAll(obj)
	{	
		if(document.forms[0].processes.value=='')
		{
			alert("Select a process name");
			return;
		}
		if(document.forms[0].phases.value=='')
		{
			alert("Select a Phase");
			return;
		}
                
                $(".isHidden").each(function( index ) {
                    this.checked = obj.checked;
                    updateHiddenInfo(this);
                });		
	}
	function updateHiddenInfo(obj)
	{	
		if(document.forms[0].processes.value=='')
		{
			alert("Select a process name");
			obj.checked = false;
			return;
		}
		if(document.forms[0].phases.value=='')
		{
			alert("Select a Phase");
			obj.checked = false;
			return;
		}
		var isHidden = 0;
		if(obj.checked) 
		{
			isHidden = 1;
			if(document.getElementById("edit_"+obj.value))
			{
				document.getElementById("edit_"+obj.value).checked = false;
				document.getElementById("edit_"+obj.value).disabled = true;
				document.getElementById("mandatory_"+obj.value).checked = false;
				document.getElementById("mandatory_"+obj.value).disabled = true;
			}
		}		
		else
		{
			if(document.getElementById("edit_"+obj.value))
			{
				document.getElementById("edit_"+obj.value).checked = false;
				document.getElementById("edit_"+obj.value).disabled = false;
			}
		}		
		jQuery.ajax({
			url : 'saveFieldSettings.jsp',
			type: 'POST',
			data: {process: document.forms[0].processes.value, phase: document.forms[0].phases.value, screenName:document.forms[0].screenName.value, fieldName:obj.value, isHidden: isHidden, action: 'CHANGE_HIDDEN'},
			dataType: 'json',
			success : function(resp)
			{ 			
			},
			error : function(resp)
			{
				alert("Some error occurred while marking field hidden");
			}
		});		
	}
	function updateMandatoryInfo(obj)
	{	
		if(document.forms[0].processes.value=='')
		{
			alert("Select a process name");
			obj.checked = false;
			return;
		}
		if(document.forms[0].phases.value=='')
		{
			alert("Select a Phase");
			obj.checked = false;
			return;
		}
		var isMandatory = 0;
		if(obj.checked) isMandatory = 1;
		jQuery.ajax({
			url : 'saveFieldSettings.jsp',
			type: 'POST',
			data: {process: document.forms[0].processes.value, phase: document.forms[0].phases.value, screenName:document.forms[0].screenName.value, fieldName:obj.value, isMandatory: isMandatory, action: 'CHANGE_MANDATORY'},
			dataType: 'json',
			success : function(resp)
			{ 			
			},
			error : function(resp)
			{
				alert("Some error occurred while marking field mandatory");
			}
		});		
	}
	function updateInfo(obj)
	{		
		if(document.forms[0].processes.value=='')
		{
			alert("Select a process name");
			obj.checked = false;
			return;
		}
		if(document.forms[0].phases.value=='')
		{
			alert("Select a Phase");
			obj.checked = false;
			return;
		}
		var isEditable = 0;
		if(obj.checked) isEditable = 1;
		else
		{
			document.getElementById("mandatory_"+obj.value).checked = false;
			document.getElementById("mandatory_"+obj.value).disabled = true;
		}
		jQuery.ajax({
			url : 'saveFieldSettings.jsp',
			type: 'POST',
			data: {process: document.forms[0].processes.value, phase: document.forms[0].phases.value, screenName:document.forms[0].screenName.value, fieldName:obj.value, isEditable: isEditable, action: 'CHANGE_EDITABLE'},
			dataType: 'json',
			success : function(resp)
			{ 	
				if(isEditable == 1)	document.getElementById("mandatory_"+obj.value).disabled = false;
			},
			error : function(resp)
			{
				alert("Some error occurred while updating field info");
			}
		});
	}
        
        function onChangeProcesses(){
                $(".section").remove();
		jQuery.ajax({
			url : 'phasesajax.jsp',
			type: 'POST',
			data: {id : $("#processes").val(), type : "getPhases"},
			dataType : 'json',
			async:false,
			success : function(json)	
			{
				$("#phases").find('option').remove();
				if(json.phases)
				{
					$("#phases").find('option').end().append('<option value="">-- Select Phase --</option>');
					for(var i=0; i<json.phases.length; i++)
					{
						$("#phases").find('option').end().append('<option value="'+json.phases[i].id+'">'+json.phases[i].name+'</option>');
					}
				}
				
			},
			error : function(){
				alert("Error while communicating with the server");
			}
		});

	}
        
        function setRowOrder(element){

			$(element).find('tr').each(function(i,tr){
				$(tr).find('.order_seq')
				// .prop('readonly',false)
				.val(i);
				// .prop('readonly',true);
			});
		};
        
        function save(){
		jQuery.ajax({
			url : 'saveFieldOrder.jsp',
			type: 'POST',
			data: $("#fieldOrder").serialize(),
			async:false,
			success : function(json)	
			{
				alert("Order saved");
			},
			error : function(){
				alert("Error while communicating with the server");
			}
		});

			//$("#fieldOrder").submit();
		};
</script>
</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
		<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
			<h1 class="h2">Field Settings</h1>
		</div>
        <div class="animated fadeIn">
            <div class="card">
              <div class="card-header">Field Settings</div>
              <div class="card-body">
                  <form name="myForm" action="fieldSettings.jsp" method="post" class="form-horizontal" role="form">			        
                      <input type="hidden" name="isSave" value="0"/> 
                      <input type="hidden" id="screenName" name="screenName" size="10" class="form-control" placeholder="0" value="CUSTOMER_EDIT">           
                      <div class="row">
                          <div class="col-xs-12 col-sm-6">
                              <div class="form-group">
                                  <label for="processes" class="col-sm-3 control-label">Processes</label>
                                  <div class="col-sm-9">
                                      <select name="processes" id="processes" onchange="onChangeProcesses();" class="form-control">
                                          <option value="">-- Select Process --</option>
                                          <% for(String key : processes.keySet()) { %>
                                          <option value="<%=key%>"><%=processes.get(key)%></option>
                                          <% } %>
                                      </select>
                                  </div>
                                  </div>
                              </div>
                      </div>
                      <div class="row">
                          <div class="col-xs-12 col-sm-6">
                              <div class="form-group">
                                  <label for="phases" class="col-sm-3 control-label">Phases</label>
                                  <div class="col-sm-9">
                                      <select name="phases" id="phases" class="form-control" onchange="load()"> </select>
                                  </div>
                              </div>
                          </div>
                      </div>
                      <div class="row">
                          <div class="col-sm-12 text-center">
                              <div class="" role="group" aria-label="controls">
                                  <button type="button" class="btn btn-success" onclick="save()" >Save Ordering</button>
                              </div>
                          </div>
                      </div>
                  </form> 
              </div>
            </div>
            <div class="card">
              <div class="card-body">
                  <form id="fieldOrder" method="POST" action="saveFieldOrder.jsp">
                <table id="field_settings" class="table table-responsive-sm resultat table-hover table-striped">
                  <thead>
                    <tr>
                        <th >Section</th>
                        <th >Field</th>
                        <th ><input type='checkbox' value='_all' onclick="updateHiddenInfoAll(this)"/> Hide?</th>
                        <th >Is Editable?</th>
                        <th >Is Mandatory?</th>
                    </tr>
                    </thead>
		</table>
                  </form>
              </div>
            </div>
          </div>
	</main>
    </div>
    <%@ include file="../WEB-INF/include/footer.jsp" %>
</body>
</html>