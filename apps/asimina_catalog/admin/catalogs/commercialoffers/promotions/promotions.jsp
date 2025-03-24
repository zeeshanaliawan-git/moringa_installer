 <jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, com.etn.asimina.util.ActivityLog, java.util.Date, java.text.*, com.etn.beans.app.GlobalParm"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="/admin/common.jsp"%>
<%!

	String getPromotionStatus(com.etn.beans.Contexte Etn, String promotionId)
	{
		String proddb = GlobalParm.getParm("PROD_DB");
		String status = "NOT_PUBLISHED";
		Set rs = Etn.execute("select * from "+proddb+".promotions where id = " + escape.cote(promotionId));
		if(rs.rs.Rows == 0)
		{
			return status;
		}
		status = "PUBLISHED";
		rs = Etn.execute("select case when p1.version = p2.version then '1' else '0' end from promotions p1, "+proddb+".promotions p2 where p1.id = p2.id and p1.id = " + escape.cote(promotionId));
		rs.next();
		if(rs.value(0).equals("0"))
		{
			status = "NEEDS_PUBLISH";
		}
		return status;
	}

	boolean isValidDateRange(String startDateString, String endDateString) throws ParseException {

		DateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
		Date startDate, endDate, currentDate;

		currentDate = df.parse(df.format(new Date()));

		startDate = (startDateString.length() == 0 ? currentDate : df.parse(startDateString));
		endDate = (endDateString.length() == 0 ? currentDate : df.parse(endDateString));

		if(!(currentDate.before(startDate) || currentDate.after(endDate))) return true;

		return false;
	}

    String buildDateFr(String date){

        if(date.length() > 0){

            String token[] = date.split("-");
            return token[2] + "/" + token[1] + "/" + token[0];
        }

        return "";
    }

%>

<%
    String selectedsiteid = parseNull(getSelectedSiteId(session));
	String isSavePromotion = parseNull(request.getParameter("is_save"));
	String isEdit = parseNull(request.getParameter("is_edit"));
	String delete_id = parseNull(request.getParameter("delete_id"));
    String edit_id = parseNull(request.getParameter("edit_id"));
	String errmsg = "";

	String logedInUserId = parseNull(Etn.getId());

	List<Language> langsList = getLangs(Etn,selectedsiteid);
	Language firstLanguage = langsList.get(0);

	if(delete_id.length() == 0) delete_id = "0";

	if(Integer.parseInt(delete_id) > 0)
	{
		Set rsp = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("PROD_DB")+".promotions WHERE id = "+ escape.cote(delete_id));
		if(rsp.rs.Rows > 0)
		{
			errmsg = "Promotion is already in production. Cannot proceed with delete. You must delete from production first";
		}
		else
		{					
			Set rs_name = Etn.execute("select name from promotions where id = " + escape.cote(delete_id));
			rs_name.next();

			Etn.executeCmd("UPDATE promotions_tbl SET is_deleted='1',updated_on=NOW()"+
				",updated_by="+escape.cote(logedInUserId)+" WHERE id = "+escape.cote(delete_id));


			ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),delete_id,"DELETED","Promotion",parseNull(rs_name.value(0)),selectedsiteid);
		}
	}

	String q = "select s.*, lg.name as last_updated_by from promotions s left outer join login lg on lg.pid = s.updated_by WHERE s.site_id = "+escape.cote(selectedsiteid);
    if(edit_id.length()>0){
        q += "and s.id = "+escape.cote(edit_id);
    }
	q += " order by coalesce(s.order_seq,999999), id ";
	Set rs = Etn.execute(q);
%>

<!DOCTYPE html>

<html>
<head>
	<title>Promotions</title>

	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>

<%
breadcrumbs.add(new String[]{"Marketing", ""});
breadcrumbs.add(new String[]{"Promotions", ""});
%>


