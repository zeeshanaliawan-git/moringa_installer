<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, com.etn.asimina.util.SiteHelper" %>
<%@ include file="../WEB-INF/include/commonMethod.jsp" %>
<%
    String siteId = getSiteId(session);
    String CATALOG_DB = GlobalParm.getParm("CATALOG_DB");
    String PORTAL_DB = GlobalParm.getParm("PORTAL_DB");
    LinkedHashMap<String, String> colValueHM = new LinkedHashMap<>();
    LinkedHashMap<String, String> systemVariables = new LinkedHashMap<>();
	
	LinkedHashMap<String, String> testSiteSystemVariable = new LinkedHashMap<>();
	LinkedHashMap<String, String> prodSiteSystemVariable = new LinkedHashMap<>();

    String save =  parseNull(request.getParameter("save"));

    // algolia settings
    String q = "SELECT * FROM "+CATALOG_DB+".algolia_settings WHERE site_id = "+escape.cote(siteId);
    Set rs  = Etn.execute(q);
    if(rs.next()){
        prodSiteSystemVariable.put("algolia_application_id", rs.value("application_id"));
        prodSiteSystemVariable.put("algolia_search_api_key", rs.value("search_api_key"));
        prodSiteSystemVariable.put("algolia_write_api_key", rs.value("write_api_key"));

        testSiteSystemVariable.put("algolia_application_id", rs.value("test_application_id"));
        testSiteSystemVariable.put("algolia_search_api_key", rs.value("test_search_api_key"));
        testSiteSystemVariable.put("algolia_write_api_key", rs.value("test_write_api_key"));
    }

    // get default index of algolia
    q = "SELECT ai.index_name as default_index_value, CONCAT('algolia_default_index_', langue_code) as default_index_name" +
            " FROM "+CATALOG_DB+".algolia_default_index ai " +
            " LEFT JOIN "+CATALOG_DB+".language AS l ON l.langue_id = ai.langue_id " +
            " WHERE ai.site_id = "+escape.cote(siteId);

    rs = Etn.execute(q);
    while(rs.next()){
        systemVariables.put(rs.value("default_index_name"), rs.value("default_index_value"));
    }

    String BasePath = getFileURLPrepend() + siteId;
    systemVariables.put("images_path", BasePath + "/img/");
    systemVariables.put("videos_path", BasePath + "/video/");
    systemVariables.put("js_path", BasePath + "/js/");
    systemVariables.put("css_path", BasePath + "/css/");
    systemVariables.put("fonts_path", BasePath + "/fonts/");
    systemVariables.put("other_files_path", BasePath + "/other/");

    rs = Etn.execute("SELECT domain FROM "+PORTAL_DB+".sites WHERE id = "+escape.cote(siteId));
    if(rs.next()){
        systemVariables.put("domain", rs.value(0));
    }
    rs = Etn.execute("SELECT * FROM "+CATALOG_DB+".shop_parameters WHERE site_id = "+escape.cote(siteId));
    if(rs.next()){
        
        systemVariables.put("currency_code", parseNull(rs.value("lang_1_currency")));
        systemVariables.put("price_formatter", parseNull(rs.value("lang_1_price_formatter")));
        systemVariables.put("round_to_decimals", parseNull(rs.value("lang_1_round_to_decimals")));
        systemVariables.put("show_decimals", parseNull(rs.value("lang_1_show_decimals")));
        systemVariables.put("currency_position", parseNull(rs.value("lang_1_currency_position")));

        Set rs2 = Etn.execute("SELECT * FROM "+CATALOG_DB+".langue_msg WHERE LANGUE_REF="+escape.cote(parseNull(rs.value("lang_1_currency"))));
        if(rs2.next()){
            systemVariables.put("currency_label", rs2.value("LANGUE_1"));
        }
    }

    if(save.equals("1")){
        String[] variableNames = request.getParameterValues("name");
        String[] variableValues = request.getParameterValues("value");
        // delete previous vaiables
        Etn.execute("DELETE FROM variables WHERE site_id = "+escape.cote(siteId));
        // insert new variables
        for(int i = 0; i<variableNames.length; i++){
            // check the variable exist in the system variable of not
            if(!systemVariables.containsKey(variableNames[i]) && !colValueHM.containsKey(variableNames[i]) && variableNames[i].length() > 0 && variableValues[i].length() > 0){
                colValueHM.clear();
                colValueHM.put("site_id", escape.cote(siteId));
                colValueHM.put("name", escape.cote(variableNames[i]));
                colValueHM.put("value", escape.cote(variableValues[i]));
                colValueHM.put("created_ts", "NOW()");
                colValueHM.put("created_by", escape.cote(Etn.getId()+""));
                q = getInsertQuery("variables", colValueHM);
                Etn.executeCmd(q);
            }
        }
    }

    q = "SELECT * FROM variables WHERE site_id = "+escape.cote(siteId)+" order by name";
    Set rsVariables = Etn.execute(q);

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="../WEB-INF/include/head2.jsp" %>
    <title>Variales</title>
    <style type="text/css">
    </style>
