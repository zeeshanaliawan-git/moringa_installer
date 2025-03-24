<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, com.etn.asimina.util.ActivityLog, java.util.Date, java.text.SimpleDateFormat, com.etn.beans.app.GlobalParm"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="/WEB-INF/include/constants.jsp"%>

<%@ include file="/admin/common.jsp"%>

<%!

	String getCartRuleStatus(com.etn.beans.Contexte Etn, String promotionId)
	{
		String proddb = com.etn.beans.app.GlobalParm.getParm("PROD_DB");
		String status = "NOT_PUBLISHED";
		Set rs = Etn.execute("select * from "+proddb+".cart_promotion where id = " + escape.cote(promotionId));
		if(rs.rs.Rows == 0)
		{
			return status;
		}
		status = "PUBLISHED";
		rs = Etn.execute("select case when cp1.version = cp2.version then '1' else '0' end from cart_promotion cp1, "+proddb+".cart_promotion cp2 where cp1.id = cp2.id and cp1.id = " + escape.cote(promotionId));
		rs.next();
		if(rs.value(0).equals("0"))
		{
			status = "NEEDS_PUBLISH";
		}
		return status;
	}

    String buildDateFr(String date){

        if(date.length() > 0){

            String token[] = date.split(" ");
            String innerToken[] = token[0].split("-");
            return innerToken[2] + "/" + innerToken[1] + "/" + innerToken[0] + " " + token[1];
        }

        return "";
    }

%>

<%
    String selectedsiteid = parseNull(getSelectedSiteId(session));

	String isSave = parseNull(request.getParameter("is_save"));
	String errmsg = parseNull(request.getParameter("errmsg"));
	String isEdit = parseNull(request.getParameter("is_edit"));
    String edit_id = parseNull(request.getParameter("edit_id"));

	String deleteId = parseNull(request.getParameter("delete_id"));

	String logedInUserId = parseNull(Etn.getId());

	if(deleteId.length() == 0) deleteId = "0";

	if(Integer.parseInt(deleteId) > 0)
	{
		Set rsp = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("PROD_DB")+".cart_promotion WHERE id = "+ escape.cote(deleteId));
		if(rsp.rs.Rows > 0)
		{
			errmsg = "Cart Rule already in production. Cannot proceed with delete. You must delete from production first";
		}
		else
		{		
			Set rs_name = Etn.execute("select name from cart_promotion where id = " + escape.cote(deleteId));
			rs_name.next();

			Etn.executeCmd("UPDATE cart_promotion_tbl SET is_deleted='1',updated_on=NOW()"+
				",updated_by="+escape.cote(logedInUserId)+" WHERE id = "+escape.cote(deleteId));

			ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),deleteId,"DELETED","Cart Rule",parseNull(rs_name.value(0)),selectedsiteid);
		}
	}



	String q = "SELECT cp.*, lg.name AS last_updated_by FROM cart_promotion cp LEFT OUTER JOIN login lg on lg.pid = cp.updated_by WHERE cp.site_id = "+escape.cote(selectedsiteid);
     if(edit_id.length()>0){
        q += "and cp.id = "+escape.cote(edit_id);//change
     }
    q+=" ORDER BY coalesce(cp.order_seq,999999), cp.id ";

	Set rs = Etn.execute(q);

%>

<!DOCTYPE html>

<html>
<head>
	<title>Cart Rules</title>

	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>

<%
breadcrumbs.add(new String[]{"Marketing", ""});
breadcrumbs.add(new String[]{"Cart Rules", ""});
%>

