<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm"%>
<%
	String ip = com.etn.asimina.util.PortalHelper.getIP(request);
	if(ip.equals("localhost") || ip.equals("127.0.0.1"))
	{
		System.out.println("Portal reload translations");
		com.etn.asimina.util.LanguageHelper.getInstance().reloadAll(Etn);
        Etn.executeCmd("insert into "+GlobalParm.getParm("COMMONS_DB")+".reload_translations (id,updated_dt) VALUES('shop',NOW()) ON DUPLICATE KEY update updated_dt=NOW()");
        Etn.executeCmd("insert into "+GlobalParm.getParm("COMMONS_DB")+".reload_translations (id,updated_dt) VALUES('prodshop',NOW()) ON DUPLICATE KEY update updated_dt=NOW()");
        Etn.executeCmd("insert into "+GlobalParm.getParm("COMMONS_DB")+".reload_translations (id,updated_dt) VALUES('selfcare',NOW()) ON DUPLICATE KEY update updated_dt=NOW()");
	}
%>
{"status":0}