<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%
	request.setCharacterEncoding("utf-8");
	response.setCharacterEncoding("utf-8");
%>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.asimina.util.UIHelper"%>
<%@ page import="java.util.Map,java.time.LocalDate,java.time.Month"%>
<%@ page import="java.util.LinkedHashMap, com.etn.beans.app.GlobalParm, org.apache.poi.ss.formula.functions.Column"%>

<%@ include file="../common.jsp" %>

<%
	String siteId=(String)session.getAttribute("SELECTED_SITE_ID");
	String startDt = parseNull(request.getParameter("startDate"));
	String endDt = parseNull(request.getParameter("endDate"));
	
	if(startDt.length() == 0||  endDt.length() ==0){
		endDt =LocalDate.now().toString().replace("-","");
		startDt = LocalDate.now().minusMonths(2).toString().replace("-","");
	}

	String query="SELECT DISTINCT count(crt_itms.id) as cart_items,crt.*,CASE WHEN COALESCE(crt.payment_method,'')!='' THEN 'Step number 3' "
		+"WHEN COALESCE(crt.delivery_method,'')!='' THEN 'Step number 2'"
		+ "  WHEN COALESCE(crt.name,'')!='' THEN 'Step number 1'   ELSE 'Step number 0' END AS step, "
		+ "DATE_FORMAT(crt.created_on, '%d/%m/%Y') as fmt_created_on, pm.displayName as paymentMethodName,"
		+"dm.displayName as deliveryMethodName,crt.visited_cart_page as visited FROM " 
		+ GlobalParm.getParm("PORTAL_DB") + ".cart crt "
		+ "LEFT JOIN "+ GlobalParm.getParm("PORTAL_DB") + ".cart_items crt_itms ON crt_itms.cart_id=crt.id "
		+ "LEFT JOIN "+ GlobalParm.getParm("CATALOG_DB") + ".payment_methods pm ON pm.site_id = crt.site_id AND pm.method = crt.payment_method "
		+ "LEFT JOIN " + GlobalParm.getParm("CATALOG_DB") + ".delivery_methods dm ON dm.site_id = crt.site_id AND dm.method = crt.delivery_method "
		+"AND COALESCE(dm.subType,'') = COALESCE(crt.delivery_type,'') "
		+" WHERE (crt.created_on BETWEEN " + escape.cote(startDt + "000000")+ " AND " + escape.cote(endDt + "235959")+ ") and crt.site_id="+escape.cote(siteId)
		+" GROUP BY crt.id ORDER BY crt.id DESC";

	Set rsCartInfo = Etn.execute(query);
