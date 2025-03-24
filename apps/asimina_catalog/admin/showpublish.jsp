<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape"%>
<%@ include file="common.jsp"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%
	String id = parseNull(request.getParameter("id"));
	String itemType = parseNull(request.getParameter("type"));
	String publishType = parseNull(request.getParameter("publishtype"));

	String process = getProcess(itemType);

	String nextpublish = "";
    int idCount = id.split(",").length;

    if(idCount == 1){
        String nextPubQ = "select date_format(priority, '%d/%m/%Y %H:%i:%s') from post_work where status = 0 and phase = 'publish' and client_key = " + escape.cote(id) + " and proces = " + escape.cote(process);
        Set rs = Etn.execute(nextPubQ);
    	if(rs.next()) nextpublish = parseNull(rs.value(0));
    }

    String publishTypeUI = publishType; //TODO ordering ?
    if("multi".equalsIgnoreCase(publishType)){
        publishTypeUI = "publish";
    }
    else if( "delete".equalsIgnoreCase(publishType)  || "multidelete".equalsIgnoreCase(publishTypeUI) ){
        publishTypeUI = "unpublish";
    }
    else if("ordering".equalsIgnoreCase(publishType)){
        publishTypeUI = "publish ordering";
    }

    String publishMessage = "" ;
    if("publish".equalsIgnoreCase(publishType) || "delete".equalsIgnoreCase(publishType)){
        //single entity
        publishMessage = "Are you sure you want to "
                            + publishTypeUI
                            + " this " + itemType + "?";
    }
    else if("multi".equalsIgnoreCase(publishType) || "multidelete".equalsIgnoreCase(publishType)
            || "ordering".equalsIgnoreCase(publishType) ){
        //coming from list page, can be multiple
        publishMessage = "" + id.split(",").length
                            +" " + itemType + "(s) selected. Are you sure you want to "
                            + publishTypeUI
                            + ("ordering".equalsIgnoreCase(publishType)?" of":"")
                            + " these " + itemType + "(s)?";
    }
%>

<!-- .modal content -->
	<div class="modal-dialog " role="document">
		<div class="modal-content">
			<!-- <div class="modal-header">
				<h5 class="modal-title">Publication</h5>
				<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
			</div> -->
			<div class="modal-body">
                <div class="container-fluid">

                <div class="form-group row">
                    <div class="col">

                        <div id='infoBox' class="alert alert-info mb-0 py-1" role="alert" <% if(nextpublish.length() == 0) { %>style='display:none'<%}%>>
                            <div id='infoPublication' <% if(nextpublish.length() == 0) { %>style='display:none'<%}%>>
                                <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
                                <span class="m-l-10">
                                    <% if(nextpublish.length() > 0) { %>
                                        Next publish on : <%=nextpublish%>
                                    <% } %>
                                </span>
                            </div>
                        </div>

                        <div class="publishMessage">
                            <%=publishMessage%>
                        </div>
                    </div>
                    <div class="col-1">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                </div>
                <div class="form-group row">
                    <label  class="col-sm-3 col-form-label">
                        <span class="text-capitalize actionName"><%=publishTypeUI%></span>
                    </label>
                    <div class="col-sm-9">
                        <button type="button" class="btn btn-primary publishNowBtn"
                             onclick="publishnow()" >Now</button>
                    </div>
                </div>
                <div class="form-group row">
                    <label  class="col-sm-3 col-form-label">
                        <span class="text-capitalize actionName"><%=publishTypeUI%></span> on
                    </label>
                    <div class="col-sm-9">
                        <div class="input-group">
                            <input type="text" class="form-control" name="publishTime" value=""
                                 id='publishOnDatetimepicker'>
                            <div class="input-group-append">
                                <button class="btn btn-primary  rounded-right publishOnBtn" type="button"
                                    onclick="publishon()">OK</button>
                            </div>
                            <div class="invalid-feedback">Please specify date and time</div>
                        </div>

                    </div>
                </div>
                </div>
			</div>
		</div><!-- /.modal-content -->
	</div><!-- /.modal-dialog -->
	<!-- /.modal content -->

<script>
	jQuery(document).ready(function() {

        var publishOnField = $("#publishOnDatetimepicker");

        flatpickr(document.querySelector("#publishOnDatetimepicker"), {
            enableTime: true,
            dateFormat: "d/m/Y H:i",
            time_24hr: true,
            allowInput: true
        });


		publishon=function()
		{
			if(publishOnField.val() == '')
			{
                publishOnField.addClass('is-invalid');
				publishOnField.focus();
                return false;
			}
            $('#publishdlg').modal("hide");
			_publish(publishOnField.val());
		};

		publishnow=function()
		{
            $('#publishdlg').modal("hide");
			_publish(-1);
		};

        _publish=function(_on)
		{
			$.ajax({
      		    url : '<%=request.getContextPath()%>/admin/publish.jsp',
 		        type: 'POST',
                data: {
                    id : '<%=id%>',
                    type : '<%=itemType%>',
                    on : _on,
                    publishtype : '<%=publishType%>'
                },
				dataType : 'json',
             	success : function(json)
                {
					if(json.response == 'success')
					{
                        bootNotify(json.msg);
						// $("#nextpublish___").html(json.next_publish_on);
						if(typeof refreshscreen != 'undefined'){
                            refreshscreen();
                        }
					}else{
                        bootAlert(json.msg);
                    }
	            },
			    error : function()
			    {
					bootNotifyError("Error while communicating with the server");
				}
			});
		};


	});
</script>