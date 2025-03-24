<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.LinkedHashMap"%>

<%@ include file="../common.jsp" %>


<%	
	String siteId = parseNull((String)session.getAttribute("SELECTED_SITE_ID"));

	String saveSuppliers = parseNull(request.getParameter("saveSuppliers"));
	if(saveSuppliers.equals("")) saveSuppliers = "0";
	String updateSuppliers = parseNull(request.getParameter("updateSuppliers"));
	if(updateSuppliers.equals("")) updateSuppliers = "0";
	String[] suppliers = request.getParameterValues("supplier");
	String[] categorys = request.getParameterValues("category");
	String[] addresses = request.getParameterValues("address");
	String[] emails = request.getParameterValues("email");
	String[] phoneNumbers = request.getParameterValues("phone_number");
	String[] supplierDetails = request.getParameterValues("supplier_detail");
	String[] deleteSupplier = request.getParameterValues("deleteSupplier");
	String[] supplierIds = request.getParameterValues("supplier_id");
	String message = "";

	if(saveSuppliers.equals("1") && suppliers != null)
	{
		for(int i=0; i<suppliers.length;i++)
		{
			if(suppliers[i].trim().length() >0)
			{
 
				int person_id = Etn.executeCmd("insert into supplier (supplier, category, address, email, phone_number, supplier_detail,site_id) values (" + escape.cote(parseNull(suppliers[i])) + ", " + escape.cote(parseNull(categorys[i])) + ", " + escape.cote(parseNull(addresses[i])) + ", " + escape.cote(parseNull(emails[i])) + ", " + escape.cote(parseNull(phoneNumbers[i])) + ", " + escape.cote(parseNull(supplierDetails[i])) + ","+escape.cote(siteId)+")");

				if(person_id > 0)
					message = "Suppliers added successfully!!!";
%>
					<script type="text/javascript">
						window.location = window.location.href;
					</script>

<%					
			}
		}
	}

	if(updateSuppliers.equals("1") && suppliers != null)
	{
		for(int i=0; i<suppliers.length;i++)
		{
			Etn.executeCmd("UPDATE supplier SET supplier = " + escape.cote(parseNull(suppliers[i])) + ", category = " + escape.cote(parseNull(categorys[i])) + ", address = " + escape.cote(parseNull(addresses[i])) + ", email = " + escape.cote(parseNull(emails[i])) + ", phone_number = " + escape.cote(parseNull(phoneNumbers[i])) + ", supplier_detail = " + escape.cote(parseNull(supplierDetails[i])) + " WHERE id = " + escape.cote(parseNull(supplierIds[i])));
		}
		
		if(deleteSupplier != null)
		{
			for(int i=0; i<deleteSupplier.length;i++)
			{
				Etn.executeCmd("DELETE FROM supplier WHERE id = "+escape.cote(deleteSupplier[i])+" ");				
				System.out.println("DELETE FROM supplier WHERE id = "+escape.cote(deleteSupplier[i])+" ");
			}
		}
		message = "Suppliers updated/deleted successfully!!!";
	}

	Map<String, String> profiles = new LinkedHashMap<String, String>();
	Set rsProfile = Etn.execute("select * from profil order by description ");