</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
	<!-- title -->
	<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
		<div>
			<h1 class="h2">Cart Rules</h1>
			<p class="lead"></p>
		</div>

		<!-- buttons bar -->
		<div class="btn-toolbar mb-2 mb-md-0">
			<div class="btn-group mr-2" role="group" aria-label="...">
				<button type="button" class="btn btn-danger" onclick='onpublish("multi")' id='publishtoprodbtn'>Publish </button>
				<button type="button" class="btn btn-danger" onclick='onpublish("multidelete")' id='unpublishtoprodbtn'>Unpublish</button>
			</div>
			<div class="btn-group mr-2" role="group" aria-label="...">
				<a href="../../../gestion.jsp" class="btn btn-primary" >Back</a>
				<button type="button" class="btn btn-primary" id="saveBtn" onclick='onsave(this)'>Save</button>
			</div>
			<div class="btn-group mr-2" role="group" aria-label="...">
				<button id="newCatalogButton" type="button" class="btn btn-success add_cart_rule" data-toggle="modal" data-target="#edit_cart_rule">Add a cart rule</button>

				<button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Cart Rules');" title="Add to shortcuts">
					<i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
				</button>

			<%-- <button type="button" class="btn btn-primary " onclick='javascript:window.location="copycatalog.jsp";'>Copy</button>  --%>
			</div>
		</div>
		<!-- /buttons bar -->
	</div><!-- /d-flex -->
	<!-- /title -->

	<!-- container -->
	<div class="animated fadeIn">
	<div>
	<form name='frm' id='frm' method='post' action='promotions.jsp' >
		<input type='hidden' value='1' name='issave' />
		<input type='hidden' value='0' name='delete_id' />

	<!-- legend -->
	<div>
		<small>
		<%
			if(true){
		%>
			<span class="text-muted">Drag / drop to change order.</span>
		<%
			}
			else{
		%>
			<span class="text-primary">Note: Promotion reordering disabled while filters applied.</span>
		<%
			}
		%>
		</small>
	</div>

	
		<% if(errmsg.length() > 0) { %>
		<div class="alert alert-danger" role="alert"><%=escapeCoteValue(errmsg)%></div>
		<% } %>
		<div id="save_promotions" style="display: none;" class="col-md-12 alert alert-success" role="alert">Cart rule is saved.</div>
		<div id="edit_promotions" style="display: none;" class="col-md-12 alert alert-success" role="alert">Modifications have been saved.</div>
		
		<table class="table table-hover table-vam m-t-20 nowrap" id="resultsdata">
			<thead class="thead-dark">
				<th scope="col"><input type='checkbox' id='sltall' value='1' /></th>
				<th scope="col">Order</th>
				<th scope="col">Rule name</th>
				<th scope="col">Coupon code</th>
				<th scope="col">Start</th>
				<th scope="col">End</th>
				<th scope="col">Last publication</th>
				<th scope="col">Next publication</th>
				<th scope="col">Last changes</th>
				<th scope="col">Action</th>
			</thead>
			<tbody class="sortable">
			<%
				String process = getProcess("cartrule");
				String rowColor = "";
				SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
				String promotionId = "";
				Set couponRs = null;
				String cartRuleStatus = "";

				while(rs.next()) {

					promotionId = parseNull(rs.value("id"));

					cartRuleStatus = getCartRuleStatus(Etn, promotionId);

					if("NOT_PUBLISHED".equals(cartRuleStatus)) rowColor = "danger"; //red
					else if("NEEDS_PUBLISH".equals(cartRuleStatus)) rowColor = "warning"; //orange
					else rowColor = "success"; //green

					if(promotionId.length() > 0){

						couponRs = Etn.execute("SELECT * from cart_promotion_coupon WHERE cp_id = " + escape.cote(promotionId));
					}

					String nextpublish = "", lastpublish = "";
					Set rspw = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s') as _dt, phase from post_work where status = 0 and phase in  ('publish','publish_ordering','delete') and client_key = " + escape.cote(rs.value("id")) + " and proces = " + escape.cote(process));
					if(rspw.next())
					{
						String __ty = "publish";
						if(rspw.value("phase").equals("publish_ordering")) __ty = "publish ordering";
						else if(rspw.value("phase").equals("delete")) __ty = "unpublish";
						
						nextpublish = "<span style='color:red'>"+parseNull(rspw.value("_dt"))+"</span>";
						nextpublish += "&nbsp;&nbsp;&nbsp;<a style='color:black' href='"+request.getContextPath()+"/admin/cancelaction.jsp?type=cartrule&id="+rs.value("id")+"&goto=catalogs/commercialoffers/cartrules/promotions.jsp'>Cancel "+__ty+"</a>";
					}

					rspw = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s')  as _dt from post_work where status in (0,2) and phase = 'published' and client_key = " + escape.cote(rs.value("id")) + " and proces = "+escape.cote(process)+" order by id desc limit 1 ");
					if(rspw.next()) lastpublish = parseNull(rspw.value("_dt"));

					Set prodrs = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("PROD_DB")+".catalogs where id = " + escape.cote(rs.value("id")));//changed

					Set rspr = Etn.execute("select * from products where catalog_id = " + escape.cote(rs.value("id")));//changed
	  			%>

					<tr class="table-<%=rowColor%>" style="cursor: move;">
						<td style='text-align:center'>
							<input type='checkbox' class='slt_option' value='<%=escapeCoteValue(rs.value("id"))%>' />
							<input type='hidden' name='id' value='<%=escapeCoteValue(rs.value("id"))%>'  />
						</td>
						<td align='center'>
							<input type='text' size='2' maxlength='5' name='order_seq' class="order_seq form-control" value='<%=escapeCoteValue(parseNull(rs.value("order_seq")))%>' />
							<input type='hidden' size='2' maxlength='5' name='order_seq_sort' class="order_seq_sort form-control" value='<%=escapeCoteValue(parseNull(rs.value("order_seq")))%>' />
						</td>
						<td><strong><%=escapeCoteValue(rs.value("name"))%></strong></td>
						<td>
						<%

							if(couponRs.rs.Rows > 1) {
						%>
								<button id='<%= rs.value("id")%>' type="button" class="btn btn-primary generated_coupon_code" data-toggle="modal" data-target="#generated_coupon_code"> Generated </button>
						<%
							} else {

								if(couponRs.next()){
						%>
									<%=escapeCoteValue(couponRs.value("coupon_code"))%>
						<%
								}
							}

							try{

						%>

						</td>
						<td><%=escapeCoteValue(rs.value("start_date"))%></td>
						<td><%=escapeCoteValue(rs.value("end_date"))%></td>
						<td>
							<%= lastpublish%>
						</td>
						<td><%= nextpublish %></td>
						<td><% if(parseNull(rs.value("updated_on")).length() >0) { out.write("<span style='color:green'>On</span>: " + parseNull(rs.value("updated_on")) +"<br><span style='color:green'>By</span>: "+parseNull(rs.value("last_updated_by")));}else{out.write("&nbsp;");}%></td>
						<td class="dt-body-right text-nowrap" nowrap>
							<button id='<%= escapeCoteValue(rs.value("id"))%>' type="button" class="btn btn-primary btn-sm edit_cart_rule" data-toggle="modal" data-target="#edit_cart_rule"><i data-feather="edit"></i></button>
							<a href="javascript:oncopy('<%=rs.value("id")%>')" class="btn btn-primary btn-sm" data-toggle="tooltip" data-placement="top" title="Duplicate parameters of : <%=escapeCoteValue(rs.value("name"))%>"><i data-feather="copy"></i></a>
							<a href="couponTracking.jsp?cpid=<%=rs.value("id")%>" class="btn btn-primary btn-sm" data-toggle="tooltip"><i data-feather="gift"></i></a>
						<%
						}catch(Exception e){
							e.printStackTrace();
						}


							if("NOT_PUBLISHED".equals(cartRuleStatus)) {
						%>
								<a href="javascript:ondelete('<%=rs.value("id")%>')" class="btn btn-danger btn-sm" ><i data-feather="trash-2"></i></a>
						<%
							} else {
						%>
								<button type="button" class="btn btn-danger btn-sm" onclick="onbtnclickpublish('<%=rs.value("id")%>', 'cartrules', 'delete')" id='unpublishtoprodbtn'>Unpublish</button>
						<%
							}
						%>

						</td>



	   				</tr>
				<%
					}//while
				%>

			</tbody>
		</table>
	</form>
	</div>
	<div class="row justify-content-end m-t-10"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
	</div>
	<br>

	<!-- Modal -->
	<div class="modal fade" id="generated_coupon_code" tabindex="-1" role="dialog" aria-labelledby="Generated coupon code" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="Generated coupon code">Coupon codes</h5>

					<button type="button" class="close" data-dismiss="modal" aria-label="Close">
						<span aria-hidden="true">&times;</span>
					</button>
				</div>

				<div id="generated_coupon_code_list" class="modal-body">

				</div>

				<div class="modal-footer">
					<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
				</div>
			</div>
		</div>
	</div>

	<!-- Modal edit cart rule -->
	<div class="modal fade" id="edit_cart_rule" tabindex="-1" role="dialog" data-backdrop="static" aria-labelledby="Edit cart rule" aria-hidden="true">
		<div class="modal-dialog modal-lg modal-dialog-slideout" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title">Edit cart rule</h5>

					<button type="button" class="close" data-dismiss="modal" aria-label="Close">
						<span aria-hidden="true">&times;</span>
					</button>
				</div>

				<div id="edit_cart_rule_content" class="modal-body">

				</div>

				<div class="modal-footer">
					<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
					<button id="selectionSave" type="button" class="btn btn-primary" style="" onclick='onCartRuleSave()'>Save</button>
				</div>
			</div>
		</div>
	</div>