</head>
<body class="c-app" style="background-color:#efefef">
    <%@ include file="/WEB-INF/include/sidebar.jsp" %>
    <div class="c-wrapper c-fixed-components">
            <%
            breadcrumbs.add(new String[]{"Developers", ""});
            breadcrumbs.add(new String[]{"Variables", ""});
        %>
        <%@ include file="/WEB-INF/include/header.jsp" %>
        <div class="c-body">
            <main class="c-main"  style="padding:0px 30px">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">Variables</h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <button type="button" class="btn btn-primary mr-2"
                                onclick="goBack('variables.jsp')">Back
                        </button>
                        <button type="button" class="btn btn-success mr-2"
                                onclick="saveVariables()">Save Variables
                        </button>
                        <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Variables');" title="Add to shortcuts">
                            <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
                        </button>
                    </div>
                </div>
                <div class="card">
                    <div class="card-body">
                        <form method="post" action="variables.jsp" id="variableForm">
                            <input type="hidden" id="saveFlagInput" value="0" name="save">
                            <table class="table table-hover table-bordered" cellpadding="0" cellspacing="0" border="0" id="variableTable" width="95%">
                                <thead class="thead-dark">
                                <tr>
                                    <th>Variable Name</th>
                                    <th>Variable Value</th>
                                    <th>Action</th>
                                </tr>
                                </thead>
                                <tbody>
                                <%
                                    for (String key : prodSiteSystemVariable.keySet()) {
                                %>
                                <tr class="env-based-row">
                                    <td>
                                        <input type="text" maxlength="500" class="form-control" disabled value="<%=key%>">
                                    </td>
                                    <td>
                                        <input type="text" maxlength="500" class="form-control prod-site-value" disabled value="<%=prodSiteSystemVariable.get(key)%>">
                                        <input type="text" maxlength="500" class="form-control test-site-value" style="display:none" disabled value="<%=parseNull(testSiteSystemVariable.get(key))%>">
                                        <button type="button" class="mt-2 btn btn-sm btn-warning btn-test-site-val">Switch to Test env value</button>
                                        <button type="button" class="mt-2 btn btn-sm btn-success btn-prod-site-val" style="display:none" >Switch to Prod env value</button>
                                    </td>
                                    <td>
                                        <button disabled type="button" class="btn btn-danger">x</button>
                                    </td>
                                </tr>
                                <%
                                }
                                %>
								
                                <%
                                    for (String key : systemVariables.keySet()) {
                                %>
                                <tr>
                                    <td>
                                        <input type="text" maxlength="500" class="form-control" disabled value="<%=key%>">
                                        <%
                                            if(key.equalsIgnoreCase("currency_code") || key.equalsIgnoreCase("price_formatter") || 
                                                key.equalsIgnoreCase("round_to_decimals") || key.equalsIgnoreCase("show_decimals") || key.equalsIgnoreCase("currency_label"))
                                            {
                                         %>
                                            <p class="mb-0 text-danger" style='font-size:0.8em'>This field is multi language.</p>
                                        <%
                                            }
                                        %>
                                    </td>
                                    <td>
                                        <input type="text" maxlength="500" class="form-control" disabled value="<%=systemVariables.get(key)%>">
                                    </td>
                                    <td>
                                        <button disabled type="button" class="btn btn-danger">
                                            x</button>
                                    </td>
                                </tr>
                                <%
                                }
                                %>

                                <% while(rsVariables.next()){ %>
                                    <tr>
                                        <td>
                                            <input type="text" maxlength="500" <%if(rsVariables.value("is_editable").equals("0")){%> disabled <%}%>  class="form-control" name="name" value="<%=SiteHelper.escapeCoteValue(rsVariables.value("name"))%>" placeholder="Name">
                                        </td>
                                        <td>
                                            <input type="text" maxlength="500" <%if(rsVariables.value("is_editable").equals("0")){%> disabled <%}%> class="form-control" name="value" value="<%=SiteHelper.escapeCoteValue(rsVariables.value("value"))%>" placeholder="Value">
                                        </td>
                                        <td>
                                            <button type="button" class="btn btn-danger"
                                                    <%if(rsVariables.value("is_editable").equals("0")){%> disabled <%}%>
                                                    onclick="deleteVariable(this)">
                                                x</button>
                                        </td>
                                    </tr>
                                <%}%>
                                <tr id="templateRow" class="d-none">
                                    <td>
                                        <input type="text" maxlength="500" class="form-control" name="name" placeholder="Name">
                                    </td>
                                    <td>
                                        <input type="text" maxlength="500" class="form-control" name="value" placeholder="Value">
                                    </td>
                                    <td>
                                        <button type="button" class="btn btn-danger"
                                                onclick="deleteVariable(this)">
                                        x</button>
                                    </td>
                                </tr>
                                </tbody>
                            </table>
                            <div class="d-flex m-3 pt-4">
                                <button type="button" class="btn btn-success mr-2"
                                        onclick="saveVariables()">Save Variables
                                </button>
                                <button type="button" class="btn btn-primary mr-2"
                                        onclick="addNewVariable()">Add New Variable
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </main>
        </div>
    </div>
<script type="text/javascript">

    $(function () {
		$(".btn-test-site-val").click(function(){
			$(this).closest(".env-based-row").find(".prod-site-value").hide();
			$(this).closest(".env-based-row").find(".test-site-value").show();
			$(this).closest(".env-based-row").find(".btn-prod-site-val").show();
			$(this).hide();
		});

		$(".btn-prod-site-val").click(function(){
			$(this).closest(".env-based-row").find(".test-site-value").hide();
			$(this).closest(".env-based-row").find(".prod-site-value").show();
			$(this).closest(".env-based-row").find(".btn-test-site-val").show();
			$(this).hide();
		});
    })

        function saveVariables(){
        $('#saveFlagInput').val("1");
        $('#variableForm').submit();
     }

    function addNewVariable(){
        let row = "<tr>" + $('#templateRow').html() + "</tr>" ;
        $('#variableTable tbody').append(row)
    }

    function deleteVariable(ele){
        console.log(ele)
        console.log($(ele).parent("tr:first"))
        $(ele).parent().parent().remove()
    }

</script>
</body>
</html>