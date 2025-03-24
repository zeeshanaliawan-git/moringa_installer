 <jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, com.etn.asimina.util.ActivityLog, java.util.Map, java.util.Date, java.text.*, com.etn.beans.app.GlobalParm"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="/admin/common.jsp"%>

<%!

	String getStatus(com.etn.beans.Contexte Etn, String id)
	{
		String proddb = com.etn.beans.app.GlobalParm.getParm("PROD_DB");
		String status = "NOT_PUBLISHED";
		Set rs = Etn.execute("select * from "+proddb+".deliverymins where id = " + escape.cote(id));
		if(rs.rs.Rows == 0)
		{
			return status;
		}
		status = "PUBLISHED";
		rs = Etn.execute("select case when p1.version = p2.version then '1' else '0' end from deliverymins p1, "+proddb+".deliverymins p2 where p1.id = p2.id and p1.id = " + escape.cote(id));
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
	String delete_id = parseNull(request.getParameter("delete_id"));
	String logedInUserId = parseNull(Etn.getId());
	String errmsg = "";

	List<Language> langsList = getLangs(Etn, selectedsiteid);
	Language firstLanguage = langsList.get(0);


	if(delete_id.length() == 0) delete_id = "0";

	if(Integer.parseInt(delete_id) > 0)
	{
		Set rsp = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("PROD_DB")+".deliverymins WHERE id = "+ escape.cote(delete_id));
		if(rsp.rs.Rows > 0)
		{
			errmsg = "Delivery Minimum is already in production. Cannot proceed with delete. You must delete from production first";
		}
		else
		{					
			Set rs_name = Etn.execute("select name from deliverymins where id = " + escape.cote(delete_id));
			rs_name.next();

			Etn.executeCmd("UPDATE deliverymins_tbl SET is_deleted='1',updated_on=NOW()"+
				",updated_by="+escape.cote(logedInUserId)+" WHERE id = "+escape.cote(delete_id));


			ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),delete_id,"DELETED","Delivery Minimum",parseNull(rs_name.value(0)),selectedsiteid);
		}
	}

	String q = "select s.*, lg.name as last_updated_by from deliverymins s left outer join login lg on lg.pid = s.updated_by WHERE s.site_id = "+escape.cote(selectedsiteid);
     if(edit_id.length()>0){
        q += "and s.id = "+escape.cote(edit_id);
     }
    q += " ORDER BY coalesce(s.order_seq,999999), id ";

	Set rs = Etn.execute(q);
%>

<!DOCTYPE html>

<html>
<head>
	<title>Delivery Minimums</title>

	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>


