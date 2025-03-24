<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>
<%@ page import="com.etn.util.Base64,com.etn.util.Logger"%>
<%@ page import="com.etn.asimina.data.LanguageFactory, com.etn.asimina.util.ActivityLog"%>
<%@ page import="com.etn.asimina.beans.Language"%>
<%@ page import="com.etn.asimina.util.UrlHelper"%>
<%@ include file="../common2.jsp"%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>

<%
    
    String selectedSiteId = getSelectedSiteId(session);
    String logedInUserId = parseNull(Integer.toString(Etn.getId()));
    Logger.debug("gameProcess.jsp","Loggedin User::"+logedInUserId);
    Set promotionRs = Etn.execute("SELECT id,name FROM "+GlobalParm.getParm("PROD_CATALOG_DB")+".cart_promotion WHERE site_id="+escape.cote(selectedSiteId));

    Set formFilterRs = Etn.execute("SELECT form_id FROM "+GlobalParm.getParm("CATALOG_DB")+".person_forms pf inner join profilperson pp on pp.person_id = pf.person_id inner join profil p on p.profil_id = pp.profil_id where p.assign_site='1' and pf.person_id="+escape.cote(""+Etn.getId()));
    List<String> formIds = new ArrayList<String>();

    while(formFilterRs.next())
    {
        formIds.add(parseNull(formFilterRs.value("form_id")));
    }

%>

<!DOCTYPE html>

