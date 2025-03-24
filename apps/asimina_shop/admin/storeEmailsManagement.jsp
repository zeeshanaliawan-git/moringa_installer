<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.LinkedHashMap"%>

<%@ include file="../common.jsp" %>


<%
	String siteId = parseNull((String)session.getAttribute("SELECTED_SITE_ID"));

	String saveStoreEmails = parseNull(request.getParameter("saveStoreEmails"));
	if(saveStoreEmails.equals("")) saveStoreEmails = "0";
	String updateStoreEmails = parseNull(request.getParameter("updateStoreEmails"));
	if(updateStoreEmails.equals("")) updateStoreEmails = "0";
	String[] names = request.getParameterValues("name");
	String[] cities = request.getParameterValues("city");
	String[] emails = request.getParameterValues("email");
	String[] deleteStoreEmail = request.getParameterValues("deleteStoreEmail");
	String[] storeEmailIds = request.getParameterValues("store_email_id");
	String message = "";

	if(saveStoreEmails.equals("1") && names != null)
	{
		for(int i=0; i<names.length;i++)
		{
			if(names[i].trim().length() >0)
			{
 
				int person_id = Etn.executeCmd("insert into store_emails (name, city, email,site_id) values (" + escape.cote(parseNull(names[i])) + ", " + escape.cote(parseNull(cities[i])) + ", " + escape.cote(parseNull(emails[i])) + ","+escape.cote(siteId)+")");

				if(person_id > 0)
					message = "Store e-mails added successfully!!!";
%>
					<script type="text/javascript">
						window.location = window.location.href;
					</script>

<%					
			}
		}
	}

	if(updateStoreEmails.equals("1") && names != null)
	{
		for(int i=0; i<names.length;i++)
		{
			Etn.executeCmd("UPDATE store_emails SET name = " + escape.cote(parseNull(names[i])) + ", city = " + escape.cote(parseNull(cities[i])) + ", email = " + escape.cote(parseNull(emails[i])) + " WHERE id = " + escape.cote(parseNull(storeEmailIds[i])));
		}
		
		if(deleteStoreEmail != null)
		{
			for(int i=0; i<deleteStoreEmail.length;i++)
			{
				Etn.executeCmd("DELETE FROM store_emails WHERE id = "+escape.cote(deleteStoreEmail[i])+" ");				
				//System.out.println("DELETE FROM store_emails WHERE id = "+escape.cote(deleteStoreEmail[i])+" ");
			}
		}
		message = "Store e-mails updated/deleted successfully!!!";
        }       
	
	Set rsStoreEmails = Etn.execute("SELECT * FROM store_emails where site_id="+escape.cote(siteId));

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
<title>Store E-mail</title>
    <link href="<%=request.getContextPath()%>/css/coreui-icons.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/font-awesome.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/simple-line-icons.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/coreui.css" rel="stylesheet">
