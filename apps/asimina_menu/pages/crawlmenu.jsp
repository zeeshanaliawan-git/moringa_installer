<%
	String menuid = request.getParameter("menuid");
	if(menuid == null || menuid.length() == 0)
	{
		out.write("{\"msg\":\"Error. Menu id is missing\"}");
		return;
	}
	String _script = com.etn.beans.app.GlobalParm.getParm("CRAWLER_SCRIPT");
	if(menuid == null || menuid.length() == 0)
	{
		out.write("{\"msg\":\"Script path not configured\"}");
		return;
	}

	String[] cmd = new String[2];
	cmd[0] = _script;
	cmd[1] = menuid;
//System.out.println("cmd : " + _script + " " + menuid);
	Process proc = Runtime.getRuntime().exec(cmd);
//	int r = proc.waitFor();					
	out.write("{\"msg\":\"Crawler is initiated. It could take sometime to crawl the complete site. To test the site copy the html link of homepage in a new tab or browser. \"}");


%>