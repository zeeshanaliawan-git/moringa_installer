<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64, com.etn.asimina.util.ActivityLog, com.etn.beans.app.GlobalParm,com.etn.util.ItsDate"%>

<%@ include file="common.jsp"%>

<%
	String siteid = getSiteId(session);
	String lang = parseNull(request.getParameter("lang"));
	boolean isProd = "1".equals(parseNull(request.getParameter("prod")));

	String menuid = "";
	String menuname = "";
	Set rsL = Etn.execute("select * from language where langue_code = "+escape.cote(lang));
	if(rsL.next())
	{		
		Set rsSd = Etn.execute("select * from sites_details where site_id = "+escape.cote(siteid) + " and langue_id = "+escape.cote(parseNull(rsL.value("langue_id"))));
		if(rsSd.next())
		{
			Set rsSm = Etn.execute("select * from site_menus where menu_version = 'V2' and site_id = "+escape.cote(siteid) + " and lang = "+escape.cote(lang));
			if(rsSm.next())
			{
				System.out.println("Menu already found");
				Etn.executeCmd("update site_menus set is_active = 1, updated_on = now(), updated_by = "+escape.cote(""+Etn.getId())+", homepage_url = "+escape.cote(parseNull(rsSd.value("homepage_url")))+", prod_homepage_url = "+escape.cote(parseNull(rsSd.value("homepage_url")))+", 404_url = "+escape.cote(parseNull(rsSd.value("page_404_url")))+", prod_404_url = "+escape.cote(parseNull(rsSd.value("page_404_url")))+", version = version + 1, production_path = "+escape.cote(parseNull(rsSd.value("production_path")))+" where id = "+escape.cote(rsSm.value("id")) );
				menuid = rsSm.value("id");
				menuname = rsSm.value("name");
			}
			else
			{
				System.out.println("No menu found");
				int i = Etn.executeCmd("insert into site_menus (site_id, name, created_by, is_active, homepage_url, prod_homepage_url, lang, menu_uuid, 404_url, prod_404_url, version, production_path, menu_version) values ("+escape.cote(siteid)+", "+escape.cote("Menu "+lang)+", "+escape.cote(""+Etn.getId())+", 1, "+escape.cote(parseNull(rsSd.value("homepage_url")))+", "+escape.cote(parseNull(rsSd.value("homepage_url")))+", "+escape.cote(lang)+", uuid(), "+escape.cote(parseNull(rsSd.value("page_404_url")))+", "+escape.cote(parseNull(rsSd.value("page_404_url")))+", 1, "+escape.cote(parseNull(rsSd.value("production_path")))+", 'V2') ");
				if(i > 0)
				{
					menuid = "" + i;					
				}
			}
		}
		else 
		{
			out.write("{\"status\":200, \"msg\":\"No data found for the site and selected language. Please check site parameters are configured\"}");
		}
	}
	else 
	{
		out.write("{\"status\":100, \"msg\":\"Language not found\"}");
	}
	

	if(menuid.length() > 0)
	{	
		if(isProd == false)
		{
			String _script = GlobalParm.getParm("CRAWLER_SCRIPT");

			String[] cmd = new String[2];
			cmd[0] = _script;
			cmd[1] = menuid;

			Process proc = Runtime.getRuntime().exec(cmd);
		//	int r = proc.waitFor();

			Set rs =  Etn.execute("select name from site_menus where id = "+escape.cote(menuid)+" and site_id = "+escape.cote(siteid));
			rs.next();
			ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),menuid,"PUBLISH TEST","Menu",parseNull(rs.value(0)),siteid);
			out.write("{\"status\":0, \"msg\":\"Published\"}");
		}
		else
		{
			String ty = parseNull(request.getParameter("type"));
			String on = parseNull(request.getParameter("on"));			
		    String date = on;

			if(date.equals("-1")) date = "";
			else date = " for "+ date;

			String _d = "";
			if(!"-1".equals(on))
			{
				if(on.length() != 16)
				{
					out.write("{\"status\":300,\"msg\":\"Invalid date/time format. Format must be dd/mm/yyyy hh:mm\"}");
					return;
				}
				on = on + ":00";
				try {
					on =  ItsDate.stamp(ItsDate.getDate(on));
				} catch(Exception e) {
					out.write("{\"status\":300,\"msg\":\"Invalid date/time format. Format must be dd/mm/yyyy hh:mm\"}");
					return;
				}
			}
			
			String process = getProcess(ty);

			String phase = "publish";
			String msg = "Sucess";
			int status = 0;
			boolean dosemfree = movephase(Etn, menuid, process, phase, on);

			String publishon = "";
			Set rs = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s') from post_work where status = 0 and phase = 'publish' and client_key = "+escape.cote(menuid)+" and proces = " +escape.cote(process));
			if(rs.next()) publishon = "Next publish on : " + parseNull(rs.value(0));

			if(!dosemfree)
			{
				status = 350;
				msg = "Publish already in process";
			}
			else
			{
				ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),menuid,"PUBLISH PROD",process,menuname+date,siteid);
			}

			out.write("{\"status\":"+status+",\"msg\":\""+msg+"\", \"next_publish_on\":\""+publishon+"\"}");
			if(dosemfree) Etn.execute("select semfree('"+GlobalParm.getParm("SEMAPHORE")+"') ");
			
		}
	}
%>
