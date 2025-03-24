<%
String ip = com.etn.asimina.util.PortalHelper.getIP(request);
if(ip.equals("127.0.0.1"))
{
	String id = request.getParameter("id");
	if(id == null) id = "";
	if("all".equalsIgnoreCase(id))
	{	
		com.etn.asimina.util.ApplyPageTemplateHelper.getInstance().reloadAll();
	}
	else if(id.trim().length() > 0)
	{
		com.etn.asimina.util.ApplyPageTemplateHelper.getInstance().reload(id);
	}
}
%>