<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>


<%
	String[] screens = request.getParameterValues("screen");
	String[] uiItems = request.getParameterValues("uiItem");
	String[] values = request.getParameterValues("value");
	for(int i=0;i<screens.length;i++)
	{
		Set rs = Etn.execute("select count(0) as c from uipreferences where user = "+escape.cote((String)session.getAttribute("LOGIN"))+" and screen = "+escape.cote(screens[i])+" and uiItem = "+escape.cote(uiItems[i])+" ");
		rs.next();
		if(Integer.parseInt(rs.value("c")) > 0) //means already exists so update it
		{	
			Etn.executeCmd("update uipreferences set user = "+escape.cote((String)session.getAttribute("LOGIN"))+", screen = "+escape.cote(screens[i])+", uiItem = "+escape.cote(uiItems[i])+", value = "+escape.cote(values[i])+" where user = "+escape.cote((String)session.getAttribute("LOGIN"))+" and screen = "+escape.cote(screens[i])+" and uiItem = "+escape.cote(uiItems[i])+" ");
		}
		else		
		{
			Etn.executeCmd("insert into uipreferences (user, screen, uiItem, value) values ("+escape.cote((String)session.getAttribute("LOGIN"))+", "+escape.cote(screens[i])+", "+escape.cote(uiItems[i])+", "+escape.cote(values[i])+" )");
		}
	}
%>