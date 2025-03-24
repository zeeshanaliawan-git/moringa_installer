<%!
	String getHomePage(com.etn.beans.Contexte Etn, String profilId, String menuLang) throws Exception
	{
		String homepage = "";
		String menuId = "";
		if(profilId.length() > 0)
		{
			com.etn.lang.ResultSet.Set rs = Etn.execute("select profil,homepage,menu_id from client_profils where id = " + com.etn.sql.escape.cote(profilId));
			if(rs != null && rs.next())
			{
				homepage = rs.value("homepage");
				menuId = rs.value("menu_id");
				String profil = rs.value("profil");                
				com.etn.lang.ResultSet.Set rs1 = Etn.execute("select homepage,menu_id from client_profils where profil = " + com.etn.sql.escape.cote(profil + "_" + menuLang));
				if(rs1 != null && rs1.next())
				{
					homepage = rs1.value("homepage");
					menuId = rs1.value("menu_id");
				}
			}
		}
		if(homepage.length() > 0 && menuId.length() > 0)
		{
			//check if homepage is cached or not
			com.etn.lang.ResultSet.Set _rs1 = Etn.execute("select c.id, c.filename, cp.file_path, cp.file_url from cached_pages c, cached_pages_path cp where c.is_url_active = 1 and cp.id = c.id and c.menu_id = "+com.etn.sql.escape.cote(menuId)+" and c.hex_eurl = hex(sha("+com.etn.sql.escape.cote(com.etn.util.Base64.encode(homepage.getBytes("UTF-8")))+")) ");
			if(_rs1.next())
			{
				com.etn.util.Logger.info("dologin.jsp","HP is cached");
				homepage = parseNull(_rs1.value("file_url")) + parseNull(_rs1.value("filename"));
			}
			else
			{
				homepage = com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK") + "process.jsp?___mid="+com.etn.util.Base64.encode(menuId.getBytes("UTF-8"))+"&___mu="+com.etn.util.Base64.encode(homepage.getBytes("UTF-8"));	
			}
		}
		return homepage;
	}

%>