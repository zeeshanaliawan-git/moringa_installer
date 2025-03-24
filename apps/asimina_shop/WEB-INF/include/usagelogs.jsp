<%!
	void addusagelog(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String login, String activity, String details)
	{
		String useragent = "";
		useragent = request.getHeader("User-Agent");
		if(useragent == null) useragent = "";
		String activityfrom = "web";
		if(useragent.toLowerCase().indexOf("android") != -1 || useragent.toLowerCase().indexOf("ipad") != -1 || useragent.toLowerCase().indexOf("iphone") != -1 || useragent.toLowerCase().indexOf("apache-httpclient/unavailable") != -1 ) activityfrom = "device";

		if(details == null) details = "";
	
		String ip = "";
		if(request.getHeader("x-forwarded-for") != null) ip = request.getHeader("x-forwarded-for");
		Etn.executeCmd("insert into usage_logs (login, activity, ip, activity_from, user_agent, details) values ("+com.etn.sql.escape.cote(login)+","+com.etn.sql.escape.cote(activity)+","+com.etn.sql.escape.cote(ip)+","+com.etn.sql.escape.cote(activityfrom)+", "+com.etn.sql.escape.cote(useragent)+", "+com.etn.sql.escape.cote(details)+")");		
	}
%>