<link href="<%=request.getContextPath()%>/css/my.css" rel="stylesheet">

    <script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
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

	var storeEmailCount = 1;
	
	function onUpdateStoreEmails()
	{	 
		var isError = 0; 
		var updateStoreEmailLength = $(storeEmailFrm).find($('input[name="name"]')).length;
		for(var i=0;i<updateStoreEmailLength;i++)
		{
			jQuery("#userErr_"+i).html("&nbsp;");

			if(updateStoreEmailLength == 1){
	
				if(document.storeEmailFrm.name.value == ''){

					jQuery("#userErr_"+i).html("Required fields are missing");
					isError = 1;
				}else if(document.storeEmailFrm.city.value == ''){

					jQuery("#userErr_"+i).html("Required fields are missing");
					isError = 1;				
				}else if(document.storeEmailFrm.email.value == ''){

					jQuery("#userErr_"+i).html("Required fields are missing");
					isError = 1;				
				}
	
			} else{

				if(document.storeEmailFrm.name[i].value == ''){

					jQuery("#userErr_"+i).html("Required fields are missing");
					isError = 1;
				}else if(document.storeEmailFrm.city[i].value == ''){

					jQuery("#userErr_"+i).html("Required fields are missing");
					isError = 1;				
				}else if(document.storeEmailFrm.email[i].value == ''){

					jQuery("#userErr_"+i).html("Required fields are missing");
					isError = 1;				
				}	
			} 
			
		}

		if(!isError) document.storeEmailFrm.submit();
	}

	function onSaveNewStoreEmails()
	{
		var isError = 0;
		var anythingToSave = 0;
		var rowError = 0;
		var newStoreEmailLength = $(newStoreEmailFrm).find($('input[name="name"]')).length;

		for(var i=0; i<newStoreEmailLength; i++)
		{
			jQuery("#new_colErr_"+i).html("&nbsp;");
			rowError = 0;

			anythingToSave = 1;
			if(jQuery('#name_'+i).val() == '') {

				isError = 1;
				rowError = 1;
			}else if(jQuery('#city_'+i).val() == ''){

				isError = 1;
				rowError = 1;
			}else if(jQuery('#email_'+i).val() == ''){

				isError = 1;
				rowError = 1;
			}

			if(rowError) jQuery("#new_colErr_"+i).html("Required fields are missing");
		}
		if (isError) return;
		if(!anythingToSave) return;
		
		for(var i=0; i<newStoreEmailLength; i++)
		{			

			var rowError = 0;
			if(jQuery('#name_'+i).val() != '') 
			{			
				for(var j=0; j<newStoreEmailLength; j++)
				{
					if(jQuery('#name_'+j).val() != '' && jQuery('#name_'+j).val() == jQuery('#name_'+i).val() && i!=j) 
					{
						isError = 1;
						rowError = 1;
						jQuery("#new_colErr_"+i).html("Store name already exists in the list");
						break;
					}
				}
				if(!rowError)
				{
					jQuery.ajax({
						url: 'validateStoreEmail.jsp',
						data: {name : jQuery('#name_'+i).val(), rowNum : i},
						type: 'POST',		
						dataType: 'json',
						async: false,
						success : function(json) {
							if(json.STATUS == "ERROR")
							{
								isError = 1;
								jQuery("#new_colErr_"+json.ROWNUM).html("Store name already in use");
							}
						}
					});			
				}
			}
		}
		
		if(isError) return;

		document.newStoreEmailFrm.submit();
	}

	function add_more_store_email(){

		var html = "<tr id='store_email_row_" + storeEmailCount + "'> <td> <input type='text' maxlength='50' size='30' id='name_" + storeEmailCount + "' name='name' class='form-control' value='' /> </td> <td> <input type='text' id='city_" + storeEmailCount + "' name='city' class='form-control'> </td> <td> <input type='text' maxlength='50' size='30' id='email_" + storeEmailCount + "' name='email' class='form-control' value='' /> </td> <td> <span id='new_colErr_" + storeEmailCount + "' style='font-size:9pt;color:red'>&nbsp;</span> </td> </tr>";

		$("#store_email_row_"+(storeEmailCount-1)).after(html);
		storeEmailCount++;

	}