%>
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
		<title>Incomplete Carts</title>



		<link href="<%=request.getContextPath()%>/css/coreui.css" rel="stylesheet">
		<link href="<%=request.getContextPath()%>/css/my.css" rel="stylesheet">
		<link href="<%=request.getContextPath()%>/css/coreui-icons.min.css" rel="stylesheet">
		<link href="<%=request.getContextPath()%>/css/font-awesome.min.css" rel="stylesheet">
		<link href="<%=request.getContextPath()%>/css/simple-line-icons.css" rel="stylesheet">
		<link href="<%=request.getContextPath()%>/css/jquery-ui.min.css" rel="stylesheet">
		<link href="<%=request.getContextPath()%>/css/datatables.min.css" rel="stylesheet">
		<link href="<%=request.getContextPath()%>/css/flatpickr.min.css" rel="stylesheet">
		<link href="<%=request.getContextPath()%>/css/moringa-cui.css" rel="stylesheet">


		<script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
		<script src="<%=request.getContextPath()%>/js2/common.js"></script>
		<script src="<%=request.getContextPath()%>/js/common.js"></script>
		<script src="<%=request.getContextPath()%>/js/popper.min.js"></script>
		<script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>
		<script src="<%=request.getContextPath()%>/js/coreui.min.js"></script>
		<script src="<%=request.getContextPath()%>/js/feather.js"></script>
		<script src="<%=request.getContextPath()%>/js/moment.min.js"></script>
		<script src="<%=request.getContextPath()%>/js/flatpickr.min.js"></script>
		<script src="<%=request.getContextPath()%>/js/feather.min.js?v=2.28.0"></script>
		<script src="<%=request.getContextPath()%>/js/datatables.min.js"></script>
		<script src="<%=request.getContextPath()%>/js/rangePlugin.js"></script>
		<script src="<%=request.getContextPath()%>/js/datetime-moment.js"></script>


	</head>
	<body class="c-app" style="background-color:#efefef">
		<%@ include file="/WEB-INF/include/sidebar.jsp" %>
		<div class="c-wrapper c-fixed-components">
			<%@ include file="/WEB-INF/include/header.jsp" %>
			<div class="c-body">
				<main class="c-main"  style="padding:0px 30px">
					<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
						<div>
							<h1 class="h2">Incomplete Carts</h1>
							<p class="lead"></p>
							
							<a href="exportCart.jsp?startDate=<%=UIHelper.escapeCoteValue(startDt)%>&endDate=<%=UIHelper.escapeCoteValue(endDt)%>"target="_blank">
								<button id="exportDiv" type="button" class="btn btn-primary" >Export Excel
								</button>
							</a>
						</div>

					</div>
					<div class="">
						<div class="mb-3">
							<div class="d-flex align-items-center justify-content-md-end">

								<div class="mb-3 mb-xl-0">
									<div class="dropdown">
										<button id="reportrange" class="float-right reportrange" type="button" data-toggle="dropdown" style="background: #fff; cursor: pointer; padding: 6px 10px; border: 1px solid #ccc; ; display: inline-flex; vertical-align: middle;border-radius: .25rem;">
											&nbsp;
											<span></span>
										</button>
										<div class="dropdown-menu">
											<button class="dropdown-item" type="button" data-range="today" >Today</button>
											<button class="dropdown-item" type="button" data-range="yesterday" >Yesterday</button>
											<button class="dropdown-item" type="button" data-range="7days" >Last 7 Days</button>
											<button class="dropdown-item" type="button" data-range="30days" >Last 30 Days</button>
											<button class="dropdown-item" type="button" data-range="this-month" >This Month</button>
											<button class="dropdown-item" type="button" data-range="last-month" >Last Month</button>
											<button class="dropdown-item" type="button" data-range="this-year" >This Year</button>
											<button class="dropdown-item" type="button" data-range="last-year" >Last Year</button>
											<button class="dropdown-item" type="button" id="flatpickr" >Custom Range</button>
										</div>
									</div>
								</div>
							</div>
						</div>

						<div class="animated fadeIn">
							<div class="">
								<table class="table table-hover table-vam m-t-20" id="cartInfoTbl">
									<thead class="thead-dark">
											<th>Cart Date</th>
											<th>First Name</th>
											<th>Last Name</th>
											<th>Email</th>
											<th>Phone Number</th>
											<th>Payment Method</th>
											<th>Delivery Method</th>
											<th>Step</th>
                                            <th>Cart Saved?</th>
									</thead>
									<tbody>
										<%while(rsCartInfo.next()){
											String step="";
											if(parseNull(rsCartInfo.value("visited")).equals("0")){
												step="Add to cart";
												
											}else if(parseNull(rsCartInfo.value("cart_items")).equals("0")){
												step="Empty Cart";
											}else{
												if(parseNull(rsCartInfo.value("step")).equalsIgnoreCase("step number 0")){
													step="Cart";
												}
												else if(parseNull(rsCartInfo.value("step")).equalsIgnoreCase("step number 1")){
													step="Personal Details";
												}
												else if(parseNull(rsCartInfo.value("step")).equalsIgnoreCase("step number 2")){
													step="Delivery Mode";
												}
												else if(parseNull(rsCartInfo.value("step")).equalsIgnoreCase("step number 3")){
													step="Payment Method";
												}
											}
										%>
											<tr style="cursor:pointer" data-id="<%=UIHelper.escapeCoteValue(parseNull(rsCartInfo.value("id")))%>" >
												<td align="left">
													<%=UIHelper.escapeCoteValue(parseNull(rsCartInfo.value("fmt_created_on")))%>
												</td>
												<td align="left">
													<%=UIHelper.escapeCoteValue(parseNull(rsCartInfo.value("name")))%>
												</td>
												<td align="left">
													<%=UIHelper.escapeCoteValue(parseNull(rsCartInfo.value("surnames")))%>
												</td>
												<td align="left">
													<%=UIHelper.escapeCoteValue(parseNull(rsCartInfo.value("email")))%>
												</td>
												<td align="left">
													<%=UIHelper.escapeCoteValue(parseNull(rsCartInfo.value("contactPhoneNumber1")))%>
												</td>
												<td align="left">
													<%=UIHelper.escapeCoteValue(parseNull(rsCartInfo.value("paymentMethodName")))%>
												</td>
												<td align="left">
													<%=UIHelper.escapeCoteValue(parseNull(rsCartInfo.value("deliveryMethodName")))%>
												</td>
												<td align="left">
													<%=UIHelper.escapeCoteValue(step)%>
												</td>
                                                <td align="left">
                                                    <%=UIHelper.escapeCoteValue(parseNull(rsCartInfo.value("keepEmail")))%>
                                                </td>
											</tr>
										<%}%>
									</tbody>
								</table>
							</div>
						</div>
					</div>
				</main>


			</div>
			<%@ include file="../WEB-INF/include/footer.jsp" %>
		</div>