//	profiles.put("#","-- Selecciona perfil --");
	while(rsProfile.next())
	{
		profiles.put(rsProfile.value("profil_id"),rsProfile.value("description"));
	}
	
	Set rsSuppliers = Etn.execute("SELECT * FROM supplier where site_id="+escape.cote(siteId));

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
<title>Supplier</title>
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

	var supplierCount = 1;
	
	function onUpdateSuppliers()
	{	 
		var isError = 0; 
		var updateSupplierLength = $(supplierFrm).find($('input[name="supplier"]')).length;
		for(var i=0;i<updateSupplierLength;i++)
		{
			jQuery("#userErr_"+i).html("&nbsp;");

			if(updateSupplierLength == 1){
	
				if(document.supplierFrm.category.value == ''){

					jQuery("#userErr_"+i).html("Required fields are missing");
					isError = 1;
				}else if(document.supplierFrm.address.value == ''){

					jQuery("#userErr_"+i).html("Required fields are missing");
					isError = 1;				
				}else if(document.supplierFrm.email.value == ''){

					jQuery("#userErr_"+i).html("Required fields are missing");
					isError = 1;				
				}else if(document.supplierFrm.phone_number.value == ''){

					jQuery("#userErr_"+i).html("Required fields are missing");
					isError = 1;				
				}
	
			} else{

				if(document.supplierFrm.category[i].value == ''){

					jQuery("#userErr_"+i).html("Required fields are missing");
					isError = 1;
				}else if(document.supplierFrm.address[i].value == ''){

					jQuery("#userErr_"+i).html("Required fields are missing");
					isError = 1;				
				}else if(document.supplierFrm.email[i].value == ''){

					jQuery("#userErr_"+i).html("Required fields are missing");
					isError = 1;				
				}else if(document.supplierFrm.phone_number[i].value == ''){

					jQuery("#userErr_"+i).html("Required fields are missing");
					isError = 1;				
				}	
			} 
			
		}

		if(!isError) document.supplierFrm.submit();
	}

	function onSaveNewSuppliers()
	{
		var isError = 0;
		var anythingToSave = 0;
		var rowError = 0;
		var newSupplierLength = $(newSupplierFrm).find($('input[name="supplier"]')).length;

		for(var i=0; i<newSupplierLength; i++)
		{
			jQuery("#new_colErr_"+i).html("&nbsp;");
			rowError = 0;

			anythingToSave = 1;
			if(jQuery('#supplier_'+i).val() == '') {

				isError = 1;
				rowError = 1;
			}else if(jQuery('#category_'+i).val() == ''){

				isError = 1;
				rowError = 1;
			}else if(jQuery('#address_'+i).val() == ''){

				isError = 1;
				rowError = 1;
			}else if(jQuery('#email_'+i).val() == ''){

				isError = 1;
				rowError = 1;
			}else if(jQuery('#phone_number_'+i).val() == ''){

				isError = 1;
				rowError = 1;
			}

			if(rowError) jQuery("#new_colErr_"+i).html("Required fields are missing");
		}
		if (isError) return;
		if(!anythingToSave) return;
		
		for(var i=0; i<newSupplierLength; i++)
		{			

			var rowError = 0;
			if(jQuery('#supplier_'+i).val() != '') 
			{			
				for(var j=0; j<newSupplierLength; j++)
				{
					if(jQuery('#supplier_'+j).val() != '' && jQuery('#supplier_'+j).val() == jQuery('#supplier_'+i).val() && i!=j) 
					{
						isError = 1;
						rowError = 1;
						jQuery("#new_colErr_"+i).html("Supplier name already exists in the list");
						break;
					}
				}
				if(!rowError)
				{
					jQuery.ajax({
						url: 'validateSupplier.jsp',
						data: {supplier : jQuery('#supplier_'+i).val(), rowNum : i},
						type: 'POST',		
						dataType: 'json',
						async: false,
						success : function(json) {
							if(json.STATUS == "ERROR")
							{
								isError = 1;
								jQuery("#new_colErr_"+json.ROWNUM).html("Supplier name already in use");
							}
						}
					});			
				}
			}
		}
		
		if(isError) return;

		document.newSupplierFrm.submit();
	}

	function add_more_supplier(){

		var html = "<tr id='supplier_row_" + supplierCount + "'> <td> <input type='text' maxlength='50' size='30' id='supplier_" + supplierCount + "' name='supplier' class='form-control' value='' /> </td> <td> <input type='text' id='category_" + supplierCount + "' name='category' class='form-control'> </td> <td> <input type='text' maxlength='50' size='30' id='address_" + supplierCount + "' name='address' class='form-control' value='' /> </td> <td> <input type='text' maxlength='50' size='30' id='email_" + supplierCount + "' name='email' class='form-control' value='' /> </td> <td> <input type='text' maxlength='50' size='30' id='phone_number_" + supplierCount + "' name='phone_number' class='form-control' value='' /> </td> <td> <input type='textarea' maxlength='50' size='30' id='supplier_detail_" + supplierCount + "' name='supplier_detail' class='form-control' value='' /> </td> <td> <span id='new_colErr_" + supplierCount + "' style='font-size:9pt;color:red'>&nbsp;</span> </td> </tr>";

		$("#supplier_row_"+(supplierCount-1)).after(html);
		supplierCount++;

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
			<h1 class="h2">Suppliers</h1>
		</div>
        <div class="animated fadeIn">
            <div class="card">
              <div class="card-body bg-light">
		<form name="newSupplierFrm" action="supplier.jsp" method="post" class="form-horizontal" role="form">			        
			<input type="hidden" name="saveSuppliers" value="1"/>            
			<table style=""> 	
				<thead> 
					<tr> 
						<th>Supplier<span style="color:red">*</span></th>
						<th>Category<span style="color:red">*</span></th>	
						<th>Address<span style="color:red">*</span></th>
						<th>Email<span style="color:red">*</span></th>
						<th>Phone Number<span style="color:red">*</span></th>
						<th>Supplier Detail</th>
					</tr>
				</thead>
                    <tbody>
				<tr id="supplier_row_0">				
					<td>
						<input type='text' maxlength='50' size='30' id='supplier_0' name='supplier' class="form-control" value='' />
					</td>
					<td>
						<input type="text" id="category_0" name="category" class="form-control">
					</td>
					<td>
						<input type='text' maxlength='50' size='30' id='address_0' name='address' class="form-control" value='' />
					</td>
					<td>
						<input type='text' maxlength='50' size='30' id='email_0' name='email' class="form-control" value='' />
					</td>
					<td>
						<input type='text' maxlength='50' size='30' id='phone_number_0' name='phone_number' class="form-control" value='' />
					</td>
					<td>
						<input type='textarea' maxlength='50' size='30' id='supplier_detail_0' name='supplier_detail' class="form-control" value='' />
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
               			<button type="button" class="btn btn-success" name="Search" onclick="onSaveNewSuppliers()"  style="margin-top:30px">Save Supplier(s)</button><button type="button" class="btn btn-primary" onclick="add_more_supplier()" style="margin-left: 10px; margin-top:30px"> Add More Suppliers</button>
                    </div>
                </div>
            </div>
        </form>	
              </div>
            </div>
            <div class="card">
              <div class="card-body p-0">		

		<form name="supplierFrm" action="supplier.jsp" method="post" class="form-horizontal" role="form">	
		        
            <input type="hidden" name="updateSuppliers" value="1"/>	

			<table class="table table-hover table-striped">
	
				<thead> 
                      <tr>
					<th>Supplier</th>
					<th>Category<span style="color:red">*</span></th>
					<th>Address<span style="color:red">*</span></th>
					<th>Email<span style="color:red">*</span></th>
					<th>Phone Number<span style="color:red">*</span></th>
					<th>Supplier Detail</th>
					<th>Delete</th>
                      </tr>
				</thead>
                    <tbody>

				<%	
					if(rsSuppliers.rs.Rows == 0){
						
				%>
                      <tr>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td><span>No Supplier(s) Found.</span></td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                      </tr>
				<%						
					}

					int rowsNum = 0;
				    while(rsSuppliers.next()){%>
					<tr>
						<td align="left">
							<input readonly type='text' maxlength='50' size='30' class="form-control" id='supplier_<%=rowsNum%>' name='supplier' value='<%=escapeCoteValue(rsSuppliers.value("supplier"))%>' />
						</td>
						<td align="left">
							<input type='text' maxlength='50' size='30' class="form-control" id='category_<%=rowsNum%>' name='category' value='<%=escapeCoteValue(rsSuppliers.value("category"))%>' />
						</td>
						<td align="left">
							<input type='text' maxlength='50' size='30' class="form-control" id='address_<%=rowsNum%>' name='address' value='<%=escapeCoteValue(rsSuppliers.value("address"))%>' />
						</td>
						<td align="left">
							<input type='text' maxlength='50' size='30' class="form-control" id='email_<%=rowsNum%>' name='email' value='<%=escapeCoteValue(rsSuppliers.value("email"))%>' />
						</td>
						<td align="left">
							<input type='text' maxlength='50' size='30' class="form-control" id='phone_number_<%=rowsNum%>' name='phone_number' value='<%=escapeCoteValue(rsSuppliers.value("phone_number"))%>' />
						</td>
						<td align="left">
							<input type='text' maxlength='50' size='30' class="form-control" id='supplier_detail_<%=rowsNum%>' name='supplier_detail' value='<%=escapeCoteValue(rsSuppliers.value("supplier_detail"))%>' />
						</td>
						<td align="center" id="activeChkBoxCol_<%=rowsNum%>">
							<input type='checkbox' id='isDelete_<%=rowsNum%>' name='deleteSupplier' value='<%=escapeCoteValue(rsSuppliers.value("id"))%>' />
						</td>
						<td align="left">
							<span id="userErr_<%=rowsNum%>" style="font-size:9pt;color:red">&nbsp;</span>
						</td>
					</tr>
					<input type="hidden" id="supplier_id_<%=rowsNum%>" name="supplier_id" value='<%=escapeCoteValue(rsSuppliers.value("id"))%>' />
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
							<button type="button" class="btn btn-success" name="Search" onclick="onUpdateSuppliers()" >Save</button>
	                    </div>
	                </div>
	            </div>

			<% } %>					

        </form>	
              </div>
            </div>
          </div>		

	</main>
<!-- Modal -->
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
