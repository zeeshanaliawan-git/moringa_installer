<%!
String libelle_msg(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest req,String lib)
{ 
	String msg="";
	boolean voir = false;

	if( Etn.lang != 0)
	{
		javax.servlet.http.HttpSession session =  req.getSession(true);
		if( session.getAttribute("libelle_msg")==null)
		{ 
			msg = lib;
		}
		else
		{
			java.util.HashMap<String,String> h_msg = (java.util.HashMap <String,String>) session.getAttribute("libelle_msg");
			String lib2 = lib.replaceAll("[éèêë]","e").toUpperCase();
			if( h_msg.get(lib2)!=null)
			{
				if(! h_msg.get(lib2).toString().trim().equals(""))
				{
					msg = h_msg.get(lib2).toString();
				}
				else
				{
					msg =  lib;
				}
			}
			else
			{
				msg = lib;
				Etn.execute("insert IGNORE into langue_msg(LANGUE_REF) values("+ com.etn.sql.escape.cote(lib)+")");
			}
		}
	}
	else
	{
		msg = lib;
	}
	return(msg);
}

%>