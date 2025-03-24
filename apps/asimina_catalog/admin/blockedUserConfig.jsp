<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, java.text.SimpleDateFormat, com.etn.beans.app.GlobalParm, com.etn.asimina.util.BlockedUserConfig" %>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../WEB-INF/include/constants.jsp"%>
<%@ include file="common.jsp"%>

<%
    String userBlockTime =  parseNull(request.getParameter("userBlockTime"));
    String userTries =  parseNull(request.getParameter("userTries"));
    String userBlockTimeUnit =  parseNull(request.getParameter("userBlockTimeUnit"));

    String ipBlockTime =  parseNull(request.getParameter("ipBlockTime"));
    String ipTries =  parseNull(request.getParameter("ipTries"));
    String ipBlockTimeUnit =  parseNull(request.getParameter("ipBlockTimeUnit"));

    String updateConfig =  parseNull(request.getParameter("updateConfig"));

    // update config
    if("1".equals(updateConfig)){
        Etn.executeCmd("UPDATE user_block_config SET number_of_tries  = "+escape.cote(userTries)+", block_time = "+escape.cote(userBlockTime)+", block_time_unit = "+escape.cote(userBlockTimeUnit)+"  WHERE type = 'user'");
        Etn.executeCmd("UPDATE user_block_config SET number_of_tries  = "+escape.cote(ipTries)+", block_time = "+escape.cote(ipBlockTime)+", block_time_unit = "+escape.cote(ipBlockTimeUnit)+"  WHERE type = 'ip' ");
        BlockedUserConfig.instance.loadConfig ();
    }
    //load config
    Set rs =  Etn.execute("select * from user_block_config;");
    while(rs.next()){
        if(rs.value("type").equals("user")){
            userBlockTime = rs.value("block_time");
            userBlockTimeUnit = rs.value("block_time_unit");
            userTries = rs.value("number_of_tries");
        }else{
            ipBlockTime = rs.value("block_time");
            ipBlockTimeUnit = rs.value("block_time_unit");
            ipTries = rs.value("number_of_tries");
        }
    }

    ArrayList<String> timeUnits = new ArrayList();
    timeUnits.add("minutes");
    timeUnits.add("hours");
    timeUnits.add("days");
    timeUnits.add("weeks");

%>
<!DOCTYPE html>
<html>
<head>
    <title>Accounts Blocking</title>
    <%@ include file="/WEB-INF/include/headsidebar.jsp"%>
