<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape,java.util.List, java.util.ArrayList, com.etn.asimina.util.ActivityLog, java.util.HashSet, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../common.jsp"%>
<%
	String selectedsiteid = getSelectedSiteId(session);


	final int PAGE_SIZE = 10;

	String isprodParam = parseNull(request.getParameter("isprod"));
	boolean isprod = "1".equals(isprodParam);

	String dbname = "";
	if(isprod){
		dbname = com.etn.beans.app.GlobalParm.getParm("PROD_DB") + ".";
	}

	String cid = parseNull(request.getParameter("cid"));

	String pageNo = parseNull(request.getParameter("page"));
	String searchTerm = parseNull(request.getParameter("searchTerm"));

	String q = null;
	Set rs = null;

	if("1".equals(request.getParameter("isEdit"))){
		//save request
		String[] selectedIdsList = request.getParameterValues("selectedIds");

		String selectedIds = convertArrayToCommaSeperated(selectedIdsList);
		//out.write("pids : "+ selectedIds);

		q = "SELECT id, product_type, lang_1_name "
			+ " FROM "+dbname+"products p "
			+ " WHERE p.catalog_id = " + escape.cote(cid)
			+ " AND p.id IN ("+selectedIds+")";

        String prodIds = "";
        String prodNames= "";
		Set prodRs = Etn.execute(q);
		String pid, prodType;
		while(prodRs.next()){
            pid = prodRs.value("id");

            if(prodIds.length()>0)
                prodIds += ", ";
            prodIds += pid;
            if(prodNames.length()>0)
                prodNames += ", ";
            prodNames += parseNull(prodRs.value("lang_1_name"));

			prodType = prodRs.value("product_type");
				//non service type product
				//attributes based sku
				String[] skuKeyList = request.getParameterValues("skuKey_"+pid);
				String[] skuValueList = request.getParameterValues("skuValue_"+pid);

				if(skuKeyList!= null && skuValueList != null && skuKeyList.length > 0 && skuKeyList.length == skuValueList.length ){

					//delete existing
					q = " DELETE FROM "+dbname+"product_skus WHERE product_id = " + escape.cote(pid);
					Etn.executeCmd(q);


					q = " INSERT INTO "+dbname+"product_skus(product_id, attribute_values, sku, created_by) VALUES ";
					for(int i=0; i<skuKeyList.length; i++){
						if(i > 0){
							q+= ",";
						}

						q += "("+escape.cote(pid)+","+escape.cote(skuKeyList[i])+","+escape.cote(skuValueList[i])+","+escape.cote(Etn.getId()+"")+")";
					}
					q += " ON DUPLICATE KEY UPDATE sku=VALUES(sku), created_by=VALUES(created_by)";
					Etn.executeCmd(q);

				}

		}//end while(prodRs.next)
        ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),prodIds,"UPDATED","Products SKU",prodNames,selectedsiteid);
	}//if(isEdit)

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html>
<head>
	<title>SKUs</title>

	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>

<style type="text/css">

	table.results{
		width: 100%;
		border: none;
	}

	table.results td:nth-child(2), table.results th:nth-child(2),
	table.results td:last-child, table.results th:last-child
	{
		text-align: left;
	}

	table.results th{
		padding: 5px;
		/*background-color: lightgrey;*/
		text-align: center;
		white-space: nowrap;
	}

	table.results td{
		padding: 5px;
		text-align: center;
		white-space: nowrap;
	}

	table.results.topaligned td{
		vertical-align: top;
	}

	table.striped tr:nth-child(odd) >td{
		background-color: #EEE;
	}

	table.striped tr:nth-child(even) >td{
		background-color: white;
	}

	tr.productRow.selected > td{
		background-color: #C7EDFC /*lightslategrey*/ !important;
		border-bottom: 1px solid #4AB5E7;
	}

	input.skuinput{
		width : 70px;
	}

	input.read-disabled{
		background-color: lightgrey;
	}

	input.error, select.error{
		border: 1px solid red;
	}


