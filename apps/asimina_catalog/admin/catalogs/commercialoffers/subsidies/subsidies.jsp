<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, com.etn.asimina.util.ActivityLog, java.util.Map, java.util.Date, java.text.SimpleDateFormat, com.etn.beans.app.GlobalParm"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="/WEB-INF/include/constants.jsp"%>

<%@ include file="/admin/common.jsp"%>

<%!

	String getSubsidiesStatus(com.etn.beans.Contexte Etn, String subsidyId)
	{
		String proddb = com.etn.beans.app.GlobalParm.getParm("PROD_DB");
		String status = "NOT_PUBLISHED";
		Set rs = Etn.execute("select * from " + proddb + ".subsidies where id = " + escape.cote(subsidyId));
		if(rs.rs.Rows == 0)
		{
			return status;
		}

		status = "PUBLISHED";

		rs = Etn.execute("select case when subsidy1.version = subsidy2.version then '1' else '0' end from subsidies subsidy1, " + proddb + ".subsidies subsidy2 where subsidy1.id = subsidy2.id and subsidy1.id = " + escape.cote(subsidyId));
		rs.next();

		if(rs.value(0).equals("0"))
		{
			status = "NEEDS_PUBLISH";
		}

		return status;
	}
%>

<%
    String selectedsiteid = parseNull(getSelectedSiteId(session));
	String isSave = parseNull(request.getParameter("is_save"));
	String isEdit = parseNull(request.getParameter("is_edit"));
    String edit_id = parseNull(request.getParameter("edit_id"));
	String errmsg = "";

	String deleteId = parseNull(request.getParameter("delete_id"));

	String logedInUserId = parseNull(Etn.getId());

	List<Language> langsList = getLangs(Etn,selectedsiteid);
	Language firstLanguage = langsList.get(0);

	if(deleteId.length() == 0) deleteId = "0";

	if(Integer.parseInt(deleteId) > 0)
	{
		Set rsp = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("PROD_DB")+".subsidies WHERE id = "+ escape.cote(deleteId));
		if(rsp.rs.Rows > 0)
		{
			errmsg = "Subsidy is already in production. Cannot proceed with delete. You must delete from production first";
		}
		else
		{					
			Set rs_name = Etn.execute("select name from subsidies where id = " + escape.cote(deleteId));
			rs_name.next();

			Etn.executeCmd("UPDATE subsidies_tbl SET is_deleted='1',updated_on=now()"+
				",updated_by="+escape.cote(logedInUserId)+" WHERE id = "+escape.cote(deleteId));


			ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),deleteId,"DELETED","Subsidie",parseNull(rs_name.value(0)),selectedsiteid);
		}
	}


	String q = "SELECT subsidy.*, lg.name AS last_updated_by FROM subsidies subsidy LEFT OUTER JOIN login lg on lg.pid = subsidy.updated_by WHERE subsidy.site_id = " + escape.cote(selectedsiteid);
     if(edit_id.length()>0){
        q += "and subsidy.id = "+escape.cote(edit_id);
     }
    q+=" ORDER BY coalesce(subsidy.order_seq,999999), subsidy.id ";

	Set rs = Etn.execute(q);

%>

<!DOCTYPE html>

<html>
<head>
	<title>Subsidies</title>

	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>
	