</main>
	<div class="modal fade" id='copyPromotionDialog' tabindex="-1" role="dialog" >
        <div class="modal-dialog" role="document">
            <div class="modal-content" >
                <form class="formPublishPages" action="" onSubmit="return false" novalidate="">
                    <div class="modal-header">
                        Copy
                    </div>
                    <div class="modal-body">
                        <form>
                        <div class="form-group">
                            <label >New Name</label>
                            <input type="text" class="form-control"  name="promotionNewName" id="copyPromotionNewName" aria-describedby="emailHelp">
                            <span class="infoMsg" style="color:blue;"></span>
                            <span class="errorMsg" style="color:red;"></span>
                        </div>
                        <button type="button" class="btn btn-primary" onclick="copyPromotion()" >Copy</button>
                        <button type="button" class="btn btn-secondary" onclick="$('#copyPromotionDialog').modal('hide');">Cancel</button>

                        </form>
                    </div>
                </form>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div><!-- /.modal -->

	<!-- .modal -->
	<div class="modal fade" id="publishdlg" tabindex="-1" role="dialog">
		<div class="modal-dialog" role="document">
			<div class="modal-content">
			<!-- modal content goes here -->
			</div>
		</div>
	</div>
	<!-- /.modal -->


<%@ include file="../../../prodpublishloginmultiselect.jsp"%>
<%@ include file="/WEB-INF/include/footer.jsp" %>
</div>