<html>
<head>
    <title>Games</title>

    <%@ include file="/WEB-INF/include/headsidebar.jsp"%>

    <!-- ace editor -->
    <script src="<%=request.getContextPath()%>/js/ace/ace.js" ></script>
    <!-- ace modes -->
    <script src="<%=request.getContextPath()%>/js/ace/mode-freemarker.js" ></script>
    <script src="<%=request.getContextPath()%>/js/ace/mode-javascript.js" ></script>

    <script src="<%=request.getContextPath()%>/js/ckeditor/adapters/jquery.js"></script>
    <script>
        CKEDITOR.timestamp = "" + parseInt(Math.random()*100000000);
    </script>

    <style type="text/css">
        .ace_editor {
            border: 1px solid lightgray;
            min-height: 500px;
            font-family: monospace;
            font-size: 14px;
        }

        .list-group-item{
            display: list-item !important;
        }
    </style>

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
            <h1 class="h2">Games</h1>
            <p class="lead"></p>
        </div>

        <!-- buttons bar -->
        <div class="btn-toolbar mb-2 mb-md-0">
            <div class="btn-group mr-2" role="group" aria-label="...">
                <button type="button" class="btn btn-danger" onclick="onPublishUnpublish('publish')" id="publishtoprodbtn">Publish</button>
                <button type="button" class="btn btn-danger" onclick="onPublishUnpublish('unpublish')" id="unpublishtoprodbtn">Unpublish</button>
            </div>

            <div class="btn-group mr-2" role="group" aria-label="...">
                <a href='../../<%=GlobalParm.getParm("CATALOG_DB")%>/admin/gestion.jsp' class="btn btn-primary">Back</a>
            </div>
            <div class="btn-group mr-2" role="group" aria-label="...">
                <button type="button" class="btn btn-success add_new_game_form" data-toggle="modal" data-target="#add_new_game_form">New Game</button>
            </div>
            <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Games');" title="Add to shortcuts">
                <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
            </button>
        </div>
        <!-- /buttons bar -->

    </div><!-- /d-flex -->
    <!-- /title -->

    <!-- container -->
    <div class="animated fadeIn">
    <div>
    <form name='frm' id='frm' method='post' action='games.jsp' >
        <table class="table table-hover m-t-20" id="resultsData" style="width: 100%">
            <thead class="thead-dark">
                <th scope="col"><input type='checkbox' id='sltall' value='1' /></th>
                <th scope="col">Game</th>
                <th scope="col">Game ID</th>
                <th scope="col">Attempts Per User</th>
                <th scope="col">Win Type</th>
                <th scope="col">Can Lose</th>
                <th scope="col">Last Changes</th>
                <th scope="col">Actions</th>
            </thead>
        </table>
    </form>
    </div>
    <div class="row justify-content-end m-t-10"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
    </div>
    <br>

    <!-- Modal add new form -->
    <div class="modal fade" id="add_new_game_form" tabindex="-1" role="dialog" data-backdrop="static" aria-labelledby="Add new game form" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-slideout process-modal" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">New Game</h5>

                    <button type="button" class="close" data-dismiss="modal" aria-label="Close" onclick="emptyModal()">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>

                <div class="p-3 collapse show" id="global_information" style="overflow-y:auto;height: calc(100vh - 120px);">
                <form id="game-creation">
                    <div class="mb-2 text-right">
                        <button id="selectionSave" type="button" class="btn btn-primary" onclick="newGame()" style="z-index: 1000;">Save</button>               
                    </div>
                    <div class="form-group row ">
                        <label for="game_name" class="col-md-3 control-label is-required">Name:</label>
                        <div class="col-md-9">
                            <input type="text" maxlength="50" id="game_name" name="game_name" data-language-id="1" class="form-control" autocomplete="off">
                            <div class="invalid-feedback">Form name is mandatory.</div>
                        </div>
                    </div>

                    <div class="form-group row ">
                        <label for="multiple_times" class="col-md-3 control-label is-required">Attempts Per User:</label>
                        <div class="col-md-9">
                            <input type="text" maxlength="50" id="multiple_times" name="multiple_times" data-language-id="1" value="1" class="form-control" autocomplete="off">
                            <div class="invalid-feedback">Form name is mandatory.</div>
                        </div>
                    </div>

                    <div class="form-group row ">
                        <label for="win_type" class="col-md-3 control-label is-required">Win Type:</label>
                        <div class="col-md-9">
                            <select class="custom-select" name="win_type" id="win_type">
                                <option value="">Choose....</option>
                                <option value="Draw">Draw</option>
                                <option value="Instant">Instant</option>
                            </select>
                        </div>
                    </div>


                    <div class="form-group row ">
                        <label for="launch-time" class="col-md-3 control-label">Launch Time : </label>
                        <div class="col-md-9">
                            <input required data-language-id="1" class="form-control" type="text" name="launch-time" id="launch-time" autocomplete="off">
                        </div>
                    </div>

                    <div class="form-group row ">
                        <label for="end-time" class="col-md-3 control-label">End Time : </label>
                        <div class="col-md-9">
                            <input required data-language-id="1" class="form-control" type="text" name="end-time" id="end-time" autocomplete="off">
                        </div>
                    </div>

                    <div class="form-group row ">
                        <label for="can_lose" class="col-md-3 control-label">Can User Lose: </label>
                        <div class="col-md-9">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" id="can_lose">
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group row">
                        <label for="prizes" class="col-md-3 control-label">Prize:</label>
                        <div class="col-md-9">
                            <table class="table table-hover" id="prizeData">
                                <thead class="thead-dark">
                                    <th scope="col">Type</th>
                                    <th scope="col">Coupons</th>
                                    <th scope="col">Prize</th>
                                    <th scope="col">Quantity</th>
                                    <th scope="col"></th>
                                </thead>
                            </table>
                        </div>
                    </div>

                    <div style="float:right;">
                        <button type="button" class="btn-primary btn-sm" id="addRow">&plus;</button>
                    </div>
                    
                </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" onclick="emptyModal()" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal edit email -->
		<div class="modal fade" id="edit_email" tabindex="-1" role="dialog" data-backdrop="static" aria-labelledby="Edit email" aria-hidden="true">
			<div class="modal-dialog modal-lg modal-dialog-slideout process-modal" role="document">
				<div class="modal-content">
					<div class="modal-header">
						<h5 class="modal-title">Define template email</h5>

						<button type="button" class="close" data-dismiss="modal" aria-label="Close">
							<span aria-hidden="true">&times;</span>
						</button>
					</div>

					<div id="edit_email_content" class="modal-body">
					</div>

					<div class="modal-footer">
						<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
					</div>
				</div>
			</div>
		</div>
   

    <!-- Modal edit form -->
    <div class="modal fade" id="edit_game" tabindex="-1" role="dialog" data-backdrop="static" aria-labelledby="edit game form" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-slideout process-modal" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Edit Game</h5>

                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>

                <div class="p-3 collapse show" id="global_information" style="overflow-y:auto;height: calc(100vh - 120px);">
                <form id="game-edition">
                    <div class="mb-2 text-right">
                        <button id="selectionEditSave" type="button" class="btn btn-primary" onclick="editGame()" style="z-index: 1000;">Save</button>               
                    </div>
                    <input type="hidden" id="game-id" name="game-id" >
                    <div class="form-group row ">
                        <label for="game_name" class="col-md-3 control-label is-required">Game name:</label>
                        <div class="col-md-9">
                            <input type="text" maxlength="50" id="edit_game_name" name="game_name" data-language-id="1" class="form-control" disabled>
                        </div>
                    </div>

                    <div class="form-group row ">
                        <label for="edit_multiple_times" class="col-md-3 control-label is-required">Attempts per user:</label>
                        <div class="col-md-9">
                            <input type="text" maxlength="50" id="edit_multiple_times" name="edit_multiple_times" data-language-id="1" value="1" class="form-control" autocomplete="off">
                            <div class="invalid-feedback">Form name is mandatory.</div>
                        </div>
                    </div>

                    <div class="form-group row ">
                        <label for="edit_win_type" class="col-md-3 control-label is-required">Win Type:</label>
                        <div class="col-md-9">
                            <select class="custom-select" name="edit_win_type" id="edit_win_type">
                                <option value="">Choose....</option>
                                <option value="Draw">Draw</option>
                                <option value="Instant">Instant</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group row ">
                        <label for="edit-launch-time" class="col-md-3 control-label">Launch Time : </label>
                        <div class="col-md-9">
                            <input required data-language-id="1" class="form-control" type="text" name="edit-launch-time" id="edit-launch-time" autocomplete="off">
                        </div>
                    </div>

                    <div class="form-group row ">
                        <label for="edit-end-time" class="col-md-3 control-label">End Time : </label>
                        <div class="col-md-9">
                            <input required data-language-id="1" class="form-control" type="text" name="edit-end-time" id="edit-end-time" autocomplete="off">
                        </div>
                    </div>

                    <div class="form-group row ">
                        <label for="edit-can_lose" class="col-md-3 control-label">Can User Lose: </label>
                        <div class="col-md-9">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" id="edit-can_lose">
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group row ">
                        <label for="edit-can_lose" class="col-md-3 control-label">Play game field: </label>
                        <div class="col-md-9">
							<select class='form-control' id='edit-play-game-column' name='play_game_column'></select>
                        </div>
                    </div>
                    
                    <div class="form-group row">
                        <label for="prizes" class="col-md-3 control-label">Prize:</label>
                        <div class="col-md-9">
                            <table class="table table-hover" id="edit-prizeData">
                                <thead class="thead-dark">
                                    <th scope="col">Type</th>
                                    <th scope="col">Coupons</th>
                                    <th scope="col">Prize</th>
                                    <th scope="col">Quantity</th>
                                    <th scope="col"></th>
                                </thead>
                                <tbody>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div style="float:right;">
                        <button type="button" class="btn-primary btn-sm" id="edit-addRow">&plus;</button>
                    </div>
                </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div><!-- modal edit code -->

    <div class="modal fade" id="modalPublishForms" tabindex="-1" role="dialog" >
        <div class="modal-dialog" role="document">
            <div class="modal-content" >
                <form class="formPublishPages" action="" onSubmit="return false" novalidate="">
                    <div class="modal-body">
                        <div class="container-fluid">
                            <div class="form-group row">
                                <div class="col publishMessage">
                                </div>
                                <div class="col-1">
                                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                        <span aria-hidden="true">&times;</span>
                                    </button>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label  class="col-sm-3 col-form-label">
                                    <span class="text-capitalize actionName">Publish</span>
                                </label>
                                <div class="col-sm-9">
                                    <button type="button" class="btn btn-primary publishNowBtn">Now</button>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label  class="col-sm-3 col-form-label">
                                    <span class="text-capitalize actionName">Publish</span> on
                                </label>
                                <div class="col-sm-9">
                                    <div class="input-group">
                                        <input type="text" class="form-control textdatetime" name="publishTime" value="">
                                        <div class="input-group-append">
                                            <button class="btn btn-primary  rounded-right publishOnBtn" type="button">OK</button>
                                        </div>
                                        <div class="invalid-feedback">Please specify date and time</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div><!-- /.modal -->

    <!-- Button trigger modal -->

