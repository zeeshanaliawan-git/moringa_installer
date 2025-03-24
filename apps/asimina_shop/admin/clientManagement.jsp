<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.LinkedHashMap"%>

<%@ include file="../common.jsp" %>

<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>

<%	
	String[] client_ids = request.getParameterValues("client_id");
	String[] profile = request.getParameterValues("profil");
	String message = "";

	String portaldb = com.etn.beans.app.GlobalParm.getParm("PORTAL_DB");
	
	if( client_ids != null)
	{
		for(int i=0; i<client_ids.length;i++)
		{
			Etn.executeCmd("update "+portaldb+".clients set profil = "+escape.cote(profile[i])+" where id = "+escape.cote(client_ids[i]));
		}
	}

	Map<String, String> profiles = new LinkedHashMap<String, String>();
	Set rsProfile = Etn.execute("select distinct profil from client_profil order by profil");
  	profiles.put("","--");
	while(rsProfile.next())
	{
		profiles.put(rsProfile.value("profil"),rsProfile.value("profil"));
	}
	
	Set rsClients = Etn.execute("select * from "+portaldb+".clients order by email");

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
<title>Client Management</title>
    <link href="<%=request.getContextPath()%>/css/coreui-icons.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/font-awesome.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/simple-line-icons.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/coreui.css" rel="stylesheet">
<link href="<%=request.getContextPath()%>/css/my.css" rel="stylesheet">

    <link href="<%=request.getContextPath()%>/css/jquery-ui.min.css" rel="stylesheet">

    <script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/jquery-ui.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/popper.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/coreui.min.js"></script>
	<script src="<%=request.getContextPath()%>/js/feather.min.js?v=2.28.0"></script>
    <script type="text/javascript">
        $(function() {
            feather.replace();
        });
    </script>
<script>
	
	function onUpdateClients()
	{	
            document.clientFrm.submit();
	}
</script>
</head>
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
		<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
			<h1 class="h2">Client Management</h1>
		</div>
        <div class="animated fadeIn">
            <div class="card">
              <div class="card-body p-0">
		<form name="clientFrm" action="clientManagement.jsp" method="post" class="form-horizontal" role="form">	
			<table class="table table-responsive-sm resultat table-hover table-striped">
                            <thead>
				<tr> 
					<th>Email</th>					
					<th>Name</th>			
					<th>Profile</th>
				</tr>
                            </thead>
                            <tbody>
				<%	int rowsNum = 0;
				    while(rsClients.next()){%>
					<tr>
						<td align="left">
							<input type='text' maxlength='50' size='30' disabled class="hasDatepicker form-control" value='<%=rsClients.value("email")%>' />
						</td>
						<td align="left">
							<input type='text' maxlength='50' size='30' disabled class="hasDatepicker form-control" value='<%=rsClients.value("name")+" "+rsClients.value("surname")%>' />
						</td>
						<td align="left">
							<%=addSelectControl("upd_select_profile_"+rowsNum,"profil",profiles, false, 3)%>	
						</td>
					</tr>
					<input type="hidden" id="client_id_<%=rowsNum%>" name="client_id" value="<%=rsClients.value("id")%>"	/>
					<script>
						jQuery("#upd_select_profile_<%=rowsNum%>").val('<%=rsClients.value("profil")%>');
					</script>
				<%
					rowsNum ++;
					}%>
                            </tbody>
			</table>

			<% if(rowsNum > 0) { %>

	            <div class="row">
	                <div class="col-sm-12 text-center">
	                    <div class="" role="group" aria-label="controls">
                                <button type="button" class="btn btn-success" name="Search" onclick="onUpdateClients()" >Save</button>
	                    </div>
	                </div>
	            </div>
			<% } %>					
        </form>	
              </div>
            </div>
          </div>
	</main>
    </div>
    <%@ include file="../WEB-INF/include/footer.jsp" %>
</body>
</html>