</style>
<script type="text/javascript">
	function onCatalogChange(select){
		var cid = $(select).val();
		if(cid !== ''){
			var form = $('#hiddenForm');
			form.find('input.cid').val(cid);
			form.attr('action','');
			form[0].submit();
		}
	}


</script>

</head>

<%

breadcrumbs.add(new String[]{"Marketing", ""});
breadcrumbs.add(new String[]{"SKUs", ""});
%>

<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
	<!-- title -->
	<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
			<div>
				<h1 class="h2">SKUs</h1>
				<p class="lead"></p>
			</div>

			<!-- buttons bar -->
			<div class="btn-toolbar mb-2 mb-md-0">
				<div class="btn-group" role="group" aria-label="...">
					<button type="button" class="btn btn-default btn-primary" onclick="saveAll()">Save</button>
					<button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('SKUs');" title="Add to shortcuts">
						<i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
					</button>
				</div>
			</div>
			<!-- /buttons bar -->
		</div>
	<!-- /title -->



	<!-- container -->
	
	<div class="animated fadeIn">
		<form action="" id="hiddenForm">
			<input type="hidden" name="isprod" class="isprod" value="<%=escapeCoteValue(isprodParam)%>" />
			<input type="hidden" name="cid" class="cid" value="<%=escapeCoteValue(cid)%>" />
		</form>
		<div class="row">
			<%
			q = "SELECT id,name FROM "+dbname+"catalogs where site_id = "+escape.cote(selectedsiteid)+" ORDER BY name";
			rs = Etn.execute(q);
			%>
			<div class="col-5">
			<select id='catalogSelect' name="ignore" onchange="onCatalogChange(this)"  class="form-control">
				<option value=''>- - - Please select a catalog - - -</option>
				<%
				while(rs.next()){
				String selected = (rs.value("id").equals(cid))?"selected='selected'":"";
				%>
				<option value='<%=escapeCoteValue(rs.value("id"))%>' <%=selected%> ><%=escapeCoteValue(rs.value("name"))%></option>
				<%}%>
			</select>
			</div>
		</div>


		<% if(cid.length() > 0){%>

		<%
			q = " SELECT p.id, p.lang_1_name as name, p.image_name, p.product_type "
				+ " , p.updated_on , lg.name as last_updated_by "
				+ " FROM "+dbname+"products p "
				+ " LEFT OUTER JOIN login lg ON lg.pid = p.updated_by "
				+ " WHERE p.catalog_id = " + escape.cote(cid)
				+ " GROUP BY p.id "
				+ " ORDER BY p.order_seq, name ";

			Set listRs = Etn.execute(q);

			String formActionbUrl = "?isprod="+isprodParam+"&cid="+cid;
		%>
		<div style=''>
			<form action="<%=formActionbUrl%>" id="mainForm" method="POST" >
				<input type="hidden" name="isEdit" value="" id="isEdit" />
				<div class="m-t-20">
					<div class="col-12 alert t-s-grey" role="alert" style="text-align: left;"><input type="checkbox" name="ignore" value='' onchange="toggleSelectAll(this)" />&nbsp;&nbsp;&nbsp;Products SKU parameters
					</div>
				</div>

				<div class="form-inline">
				<table cellspacing="0" cellpadding="0" class="topaligned table table-bordered results" >
					<tr>
						<th style="border:0px;">

						</th>
						<th colspan="5" style="border:0px;"></th>
						<!-- <th>&nbsp;</th>
						<th>Product Name</th>
						<th>Type</th>
						<th>Last Changes</th> -->

							<!-- <th>&nbsp;<input type="button" value="Save Changes" onclick="saveAll()" style="width:100px; font-weight:bold;"  /> </th>-->

					</tr>
					<%
						HashSet<String> prodIdHM = new HashSet<String>();

						while(listRs!= null && listRs.next()){

							String pid = listRs.value("id");

							if(prodIdHM.contains(pid)){
								//skip product as it was processed already
								//as a linked product
								continue;
							}

							prodIdHM.add(pid);

							String prodType = listRs.value("product_type");

							String prodName = listRs.value("name");
							prodName = "<i>Product</i> &nbsp; <a href='product.jsp?cid="+cid+"&id="+pid+"' style='font-size: 12pt;' target='_blank'>"+escapeCoteValue(prodName)+"</a>";

					%>
					<tr class="productRow" style="border: 0px;">
						<th style="border: 0px;text-align: left;">
							&nbsp;<input type="checkbox" name="selectedIds" value='<%=escapeCoteValue(pid)%>' class="selectedIds"
								onchange="selectedIdsOnChange(this)" />
						</th>


						<th style="text-align: left;border: 0px;">
							<%=prodName%>
						</th>
						<th width="2%" style="border: 0px;">
							<%
								String tImageSrc = "";
								if(parseNull(listRs.value("image_name")).length() > 0) {
									tImageSrc = GlobalParm.getParm("PRODUCTS_IMG_PATH") + listRs.value("image_name");
								}
								else

							%>
							<img src='<%=tImageSrc%>' style='max-height:50px; max-width:50px' />
						</th>
						<th style="border: 0px;"><i>Type</i>  &nbsp; <small class='text-muted'><%=prodType.replace("_"," ") %></small></th>
						<th style="border: 0px;">
							<%
							if(parseNull(listRs.value("updated_on")).length() >0) {
								out.write("<i>Last modif</i> &nbsp; <small class='text-muted'> " + parseNull(listRs.value("updated_on")) +"</small> &nbsp; &nbsp; <i>By</i>  &nbsp; <small class='text-muted'>"+parseNull(listRs.value("last_updated_by")+"</small>")) ;
							}
							%>&nbsp;
						</th>
						<th style="border: 0px;"><span style="float:right; margin:0px 20px"><button type="button" class="btn btn-default btn-primary" onclick="saveAll()">Save</button></span></th>
					</tr>
					<tr>
						<!-- last cell -->

						<td colspan="6" style="">
						<%
								 	List<String> attribNamesList = new ArrayList<String>();
								 	List<List<String>> attribValuesList = new ArrayList<List<String>>();
								 	List<String> cList = new ArrayList<String>();

							 		q = "SELECT ca.name AS name, CONCAT(pv.cat_attrib_id,'_',pv.id,'__',pv.attribute_value) AS value "
							 			+" FROM "+dbname+"products p  "
							 			+" JOIN "+dbname+"product_attribute_values pv  ON pv.product_id = p.id "
							 			+" JOIN "+dbname+"catalog_attributes ca ON ca.cat_attrib_id = pv.cat_attrib_id AND ca.type = 'selection'"
							 			+" WHERE p.id = " + escape.cote(pid)
							 			// +" AND  p.product_type != 'service' "
							 			+" ORDER BY ca.sort_order, pv.sort_order, pv.id ";

							 		rs = Etn.execute(q);


							 		// get cartesian product of all product attrib values
							 		String curName = "";
							 		while(rs.next()){
							 			if( !curName.equals(rs.value("name")) ){
							 				curName = rs.value("name");
							 				attribNamesList.add(curName);
							 				cList = new ArrayList<String>();
							 				attribValuesList.add(cList);
							 			}
							 			cList.add(rs.value("value"));
							 		}


								 	if(attribNamesList.size() == 0){
								 		attribNamesList.add("--");
								 		cList = new ArrayList<String>(1);
								 		cList.add(" __No Attributes");
								 		attribValuesList.add(cList);
								 	}

								 	List<List<String>> valuesCProdList = cartesianProduct(attribValuesList);

									String html = "<table cellspacing='0' class='table table-hover table-bordered results' style='' > <tr>";
									for(String name : attribNamesList){
										html += "<th  style=\"background: #ECECEC;\">"+ name +"</th>";
									}
									html += "<th style=\"background: #ECECEC;\">SKU</th></tr>";
									for(List<String> valuesList : valuesCProdList){
										html += "<tr>";
										List<String> skuKeyList = new ArrayList<String>();
										for(String value : valuesList){
											String[] temp = value.split("__");
											if(temp.length >= 2){

												if(temp[0].trim().length() > 0){
													skuKeyList.add(temp[0]);
												}

												html += "<td>"+temp[1] + "</td>";
											}
											else{
												html += "<td>&nbsp;</td>";
											}

										}

										//sort the key list
										java.util.Collections.sort(skuKeyList, new java.util.Comparator<String>(){

								            @Override
								            public int compare(String o1, String o2) {
								               	String[] t1 = o1.split("_");
								               	String[] t2 = o2.split("_");

											 	if(t1.length == 2 && t2.length == 2){
													return  parseInt(t1[0]) - parseInt(t2[0]) ;
											 	}
											 	else{
											 		return 0;
											 	}

								            }

								        });

										String skuKey = "";
										for(int i=0; i<skuKeyList.size(); i++){
											if(i>0){
											skuKey += "_";
											}
											skuKey += skuKeyList.get(i);
										}

										q =  "SELECT * FROM "+dbname+"product_skus ps "
											+ " WHERE product_id = " +escape.cote(pid)+ " AND attribute_values = " + escape.cote(skuKey);
										rs = Etn.execute(q);
										String skuValue = "";
										if(rs.next()){
											skuValue = rs.value("sku");
										}
										String postFix = pid; //pid + "_" + skuKey;

										html += "<td> <input type='hidden' name='skuKey_"+pid+"' value='" + escapeCoteValue(skuKey) + "'  /> "
												+ " <input type='text' class='skuinput skuValue form-control' "
												+ " 		name='skuValue_"+postFix+"' value='" + escapeCoteValue(skuValue) + "' /> "
												+ "</td>";

										html += "</tr>\n";
									}//end for(valuesList)
									html += "</table>";
									out.write(html);

							%>

						</td>
					</tr>
					<%
						}//while(rs)
					%>
				</table>
				</div>

			</form>
		</div>
		<% }//if(cid)
		%>
		<br>
		<div class="row justify-content-end"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
	<div>

	</div><!-- container -->