<!-- Message Modal -->
<div class="modal fade" id="messageModal" tabindex="-1" role="dialog" aria-labelledby="messageModal" >
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="title">Unpublish Game(s)</h5>
      </div>
      <div class="modal-body">
        <div class="d-block text-success mb-3"  id="successMessage"></div>
        <div id="failedMessage"></div>
        <div><p id="failedFormsList" class="mt-2 text-danger" style="white-space: pre-wrap;"></p></div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>
<!-- Message Modal -->
</main>

<%@ include file="/WEB-INF/include/footer.jsp" %>
</div>
<%@ include file="ajax/checkPublishLogin.jsp"%>
<script type="text/javascript">

$(document).ready( function(){

    var table = $('#resultsData').DataTable({
        processing: true,
        serverSide: true,
        lengthMenu: [[25, 50, 100, -1], [25, 50, 100, 'All']],
        order:[2,'desc'],
        responsive: true,
        ajax: {
            url: '<%=request.getContextPath()%>/admin/ajax/getGames.jsp',
            type: 'GET',
            data: {
                site_id: '<%= selectedSiteId %>'
            }
        },
        columns: [
            {"": ""},
            {"data": "name"},
            {"data": "id"},
            {"data": "attempts_per_user"},
            {"data": "win_type"},
            {"data": "can_lose"},
            {"data": "last_changes"},
            {"data": "actions", className: "dt-body-right text-nowrap"},
        ],
        columnDefs:[
            {targets: [0,2,-2,-1], searchable: false},
            {targets: [0, 2,-1], orderable: false},
			{targets: [1], render: _hEscapeHtml},
            {
                targets: [0],
                render: function (data, type, row) {            
                    return '<input type="checkbox" class="idCheck slt_option' 
                        + '" name="gameId" value="' + row.id + '" >';
                }
            },
            {
                targets:[2],
                render: function(data,type,row){
                    return `\${data}
                    <button type="button" onclick="copyit(\'\${data}\')" class="btn btn-white btn-sm"><svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 115.77 122.88" style="width:13px;enable-background:new 0 0 115.77 122.88" xml:space="preserve"><style type="text/css">.st0{fill-rule:evenodd;clip-rule:evenodd;}</style><g><path class="st0" d="M89.62,13.96v7.73h12.19h0.01v0.02c3.85,0.01,7.34,1.57,9.86,4.1c2.5,2.51,4.06,5.98,4.07,9.82h0.02v0.02 v73.27v0.01h-0.02c-0.01,3.84-1.57,7.33-4.1,9.86c-2.51,2.5-5.98,4.06-9.82,4.07v0.02h-0.02h-61.7H40.1v-0.02 c-3.84-0.01-7.34-1.57-9.86-4.1c-2.5-2.51-4.06-5.98-4.07-9.82h-0.02v-0.02V92.51H13.96h-0.01v-0.02c-3.84-0.01-7.34-1.57-9.86-4.1 c-2.5-2.51-4.06-5.98-4.07-9.82H0v-0.02V13.96v-0.01h0.02c0.01-3.85,1.58-7.34,4.1-9.86c2.51-2.5,5.98-4.06,9.82-4.07V0h0.02h61.7 h0.01v0.02c3.85,0.01,7.34,1.57,9.86,4.1c2.5,2.51,4.06,5.98,4.07,9.82h0.02V13.96L89.62,13.96z M79.04,21.69v-7.73v-0.02h0.02 c0-0.91-0.39-1.75-1.01-2.37c-0.61-0.61-1.46-1-2.37-1v0.02h-0.01h-61.7h-0.02v-0.02c-0.91,0-1.75,0.39-2.37,1.01 c-0.61,0.61-1,1.46-1,2.37h0.02v0.01v64.59v0.02h-0.02c0,0.91,0.39,1.75,1.01,2.37c0.61,0.61,1.46,1,2.37,1v-0.02h0.01h12.19V35.65 v-0.01h0.02c0.01-3.85,1.58-7.34,4.1-9.86c2.51-2.5,5.98-4.06,9.82-4.07v-0.02h0.02H79.04L79.04,21.69z M105.18,108.92V35.65v-0.02 h0.02c0-0.91-0.39-1.75-1.01-2.37c-0.61-0.61-1.46-1-2.37-1v0.02h-0.01h-61.7h-0.02v-0.02c-0.91,0-1.75,0.39-2.37,1.01 c-0.61,0.61-1,1.46-1,2.37h0.02v0.01v73.27v0.02h-0.02c0,0.91,0.39,1.75,1.01,2.37c0.61,0.61,1.46,1,2.37,1v-0.02h0.01h61.7h0.02 v0.02c0.91,0,1.75-0.39,2.37-1.01c0.61-0.61,1-1.46,1-2.37h-0.02V108.92L105.18,108.92z"></path></g></svg></button>
                    `
                }
            },
            {
                targets:[5],
                render: function(data,type,row){
                    if(data==='1')
                        return 'Yes';
                    else
                        return 'No';
                }
            }
        ],
        select: {
            style: 'multi',
            className: '',
            selector: 'td.noselector' //dummyselector
        },
        createdRow: function( row, data, dataIndex){
			var rowColor = "danger";
			if(data.publish_status == 'published') rowColor = "success";
			else if(data.publish_status == 'needs_publish') rowColor = "warning";
            $(row).addClass("table-"+rowColor+" ui-sortable-handle").css("cursor","move");
        }
    });

    $(table.table().body()).addClass("sortable ui-sortable");

    Sortable.create(document.querySelector('#resultsData tbody.sortable'), {
        direction: 'vertical',
        scroll: true,
        scrollSensitivity: 100,
        scrollSpeed: 30,
        forcePlaceholderSize: true,
        helper: function(event, element) {
            var clone = element.cloneNode(true);
            var origTdList = element.querySelectorAll('>td');
            var cloneTdList = clone.querySelectorAll('>td');
            for (var i = 0; i < cloneTdList.length; i++) {
            cloneTdList[i].style.width = origTdList[i].offsetWidth + 'px';
            }
            return clone;
        },
        onEnd: function(event) {
            setRowOrder();
            orderingchanged = true;
        }
        });
    
});