<div class="modal fade" id="orderDetailModal" tabindex="-1" role="dialog" data-backdrop="static">
    <div class="modal-dialog modal-dialog-slideout modal-xl" role="document">
        <div class="modal-content">
            <form id="orderDetailModalForm" action="" onsubmit="return false;">
                <div class="modal-header">
                    <h1 class="modal-title">Order Details</h1>
                    <div class="text-right">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                </div>
                <div class="modal-body p-4">
                    <div id="customer_form_main_div">
                        <h2 class="modal-title">Customer Information</h2>
                        <div id="customer_form" class="row">
                        </div>
                    </div>
                    <div id="order_form_main_div">
                        <div id="delivery_form_div" class="mt-3">
                            <h3 class="modal-title">Delivery Information</h3>
                            <div id="delivery_form" class="row">
                            </div>
                        </div>
                        <div id="billing_form_div" class="mt-3">
                            <h3 class="modal-title">Billing Information</h3>
                            <div id="billing_form" class="row">
                            </div>
                        </div>
                        <div class="mt-3">
                            <h3 class="modal-title">Cart Items</h3>
							<div class="col-sm-12">							
                            <table id="items_table" class="table table-hover table-vam m-t-20 mt-3 " style="width:99%">
                                <thead class="thead-dark">
                                    <th>SKU</th>
                                    <th>Variant</th>
                                    <th>Quantity</th>
                                </thead>
                                <tbody id="items_body" class="">

                                </tbody>

                            </table>
							</div>
                        </div>
                        <div id="payment_main_div" class="mt-5">
                            <h3 class="modal-title">Payment Information</h3>
							<div class="col-sm-12">							
                            <table id="payment_table" class="table table-hover table-vam m-t-20 mt-3"  style="width:99%">
                                <thead class="thead-dark">
                                    <th>Payment Method</th>
                                    <th>Payment Status</th>
                                    <th>Total Price</th>
                                </thead>
                                <tbody id="payment_body" class="">

                                </tbody>

                            </table>
							</div>
                        </div>
                    </div>
                </div>
            </form>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div>