</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">


			<!-- Title + buttons 2 -->
		<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
			<h1 class="h2">Promotions</h1>
			<p class="lead"></p>

			<!-- buttons bar -->
			<div class="btn-toolbar mb-2 mb-md-0">
				 <div class="btn-group mr-2" role="group" aria-label="...">
					<button type="button" class="btn btn-danger" onclick='onpublish("multi")' id='publishtoprodbtn'>Publish</button>
					<button type="button" class="btn btn-danger" onclick='onpublish("multidelete")' id='unpublishtoprodbtn'>Unpublish</button>
				</div>
				<div class="btn-group mr-2" role="group" aria-label="...">
					<a href="../../../gestion.jsp" class="btn btn-primary" >Back</a>
					<button type="button" class="btn btn-primary" id="saveBtn" onclick='onsave(this)'>Save</button>
				</div>
				<div class="btn-group mr-2" role="group" aria-label="...">
					<button type="button" value="" class="btn btn-success add_promotion" data-toggle="modal" data-target="#add_promotion">Add a promotion</button>

					<button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Promotions');" title="Add to shortcuts">
						<i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
					</button>
				</div>
			</div>
			<!-- /buttons bar -->
		</div>
	<!-- /Title + buttons 2 -->

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


	<form name='frm' id='frm' method='post' action='promotions.jsp' >
			<input type='hidden' value='0' name='delete_id' />

		<% if(errmsg.length() > 0) { %>
		<div class="alert alert-danger" role="alert"><%=errmsg%></div>
		<% } %>
			<div id="save_promotion" style="display: none;" class="col-md-12 alert alert-success" role="alert">Promotion is saved.</div>
			<div id="edit_promotion" style="display: none;" class="col-md-12 alert alert-success" role="alert">Modifications have been saved.</div>
			
			<table id="promotionsTable" class="table table-hover table-vam" style="width:100%;">
				<thead class="thead-dark">
					<th scope="col"><input type='checkbox' id='sltall' value='1' /></th>
					<th scope="col">Order</th>
					<th scope="col">Promotion name</th>
					<th scope="col">Status</th>
					<th scope="col">Start</th>
					<th scope="col">End</th>
					<th scope="col">Last publication</th>
					<th scope="col">Next publication</th>
					<th scope="col">Last changes</th>
					<th scope="col">Actions</th>
				</thead>
				<tbody class='sortable'>
					<%
					String process = getProcess("promotion");
					String rowColor = "";
					SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
					String promotionId = "";
					String promotionStatus = "";
					while(rs.next()) {

						promotionId = parseNull(rs.value("id"));

						promotionStatus = getPromotionStatus(Etn, promotionId);

						if("NOT_PUBLISHED".equals(promotionStatus)) rowColor = "danger"; //red
						else if("NEEDS_PUBLISH".equals(promotionStatus)) rowColor = "warning"; //orange
						else rowColor = "success"; //green

						String nextpublish = "", lastpublish = "";
						Set rspw = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s') as _dt, phase from post_work where status = 0 and phase in ('publish', 'publish_ordering','delete') and client_key = " + escape.cote(rs.value("id")) + " and proces = " + escape.cote(process));
						if(rspw.next())
						{
							String __ty = "publish";
							if(rspw.value("phase").equals("publish_ordering")) __ty = "publish ordering";
							else if(rspw.value("phase").equals("delete")) __ty = "unpublish";

							nextpublish = "<span style='color:red'>"+parseNull(rspw.value("_dt"))+"</span>";
							nextpublish += "<br><a style='color:black' href='"+request.getContextPath()+"/admin/cancelaction.jsp?type=promotion&id="+rs.value("id")+"&goto=catalogs/commercialoffers/promotions/promotions.jsp'>Cancel "+__ty+"</a>";

						}

						rspw = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s') as _dt from post_work where status in (0,2) and phase = 'published' and client_key = " + escape.cote(rs.value("id")) + " and proces = "+escape.cote(process)+" order by id desc limit 1 ");
						if(rspw.next()) lastpublish = parseNull(rspw.value("_dt"));


					%>
						<tr class="table-<%=rowColor%>" style="cursor: move;">
							<td style='text-align:center'>
								<input type='checkbox' class='slt_option' value='<%=escapeCoteValue(rs.value("id"))%>' />
								<input type='hidden' name='id' value='<%=escapeCoteValue(rs.value("id"))%>'  />
							</td>
							<td align='center'><input type='text' size='2' maxlength='5' name='order_seq' class="order_seq form-control" value='<%=escapeCoteValue(parseNull(rs.value("order_seq")))%>' />
								<input type='hidden' size='2' maxlength='5' name='order_seq_sort' class="order_seq_sort form-control" value='<%=escapeCoteValue(parseNull(rs.value("order_seq")))%>' /></td>
							<td style="font-weight: bold;" ><%=escapeCoteValue(rs.value("name"))%>
							</td>
							<td class="text-success">
                                                                <%

                                                                if(isValidDateRange(parseNull(rs.value("start_date")),parseNull(rs.value("end_date")))){
                                                                %>
                                                                <span class="cui-circle-check" aria-hidden="true"></span> <strong>Active</strong>
                                                                <%
                                                                } else {
                                                                        // nothing right now
                                                                }
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
								<button type="button" value="<%=rs.value("id")%>" class="btn btn-primary btn-sm add_promotion" data-toggle="modal" data-target="#add_promotion"><i data-feather="edit"></i></button>
								<a href="javascript:oncopy('<%=rs.value("id")%>')" class="btn btn-primary btn-sm" data-toggle="tooltip" data-placement="top" title="Duplicate parameters of : <%=escapeCoteValue(rs.value("name"))%>"><i data-feather="copy"></i></a>
							<%
								if("NOT_PUBLISHED".equals(promotionStatus)) {
							%>
								<a href="javascript:ondelete('<%=rs.value("id")%>')" class="btn btn-danger btn-sm" data-toggle="tooltip" data-placement="top" title="Delete this promotion"><i data-feather="trash-2"></i></a>
							<%
								} else {
							%>
								<button type="button" class="btn btn-danger btn-sm" onclick="onbtnclickpublish('<%=rs.value("id")%>', 'promotions', 'delete')" id='unpublishtoprodbtn' data-toggle="tooltip" data-placement="top" title="Unpublish this promotion"><i data-feather="x"></i></button>
							<%
								}
							%>

							</td>

						</tr>
				<% }%>
			</tbody>
		</table>
	</form>
	<div class="row justify-content-end m-t-10"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
	</main >
	<%@ include file="/WEB-INF/include/footer.jsp" %>
	</div><!-- /container -->
	<%@ include file="/admin/prodpublishloginmultiselect.jsp"%>
	<div class="modal fade" id="add_promotion" tabindex="-1" role="dialog" data-backdrop="static" aria-labelledby="Promotion" aria-hidden="true">
		<div class="modal-dialog modal-lg modal-dialog-slideout" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title">Promotion</h5>

					<button type="button" class="close" data-dismiss="modal" aria-label="Close">
						<span aria-hidden="true">&times;</span>
					</button>
				</div>

				<div id="add_promotion_content" class="modal-body">

				</div>

				<div class="modal-footer">
					<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
				</div>
			</div>
		</div>
	</div>
	<div class="modal fade" tabindex="-1" role="dialog" id='publishdlg'>
	</div>
	<div class="modal fade" id='copyPromotionDialog' tabindex="-1" role="dialog" >
        <div class="modal-dialog" role="document">
            <div class="modal-content" >
                <form class="formPublishPages" action="" onSubmit="return false" novalidate="">
                    <div class="modal-header">
                        Copy New Form
                    </div>
                    <div class="modal-body">
                        <form>
                        <div class="form-group">
                            <label for="exampleInputEmail1">New Name</label>
                            <input type="text" class="form-control"  name="promotionNewName" id="copyPromotionNewName" aria-describedby="emailHelp">
                            <span class="infoMsg" style="color:blue;"></span>
                            <span class="errorMsg" style="color:red;"></span>
                        </div>
                        <button type="button" class="btn btn-primary" onclick="copyPromotion()" >Copy New Form</button>
                        <button type="button" class="btn btn-secondary" onclick="$('#copyPromotionDialog').modal('hide');">Cancel</button>

                        </form>
                    </div>
                </form>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div><!-- /.modal -->