setRowOrder = function(){
    $('#resultsdata tbody tr').each(function(i,tr){
        $(tr).find('.order_seq')
        // .prop('readonly',false)
        .val(i+1);
        // .prop('readonly',true);
    });
};


var prizeTable=null;

$('#cart_type').on('change', function() {
    if(this.value==="Coupons"){
        $("#coupons-cart-rule").removeClass("d-none");
        $("#coupons-title").addClass("d-none");
    }
    else if(this.value === "Text"){
        $("#coupons-cart-rule").addClass("d-none");
        $("#coupons-title").removeClass("d-none");
    }
    else{
        $("#coupons-cart-rule").addClass("d-none");
        $("#coupons-title").addClass("d-none");
    }
});

$('[data-toggle="tooltip"]').tooltip();

// game creation 
$( "#launch-time" ).flatpickr({
    enableTime: true,
    dateFormat: 'd/m/Y H:i:00',
    step: 15
});

$( "#end-time" ).flatpickr({
    enableTime: true,
    dateFormat: 'd/m/Y H:i:00',
    step: 15,
    onShow:function( ct ){
        this.setOptions({
            minTime: $('#launch-time').val()?$('#end-time').val():false
        })
    }
});

/// game edition
$( "#edit-launch-time" ).flatpickr({
    enableTime: true,
    dateFormat: 'd/m/Y H:i:00',
    step: 15
});