<!-- /.modal -->


	<script type="text/javascript">

		var startDate = "";
		var endDate = "";

		$(document).ready(function() {
			var start = '<%=UIHelper.escapeCoteValue(startDt)%>'.length>0? moment('<%=UIHelper.escapeCoteValue(startDt)%>',"YYYYMMDD") : moment().subtract(6, 'days');
			var end = '<%=UIHelper.escapeCoteValue(endDt)%>'.length>0? moment('<%=UIHelper.escapeCoteValue(endDt)%>',"YYYYMMDD") : moment();
			cb(start,end);
			
			startDate = flatpickr.formatDate(start[0] || start._d,'Ymd');
			endDate = flatpickr.formatDate(start[1] || end._d,'Ymd');


			if(sessionStorage.getItem('pendingCartsInfoPageLength')==null){
				sessionStorage.setItem('pendingCartsInfoPageLength', 100);
			}

			$(".dropdown-menu button").on("click", function(e){
				if(e.target.id == "flatpickr") return;

				var parent = e.target.parentElement;
				if(parent.querySelector(".active")!=null)
				{
					parent.querySelector(".active").classList.remove("active");
				}

				if(e.target.dataset.range.toLowerCase()=='today')
				{
					startDate = moment();
					endDate = moment();

				}else if(e.target.dataset.range.toLowerCase()=='yesterday')
				{
					startDate = moment().subtract(1,"days");
					endDate = moment().subtract(1,"days");
				}
				else if(e.target.dataset.range.toLowerCase()=='7days')
				{
					startDate = moment().subtract(6, 'days');
					endDate = moment();
				}
				else if(e.target.dataset.range.toLowerCase()=='30days')
				{
					startDate = moment().subtract(29, 'days');
					endDate = moment();
				}
				else if(e.target.dataset.range.toLowerCase()=='this-month')
				{
					startDate = moment().startOf('month');
					endDate = moment();
				}
				else if(e.target.dataset.range.toLowerCase()=='last-month')
				{
					startDate = moment().subtract(1,"month").startOf("month");
					endDate = moment().subtract(1,"month").endOf("month");
				}
				else if(e.target.dataset.range.toLowerCase()=='this-year')
				{
					startDate = moment().startOf("year");
					endDate = moment();
				}
				else if(e.target.dataset.range.toLowerCase()=='last-year')
				{
					startDate = moment().subtract(1,"year").startOf("year");
					endDate = moment().subtract(1,"year").endOf("year");
				}

				onDateChange(startDate, endDate);
			});

			$('#cartInfoTbl').DataTable({
				responsive: true,
				filter: true,
				deferRender: true,
				"searching": true,
				order : [[0,'desc']],
				lengthMenu: [[100,250,375,500, -1], [100,250,375,500, 'All']],
				pageLength : parseInt(sessionStorage.getItem('pendingCartsInfoPageLength')),
				columnDefs: [
					{
						targets: [0],
						render: function (data, type, row) {
							return  moment(data)._i;
						}
					},
				],
			});

			$('#cartInfoTbl').on("click","tr", function (field, value, row, $el) {
				var cartId = parseInt($(this).data("id"));
				$.ajax({
					type: "GET",
					url: "<%=request.getContextPath()%>/admin/getCartData.jsp?cartId="+cartId,
					success: function(response){
						openIncompleteModal(response.orderInfo,response.customerInfo)
					},
					error:function (){
					}

				});
			});

			adjustheight();

			flatpickr("#flatpickr", {
				mode: 'range',
				minDate: new Date(1000, 1, 01),
				maxDate: new Date(),
				dateFormat: 'd/m/Y',
				onClose: onDateChange,
				shorthandCurrentMonth: true,
			});

			$("#flatpickr").on("click",function(e){
				e.preventDefault();
			})  

		});

		function openIncompleteModal(orderInfo,customerInfo) {

			let form = $('#orderDetailModalForm');
			form.get(0).reset();
			$('#payment_main_div').css('display','inline');
			$('#customer_form_main_div').css('display','inline');
			$('#delivery_form_div').css('display','inline');
			$('#billing_form_div').css('display','inline');

			$('#payment_body').html("")
			$('#items_body').html("")
			$('#customer_form').html("")
			$('#delivery_form').html("")
			$('#billing_form').html("")

			let modal = $('#orderDetailModal');
			let delivernfo =orderInfo.deliveryInfo
			let billingInfo =orderInfo.billingInfo
			let itemsInfo =orderInfo.cartItems
			let paymentInfo =orderInfo.paymentRefs
			let deliveryLabels={"deliverymethodname":"Delivery Method:","daline1":"Address 1:","daline2":"Address 2","datowncity":"Town/City:","dapostalcode":"Postal Code:"}
			let billingLabels={"baline1":"Address 1:","baline2":"Address 2","batowncity":"Town/City:","bapostalcode":"Postal Code:"}
			let customeInfoLabels={"name":"Name:","surnames":"Sr-name:","email":"Email:","newphonenumber":"Phone Number:","country":"Country:"}

			for (const item in customerInfo) {
				if(customerInfo[item]) {
					$('#customer_form').append("<div class='form-group col-sm-6 mt-3'><label class='col-sm-12' id='"+item+"_label'>"+customeInfoLabels[item]+"</label><div class='col-sm-12 mt-1'><input class='form-control' id='" + item + "_input' type='text' value='" + customerInfo[item] + "' readonly></div></div>");
				}
			}
			for (const item in delivernfo) {
				if (delivernfo[item] ) {
					$('#delivery_form').append("<div class='form-group col-sm-6 mt-3'><label class='col-sm-12' id='"+item+"_label'>"+deliveryLabels[item]+"</label><div class='col-sm-12 mt-1'><input class='form-control' id='" + item + "_input' type='text' value='" + delivernfo[item] + "' readonly></div></div>");
				}
			}
			for (const item in billingInfo) {
				if(billingInfo[item]) {
					$('#billing_form').append("<div class='form-group col-sm-6 mt-3'><label class='col-sm-12' id='"+item+"_label'>"+billingLabels[item]+"</label><div class='col-sm-12 mt-1'><input class='form-control' id='" + item + "_input' type='text' value='" + billingInfo[item] + "' readonly></div></div>");
				}
			}

			for(let i=0;i<itemsInfo.length;i++){
				$('#items_body').append("<tr><td>"+itemsInfo[i].sku+"</td><td>"+itemsInfo[i].variant_name+"</td><td>"+itemsInfo[i].quantity+"</td></tr>")
			}
			for(let i=0;i<paymentInfo.length;i++){
				let rowColor="";
				if(paymentInfo[i].payment_status==="EXPIRED"){
					rowColor="table-danger";
				}else if(paymentInfo[i].payment_status==="SUCCESS"){
					rowColor="table-success";
				}else{
					rowColor="table-secondary";
				}
				$('#payment_body').append("<tr class="+rowColor+"><td>"+paymentInfo[i].paymentmethodname+"</td><td>"+paymentInfo[i].payment_status+"</td><td>"+paymentInfo[i].total_price+"</td></tr>")
			}
			if ($('#payment_table > tbody > tr').length == 0){
				$('#payment_main_div').css('display','none');
			}
			if ($('#customer_form').children().length == 0){
				$('#customer_form_main_div').css('display','none');
			}
			if ($('#delivery_form').children().length == 0){
				$('#delivery_form_div').css('display','none');
			}
			if ($('#billing_form').children().length == 0){
				$('#billing_form_div').css('display','none');
			}
			modal.modal('show');
		}

		$('#cartInfoTbl').on( 'length.dt', function ( e, settings, len ) {
			sessionStorage.setItem('pendingCartsInfoPageLength', len);
		} );

		function adjustheight(){
			$('#customerEditCard .card-body').height( window.outerHeight - $('.app-header').height() - $('.breadcrumb').height() - $('.app-footer').height()-48)
		}

		function cb(start, end) {
			$('.reportrange span').html(flatpickr.formatDate(start[0] || start._d,'M d, Y') + ' - ' + flatpickr.formatDate(start[1] || end._d,'M d, Y'));
		}

		function onDateChange(start, end){       
			cb(start, end);
			startDate = flatpickr.formatDate(start[0] || start._d,'Ymd');
			endDate = flatpickr.formatDate(start[1] || end._d,'Ymd');
			if(startDate != '' && endDate !='')
			{
				window.location.href=window.location.origin+window.location.pathname+'?startDate='+startDate+"&endDate="+endDate;
			}
			//$('#orderTbl').DataTable().ajax.reload();
		}
	</script>
	
</body>
	
</html>

