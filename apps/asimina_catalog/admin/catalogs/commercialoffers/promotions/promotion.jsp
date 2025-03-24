<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm"%>
<%@ page import="com.google.gson.*,com.google.gson.reflect.TypeToken" %>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="/admin/common.jsp"%>
<%

	LinkedHashMap<String, String> discount_types = new LinkedHashMap<String, String>();
	discount_types.put("percentage","% (-)");
	discount_types.put("fixed","-");

	LinkedHashMap<String, String> selection_types = new LinkedHashMap<String, String>();
	selection_types.put("","");
	selection_types.put("sku","SKU");
	selection_types.put("product","Product");
	selection_types.put("product_type","Product Type");
	selection_types.put("catalog","Catalog");
	selection_types.put("manufacturer","Manufacturer");
	selection_types.put("tag","Tag");

	LinkedHashMap<String, String> feedbackDDValues = new LinkedHashMap<String, String>();
	feedbackDDValues.put("all","All Users");
	feedbackDDValues.put("logged","Logged-in Users");

	LinkedHashMap<String, String> flash_sale_types = new LinkedHashMap<String, String>();
	flash_sale_types.put("no","No");
	flash_sale_types.put("time","Time");
	flash_sale_types.put("quantity","Quantity");

	String id = parseNull(request.getParameter("id"));;

	Set rs = null;
        Set rsRules = null;
	if(id.length() > 0)
	{
		rs = Etn.execute("SELECT * FROM promotions WHERE id =  " + escape.cote(id));
		rs.next();
                rsRules = Etn.execute("SELECT * FROM promotions_rules WHERE promotion_id="+escape.cote(id));
	}

	String lastpublish = "";
	String nextpublish = "";

	if(id.length() > 0)
	{
		String process = getProcess("promotion");
		Set rspw = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s') from post_work where status = 0 and phase = 'publish' and client_key = " + escape.cote(id) + " and proces = "+escape.cote(process)+" ");
		if(rspw.next()) nextpublish = parseNull(rspw.value(0));

		rspw = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s') from post_work where status  in (0, 2) and phase = 'published' and client_key = " + escape.cote(id) + " and proces = "+escape.cote(process)+" order by id desc limit 1 ");
		if(rspw.next()) lastpublish = parseNull(rspw.value(0));
	}

	String backto = parseNull(request.getParameter("backto"));
	if(backto.length() == 0) backto = "promotions.jsp";

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html>
<head>

	<title>Promotion Admin <%=getValue(rs, "name")%></title>

	<%@ include file="/WEB-INF/include/head2.jsp"%>

	<style>
	.table tr td {border: 0px;}

        .ui-autocomplete{
                z-index: 99999;
        }

	</style>
</head>

<body >
	<%@ include file="/WEB-INF/include/newmenu2.jsp"%>

	<!-- container -->
	<div class="container">



		<!-- title -->
		<div class="page-header">
			<h1>Edition of: <%=getValue(rs, "name")%></h1>
			<p class="lead"></p>
		</div>
		<!-- /title -->
		<!-- buttons bar -->
		<div class="btn-group m-b-20" role="group" aria-label="...">
			<button type='button' class='btn btn-default btn-primary' onclick='goback()'>Back</button>
			<button type="button" class="btn btn-default btn-primary" onclick='javascript:window.location="promotion.jsp";'>New promotion</button>

		</div>

		<div class="btn-group m-b-20" role="group" aria-label="...">
			<button type="button" class="btn btn-danger" id='prodpublishbtn'>Publish to prod </button>

		</div>
		<!-- /buttons bar -->

	<div id='mycontainer'>
	<!-- messages zone  -->
	<div class='m-b-20'>
		<!-- alert -->

		<!-- /alert -->

		<!-- info -->


				<% if(lastpublish.length() > 0) { %>

				<div id='infoBox' class="alert alert-success" role="alert" >
					<div id=''>Last published on : <%=lastpublish%></div>
				</div>


				<% } %>

				<br/>

				<% if(nextpublish.length() > 0) { %>


				<div id='infoBox' class="alert alert-danger" role="alert" >
					<div id=''><span class="oi oi-info" aria-hidden="true"></span><span class="m-l-10">Next publish on</span><span style='color:red'><%=nextpublish%></span></div>
					<div ><span style='color:red'>WARNING!!!</span> If you make any changes now those will be published also</div>
				</div>


				<% } %>



		<!-- /info -->
	</div>
		<!-- messages zone  -->
	</div>