<script>

	jQuery(document).ready(function()
	{
        <% if(edit_id.length()>0){%>
            editModal('<%=edit_id%>');
            $('#edit_cart_rule').modal("show");
        <% } %>

		var breakpoints = [
			{ "name": 'desktop', "width": Infinity },
			{ "name": 'tablet',  "width": 1024 },
			{ "name": 'fablet',  "width": 768 },
			{ "name": 'phone',   "width": 480 }
		];

		var resultsDatatable = $('#resultsdata').DataTable({
			
			"language": {
				"emptyTable": "No rules found"
			},
			"pageLength": 10,
            "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
			"columnDefs": [
                { targets : [0, 7] , searchable : false},
                { targets : [0, 1, 7] , orderable : false},
			]
		});

		isLargeScreen = function () {
			var currentWidth = $(window).width();
			return currentWidth > 1024;  
		}

		var orderingchanged = false;
		$(".order_seq").change(function(){
			orderingchanged = true;
		});

		$("#sltall").click(function()
		{
			if($(this).is(":checked"))
			{
				$(".slt_option").each(function(){$(this).prop("checked",true)});
			}
			else
			{
				$(".slt_option").each(function(){$(this).prop("checked",false)});
			}
		});

		$(".slt_option").click(function()
		{
			$("#sltall").prop("checked",false);
		});

		onpublish=function(pType)
		{
			if ($(".slt_option:checked").length > 0)
			{
				var ids = "";
				$(".slt_option").each(function(){
					if($(this).is(":checked") == true) ids += $(this).val() + ",";
				});
				onbtnclickpublish(ids, "cartrules", pType);
			}
			else
			{
				alert("No items selected");
			}
		};

		/*$('#resultsdata').on('responsive-resize', function(e, datatable, columns) {
			if (isLargeScreen()) {
				console.log("Large screen");
			} else {
				new $.fn.dataTable.Responsive(resultsDatatable, {
					breakpoints: breakpoints,
					details: true
				});
				console.log("Small screen");
			}
		});		
		resultsDatatable.destroy();
		if (isLargeScreen()) {
			resultsDatatable = $('#resultsdata').DataTable({
				"language": {
					"emptyTable": "No rules found"
				},
				"pageLength": 10,
				"lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
				"columnDefs": [
					{ targets : [0, -1] , searchable : false},
					{ targets : [0, 1, -1] , orderable : false},
				]
			});
		} else {
			resultsDatatable = $('#resultsdata').DataTable({
				responsive : true,
				"language": {
					"emptyTable": "No rules found"
				},
				"pageLength": 10,
				"lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
				"columnDefs": [
					{ targets : [0, -1] , searchable : false},
					{ targets : [0, 1, -1] , orderable : false},
				]
			});
			console.log("Small screen");
		}*/	

		onpublishorder=function()
		{
			var _continue = true;
			if(orderingchanged)
			{
				if(!confirm("Some changes are made in ordering which are not saved. Do you still want to continue publishing old ordering?")) _continue = false;
			}
			if(!_continue) return;

			if ($(".slt_option:checked").length > 0)
			{
				var ids = "";
				$(".slt_option").each(function(){
					if($(this).is(":checked") == true) ids += $(this).val() + ",";
				});
				onbtnclickpublish(ids, "cart_rules", "ordering");
			}
			else
			{
				alert("No items selected");
			}
		};


		$(".add_cart_rule").on("click", function(){
            $("#edit_cart_rule").find('.modal-title').html("Add a new cart rule");

		    $.ajax({
		        url : '../ajax/cartrules.jsp',
		        type: 'POST',
		        dataType: 'HTML',
		        data: {
		        	"action": 'cart_rules'
		        },
		        success : function(response)
		        {
					var startDate;
					var endDate;
		        	$("#edit_cart_rule_content").html(response);

			        flatpickr('#start_date', {
						dateFormat: 'Y-m-d H:i:S',
						minDate: 'today',
						enableTime: true,
						onChange: function(selectedDates, dateStr, instance) {
							const endDatePicker = document.querySelector('#end_date');
							const endDate = endDatePicker._flatpickr;
							if (endDate) {
								endDate.set('minDate', selectedDates[0]);
							}
						},
					});

					flatpickr('#end_date', {
						dateFormat: 'Y-m-d H:i:S',
						minDate: 'today',
						enableTime: true,
						onClose: function(selectedDates, dateStr, instance) {
							const startDatePicker = document.querySelector('#start_date');
							const startDate = startDatePicker._flatpickr;
							if (startDate) {
								const selectedStartDate = startDate.selectedDates[0];
								if (selectedStartDate && selectedStartDate > selectedDates[0]) {
									alert('End date is not lesser than start date.');
									startDate.clear();
								}
							}
						},
					});


					setTimeout(function(){

						$('#coupon_tracking_resultsdata').DataTable({
							"responsive": true,
							"language": {
								"emptyTable": "No coupon tracking found"
							}
						});

					}, 1000);

					if($("#rule_type").val() == ""){

						$("#verify_condition").attr("disabled", "disabled");
						$("#rule_condition").attr("disabled", "disabled");
						$("#rule_condition_value").attr("disabled", "disabled");

					}

			    	verify_condition_method();

					$(".rule_value_cart_attr").focusout(function(){

						if($("#verify_condition").val() == "total_quantity" || $("#verify_condition").val() == "total_amount"){

							$("#rule_condition_key").val($(this).val());
						}

					});

					initProductAC();
					checkElementOn(true);

			    }
		    });

		});

		$("#resultsdata tbody").on("click", "tr", function(){

            editModal($(this).find(".edit_cart_rule").prop("id"));

		});

		refreshscreen=function()
		{
			window.location = window.location
		};

		$(".generated_coupon_code").on("click", function(){

		    $.ajax({
		        url : '../ajax/cartrules.jsp',
		        type: 'POST',
		        dataType: 'HTML',
		        data: {
		        	"action": 'get_generated_cc',
		        	"promotion_id": $(this).prop("id")
		        },
		        success : function(response)
		        {
		        	$("#generated_coupon_code_list").html(response);
		        }
		    });

		});

		onCartRuleSave=function()
		{

			var flagCartRule = false;

			if($("#name").val() == "") {

				$("#name").next().css("display","block");
				flagCartRule = true;
			}
			else $("#name").next().css("display","none");

			if($("#amount").val() == "") {

				$("#amount").parent().find(".invalid-feedback").css("display","block");
				flagCartRule = true;
			}
			else $("#amount").parent().find(".invalid-feedback").css("display","none");

			if($("#slct_element_on").val() == "") {

				$("#slct_element_on").next().css("display","block");
				flagCartRule = true;
			}
			else $("#slct_element_on").next().css("display","none");
			
			if($("#discount_value").val() == "") {
				$("#discount_value").next().show();
				flagCartRule = true;
			}
			else{ 
				let pattern = /^\d+(\.\d+)?$/;
				if(!pattern.test($("#discount_value").val())){ 
					$("#discount_value").next().text("Invalid discount value");
					$("#discount_value").next().show();
					flagCartRule = true;
				}
				else{ 
					$("#discount_value").next().text("Amount is mandatory.");
					$("#discount_value").next().css("display","none");
				}				
				
			}

			if(flagCartRule) return false;

			$("#cartrulefrm").submit();
		};

		onsave = function(btn){

			var promoIds = [];
			var flags = [];

			$('#resultsdata tbody tr').each(function(i, tr){

				var promoId = $(tr).find('input[name=id]:first');
				if(promoId.length == 1){
					promoIds.push(promoId.val());
				}

				if($(tr).find('.order_seq').val() == $(tr).find('.order_seq_sort').val()) flags.push("false");
				else flags.push("true");

			});

			if(promoIds.length === 0){
				return false;
			}

			var params = {
				action : "order_cartrule",
				promoIds  : promoIds.join(","),
				seq_order : flags.join(",")
			};


			$(btn).prop('disabled',true);
			showLoader();
			$.ajax({
				url: '../ajax/cartrules.jsp',
				type: 'POST',
				dataType: 'json',
				data: params
			})
			.done(function(response) {
				if(response.status !== "SUCCESS"){
					alert("Error: promotions order not saved. please try again.");
				}
				else{
					alert("promotions order saved.");
					orderingchanged = false;
				}

			})
			.fail(function() {
				alert("Error: promotions order not saved. please try again.");
			})
			.always(function() {
				$(btn).prop('disabled',false);
				hideLoader();
			});
		}

		onKeyOrderSeq = function(event){
			var input = $(event.target);
			allowNumberOnly(input);
			if(event.which == 13 ){
				//enter pressed
				var val = parseInt(input.val());
				if( !isNaN(val) && val >= 0 ){
					var tr = input.parents("tr:first");
					var maxNum = tr.siblings().length + 1;

					if(val > maxNum){
						val = maxNum;
					}

					if(val <= 1){
						tr.insertBefore(tr.siblings(':eq(0)'));
					}
					else{
						tr.insertAfter(tr.siblings(':eq('+(val-2)+')'));
					}

					setRowOrder();
					// input.focus();
				}
			}
		};

		setRowOrder = function(){

			$('#resultsdata tbody tr').each(function(i,tr){

				$(tr).find('.order_seq_sort').val($(tr).find('.order_seq').val());

				$(tr).find('.order_seq')
				// .prop('readonly',false)
				.val(i+1);
				// .prop('readonly',true);
			});
		};

		Sortable.create(document.querySelector('#resultsdata tbody.sortable'), {
			animation: 150,
			scroll: true,
			scrollSensitivity: 100,
			scrollSpeed: 30,
			forcePlaceholderSize: true,
			helper: function (event, element) {
				var clone = element.cloneNode(true);
				var origTdList = element.querySelectorAll('>td');
				var cloneTdList = clone.querySelectorAll('>td');

				for (var i = 0; i < cloneTdList.length; i++) {
				cloneTdList[i].style.width = origTdList[i].offsetWidth + 'px';
				}

				return clone;
			},
			onUpdate: function (event) {
				setRowOrder();
				orderingchanged = true;
			}
		});


		$('#resultsdata tbody tr input.order_seq')
			.keyup(onKeyOrderSeq)
			.blur(setRowOrder);

		setRowOrder();


		change_ag_cc = function(element) {

			if($(element).val() == "1"){

				$("#coupon_quantity").parent().parent().css("display", "");
				$("#coupon_code_length").parent().parent().css("display", "");
				$("#coupon_code_prefix").parent().parent().css("display", "");
				$("#coupon_code").val("");
				$("#coupon_code").attr("readonly","true");

			} else if($(element).val() == "0"){

				$("#coupon_quantity").parent().parent().css("display", "none");
				$("#coupon_code_length").parent().parent().css("display", "none");
				$("#coupon_code_prefix").parent().parent().css("display", "none");
				$("#coupon_code").removeAttr("readonly");
			}
		};

		rule_method_condition = function(element){

			$(".rule_value_cart_attr").val("");

			if($(element).val() == "total_amount" || $(element).val() == "total_quantity"){

				$('#rule_condition option[value="greater_than"]').remove();
				$('#rule_condition option[value="less_than"]').remove();

				$("#rule_condition").append($("<option></option>").attr("value","greater_than").text("Greater than"));
				$("#rule_condition").append($("<option></option>").attr("value","less_than").text("Less than"));

			} else {

				$('#rule_condition option[value="greater_than"]').remove();
				$('#rule_condition option[value="less_than"]').remove();
			}
		}

		change_rule_if = function(element, frmname){

			$("#"+frmname).find('#verify_condition option[value="delivery_method"]').remove();
			$("#"+frmname).find('#verify_condition option[value="payment_method"]').remove();
			$("#"+frmname).find('#verify_condition option[value="total_quantity"]').remove();
			$("#"+frmname).find('#verify_condition option[value="total_amount"]').remove();

			$("#"+frmname).find('#verify_condition option[value="sku"]').remove();
			$("#"+frmname).find('#verify_condition option[value="product"]').remove();
			$("#"+frmname).find('#verify_condition option[value="product_type"]').remove();
			$("#"+frmname).find('#verify_condition option[value="catalog"]').remove();
			$("#"+frmname).find('#verify_condition option[value="manufacturer"]').remove();
			$("#"+frmname).find('#verify_condition option[value="tag"]').remove();

			$("#"+frmname).find("#rule_condition_value").val("");
			$("#"+frmname).find("#rule_condition_key").remove();

			$("#"+frmname).find(".rule_element_value").css("display", "none");
			$("#"+frmname).find(".rule_element_value").parent().addClass("d-none");
			$("#"+frmname).find(".rule_value_cart_attr").css("display", "none");
			$("#"+frmname).find(".rule_value_cart_attr").parent().addClass("d-none");

			if($(element).val() == ""){

				$("#"+frmname).find("#verify_condition").attr("disabled", "disabled");
				$("#"+frmname).find("#rule_condition").attr("disabled", "disabled");
				$("#"+frmname).find("#rule_condition_value").attr("disabled", "disabled");

			} else if($(element).val() == "cart_attribute"){

				$("#"+frmname).find("#verify_condition").removeAttr("disabled");
				$("#"+frmname).find("#rule_condition").removeAttr("disabled");
				$("#"+frmname).find("#rule_condition_value").removeAttr("disabled");

				$("#"+frmname).find("#verify_condition").append($("<option></option>").attr("value","delivery_method").text("Delivery method"));
				$("#"+frmname).find("#verify_condition").append($("<option></option>").attr("value","payment_method").text("Payment method"));
				$("#"+frmname).find("#verify_condition").append($("<option></option>").attr("value","total_quantity").text("Total quantity"));
				$("#"+frmname).find("#verify_condition").append($("<option></option>").attr("value","total_amount").text("Total amount"));

				$("#"+frmname).find(".rule_value_cart_attr").css("display", "block");
				$("#"+frmname).find(".rule_value_cart_attr").parent().removeClass("d-none");
				$("#"+frmname).find(".rule_value_cart_attr").attr("id", "rule_condition_value");
				$("#"+frmname).find(".rule_element_value").parent().parent().append('<input type="hidden" id="rule_condition_key" name="rule_condition_value" />');
				$("#"+frmname).find("#rule_condition").attr('style','display: block !important');

				$("#"+frmname).find(".rule_element_value").css("display", "none");
				$("#"+frmname).find(".rule_element_value").parent().addClass("d-none");
				$("#"+frmname).find(".rule_element_value").removeAttr("id");
				$("#"+frmname).find(".rule_element_value").removeAttr("name");
				$("#"+frmname).find(".rule_element_value").val("");

			} else if($(element).val() == "cart_product") {

				$("#"+frmname).find("#verify_condition").removeAttr("disabled");
				$("#"+frmname).find("#rule_condition").removeAttr("disabled");
				$("#"+frmname).find("#rule_condition_value").removeAttr("disabled");

				$("#"+frmname).find('#rule_condition option[value="greater_than"]').remove();
				$("#"+frmname).find('#rule_condition option[value="less_than"]').remove();

				$("#"+frmname).find("#verify_condition").append($("<option></option>").attr("value","sku").text("SKU"));
				$("#"+frmname).find("#verify_condition").append($("<option></option>").attr("value","product").text("Product"));
				$("#"+frmname).find("#verify_condition").append($("<option></option>").attr("value","product_type").text("Product Type"));
				$("#"+frmname).find("#verify_condition").append($("<option></option>").attr("value","catalog").text("Catalog"));
				$("#"+frmname).find("#verify_condition").append($("<option></option>").attr("value","manufacturer").text("Manufacturer"));
				$("#"+frmname).find("#verify_condition").append($("<option></option>").attr("value","tag").text("Tag"));

				$("#"+frmname).find(".rule_element_value").css("display", "block");
				$("#"+frmname).find(".rule_element_value").parent().removeClass("d-none");
				$("#"+frmname).find(".rule_element_value").attr("id", "rule_condition_value");
				$("#"+frmname).find(".rule_element_value").parent().parent().append('<input type="hidden" id="rule_condition_key" name="rule_condition_value" />');


				$("#"+frmname).find(".rule_value_cart_attr").css("display", "none");
				$("#"+frmname).find("#rule_condition").attr('style','display: none !important');
				$("#"+frmname).find(".rule_value_cart_attr").removeAttr("id");
				$("#"+frmname).find(".rule_value_cart_attr").removeAttr("name");
				$("#"+frmname).find(".rule_value_cart_attr").val("");

				addAppliedTo($(".rule_element_value").val(), "", $(".rule_element_value").val());

			} else {

				$("#"+frmname).find('#rule_condition option[value="greater_than"]').remove();
				$("#"+frmname).find('#rule_condition option[value="less_than"]').remove();
				$("#"+frmname).find("#rule_condition").attr('style','display: block !important');
			}
		}

		checkElementOn = function(first=false){
			if($("#slct_element_on").val() == "product" || $("#slct_element_on").val() == "sku"){
				$("#slct_element_on_label").removeAttr("disabled");
			} else {
				let anyPill = ($("#elements_on_container").find("input[name=element_on]").length > 0);
				if(anyPill)
				{
					if(confirm("Select this option will remove all items added below. Are you sure to continue?"))
					{
						$("#slct_element_on_label").attr("disabled", "disabled");
						$("#elements_on_container").html("");						
					}
					else
					{
						$("#slct_element_on").val("product");
					}
				}
				else
				{
					$("#slct_element_on_label").attr("disabled", "disabled");
				}
			}
			$("#slct_element_on_label").val("");
			$("#slct_element_on_label").attr("data-id", "");
			
		}
	});
	
	function delete_selected_on(element){

		$(element).parent().parent().remove();
	}


    function addAppliedTo(type,label,value){

		$(".rule_element_value").on("input", function(ele){
			
			if(ele.target.value.length>1)
			{
				const input = ele.target;
				$.ajax({
					url: '../ajax/getItems.jsp',
					type: 'GET',
					dataType: 'json',
					data: {term: input.value, type: $('#verify_condition').val()},
				})
				.done(function(json) {
					const term = input.value.toLowerCase();
					const parent = input.closest(".form-group");
					
					var autocompleteList = input.nextElementSibling;
					if(autocompleteList==null)
					{
						autocompleteList=document.createElement("ul");
						autocompleteList.classList.add("autocomplete-items","p-0","w-100");
						autocompleteList.style.listStyleType="none";
						autocompleteList.style.borderTop="none";
						autocompleteList.style.border="1px solid #ddd";
					}
					else{
						autocompleteList.innerHTML="";
					}

					json.forEach(function(tag) {
						const suggestion = document.createElement('li');
						var newText;
						newText = tag.value;
						suggestion.innerHTML = `<a style="cursor:pointer;" title="${newText}" id="${tag.id}">${newText}</a>`;
						suggestion.addEventListener('mousedown', function(e) {
							
							var parentElement = e.target.closest(".form-group");
							var docEle = e.target;
							if(docEle.tagName.toLowerCase()!="a")
								docEle = docEle.querySelector("a");

							input.value = docEle.innerText.trim();	
							parentElement.querySelector("#rule_condition_key").value = docEle.id;
							autocompleteList.outerHTML="";
						});
						
						autocompleteList.appendChild(suggestion);
						const parent = input.parentElement;
						const oldAutocompleteList = parent.querySelector('.autocomplete-items');
						if (oldAutocompleteList) {
							parent.removeChild(oldAutocompleteList);
						}
						parent.appendChild(autocompleteList);
					});
				})
				.fail(function() {
					console.log("error");
					alert("Error connecting with server");
				});
			}
			else
			{
				const parent = ele.target.closest(".form-group");
				if(parent.querySelector(".autocomplete-items"))
				parent.querySelector(".autocomplete-items").outerHTML="";
			}
		});

        $('.rule_element_value').val(label);
    }

    function verify_condition_method(){

		$(".rule_value_cart_attr").on("input", function(ele){
			
			if(ele.target.value.length>1)
			{
				const input = ele.target;
				$.ajax({
					url: '../ajax/getItems.jsp',
					type: 'GET',
					dataType: 'json',
					data: {term: input.value, type: $('#verify_condition').val()},
				})
				.done(function(json) {
					const term = input.value.toLowerCase();
					const parent = input.closest(".form-group");
					
					var autocompleteList = input.nextElementSibling;
					if(autocompleteList==null)
					{
						autocompleteList=document.createElement("ul");
						autocompleteList.classList.add("autocomplete-items","p-0","w-100");
						autocompleteList.style.listStyleType="none";
						autocompleteList.style.borderTop="none";
						autocompleteList.style.border="1px solid #ddd";
					}
					else{
						autocompleteList.innerHTML="";
					}

					json.forEach(function(tag) {
						const suggestion = document.createElement('li');
						var newText;
						newText = tag.value;
						suggestion.innerHTML = `<a style="cursor:pointer;" title="${newText}" id="${tag.id}">${newText}</a>`;
						suggestion.addEventListener('mousedown', function(e) {
							var docEle = e.target;
							if(docEle.tagName.toLowerCase()!="a")
								docEle = docEle.querySelector("a");
							
							input.value = docEle.innerText.trim();
							document.getElementById("rule_condition_key").value = docEle.id;
							autocompleteList.outerHTML="";
						});
						
						autocompleteList.appendChild(suggestion);
						const parent = input.parentElement;
						const oldAutocompleteList = parent.querySelector('.autocomplete-items');
						if (oldAutocompleteList) {
							parent.removeChild(oldAutocompleteList);
						}
						parent.appendChild(autocompleteList);
					});
				})
				.fail(function() {
					console.log("error");
					alert("Error connecting with server");
				});
			}
			else
			{
				const parent = ele.target.closest(".form-group");
				if(parent.querySelector(".autocomplete-items"))
				parent.querySelector(".autocomplete-items").outerHTML="";
			}
		});

    }

	function add_selected_element()
	{
		console.log($("#slct_element_on").val());
		console.log($("#slct_element_on_label").val());
		console.log($("#slct_element_on_label").attr("data-id"));
		if($("#slct_element_on").val() == "product" || $("#slct_element_on").val() == "sku")
		{
			if($("#slct_element_on_label").val() != "" && $("#slct_element_on_label").attr("data-id") != "")
			{
				let h = `<div style="margin-left: 20px; margin-top: 10px;"><button class="btn btn-pill btn-block btn-secondary" type="button">
						<strong onclick="delete_selected_on(this)" style="color:#f16e00; cursor: pointer;">X</strong>
							`+$("#slct_element_on_label").val()+`
						</button>
						<input type="hidden" name="element_on" value='`+$("#slct_element_on").val()+`' />
						<input type="hidden" name="element_on_value" value='`+$("#slct_element_on_label").attr("data-id")+`' /></div>`;
				$("#elements_on_container").append(h);
				
				$("#slct_element_on_label").val("");
				$("#slct_element_on_label").attr("data-id", "");
			}
		}
		else
		{
			$("#elements_on_container").append(h);
		}
	}

    function initProductAC(){

		$("#slct_element_on_label").on("input", function(ele){
			
			if(ele.target.value.length>1)
			{
				const input = ele.target;
				$(input).attr("data-id", "");
				$.ajax({
					url: '../ajax/getItems.jsp',
					type: 'GET',
					dataType: 'json',
					data: {term: input.value, type: $('#slct_element_on').val()},
				})
				.done(function(json) {
					const term = input.value.toLowerCase();
					const parent = input.closest(".form-group");
					
					var autocompleteList = input.nextElementSibling;
					if(autocompleteList==null)
					{
						autocompleteList=document.createElement("ul");
						autocompleteList.classList.add("autocomplete-items","p-0","w-100");
						autocompleteList.style.listStyleType="none";
						autocompleteList.style.borderTop="none";
						autocompleteList.style.border="1px solid #ddd";
					}
					else{
						autocompleteList.innerHTML="";
					}

					json.forEach(function(tag) {

						const suggestion = document.createElement('li');
						var newText;
						newText = tag.value;
						suggestion.innerHTML = `<a style="cursor:pointer;" title="${newText}" id="${tag.id}">${newText}</a>`;
						suggestion.addEventListener('mousedown', function(e) {

							var parentElement = e.target.closest(".form-group");
							var docEle = e.target;
							if(docEle.tagName.toLowerCase()!="a")
								docEle = docEle.querySelector("a");
							
							input.value = docEle.innerText;
							$(input).attr("data-id", docEle.id);
							autocompleteList.outerHTML="";
							
						});
						
						autocompleteList.appendChild(suggestion);
						const parent = input.parentElement;
						const oldAutocompleteList = parent.querySelector('.autocomplete-items');
						if (oldAutocompleteList) {
							parent.removeChild(oldAutocompleteList);
						}
						parent.appendChild(autocompleteList);
					});
				})
				.fail(function() {
					console.log("error");
					alert("Error connecting with server");
				});
			}
			else
			{
				const parent = ele.target.closest(".form-group");
				if(parent.querySelector(".autocomplete-items"))
				parent.querySelector(".autocomplete-items").outerHTML="";
			}
		});

    }

	function ondelete(tid)
	{
		if(confirm("Are you sure to delete this cart rule?"))
		{
			document.frm.delete_id.value= tid;
			document.frm.submit();
		}
	}
	function search()
	{
		document.frm.issave.value = "0";
		document.frm.submit();
	}

	function oncopy(sid)
	{
		openCopyDialog(sid);
	}

	function openCopyDialog(sid){
		var copyDialog = $('#copyPromotionDialog');

		$('#copyPromotionId').val(sid);
		$('#copyPromotionNewName').val("");

		copyDialog.find('.infoMsg').html("");
		copyDialog.find('.errorMsg').html("");

		copyDialog.modal("show");

	}
    editModal=function(id){
        if(id){
            $("#edit_cart_rule").find('.modal-title').html("Edit cart rule");

            $.ajax({
                url : '../ajax/cartrules.jsp',
                type: 'POST',
                dataType: 'HTML',
                data: {
                    "action": 'cart_rules',
                    "id": id
                },
                success : function(response)
                {


                    var startDate;
                    var endDate;
                    $("#edit_cart_rule_content").html(response);

                    flatpickr('#start_date', {
						dateFormat: 'Y-m-d H:i:S',
						minDate: 'today',
						enableTime: true,
						onChange: function(selectedDates, dateStr, instance) {
							const endDatePicker = document.querySelector('#end_date');
							const endDate = endDatePicker._flatpickr;
							if (endDate) {
								endDate.set('minDate', selectedDates[0]);
							}
						},
					});

					flatpickr('#end_date', {
						dateFormat: 'Y-m-d H:i:S',
						minDate: 'today',
						enableTime: true,
						onClose: function(selectedDates, dateStr, instance) {
							const startDatePicker = document.querySelector('#start_date');
							const startDate = startDatePicker._flatpickr;
							if (startDate) {
								const selectedStartDate = startDate.selectedDates[0];
								if (selectedStartDate && selectedStartDate > selectedDates[0]) {
									alert('End date is not lesser than start date.');
									startDate.clear();
								}
							}
						},
					});


                    if($("#rule_type").val() == ""){

                        $("#verify_condition").attr("disabled", "disabled");
                        $("#rule_condition").attr("disabled", "disabled");
                        $("#rule_condition_value").attr("disabled", "disabled");

                    }

                    verify_condition_method();

                    if($("#rule_type").val() == "cart_product"){

                        addAppliedTo($(".rule_element_value").val(), $(".rule_element_value").val(), $(".rule_element_value").val());
                    }


                    $(".rule_value_cart_attr").focusout(function(){

                        if($("#verify_condition").val() == "total_quantity" || $("#verify_condition").val() == "total_amount"){

                            $("#rule_condition_key").val($(this).val());
                        }

                    });

					initProductAC();
					checkElementOn(true);

                }
            });

        }
    }

	function copyPromotion(){

		var dialogDiv = $('#copyPromotionDialog');
		var promoNewName = $('#copyPromotionNewName').val().trim();

		//validations
		if(promoNewName === ""){
			alert("Error: promotion name cannot be empty.");
			return false;
		}

		if(!confirm("Are you sure to copy?")){
			return false;
		}
		var errorMsg = dialogDiv.find('.errorMsg');
		var infoMsg = dialogDiv.find('.infoMsg');

		errorMsg.html("");
		infoMsg.html("");

		//call recursive function
		var promotionId = $('#copyPromotionId').val();

        showLoader();
        var params = {
                promotionId : promotionId,
                promotionNewName : promoNewName,
                action : 'copyCartRulePromotion'
        };

        $.ajax({
            type :  'POST',
            url :   '../ajax/cartrules.jsp',
            data :  params,
            dataType : "json",
            cache : false,
            success:function(response){

                if(response["status"] !== "ERROR"){
                        infoMsg.html("Promotion copied successfullly. Refreshing list...");
                        window.location.href = window.location.href;
                }
            },
            complete : function(){
                hideLoader();
            }
        });
	}

</script>
</body>
</html>

<%

	if(isSave.equals("1")){
%>

		<script type="text/javascript">
			$("#save_promotions").css("display","block");
		</script>
<%
	}

	if(isEdit.equals("1")){
%>

		<script type="text/javascript">
			$("#edit_promotions").css("display","block");
		</script>

<%
	}
%>