<%
breadcrumbs.add(new String[]{"Marketing", ""});
breadcrumbs.add(new String[]{"Subsidies", ""});
%>

    <script src="<%=request.getContextPath()%>/js/urlgen/etn.urlgenerator.js"></script>
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
				<h1 class="h2">Subsidies</h1>
				<p class="lead"></p>
			</div>

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
					<button type="button" class="btn btn-success add_subsidy" data-toggle="modal" data-target="#add_subsidy">Add a subsidy</button>

					<button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Subsidies');" title="Add to shortcuts">
						<i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
					</button>
				</div>
			</div>
			<!-- /buttons bar -->
		</div>
	<!-- /title -->

	<!-- container -->
	<div class="animated fadeIn">
	<div>
	<form name='frm' id='frm' method='post' action='subsidies.jsp' >
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
			<span class="text-primary">Note: subsidies reordering disabled while filters applied.</span>
		<%
			}
		%>
		</small>
	</div>

	
	<!-- /legend -->
		<% if(errmsg.length() > 0) { %>
		<div class="alert alert-danger" role="alert"><%=errmsg%></div>
		<% } %>
        <div id="save_subsidies" style="display: none;" class="col-md-12 alert alert-success" role="alert">Subsidy is saved.</div>
        <div id="edit_subsidies" style="display: none;" class="col-md-12 alert alert-success" role="alert">Modifications have been saved.</div>
		<table class="table table-hover table-vam m-t-20" id="resultsdata">
			<thead class="thead-dark">
				<th scope="col"><input type='checkbox' id='sltall' value='1' /></th>
				<th scope="col">Subsidy</th>
				<th scope="col">Last publication</th>
				<th scope="col">Next publication</th>
				<th scope="col">Last changes</th>
				<th scope="col">Action</th>
			</thead>
			<tbody class="sortable">
			<%
				String process = getProcess("subsidies");
				String rowColor = "";
				SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
				String subsidyId = "";
				String subsidiesStatus = "";

				while(rs.next()) {

					subsidyId = parseNull(rs.value("id"));

					subsidiesStatus = getSubsidiesStatus(Etn, subsidyId);

					if("NOT_PUBLISHED".equals(subsidiesStatus)) rowColor = "danger"; //red
					else if("NEEDS_PUBLISH".equals(subsidiesStatus)) rowColor = "warning"; //orange
					else rowColor = "success"; //green

					String nextpublish = "", lastpublish = "";
					Set rspw = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s') as _dt, phase from post_work where status = 0 and phase in ('publish', 'publish_ordering','delete') and client_key = " + escape.cote(rs.value("id")) + " and proces = " + escape.cote(process));

					if(rspw.next()) {

						String __ty = "publish";
						if(rspw.value("phase").equals("publish_ordering")) __ty = "publish ordering";
						else if(rspw.value("phase").equals("delete")) __ty = "unpublish";

						nextpublish = "<span style='color:red'>"+parseNull(rspw.value("_dt"))+"</span>";
						nextpublish += "<br><a style='color:black' href='"+request.getContextPath()+"/admin/cancelaction.jsp?type=subsidies&id="+rs.value("id")+"&goto=catalogs/commercialoffers/subsidies/subsidies.jsp'>Cancel "+__ty+"</a>";
					}

					rspw = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s') as _dt from post_work where status in (0,2) and phase = 'published' and client_key = " + escape.cote(rs.value("id")) + " and proces = "+escape.cote(process)+" order by id desc limit 1 ");
					if(rspw.next()) lastpublish = parseNull(rspw.value("_dt"));
	  			%>
					<tr class="table-<%=rowColor%>" style="cursor: move;">
						<td style='text-align:center'>
							<input type='checkbox' class='slt_option' value='<%=escapeCoteValue(rs.value("id"))%>' />
							<input type='hidden' name='id' value='<%=escapeCoteValue(rs.value("id"))%>'  />
						</td>
						<td><%=escapeCoteValue(rs.value("name"))%></td>
						<td>
							<%= lastpublish%>
						</td>
						<td><%= nextpublish %></td>
						<td><% if(parseNull(rs.value("updated_on")).length() >0) { out.write("<span style='color:green'>On</span>: " + parseNull(rs.value("updated_on")) +"<br><span style='color:green'>By</span>: "+parseNull(rs.value("last_updated_by")));}else{out.write("&nbsp;");}%></td>
						<td class="dt-body-right text-nowrap" nowrap>
							<button id='<%= escapeCoteValue(rs.value("id"))%>' type="button" class="btn btn-primary btn-sm edit_subsidy" data-toggle="modal" data-target="#edit_subsidy"><i data-feather="edit"></i></button>
							<a href="javascript:oncopy('<%=rs.value("id")%>')" class="btn btn-primary btn-sm" data-toggle="tooltip" data-placement="top" title="Duplicate subsidies parameters of : <%=escapeCoteValue(rs.value("name"))%>"><i data-feather="copy"></i></a>
						<%
							if("NOT_PUBLISHED".equals(subsidiesStatus)) {
						%>
								<a href="javascript:ondelete('<%=rs.value("id")%>')" class="btn btn-danger btn-sm" ><i data-feather="trash-2"></i></a>
						<%
							} else {
						%>
								<button type="button" class="btn btn-danger btn-sm" onclick="onbtnclickpublish('<%=rs.value("id")%>', 'subsidies', 'delete')" id='unpublishtoprodbtn'>Unpublish</button>
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

	<!-- Modal add subsidy -->
	<div class="modal fade" id="add_subsidy" tabindex="-1" role="dialog" data-backdrop="static" aria-labelledby="Add subsidy" aria-hidden="true">
		<div class="modal-dialog modal-lg modal-dialog-slideout" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title">Subsidy</h5>

					<button type="button" class="close" data-dismiss="modal" aria-label="Close">
						<span aria-hidden="true">&times;</span>
					</button>
				</div>

				<div id="add_subsidy_content" class="modal-body">

				</div>

				<div class="modal-footer">
					<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
				</div>
			</div>
		</div>
	</div>

	<!-- Modal edit subsidy -->
	<div class="modal fade" id="edit_subsidy" tabindex="-1" role="dialog" data-backdrop="static" aria-labelledby="Edit subsidy" aria-hidden="true">
		<div class="modal-dialog modal-lg modal-dialog-slideout" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title">Edit Subsidy</h5>

					<button type="button" class="close" data-dismiss="modal" aria-label="Close">
						<span aria-hidden="true">&times;</span>
					</button>
				</div>

				<div id="edit_subsidy_content" class="modal-body">

				</div>

				<div class="modal-footer">
					<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
				</div>
			</div>
		</div>
	</div>

</main>
<div class="modal fade" id='copySubsidyDialog' tabindex="-1" role="dialog" >
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
                            <input type="text" class="form-control"  name="subsidyNewName" id="copySubsidyNewName" aria-describedby="emailHelp">
                            <span class="infoMsg" style="color:blue;"></span>
                            <span class="errorMsg" style="color:red;"></span>
                        </div>
                        <button type="button" class="btn btn-primary" onclick="copySubsidy()" >Copy</button>
                        <button type="button" class="btn btn-secondary" onclick="$('#copySubsidyDialog').modal('hide');">Cancel</button>

                        </form>
                    </div>
                </form>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div><!-- /.modal -->
	

	<!-- .modal -->
	<div class="modal fade" tabindex="-1" role="dialog" id='publishdlg'>
	</div>
	<!-- /.modal -->



<!--
<div id='publishdlg' title='Publish' style='text-align:center; display:none; clear:both;' >
</div> -->


<%@ include file="../../../prodpublishloginmultiselect.jsp"%>
<%@ include file="/WEB-INF/include/footer.jsp" %>
</div>

<script>

	var langId = "";

	jQuery(document).ready(function()
	{


		$('#resultsdata').DataTable({
			"responsive": true,
			"language": {
				"emptyTable": "No subsidy found"
			},
            "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
			"columnDefs": [
                { targets : [0, 5] , searchable : false},
                { targets : [0, 5] , orderable : false}
			]
		});

        <% if(edit_id.length()>0){%>
            editModal('<%=edit_id%>');
            $('#edit_subsidy').modal("show");
        <%}%>


		// $("#copySubsidyDialog").modal('show');

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
				onbtnclickpublish(ids, "subsidies", pType);
			}
			else
			{
				alert("No items selected");
			}
		};

		refreshscreen=function()
		{
			window.location = window.location
		};

		$(".add_subsidy").on("click", function(){

		    $.ajax({
		        url : '../ajax/subsidies.jsp',
		        type: 'POST',
		        dataType: 'HTML',
		        data: {
		        	"action": 'subsidy'
		        },
		        success : function(response)
		        {
					var startDate;
					var endDate;

		        	$("#add_subsidy_content").html(response);
					selecttab('lang<%=firstLanguage.getLanguageId()%>show', '<%=firstLanguage.getLanguageId()%>');

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


				    etn.initUrlGenerator($('#redirect_url'),'<%=GlobalParm.getParm("URL_GEN_AJAX_URL")%>', { langId : langId, showOpenType : true, allowEmptyValue : true});
		        }
		    });
		});

		$("#resultsdata tbody").on("click", "tr", function(){

            editModal($(this).find(".edit_subsidy").prop("id"));

		});
        function editModal(id){
            if(id){
                $.ajax({
                    url : '../ajax/subsidies.jsp',
                    type: 'POST',
                    dataType: 'HTML',
                    data: {
                        "action": 'subsidy',
                        "id":id
                    },
                    success : function(response)
                    {
                        var startDate;
                        var endDate;
                        $("#edit_subsidy_content").html(response);
                        selecttab('lang<%=firstLanguage.getLanguageId()%>show', '<%=firstLanguage.getLanguageId()%>');

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


                        var menuItemUrlGen = etn.initUrlGenerator($('#redirect_url'),'<%=GlobalParm.getParm("URL_GEN_AJAX_URL")%>', { langId : langId, showOpenType : true, allowEmptyValue : true});

                        menuItemUrlGen.setOpenType($("#open_as").val());

                    }
                });

            }
        }
		onsave = function(btn){

			var subsidyIds = [];
			var flags = [];

			$('#resultsdata tbody tr').each(function(i, tr){

				var subsidy = $(tr).find('input[name=id]:first');
				if(subsidy.length == 1){
					subsidyIds.push(subsidy.val());
				}

				if($(tr).find('.order_seq').val() == $(tr).find('.order_seq_sort').val()) flags.push("false");
				else flags.push("true");
			});

			if(subsidyIds.length === 0){
				return false;
			}

			var params = {
				action : "order_subsidies",
				subsidyIds  : subsidyIds.join(","),
				seq_order : flags.join(",")
			};


			$(btn).prop('disabled',true);
			showLoader();
			$.ajax({
				url: '../ajax/subsidies.jsp',
				type: 'POST',
				dataType: 'json',
				data: params
			})
			.done(function(response) {
				if(response.status !== "SUCCESS"){
					alert("Error: subsidies order not saved. please try again.");
				}
				else{
					alert("Subsidies order saved.");
					orderingchanged = false;
				}

			})
			.fail(function() {
				alert("Error: subsidies order not saved. please try again.");
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

		onSubsidySave=function()
		{

			var flagSubsidy = false;

			if($("#name").val() == ""){

				$("#name").next().css("display","block");
				flagSubsidy = true;
			}
			else $("#name").next().css("display","none");

			if($("#lang_"+langId+"_description").val() == ""){

				$("#lang_"+langId+"_description").parent().find(".invalid-feedback").css("display", "block");
				flagSubsidy = true;
			}
			else $("#lang_"+langId+"_description").parent().find(".invalid-feedback").css("display", "none");

			if($("#applied_to_value").val() == ""){

				$("#applied_to_value").parent().next().css("display","block");
				flagSubsidy = true;
			}
			else $("#applied_to_value").parent().next().css("display","none");

			if($("#discount_value").val() == ""){

				$("#discount_value").next().css("display","block");
				flagSubsidy = true;
			}
			else $("#discount_value").next().css("display","none");

			if($("#selected_prod_hvng").find("input[name=associated_to_value_subsidy]").length == 0){

				$(".associated_to_value_subsidy").parent().next().css("display","block");
				flagSubsidy = true;

			} else $(".associated_to_value_subsidy").parent().next().css("display","none");


			if(flagSubsidy) return false;

			$("#open_as").val($(".urlGenOpenType").val())
			$("div.multilingual-section").find('input, select').removeAttr('disabled');
			$("#subsidyfrm").submit();
		};

		onEditSubsidySave=function()
		{

			var flagSubsidy = false;
			var length = 0;

			if($("#name").val() == ""){

				$("#name").next().css("display","block");
				flagSubsidy = true;
			}
			else $("#name").next().css("display","none");

			if($("#lang_"+langId+"_description").val() == ""){

				$("#lang_"+langId+"_description").parent().find(".invalid-feedback").css("display", "block");
				flagSubsidy = true;
			}
			else $("#lang_"+langId+"_description").parent().find(".invalid-feedback").css("display", "none");

			if($("#applied_to_value").val() == ""){

				$("#applied_to_value").parent().next().css("display","block");
				flagSubsidy = true;
			}
			else $("#applied_to_value").parent().next().css("display","none");

			if($("#discount_value").val() == ""){

				$("#discount_value").next().css("display","block");
				flagSubsidy = true;
			}
			else $("#discount_value").next().css("display","none");

			if($("#selected_prod_hvng").find("input[name=associated_to_value_subsidy]").length == 0){

				$(".associated_to_value_subsidy").parent().next().css("display","block");
				flagSubsidy = true;

			} else $(".associated_to_value_subsidy").parent().next().css("display","none");

			if(flagSubsidy) return false;

			$("#open_as").val($(".urlGenOpenType").val())
			$("div.multilingual-section").find('input, select').removeAttr('disabled');
			$("#editSubsidyfrm").submit();
		};

		$('#resultsdata tbody tr input.order_seq')
			.keyup(onKeyOrderSeq)
			.blur(setRowOrder);
			
		selecttab = function(tab,id) {
			if(tab !== "lang<%=firstLanguage.getLanguageId()%>show")
				$("div.multilingual-section").find('input, select').attr('disabled','disabled');
			else
				$("div.multilingual-section").find('input, select').removeAttr('disabled');
			
			<% for(Language lang: langsList){%>
				$(".lang<%=lang.getLanguageId()%>show").hide();
			<% } %>
			
			$("."+tab).show();
			langId = id;
		};

		setRowOrder();
	});

	function ondelete(tid)
	{
		if(confirm("Are you sure to delete this subsidy?"))
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

    function addAppliedTo(type,label,value){

		$(".applied_to_value_subsidy").on("input", function(ele){
			
			if(ele.target.value.length>1)
			{
				const input = ele.target;
				$.ajax({
					url: '../ajax/getItems.jsp',
					type: 'GET',
					dataType: 'json',
					data: {term: input.value, type: $("#applied_to_type").val(), langid: langId},
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
							parentElement.querySelector("#applied_to_value_key_subsidy").value = docEle.id;
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
        $('.applied_to_value_subsidy').val(label);

    }



	
    function addAssociatedTo(type,label,value){

		$(".associated_to_value_subsidy").on("input", function(ele){
			
			if(ele.target.value.length>1)
			{
				const input = ele.target;
				$.ajax({
					url: '../ajax/getItems.jsp',
					type: 'GET',
					dataType: 'json',
					data: {term: input.value, type: $("#associated_to_type").val(), langid: langId},
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
							document.getElementById("associated_to_type_key_subsidy").value=docEle.id;
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
        $('.associated_to_value_subsidy').val(label);

    }

    function add_selected_prod(){
    	var prodVal = $(".associated_to_value_subsidy").val();
    	var prodKey = $("#associated_to_type").val();

    	if(prodVal.length > 0){

	    	$("#selected_prod_hvng").append('<div style="margin-left: 20px; margin-top: 10px;"><button class="btn btn-pill btn-block btn-secondary" type="button"><strong onclick="delete_selected_on(this)" style="color:#f16e00; cursor: pointer;">X</strong> ' + prodVal + '</button> <input type="hidden" name="associated_to_type_subsidy" value="' + prodKey + '" /> <input type="hidden" name="associated_to_value_subsidy" value="' + $("#associated_to_type_key_subsidy").val() + '" /> </div>');
	    	$(".associated_to_value_subsidy").val("");
    	}

    }

	function oncopy(sid)
	{
		openCopyDialog(sid);
	}

	function openCopyDialog(sid){
		var copyDialog = $('#copySubsidyDialog');

		$('#copySubsidyId').val(sid);
		$('#copySubsidyNewName').val("");

		copyDialog.find('.infoMsg').html("");
		copyDialog.find('.errorMsg').html("");

		copyDialog.modal("show");

	}

	function copySubsidy(){

		var dialogDiv = $('#copySubsidyDialog');
		var subsidyNewName = $('#copySubsidyNewName').val().trim();

		//validations
		if(subsidyNewName === ""){
			alert("Error: subsidy name cannot be empty.");
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
		var subsidyId = $('#copySubsidyId').val();

        showLoader();
        var params = {
                subsidyId : subsidyId,
                subsidyNewName : subsidyNewName,
                action : 'copySubsidy'
        };

        $.ajax({
            type :  'POST',
            url :   '../ajax/subsidies.jsp',
            data :  params,
            dataType : "json",
            cache : false,
            success:function(response){

                if(response["status"] !== "ERROR"){
                    window.location.href = window.location.href;
                }
            },
            complete : function(){
                hideLoader();
            }
        });
	}

	function removeAppliedTo(ele){

		$(ele).parent().parent().parent().remove();
	}

	function delete_selected_on(element){

		$(element).parent().parent().remove();
	}

</script>
</body>
</html>

<%
	if(isSave.equals("1")){
%>
		<script type="text/javascript">
			$("#save_subsidies").css("display","block");
		</script>
<%
	}

	if(isEdit.equals("1")){
%>
		<script type="text/javascript">
			$("#edit_subsidies").css("display","block");
		</script>
<%
	}
%>