$( "#edit-end-time" ).flatpickr({
    enableTime: true,
    dateFormat: 'd/m/Y H:i:00',
    step: 15,
    onShow:function( ct ){
        this.setOptions({
            minTime: $('#edit-launch-time').val()?$('#edit-end-time').val():false
        })
    }
});


$("#addRow").on("click", function(){
    if(prizeTable==null){

        prizeTable = $("#prizeData").DataTable({
            "responsive": true,
            "searching": false,
            "paging": false,
            "info": false,
            "autoWidth": false,
            "ordering": false,
        });
    }
    var dataOptionsHTML="<% promotionRs.moveFirst(); while(promotionRs.next() && promotionRs != null) {%><option value='<%=promotionRs.value("id")%>'><%=escapeCoteValue(promotionRs.value("name"))%></option><%  }%>";

    prizeTable.row.add([`<select class="custom-select cart-type-select" name="cart_type" ><option value="">Choose....</option><option value="Coupon">Coupon</option><option value="Prize">Prize</option></select>`,
        `<select name="coupons" data-language-id="1" class="form-control"><option value=''>Choose...</option>`+dataOptionsHTML+`</select>`,
        `<input type="text" maxlength="50" name="others" data-language-id="1" class="form-control">`,
        `<input type="number" min="1" maxlength="11" name="quantity" data-language-id="1" class="form-control">`,
        `<button type="button" class="btn btn-danger btn-sm" onclick="deleteRow(this)"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-x"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button> `]).draw(false);

});