<%	
breadcrumbs.add(new String[]{"System", ""});
breadcrumbs.add(new String[]{"Accounts Blocking", ""});
%>
</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">

            <!-- /title -->
            <!-- title -->
               <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                   <div>
                       <h1 class="h2">Accounts Blocking</h1>
                   </div>
                   <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Accounts Blocking');" title="Add to shortcuts">
                        <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
                    </button>
               </div>
               <!-- /title -->

               <ul class="nav nav-tabs trustedTabs" role="tablist">
                   <li class="nav-item" >
                       <a class='nav-link active'
                       data-toggle="tab" href="#tabConfig"
                       role="tab"  aria-selected="true">Rules</a>
                   </li>
                   <li class="nav-item" >
                       <a class='nav-link'
                       data-toggle="tab" href="#tabBlock"
                       role="tab"  aria-selected="true">Blocked</a>
                   </li>
               </ul>
               <!-- content -->

               <div class="tab-content p-3">
                   <div  class="tab-pane fade" role="tabpanel" aria-labelledby="nav-d-tab"  id="tabBlock">
                       <div class="row animated">
                           <div class="col">
                               <div class="col-3 mb-5 mt-3">
                                   <select class="form-control" id="blockType" onchange="onChangeSelect(this)">
                                       <option value="user">User Account</option>
                                       <option value="ip">IP Address</option>
                                   </select>
                               </div>
                               <table class="table" style="width: 100%;"  id="blockTable">
                                   <thead class="thead-dark">
                                       <tr>
                                           <th  id="ipOrUsernameCol"scope="col"></th>
                                           <th scope="col">No. of Attemps</th>
                                           <th scope="col">Last Attempt</th>
                                           <th scope="col" class="dt-body-right text-nowrap"
                                               style="width:100px">Actions</th>
                                       </tr>
                                   </thead>
                                   <tbody id="blockTableBody">

                                   </tbody>
                               </table>
                           </div>
                       </div>
                   </div>
                   <div class="tab-pane fade show active" role="tabpanel" aria-labelledby="nav-home-tab"  id="tabConfig" >
                       <div class="col pl-5 pt-3">
                           <form action="blockedUserConfig.jsp" method="post">
                               <input type="hidden" name="updateConfig" value="1">
                               <div class="row">
                                   <div class="col-2">
                                       <strong>Type</strong>
                                   </div>
                                   <div class="col-3">
                                       <strong>Blocking Time</strong>
                                   </div>
                                   <div class="col-3">
                                       <strong>No. of Tries</strong>
                                   </div>
                               </div>
                               <br>
                               <div class="row">
                                   <div class="col-2">
                                       <label>User Account</label>
                                   </div>
                                   <div class="col-3">
                                       <div class="input-group w-75">
                                           <input type="text" name="userBlockTime" value="<%=userBlockTime%>" onkeyup="allowNumberOnly(this)" class="form-control text-center"  required >
                                           <select class="form-control" name="userBlockTimeUnit">
                                               <% for(String unit : timeUnits){ %>
                                                   <option value="<%=unit%>" <%if(userBlockTimeUnit.equals(unit)){%>selected<%}%>><%=toProperCase(unit)%></option>
                                               <% } %>
                                           </select>
                                       </div>
                                   </div>
                                   <div class="col-3">
                                       <input type="text" class="form-control w-25 text-center" name="userTries" value="<%=userTries%>" onkeyup="allowNumberOnly(this)" required >
                                   </div>
                               </div>

                               <br>
                               <div class="row">
                                   <div class="col-2">
                                       <label class="mt-2">IP Address</label>
                                   </div>
                                   <div class="col-3" >
                                       <div class="input-group w-75">
                                           <input type="text" name="ipBlockTime" value="<%=ipBlockTime%>" onkeyup="allowNumberOnly(this)" class="form-control text-center" required >
                                           <select class="form-control" name="ipBlockTimeUnit">
                                               <% for(String unit : timeUnits){ %>

                                                   <option value="<%=unit%>" <%if(ipBlockTimeUnit.equals(unit)){%>selected<%}%>><%=toProperCase(unit)%></option>
                                               <% } %>
                                           </select>
                                       </div>
                                   </div>
                                   <div class="col-3">
                                       <input type="text" class="form-control w-25 text-center" name="ipTries" value="<%=ipTries%>" onkeyup="allowNumberOnly(this)"  required >
                                   </div>
                               </div>
                                   <button type="submit" class="btn btn-primary mt-5" >Save</button>
                           </form>
                       </div>
                   </div>
               </div>
            <!--end content -->
            <!-- /end of container -->
        </main>
    <%@ include file="/WEB-INF/include/footer.jsp" %>
    </div>
        <script>
            //ready function
            $(function(){
                $('#blockTable').DataTable({
                    "responsive": true,
                    "language": {
                        "emptyTable": "No record found"
                    },
                    "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
                    "columnDefs": [
                        { targets : [3] , searchable : false},
                        { targets : [3] , orderable : false},
                    ],
                });

                $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
                    var target = $(e.target).attr("href") // activated tab
                    if(target == "#tabBlock"){
                        getLoginTriesData("user");
                    }
                });
            });

            function onChangeSelect(select){
                getLoginTriesData($(select).val());
            }

            function unblockItem(ipOrUsername){
                console.log("hereerer");
                console.log(ipOrUsername);
                getLoginTriesData($('#blockType').val(), ipOrUsername);
            }

            function getLoginTriesData(blockType, ipOrUsername){
                $('#blockTableBody').html("<tr><td colspan='5'><div class='d-flex justify-content-center mt-3'>Loading ...</div></td></tr>");
                if(blockType == "user"){
                    $('#ipOrUsernameCol').html("Username");
                }else{
                    $('#ipOrUsernameCol').html("IP Address");
                }
                $.ajax({
                    url: 'blockedUserAjax.jsp',
                    type: 'post',
                    dataType: 'json',
                    data: {blockType: blockType, ipOrUsername: ipOrUsername},
                })
                .done(function(json) {
                    var htmlrows = "";
                    for(var i = 0; i<json.length; i++){
                        htmlrows +=
                            '<tr>'+
                            '<td>'+json[i].ipOrUsername+'</td>'+
                            '<td>'+json[i].attempts+'</td>'+
                            '<td>'+json[i].lastAttempt+'</td>'+
                            '<td>'+
                            '<button class="btn btn-sm btn-danger mr-3" type="button" onclick="unblockItem(\''+json[i].ipOrUsername+'\')" >Un-Block</button>'+
                            '</td></tr>';
                    }
                    $('#blockTableBody').html("");
                    if(json.length>0){
                        $('#blockTableBody').html(htmlrows);
                    }else{
                        $('#blockTableBody').html("<tr><td colspan='5'><div class='d-flex justify-content-center mt-3'>No record found</div></td></tr>");
                    }
                })
                .fail(function() {
                    console.log("error");
                    alert("Error connecting with server");
                })
                .always(function() {
                    console.log("complete");
                });
            }

        </script>
    </body>
</html>