</script>
</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
			<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
			<h1 class="h2">Store Emails</h1>
		</div>
        <div class="animated fadeIn">
            <div class="card">
              <div class="card-body bg-light">
		<form name="newStoreEmailFrm" action="storeEmailsManagement.jsp" method="post" class="form-horizontal" role="form">			        
			<input type="hidden" name="saveStoreEmails" value="1"/>            
			<table style="margin-top:30px;"> 	
				<thead> 
					<tr> 
						<th>Name<span style="color:red">*</span></th>
						<th>City<span style="color:red">*</span></th>
						<th>Email<span style="color:red">*</span></th>
					</tr>
				</thead>
                    <tbody>
				<tr id="store_email_row_0">				
					<td>
						<input type='text' maxlength='50' size='30' id='name_0' name='name' class="form-control" value='' />
					</td>
					<td>
						<input type="text" id="city_0" name="city" class="form-control">
					</td>
					<td>
						<input type='text' maxlength='500' size='30' id='email_0' name='email' class="form-control" value='' />
					</td>
					<td>
						<span id="new_colErr_0" style="font-size:9pt;color:red"> </span>
					</td>		
				</tr>	
                    </tbody>
			</table>

            <div class="row">
                <div class="col-sm-12 text-center">
                    <div role="group" aria-label="controls">
               			<button type="button" class="btn btn-success" name="Search" onclick="onSaveNewStoreEmails()"  style="margin-top:30px">Save Store Email(s)</button><button type="button" class="btn btn-primary" onclick="add_more_store_email()" style="margin-left: 10px; margin-top:30px"> Add More Store Emails</button>
                    </div>
                </div>
            </div>
        </form>	
              </div>
            </div>
            <div class="card">
              <div class="card-body p-0">		

		<form name="storeEmailFrm" action="storeEmailsManagement.jsp" method="post" class="form-horizontal" role="form">	
		        
            <input type="hidden" name="updateStoreEmails" value="1"/>	

			<table class="table table-hover table-striped" >
	
				<thead> 
                      <tr>
					<th>Name<span style="color:red">*</span></th>
					<th>City<span style="color:red">*</span></th>
					<th>Email<span style="color:red">*</span></th>
					<th>Delete</th>
                      </tr>
				</thead>
                    <tbody>

				<%	
					if(rsStoreEmails.rs.Rows == 0){
						
				%>
                      <tr>
                        <td> </td>
                        <td><span>No Store Email Found.</span></td>
                        <td> </td>
                        <td> </td>
                      </tr>
				<%						
					}

					int rowsNum = 0;
				    while(rsStoreEmails.next()){%>
					<tr>
						<td align="left">
							<input type='text' maxlength='50' size='30' class="form-control" id='name_<%=rowsNum%>' name='name' value="<%=escapeCoteValue(rsStoreEmails.value("name"))%>" />
						</td>
						<td align="left">
							<input type='text' maxlength='50' size='30' class="form-control" id='city_<%=rowsNum%>' name='city' value="<%=escapeCoteValue(rsStoreEmails.value("city"))%>" />
						</td>
						<td align="left">
							<input type='text' maxlength='500' size='30' class="form-control" id='email_<%=rowsNum%>' name='email' value='<%=escapeCoteValue(rsStoreEmails.value("email"))%>' />
						</td>
						<td align="center" id="activeChkBoxCol_<%=rowsNum%>">
							<input type='checkbox' id='isDelete_<%=rowsNum%>' name='deleteStoreEmail' value='<%=escapeCoteValue(rsStoreEmails.value("id"))%>' />
						</td>
						<td align="left">
							<span id="userErr_<%=rowsNum%>" style="font-size:9pt;color:red">&nbsp;</span>
						</td>
					</tr>
					<input type="hidden" id="store_email_id_<%=rowsNum%>" name="store_email_id" value='<%=escapeCoteValue(rsStoreEmails.value("id"))%>' />
					<%
						rowsNum ++;
					}
					%>

                    </tbody>
			</table>

			<% if(rowsNum > 0) { %>

	            <div class="row">
	                <div class="col-sm-12 text-center">
	                    <div class="" role="group" aria-label="controls">
							<button type="button" class="btn btn-success" name="Save" onclick="onUpdateStoreEmails()" >Save</button>
	                    </div>
	                </div>
	            </div>

			<% } %>					

        </form>	
              </div>
            </div>
          </div>		

	</main>
<div class="modal fade" id="dialogWindow" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="exampleModalLabel">Change Password</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
      </div>
	  <div class="modal-footer">
      </div>
    </div>
  </div>
</div>
    </div>
    <%@ include file="../WEB-INF/include/footer.jsp" %>
</body>

</html>