function publishUnpublishForms(ids, action, publishTime){

    showLoader();
    $.ajax({
        url: '<%=request.getContextPath()%>/admin/ajax/publishAjax.jsp', type: 'POST', dataType: 'json',
        data: {
            requestType : action + 'Games',
            ids : ids,
            publishTime : publishTime
        },
    })
    .done(function(resp) {

        if(resp.status === 1){
            if(resp.unpublishedPagesForms.length>0){
                $('#messageModal').find('#successMessage').addClass('text-success').removeClass('text-danger');
                $('#messageModal').find('#successMessage').html(resp.message);
                $('#messageModal').modal("show");
                $('#messageModal').find(".btn").click(function(event) {
                    $('#frm').submit();
                });
            }else{
                bootNotify(resp.message);
                $('#frm').submit();
            }
        }
        else{
            if(resp.unpublishedPagesForms.length>0){
                $('#messageModal').find('#successMessage').addClass('text-danger').removeClass('text-success');
                $('#messageModal').find('#successMessage').html(resp.message);
                $('#messageModal').modal("show");
                $('#messageModal').find(".btn").prop("onclick", 'null');
            }else{
                bootNotifyError(resp.message);
            }
        }

    })
    .fail(function() {
        bootNotifyError("Error in contacting server. please try again.");
    })
    .always(function() {
        hideLoader();
    });
}

function copyit(id)
{
    var value = '<input value="' + id + '" id="copyclipboard" />';
    $(value).insertAfter('#'+id);
    $("#copyclipboard").select();
    document.execCommand("Copy");
    $('body').find("#copyclipboard").remove();
    bootNotify("Text Copied");
}

function onPublishUnpublish(action,isLogin){


    if ($(".slt_option:checked").length > 0) {
                
        var ids = "";
        var fcount = 0;
        $(".slt_option").each(function(){
            
            if($(this).is(":checked") == true) {
                fcount++;
                ids += $(this).val() + ",";
            }
        });

        if(typeof isLogin == 'undefined' || !isLogin){
            
            checkPublishLogin(action);
        }
        else{

            var msg = "" + fcount + " Game(s) selected.\n";
            msg += "Are you sure you want to "+action+" these Game(s)?";
            
            showPublishFormsModal(msg, action, function(publishTime){
                publishUnpublishForms(ids, action, publishTime);
            });

        }

    } else {

        bootNotifyError("No Game selected");
    }
}

function unpublishGame(id){
    
    var msg = "" + 1 + " Game(s) selected.\n";
    msg += "Are you sure you want to unpublish these Game(s)?";
    
    showPublishFormsModal(msg, "unpublish", function(publishTime){
        publishUnpublishForms(id, "unpublish", publishTime);
    });
    
}

