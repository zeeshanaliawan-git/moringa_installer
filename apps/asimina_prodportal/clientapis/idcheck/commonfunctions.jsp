<%!
    boolean tokenExpiry(com.etn.beans.Contexte Etn, String token) {
        com.etn.lang.ResultSet.Set rs = Etn.execute("select access_token_expires_in < NOW() as is_expired from idcheck_access_tokens where token="+com.etn.sql.escape.cote(token));
        rs.next();
        return com.etn.asimina.util.PortalHelper.parseNull(rs.value("is_expired")).equals("1");
    }
	
    String getIdnowUuidForToken(com.etn.beans.Contexte Etn, String token)
    {
        com.etn.lang.ResultSet.Set rs = Etn.execute("SELECT * FROM idcheck_access_tokens WHERE token="+com.etn.sql.escape.cote(token));
        if(rs.next()) return com.etn.asimina.util.PortalHelper.parseNull(rs.value("idnow_uuid"));
        return "";
    }
	
    String getIdnowToken(com.etn.beans.Contexte Etn, String token)
    {
        com.etn.lang.ResultSet.Set rs = Etn.execute("SELECT * FROM idcheck_access_tokens WHERE token="+com.etn.sql.escape.cote(token));
        if(rs.next()) return com.etn.asimina.util.PortalHelper.parseNull(rs.value("access_token"));
        return "";
    }

	
    String getSiteId(com.etn.beans.Contexte Etn, String siteUuid)
    {
        com.etn.lang.ResultSet.Set rs = Etn.execute("SELECT id from sites where suid="+com.etn.sql.escape.cote(siteUuid));
        if(rs.next()) 
            return com.etn.asimina.util.PortalHelper.parseNull(rs.value("id"));
        return "";
    }

    String getAccessToken(Cookie[] cookies) {
        if(cookies == null) return "";
        for (Cookie cookie : cookies)
        {
            if( "__idnow".equalsIgnoreCase(cookie.getName())) return com.etn.asimina.util.PortalHelper.parseNull(cookie.getValue());
        }
        return "";
    } 
    
    String getUuidForIdnowId(com.etn.beans.Contexte Etn, String uid)
    {
        com.etn.lang.ResultSet.Set rs = Etn.execute("SELECT uuid FROM idnow_sessions WHERE idnow_uid="+com.etn.sql.escape.cote(uid));
        if(rs.next()) return com.etn.asimina.util.PortalHelper.parseNull(rs.value("uuid"));
        return "";
    }
	
    String getIdnowId(com.etn.beans.Contexte Etn, String uuid)
    {
        com.etn.lang.ResultSet.Set rs = Etn.execute("SELECT idnow_uid FROM idnow_sessions WHERE uuid="+com.etn.sql.escape.cote(uuid));
        if(rs.next()) return com.etn.asimina.util.PortalHelper.parseNull(rs.value("idnow_uid"));
        return "";
    }

    boolean verifyLang(com.etn.beans.Contexte Etn, String langCode, String siteId)
    {
		String catalogDb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
		String commonsDb = com.etn.beans.app.GlobalParm.getParm("COMMONS_DB");
        com.etn.lang.ResultSet.Set rs = Etn.execute("SELECT * from "+commonsDb+".sites_langs where site_id="+escape.cote(siteId)+" AND langue_id=( Select langue_id from "+catalogDb+".language where langue_code="+escape.cote(langCode)+")");
        if(rs.next()) return true;
        return false;
    }

    String getFirstLang(com.etn.beans.Contexte Etn, String siteId)
    {
		String catalogDb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
		String commonsDb = com.etn.beans.app.GlobalParm.getParm("COMMONS_DB");
        com.etn.lang.ResultSet.Set rs = Etn.execute("SELECT langue_code from "+catalogDb+".language where langue_id in (SELECT langue_id from "+commonsDb+".sites_langs where site_id="+escape.cote(siteId)+" order by langue_id)");
        rs.next();
        return PortalHelper.parseNull(rs.value("langue_code"));
    }

    String getLang(com.etn.beans.Contexte Etn, String langCode,String siteId)
    {        
        if(langCode.length() == 0 || !verifyLang(Etn,langCode,siteId)) return getFirstLang(Etn,siteId);
        return langCode;
    }


%>