<script>
	$(document).ready(function() {

		var langId = "";

		$(function () {
		  $('[data-toggle="tooltip"]').tooltip()
		})

		

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
				onbtnclickpublish(ids, "promotions", pType);
			}
			else
			{
				alert("No items selected");
			}
		};

		$(".add_promotion").on("click", function(){
            editModal($(this).prop("value"));
		});

        editModal = function(id){
            $.ajax({
            url : '../ajax/backendAjaxCallHandler.jsp',
            type: 'POST',
            dataType: 'HTML',
            data: {
                "action": 'promotions',
                "id": id
            },
            success : function(response)
            {
                var startDate;
                var endDate;
                $("#add_promotion_content").html(response);
                selecttab('lang<%=firstLanguage.getLanguageId()%>show');

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


                addAppliedTo();
            }
            });
        }


        <% if(edit_id.length()>0){%>
            editModal('<%=edit_id%>');
            $('#add_promotion').modal("show");
        <%}%>

		refreshscreen=function()
		{
			window.location = window.location
		};



		onPromotionSave=function()
		{

			var flagPromotion = false;

			if($("#name").val() == "") {

				$("#name").next().css("display","block");
				flagPromotion = true;
			}
			else $("#name").next().css("display","none");

			if($("#lang_"+langId+"_description").val() == ""){

				$("#lang_"+langId+"_description").parent().find(".invalid-feedback").css("display", "block");
				flagPromotion = true;
			}
			else $("#lang_"+langId+"_description").parent().find(".invalid-feedback").css("display", "none");

			if($("#discount_type").val() == "") {

				$("#discount_type").parent().find(".invalid-feedback").css("display","block");
				flagPromotion = true;
			}
			else $("#discount_type").parent().find(".invalid-feedback").css("display","none");

			if($("#discount_value").val() == "") {

				$("#discount_value").parent().find(".invalid-feedback").css("display","block");
				flagPromotion = true;
			}
			else $("#discount_value").parent().find(".invalid-feedback").css("display","none");

			if(flagPromotion) return false;

			$("div.multilingual-section").find('input, select').removeAttr('disabled');
            $("#promotionForm").submit();
		};

                onsave=function(btn){

                        var promoIds = [];
			var flags = [];

                        $('#promotionsTable tbody tr').each(function(i, tr){

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
                                action : "order_promotion",
                                promoIds  : promoIds.join(","),
				seq_order : flags.join(",")
                        };


                        $(btn).prop('disabled',true);
                        showLoader();
                        $.ajax({
				url: '../ajax/backendAjaxCallHandler.jsp',
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
			$('#promotionsTable tbody tr').each(function(i,tr){
				$(tr).find('.order_seq_sort').val($(tr).find('.order_seq').val());
				$(tr).find('.order_seq').val(i+1);				
			});
		};

		selecttab = function(tab) {
			if(tab !== "lang<%=firstLanguage.getLanguageId()%>show")
				$("div.multilingual-section").find('input, select').attr('disabled','disabled');
			else
				$("div.multilingual-section").find('input, select').removeAttr('disabled');
			
			<% for(Language lang: langsList){%>
				$(".lang<%=lang.getLanguageId()%>show").hide();
			<% } %>
			
			$("."+tab).show();
		};
		
		$('#promotionsTable').DataTable({
			responsive: true,
			order : [],
            lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
			columnDefs : [
				{ targets : [0,1,3,4,5,6] , searchable : false},
				{ targets : [0,1,2,3,4,5,6,-1] , orderable : false}
			]
		});

		Sortable.create(document.querySelector('#promotionsTable tbody.sortable'), {
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

		onChangeFlashSale = function(element){

			if($(element).val() == "quantity")
				$("#flash_sale_quantity").parent().parent().removeClass("d-none");
			else
				$("#flash_sale_quantity").parent().parent().addClass("d-none");
		}

		$('#promotionsTable tbody tr input.order_seq')
			.keyup(onKeyOrderSeq)
			.blur(setRowOrder);

		setRowOrder();
	});



        function addAppliedTo(type,label,value){

			$(".applied_to_value").on("input", function(ele){
			
			if(ele.target.value.length>1)
			{
				const input = ele.target;
				$.ajax({
					url: '../ajax/getItems.jsp',
					type: 'GET',
					dataType: 'json',
					data: {term: input.value, type: $("#applied_to_type_sl").val()},
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
							parentElement.querySelector("#applied_to_key").value = docEle.id;
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
        $('.applied_to_value').val(label);
        }

        function removeAppliedTo(ele){

			$(ele).parent().parent().remove();

		}

	function ondelete(tid)
	{
		if(confirm("Are you sure to delete this promotion?"))
		{
			document.frm.delete_id.value= tid;
			document.frm.submit();
		}
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

	function copyPromotion(){
		var dialogDiv = $('#copyPromotionDialog');
		var promoNewName = $('#copyPromotionNewName').val().trim();

		//validations
		if(promoNewName === ""){
			alert("Error: promotion name cannot be empty.");
			return false;
		}

		if(!confirm("Are you sure ?")){
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
                        action : 'copyPromotion'
                };

                $.ajax({
                    type :  'POST',
            url :   '../ajax/backendAjaxCallHandler.jsp',
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

    function addProduct(){

    	var prodVal = $(".applied_to_value").val();
    	var prodKey = $("#applied_to_key").val();

    	if(prodVal.length > 0){

	    	$("#selected_prod_hvng").append('<div style="margin-left: 20px; margin-top: 10px;"><button class="btn btn-pill btn-block btn-secondary" type="button"><strong onclick="removeAppliedTo(this)" style="color:#f16e00; cursor: pointer;">X</strong> ' + prodVal + '</button> <input type="hidden" name="applied_to_value" value="' + prodKey + '" /> <input type="hidden" name="applied_to_type" value="' + $("#applied_to_type_sl").val() + '" /> </div>');
	    	$(".applied_to_value").val("");
    	}

    }

    jQuery(document).ready(function() {
        $('#add_promotion_content').popover({
                selector : 'textarea.infoText',
                content : "Use following <strong>&lt;...&gt;</strong> placeholders in text to output corresponding values dynamically<br>"
                                + " - &lt;amount&gt;<br>- &lt;duration&gt;<br>- &lt;currency&gt;",
                trigger : 'focus',
                container : 'body',
                html 	: true
        });
<%
	if(isSavePromotion.equals("1")){
%>
			$("#save_promotion").css("display","block");
<%
	}
        else if(isEdit.equals("1")){
%>
			$("#edit_promotion").css("display","block");
<%
	}
%>
    });

</script>
</body>
</html>
<%

	if(isSavePromotion.equals("1")){
%>

		<script type="text/javascript">
			$("#save_promotion").css("display","block");
		</script>
<%
	}

	if(isEdit.equals("1")){
%>
		<script type="text/javascript">
			$("#edit_promotion").css("display","block");
		</script>
<%
	}
%>