</main>
</div><!-- c-body -->
<%@ include file="/WEB-INF/include/footer.jsp" %>
<script type="text/javascript">
	$(document).ready(function() {

		//unselect all rows on page load
		$('.selectedIds').prop('checked',false).trigger('change');

		$('.read-disabled').focus(function(){
			$(this).blur();
		});

	});

	var refreshscreen=function(){
		window.location = window.location
	};

	function toggleSelectAll(checkbox){
		checkbox = $(checkbox);
		if( checkbox.prop('checked') ){
			$('.selectedIds').prop('checked',true).trigger("change");
		}
		else{
			$('.selectedIds').prop('checked',false).trigger("change");
		}
	}

	function selectRow(ele){
		var tr = $(ele).parents('tr.productRow:first');
		if(tr.length > 0){
			tr.find('input.selectedIds').prop('checked',true).trigger("change");
		}
	}

	function selectedIdsOnChange(input){
		var tr = $(input).parents('tr.productRow:first');
		if($(input).prop('checked')){
			tr.addClass('selected');
		}
		else{
			tr.removeClass('selected');
		}
	}

	function saveAll(){
		var selectedProds = $('.selectedIds:checked');
		if( selectedProds.length <= 0 ){
			alert("No product selected. Please select 1 or more products first.");
			return;
		}

		var isError = false;
		selectedProds.each(function(i,ele){

			var productRow = $(ele).parents('tr.productRow:first');
			if(productRow.length > 0){
				var errorInputs = productRow.find(".error");
				if(errorInputs.length > 0 ){
					isError = true;
					var errorIn = $(errorInputs.get(0));
						alert("Error: Invalid value. Please specify valid value.");
						errorIn.focus();

				}
			}
		});

		if(isError){
			return false;
		}

		var msg = selectedProds.length
		+ " products are selected. Their SKU updates will be saved.\n Are you sure?";

		if(confirm(msg )){
			$('#isEdit').val("1");
			$('#mainForm').get(0).submit();
		}

	}
</script>
</body>
</html>