<%
breadcrumbs.add(new String[]{"Marketing", ""});
breadcrumbs.add(new String[]{"Delivery Minimums", ""});
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
			<div>
				<h1 class="h2">Delivery Minimums</h1>
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
					<button type="button" value="" class="btn btn-success add_new" data-toggle="modal" data-target="#add_new">Add</button>

					<button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Delivery Minimums');" title="Add to shortcuts">
						<i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
					</button>
				</div>
			</div>
			<!-- /buttons bar -->
		</div>
	<!-- /Title + buttons 2 -->

	<!-- legend -->
	<small>
	<%
		if(true){
	%>
		<span class="text-muted">Drag / drop to change order.</span>
	<%
		}
		else{
	%>
		<span class="text-primary">Note: Reordering disabled while filters applied.</span>
	<%
		}
	%>
	</small>


	<form name='frm' id='frm' method='post' action='deliverymins.jsp' >
			<input type='hidden' value='0' name='delete_id' />

		<% if(errmsg.length() > 0) { %>
		<div class="alert alert-danger" role="alert"><%=errmsg%></div>
		<% } %>
			<div id="save" style="display: none;" class="col-md-12 alert alert-success" role="alert">Delivery Minimum is saved.</div>
                        <div id="edit" style="display: none;" class="col-md-12 alert alert-success" role="alert">Modifications have been saved.</div>
			<table id="deliveryminsTable" class="table table-hover table-vam" style="width:100%;">
				<thead class="thead-dark">
					<th scope="col"><input type='checkbox' id='sltall' value='1' /></th>
					<th scope="col">Order</th>
					<th scope="col">Delivery Minimum name</th>
                                        <th scope="col">Last publication</th>
                                        <th scope="col">Next publication</th>
					<th scope="col">Last changes</th>
					<th scope="col">Actions</th>
				</thead>
				<tbody class='sortable'>
					<%
					String process = getProcess("deliverymin");
					String rowColor = "";
					SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
					String id = "";
					String status = "";
					while(rs.next()) {

						id = parseNull(rs.value("id"));

						status = getStatus(Etn, id);

						if("NOT_PUBLISHED".equals(status)) rowColor = "danger"; //red
						else if("NEEDS_PUBLISH".equals(status)) rowColor = "warning"; //orange
						else rowColor = "success"; //green

						String nextpublish = "", lastpublish = "";
						Set rspw = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s') as _dt, phase from post_work where status = 0 and phase in ('publish', 'publish_ordering','delete') and client_key = " + escape.cote(rs.value("id")) + " and proces = " + escape.cote(process));
						if(rspw.next())
						{
							String __ty = "publish";
							if(rspw.value("phase").equals("publish_ordering")) __ty = "publish ordering";
							else if(rspw.value("phase").equals("delete")) __ty = "unpublish";

							nextpublish = "<span style='color:red'>"+parseNull(rspw.value("_dt"))+"</span>";
							nextpublish += "<br><a style='color:black' href='"+request.getContextPath()+"/admin/cancelaction.jsp?type=deliverymin&id="+rs.value("id")+"&goto=catalogs/commercialoffers/delivery/deliverymins.jsp'>Cancel "+__ty+"</a>";

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
							<td>
									<%= lastpublish%>
							</td>
							<td><%= nextpublish %></td>
							<td><% if(parseNull(rs.value("updated_on")).length() >0) { out.write("<span style='color:green'>On</span>: " + parseNull(rs.value("updated_on")) +"<br><span style='color:green'>By</span>: "+parseNull(rs.value("last_updated_by")));}else{out.write("&nbsp;");}%></td>

							<td class="dt-body-right text-nowrap" nowrap>
								<button type="button" value="<%=rs.value("id")%>" class="btn btn-primary btn-sm add_new" data-toggle="modal" data-target="#add_new"><i data-feather="edit"></i></button>
								<a href="javascript:oncopy('<%=rs.value("id")%>')" class="btn btn-primary btn-sm" data-toggle="tooltip" data-placement="top" title="Duplicate parameters of : <%=escapeCoteValue(rs.value("name"))%>"><i data-feather="copy"></i></a>
							<%
								if("NOT_PUBLISHED".equals(status)) {
							%>
								<a href="javascript:ondelete('<%=rs.value("id")%>')" class="btn btn-danger btn-sm" data-toggle="tooltip" data-placement="top" title="Delete"><i data-feather="trash-2"></i></a>
							<%
								} else {
							%>
								<button type="button" class="btn btn-danger btn-sm" onclick="onbtnclickpublish('<%=rs.value("id")%>', 'deliverymins', 'delete')" id='unpublishtoprodbtn' data-toggle="tooltip" data-placement="top" title="Unpublish"><i data-feather="x"></i></button>
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


	<!-- Modal add -->
	<div class="modal fade" id="add_new" tabindex="-1" role="dialog" data-backdrop="static" aria-labelledby="Delivery Minimum" aria-hidden="true">
		<div class="modal-dialog modal-lg modal-dialog-slideout" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title">Delivery Minimum</h5>

					<button type="button" class="close" data-dismiss="modal" aria-label="Close">
						<span aria-hidden="true">&times;</span>
					</button>
				</div>

				<div id="add_content" class="modal-body">

				</div>

				<div class="modal-footer">
					<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
				</div>
			</div>
		</div>
	</div>
</main>
        <!-- .modal -->
	<div class="modal fade" tabindex="-1" role="dialog" id='publishdlg'>
	</div>
	<!-- /.modal -->
<%@ include file="/admin/prodpublishloginmultiselect.jsp"%>
<div class="modal fade" id='copyDialog' tabindex="-1" role="dialog" >
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
                            <input type="text" class="form-control"  name="newName" id="copyNewName" aria-describedby="emailHelp">
                            <span class="infoMsg" style="color:blue;"></span>
                            <span class="errorMsg" style="color:red;"></span>
                        </div>
                        <button type="button" class="btn btn-primary" onclick="copy()" >Copy</button>
                        <button type="button" class="btn btn-secondary" onclick="$('#copyDialog').modal('hide');">Cancel</button>

                        </form>
                    </div>
                </form>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div><!-- /.modal -->
<%-- <div id='' title='Copy' style='text-align:center; display:none; clear:both;' >
	<form method='' action='' enctype=''>
		<input type="hidden" name="id" id="copyId" value=""/>
		<table cellpadding="0" cellspacing="5" border="0" style="width: 100%;" >

			<tr>
				<td style='font-weight:bold' align='left'>New Name</td>
				<td style='font-weight:bold' align='left'>:</td>
				<td align='left'>
					<input type="text" name="newName" id="copyNewName"
						value="" maxlength="255" />
				</td>
			</tr>
			<tr>
				<td colspan="3" style="text-align:left;font-size:10px;" >
					&nbsp;
					<span class="infoMsg" style="color:blue;"></span><br>
					<span class="errorMsg" style="color:red;"></span>
				</td>
			</tr>
			<tr>
				<td style='font-weight:bold' align='left'>&nbsp;</td>
				<td style='font-weight:bold' align='left'>&nbsp;</td>
				<td align='left'>
					<input type='button' value='Copy' onclick="copy()" />
					<input type='button' value='Cancel' class="" onclick="$('#copyDialog').modal('hide');" />
				</td>
			</tr>
		</table>

	</form>
</div> --%>
<br>

<%@ include file="/WEB-INF/include/footer.jsp" %>
	</div><!-- /container -->
<script>
	$(document).ready(function() {

        <% if(edit_id.length()>0){%>
            editModal('<%=edit_id%>');
            $('#add_new').modal("show");
        <%}%>

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
				onbtnclickpublish(ids, "deliverymins", pType);
			}
			else
			{
				alert("No items selected");
			}
		};

		$(".add_new").on("click", function(){
            editModal($(this).prop("value"))
		});

		refreshscreen=function()
		{
			window.location = window.location
		};

                checkDepType=function(element)
		{
			if(element.value=="all") $("#dep_value").attr("readonly","readonly");
                        else $("#dep_value").removeAttr("readonly");
		};



		onDeliveryMinSave=function()
		{

			var flag = false;

			if($("#name").val() == "") {

				$("#name").next().css("display","block");
				flag = true;
			}
			else $("#name").next().css("display","none");

			if($("#lang_"+langId+"_description").val() == ""){

				$("#lang_"+langId+"_description").parent().find(".invalid-feedback").css("display", "block");
				flag = true;
			}
			else $("#lang_"+langId+"_description").parent().find(".invalid-feedback").css("display", "none");

			if($("#dep_type").val() == "") {

				$("#dep_type").parent().find(".invalid-feedback").css("display","block");
				flag = true;
			}
			else $("#dep_type").parent().find(".invalid-feedback").css("display","none");

			if($("#dep_type").val() !="all" && $("#dep_value").val() == "") {

				$("#dep_value").parent().find(".invalid-feedback").css("display","block");
				flag = true;
			}
			else $("#dep_value").parent().find(".invalid-feedback").css("display","none");

			if($("#min").val() == "") {

				$("#min").parent().find(".invalid-feedback").css("display","block");
				flag = true;
			}
			else $("#min").parent().find(".invalid-feedback").css("display","none");

			if(flag) return false;

			$("div.multilingual-section").find('input, select').removeAttr('disabled');
                        $("#saveForm").submit();
		};

                onsave=function(btn){

                        var ids = [];
			var flags = [];

                        $('#deliveryminsTable tbody tr').each(function(i, tr){

                                var id = $(tr).find('input[name=id]:first');
                                if(id.length == 1){
                                        ids.push(id.val());
                                }

				if($(tr).find('.order_seq').val() == $(tr).find('.order_seq_sort').val()) flags.push("false");
				else flags.push("true");

                        });

                        if(ids.length === 0){
                                return false;
                        }

                        var params = {
                                action : "order_deliverymin",
                                ids  : ids.join(","),
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
                                        alert("Error: Ordering not saved. please try again.");
                                }
                                else{
                                        alert("Ordering saved.");
                                }

                        })
                        .fail(function() {
                                alert("Error: Ordering not saved. please try again.");
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

			$('#deliveryminsTable tbody tr').each(function(i,tr){

				$(tr).find('.order_seq_sort').val($(tr).find('.order_seq').val());
				$(tr).find('.order_seq')
				// .prop('readonly',false)
				.val(i+1);
				// .prop('readonly',true);
			});
		};

		selecttab = function(tab, element) {
            if(tab !== "lang<%=firstLanguage.getLanguageId()%>show")
				$("div.multilingual-section").find('input, select').attr('disabled','disabled');
			else
				$("div.multilingual-section").find('input, select').removeAttr('disabled');

			<% for(Language lang: langsList){%>
				$(".lang<%=lang.getLanguageId()%>show").hide();
			<% } %>

			$("."+tab).show();
		};


                    $('#deliveryminsTable').DataTable({
                        // dom : "<flipt>",
                        // deferRender : true,
						responsive: true,
                        order : [],
						lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
                        columnDefs : [
                            { targets : [0,1,3,4] , searchable : false},
                            { targets : [0,1,2,3,4] , orderable : false}
                        ]
                    });

		Sortable.create(document.querySelector('#deliveryminsTable tbody.sortable'), {
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

		$('#deliveryminsTable tbody tr input.order_seq')
			.keyup(onKeyOrderSeq)
			.blur(setRowOrder);

		setRowOrder();
	});

	function ondelete(tid)
	{
		if(confirm("Are you sure to delete this?"))
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
		var copyDialog = $('#copyDialog');

		$('#copyId').val(sid);
		$('#copyNewName').val("");

		copyDialog.find('.infoMsg').html("");
		copyDialog.find('.errorMsg').html("");

		copyDialog.modal("show");

	}

    function editModal(id){
        $.ajax({
            url : '../ajax/backendAjaxCallHandler.jsp',
            type: 'POST',
            dataType: 'HTML',
            data: {
                "action": 'deliverymins',
                "id":id
            },
            success : function(response)
            {
                $("#add_content").html(response);
                selecttab('lang<%=firstLanguage.getLanguageId()%>show');

            }
        });
    }

	function copy(){
		var dialogDiv = $('#copyDialog');
		var newName = $('#copyNewName').val().trim();

		//validations
		if(newName === ""){
			alert("Error: Name cannot be empty.");
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
		var id = $('#copyId').val();

                showLoader();
                var params = {
                        id : id,
                        newName : newName,
                        action : 'copyDeliveryMin'
                };

                $.ajax({
                    type :  'POST',
            url :   '../ajax/backendAjaxCallHandler.jsp',
                    data :  params,
                    dataType : "json",
                    cache : false,
                    success:function(response){
                        if(response["status"] !== "ERROR"){
                                infoMsg.html("Copied successfullly. Refreshing list...");
                                window.location.href = window.location.href;
                        }
                    },
                    complete : function(){
                        hideLoader();
                    }
                });
	}

    jQuery(document).ready(function() {
        $('#add_content').popover({
                selector : 'textarea.infoText',
                content : "Use following <strong>&lt;...&gt;</strong> placeholders in text to output corresponding values dynamically<br>"
                                + " - &lt;amount&gt;<br>- &lt;duration&gt;<br>- &lt;currency&gt;",
                trigger : 'focus',
                container : 'body',
                html 	: true
        });
<%
	if(isSave.equals("1")){
%>
			$("#save").css("display","block");
<%
	}
        else if(isEdit.equals("1")){
%>
			$("#edit").css("display","block");
<%
	}
%>
    });

</script>
</body>
</html>
<%

	if(isSave.equals("1")){
%>

		<script type="text/javascript">
			$("#save").css("display","block");
		</script>
<%
	}

	if(isEdit.equals("1")){
%>
		<script type="text/javascript">
			$("#edit").css("display","block");
		</script>
<%
	}
%>