</div>
<div class="container">



	<form name='promotionForm' id='promotionForm' method='post' action='savepromotion.jsp'  >
		<input type='hidden' name='id' id="promotion_id" value='<%=getValue(rs, "id")%>' />

		<!-- Products Selection -->
		<div class=" m-t-20">
			<div class="alert t-s-grey" role="alert">General Information <span style="float:right; margin:0px 20px"><button type='button' id="selectionSave" class='btn btn-default btn-primary btn-sm' onclick='onsave()'>Save</button></span></div>
		</div>
		<div class="form-horizontal">
                    <div class="form-group row ">
                        <label for="name" class='col-md-2 control-label'>Promo Name: </label>
                        <div class='col-md-4'>
                            <input type="text" id="name" name="name" value="<%=getRsValue(rs, "name")%>" class="form-control" />
                        </div>
                        <label for="name" class='col-md-2 control-label'>Description: </label>
                        <div class='col-md-4'>
                            <textarea id="description" name="description" class="form-control"><%=getRsValue(rs, "description")%></textarea>
                        </div>
                    </div>
                    <div class="form-group row ">
                        <label for="name" class='col-md-2 control-label'>Applicable to: </label>
                        <div class='col-md-4'>
                            <%
                                    ArrayList arr = new ArrayList<String>();
                                    arr.add(getRsValue(rs, "visible_to"));
                            %>
                            <%=addSelectControl("visible_to", "visible_to", feedbackDDValues, arr, "form-control", "", false)%>
                        </div>
                    </div>
                    <div class="form-group row ">
                        <label for="start_date" class='col-md-2 control-label'>Start Date: </label>
                        <div class='col-md-3'>
                            <input type="text" id="start_date" name="start_date" value="<%=getRsValue(rs, "start_date")%>" class="form-control" />
                        </div>
                        <div class='col-md-1'>
                            <button type="button" name="ignore" class="btn btn-warning pull-right" onclick="$('#start_date').val('');" ><span class="oi oi-delete" aria-hidden="true"></span></button>&nbsp;
                        </div>
                        <label for="end_date" class='col-md-2 control-label'>End Date: </label>
                        <div class='col-md-3'>
                            <input type="text" id="end_date" name="end_date" value="<%=getRsValue(rs, "end_date")%>" class="form-control" />
                        </div>
                        <div class='col-md-1'>
                            <button type="button" name="ignore" class="btn btn-warning pull-right" onclick="$('#end_date').val('');" ><span class="oi oi-delete" aria-hidden="true"></span></button>&nbsp;
                        </div>
                    </div>
                    <div class="form-group row ">
                        <label for="flash_sale" class='col-md-2 control-label'>Flash Sale: </label>
                        <div class='col-md-4'>
                            <%
                                    arr = new ArrayList<String>();
                                    arr.add(getRsValue(rs, "flash_sale"));
                            %>
                            <%=addSelectControl("", "flash_sale", flash_sale_types, arr, "form-control", "", false)%>
                        </div>
                        <label for="duration" class='col-md-2 control-label'>Duration (if recurring): </label>
                        <div class='col-md-4'>
                            <input type="text" id="duration" name="duration" value="<%=getRsValue(rs, "duration")%>" class="form-control" />
                        </div>
                    </div>
                    <div class="form-group row ">
                        <label for="flash_sale_quantity" class='col-md-2 control-label'>Quantity (Flash Sale): </label>
                        <div class='col-md-4'>
                            <input type="text" id="flash_sale_quantity" name="flash_sale_quantity" value="<%=getRsValue(rs, "flash_sale_quantity")%>" class="form-control" />
                        </div>
                    </div>
		</div>
		<!-- /Products Selection -->

		<!-- Rule -->
		<div class=" m-t-20">
			<div class="alert t-s-grey" role="alert">Rule <span style="float:right; margin:0px 20px"><button type='button' id="selectionSave" class='btn btn-default btn-primary btn-sm' onclick='onsave()'>Save</button></span></div>
		</div>
		<div class="form-horizontal">
                            <div class="form-group row">
                                <label for="discount_value" class='col-md-2 control-label'>Apply Price Diff: </label>
                                <div class='col-md-1'>
                                    <input type="text" id="discount_value" name="discount_value" value="<%=getRsValue(rs, "discount_value")%>" class="form-control" />
                                </div>
                                <div class='col-md-1'>
                                    <%
                                            arr = new ArrayList<String>();
                                            arr.add(getRsValue(rs, "discount_type"));
                                    %>
                                    <%=addSelectControl("discount_type", "discount_type", discount_types, arr, "form-control", "", false)%>
                                </div>
                                <label for="" class='col-md-2 control-label'>to products having: </label>
                                <div id="appliedToContainer" class='col-md-6'>
                                    <div id="appliedToTemplate" style="display:none;">
                                        <div class="form-group row">
                                            <div class='col-md-4'>
                                            <%
                                                    arr = new ArrayList<String>();
                                            %>
                                            <%=addSelectControl("", "applied_to_type", selection_types, arr, "form-control applied_to_type", "", false)%>
                                            </div>
                                            <div class='col-md-6'>
                                                <input type="text" name="" value="" class="form-control applied_to_value" />
                                                <input type="hidden" name="applied_to_value" value="" class="form-control applied_to_actual_value" />
                                            </div>
                                            <div class='col-md-2'>
                                                <button type="button" onclick='removeAppliedTo(this);' class='btn btn-default text-danger pull-right'><i class="oi oi-x" aria-hidden="true"></i></button>
                                            </div>
                                        </div>
                                    </div>
                                <script>
                                    jQuery(document).ready(function() {
                                    <%

                                    while(rsRules!=null&&rsRules.next()){
                                        String label = getRsValue(rsRules, "applied_to_value");
                                        String type = getRsValue(rsRules, "applied_to_type");
                                        String value = getRsValue(rsRules, "applied_to_value");

                                        Set rsValue = null;
                                        if(type.equals("product")){
                                            rsValue = Etn.execute("select lang_1_name from products where id = "+escape.cote(value));
                                            if(rsValue.next()){
                                                label = rsValue.value(0);
                                            }
                                        }
                                        else if(type.equals("catalog")){
                                            rsValue = Etn.execute("select name from catalogs where id = "+escape.cote(value));
                                            if(rsValue.next()){
                                                label = rsValue.value(0);
                                            }
                                        }
                                        else if(type.equals("product_type")){
                                            rsValue = Etn.execute("select name from catalog_types where value = "+escape.cote(value));
                                            if(rsValue.next()){
                                                label = rsValue.value(0);
                                            }
                                        }

                                    %>
                                        addAppliedTo('<%=type%>','<%=label%>','<%=value%>');

                                    <%
                                    }
                                    %>
                                    });
                                </script>
                                </div>
                            </div>
                                <div class="form-group row ">
                                    <div class='col-md-12'>
                                        <button type="button" class="btn btn-default btn-success pull-right" onclick='addAppliedTo();'>+ Add More</button>
                                    </div>
                                </div>