function showPublishFormsModal(message, action, callback){
        var modal = $('#modalPublishForms');

        modal.find('.actionName').text(action);

        modal.find('.publishMessage').text(message);

        modal.find(".publishNowBtn").off('click')
        .click(function(){
            var publishTime = "now";
            modal.modal('hide');
            callback(publishTime);
        });

        var publishTimeField = modal.find('input[name=publishTime]');
        publishTimeField.val("");

        modal.find(".publishOnBtn").off('click')
        .click(function(){
            var publishTime = publishTimeField.val().trim();

            if(publishTime.length === 0){
                publishTimeField.addClass('is-invalid');
                return false;
            }

            modal.modal('hide');
            callback(publishTime);
        });

        modal.modal('show');
    }

$("#edit-addRow").on("click", function(){
    
    var dataOptionsHTML="<% promotionRs.moveFirst(); while(promotionRs.next() && promotionRs != null) {%><option value='<%=promotionRs.value("id")%>'><%=escapeCoteValue(promotionRs.value("name"))%></option><%  }%>";
    $("#edit-prizeData tbody").append(`<tr>
        <td><input type="hidden" name="prize-id" value=""/>
            <select class="custom-select cart-type-select" name="cart_type" >
                <option value="" >Choose....</option><option value="Coupon" >Coupon</option>
                <option value="Prize">Prize</option>
            </select>
        </td>
        <td><select name="coupons" data-language-id="1" class="form-control"><option value=''>Choose...</option>\${dataOptionsHTML}</select></td>
        <td><input type="text" maxlength="50" name="others" data-language-id="1" class="form-control" value=""></td>
        <td><input type="number" min="1" maxlength="11" name="quantity" data-language-id="1" class="form-control" value=""></td>
        <td><button type="button" class="btn btn-danger btn-sm" onclick="editDeleteRow(this)"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-x"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button>
        </td>
        </tr>`);
    
});


var deletedPrize=[]

function editDeleteRow(btn){
    var row = $(btn).closest('tr');
    if($($(row).find('input')[0]).val().length > 0){
        $(row).addClass('d-none is-deleted');
        deletedPrize.push($($(row).find('input')[0]).val());
    }else{
        $(row).remove();
    }
}

function emptyModal()
{
    document.getElementById("game-creation").reset();
    if(prizeTable!==null)
        prizeTable.clear().draw();
}

function delGame(id)
{
	if(confirm("Are you sure you want to delete this game?"))
	{
		$.ajax({
			url : '<%=request.getContextPath()%>/admin/ajax/deleteGame.jsp',
			type: 'POST',
			datatype: 'json',
			data: {
				"game_id": id,
			},
			success : function(json)
			{            
				bootNotify("Successfully deleted");
				window.location.href = "<%=request.getContextPath()%>/admin/games.jsp";
			},
			error : function(response)
			{
				bootNotifyError("Error Occurred while Deletion");
			}
		});
	}
}

function editGame()
{
    var data = [];
    var can_lose = $("#edit-can_lose").is(":checked")? 1 : 0 ;
    
    data = $('#edit-prizeData').find('input,select').serializeArray();
    data.push(
            {name: 'can_lose', value: can_lose},
            {name: 'game_id', value: $("#game-id").val()},
            {name: 'game_name', value: $("#edit_game_name").val()},
            {name: 'multiple_times', value: $("#edit_multiple_times").val()},
            {name: 'win_type', value: $("#edit_win_type").val()},
            {name: 'launch_date', value: $("#edit-launch-time").val()},
            {name: 'end_date', value: $("#edit-end-time").val()},
            {name: 'deleted_prizes', value: deletedPrize },
            {name: 'play_game_column', value: $("#edit-play-game-column").val() }
    );
    
    $.ajax({
        url : '<%=request.getContextPath()%>/admin/ajax/editGame.jsp',
        type: 'POST',
        datatype: 'json',
        data: data,
        success : function(json)
        {
            if(json.status === 0){
                bootNotify("Successfully Edited");
                window.location.replace('<%=request.getContextPath()%>/admin/games.jsp');
            }
            else
                bootNotifyError(json.err_description);
        }
    });
}

function getGame(id)
{
    $.ajax({
        url : '<%=request.getContextPath()%>/admin/ajax/getGame.jsp',
        type: 'GET',
        datatype: 'json',
        data: {
            "game_id": id,
        },
        success : function(response)
        {
            if(response.status == 0)
            {
                
                var resp = response.data;
                if(resp.can_lose === '1')
				$("#edit-can_lose").attr('checked','');
                $("#edit_game_name").val(resp.name);
                $("#edit_multiple_times").val(resp.attempts_per_user);
                $("#edit_win_type").val(resp.win_type);
                $("#edit-launch-time").val(resp.launch_date);
                $("#edit-end-time").val(resp.end_date);
                $("#game-id").val(id);
                $("#edit-prizeData tbody").empty();
				
				
                $("#edit-play-game-column").empty();
				
				for(let j=0 ; j < resp.columns.length; j++)
				{
					$("#edit-play-game-column").append("<option "+((resp.play_game_column==resp.columns[j].col)?"selected":"")+" value='"+resp.columns[j].col+"'>"+resp.columns[j].name+"</option>");
				}
                
				
                deletedPrize=[];
                $('#edit_game').modal('show');
                Array.from(resp.prizes).forEach(function(val){
                    
                    var dataOptionsHTML=`<% promotionRs.moveFirst(); while(promotionRs.next() && promotionRs != null) {%><option value='<%=promotionRs.value("id")%>' \${val.cart_rule_id==='<%=promotionRs.value("id")%>'? "selected":'' }><%=escapeCoteValue(promotionRs.value("name"))%></option><%  }%>`;
                    $("#edit-prizeData tbody").append(`<tr>
                    <td><input type="hidden" name="prize-id" value="\${val.id}"/>
                        <select class="custom-select cart-type-select" name="cart_type" >
                            <option value="" >Choose....</option><option value="Coupon" \${val.type==='Coupon'? "selected":'' }>Coupon</option>
                            <option value="Prize" \${val.type==='Prize'? "selected":'' }>Prize</option>
                        </select>
                    </td>
                    <td><select name="coupons" data-language-id="1" class="form-control"><option value=''>Choose...</option>\${dataOptionsHTML}</select></td>
                    <td><input type="text" maxlength="50" name="others" data-language-id="1" class="form-control" value="\${val.prize}"></td>
                    <td><input type="number" min="1" maxlength="11" name="quantity" data-language-id="1" class="form-control" value="\${val.quantity}"></td>
                    <td><button type="button" class="btn btn-danger btn-sm" onclick="editDeleteRow(this)"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-x"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button>
                    </td>
                    </tr>`);
                });
                
            }
            else
            {
                bootNotifyError(response.err_description);
            }
        },
        
    });
}

function newGame()
{
    if($("#game_name").val().length === 0)
    {
        bootNotifyError("Game name is empty");
    }
    else if($("#multiple_times").val().length === 0 || parseInt($("#multiple_times").val()) <= -1)
    {
        bootNotifyError("Invalid times play");
    }
    else if($("#win_type").val().length === 0)
    {
        bootNotifyError("Win Type not selected");
    }
    else{		
		var prizeCount = 0;
		var data = [];
		if(prizeTable != null) 
		{
			data = prizeTable.$('input, select').serializeArray();
			prizeCount = prizeTable.data().rows().count();
		}
		var can_lose = $("#can_lose").is(":checked")? 1 : 0 ;

        data.push(
            {name: 'can_lose', value: can_lose},
            {name: 'game_id', value: $("#game-id").val()},
            {name: 'game_name', value: $("#game_name").val()},
            {name: 'multiple_times', value: $("#multiple_times").val()},
            {name: 'win_type', value: $("#win_type").val()},
            {name: 'launch_date', value: $("#launch-time").val()},
            {name: 'end_date', value: $("#end-time").val()},
        );

        $.ajax({
            url: '<%=request.getContextPath()%>/admin/ajax/createGame.jsp',
            type: 'POST',
            data: data,
			dataType : 'json',
            success: function(resp)
            {
                if(resp.status===0)
                    window.location.href = "<%=request.getContextPath()%>/admin/games.jsp";
                else
                    bootNotifyError(resp.err_description);
            }
        });
    }
}


</script>
</body>