<!--                    <div class="form-group row ">
                        <div class='col-md-6'>
                            <div class="form-group row">
                                <label for="discount_value" class='col-md-4 control-label'>Apply Price Diff: </label>
                                <div class='col-md-2'>
                                    <input type="text" id="discount_value" name="discount_value" value="" class="form-control" />
                                </div>
                                <div class='col-md-2'>
                                    <select class="form-control">
                                        <option value="percentage">% (-)</option>
                                        <option value="fixed">-</option>
                                    </select>
                                </div>
                                <label for="" class='col-md-4 control-label'>if associated to </label>
                            </div>
                            <div class="form-group row">
                                <label for="" class='col-md-4 control-label'>Applicable to: </label>
                                <div class='col-md-4'>
						<%
							arr = new ArrayList<String>();
						%>
                                    <%=addSelectControl("", "visible_to", feedbackDDValues, arr, "form-control", "", false)%>
                                </div>
                            </div>
                        </div>
                        <div class='col-md-6'>
                            <div class="form-group row">
                                <div class='col-md-6'>
                                <%
                                        arr = new ArrayList<String>();
                                %>
                                <%=addSelectControl("", "rule_applied_to_type", selection_types, arr, "form-control", "", false)%>
                                </div>
                                <div class='col-md-6'>
                                    <input type="text" name="rule_applied_to_value" value="" class="form-control" />
                                </div>
                            </div>
                            <div class="form-group row">
                                <div class='col-md-6'>
                                <%
                                        arr = new ArrayList<String>();
                                %>
                                <%=addSelectControl("", "rule_applied_to_type", selection_types, arr, "form-control", "", false)%>
                                </div>
                                <div class='col-md-6'>
                                    <input type="text" name="rule_applied_to_value" value="" class="form-control" />
                                </div>
                            </div>
                        </div>
                    </div>-->
		</div>
		<!-- /Rule -->

	</form>
	</div>

	<br>
	<div style="float: right;"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
	<br>


<!-- .modal -->
	<div class="modal fade" id='publishdlg' title='Publish' style='text-align:center; display:none; clear:both;' ></div>
<!-- /.modal -->



<%
	String prodpushid = id;
	String prodpushtype = "promotion";
%>
<%@ include file="/admin/prodpublishlogin.jsp"%>


</body>
<script type="text/javascript">
	var anythingchanged=  false;

	jQuery(document).ready(function() {

            $("input[type=text]").change(function(){
                    anythingchanged = true;
            });

            $("select").change(function(){
                    anythingchanged = true;
            });

            $("textarea").change(function(){
                    anythingchanged = true;
            });

            flatpickr("#start_date, #end_date", {
                dateFormat: "Y-m-d"
            });


            addAppliedTo();

		onPromotionSave=function()
		{
                    $("#promotionForm").submit();
		};


	});

        function addAppliedTo(type,label,value){
            var div = $('#appliedToTemplate div:first').clone(true);
            div.find('select.applied_to_type').val(type);

            div.find('input.applied_to_value').on("input", function(ele){
			
			if(ele.target.value.length>1)
			{
				const input = ele.target;
				$.ajax({
					url: '../ajax/getItems.jsp',
					type: 'GET',
					dataType: 'json',
					data: {term: input.value, type: div.find('select.applied_to_type').val()},
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
							parentElement.querySelector("input.applied_to_actual_value").value = docEle.id;
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
        div.find('input.applied_to_value').val(label);
        div.find('input.applied_to_actual_value').val(value);
        $('#appliedToContainer').append(div);
        }

        function removeAppliedTo(ele){
		// if( $('#discountPricesList li').length <= 1){
		// 	var msg = "Cannot remove. There must be atleast 1 price";
		// 	alert(msg);
		// 	return false;
		// }
		// else{
			$(ele).parent().parent('div.row').remove();
		// }
	}



</script>
</html>