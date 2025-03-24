<%@ page import="com.etn.lang.ResultSet.Set"%>
<%!
	String getDomain(String url)
	{
		String domain = url;
		if(domain.toLowerCase().indexOf("https://") > -1) domain = domain.substring(domain.toLowerCase().indexOf("https:") + 8);
		else if(domain.toLowerCase().indexOf("http://") > -1) domain = domain.substring(domain.toLowerCase().indexOf("http:") + 7);

		if(domain.indexOf("/") > -1) domain = domain.substring(0, domain.indexOf("/"));
		return domain.trim();
	}

	private String fixpath(String path)
	{
		return path.replace("%20", " ")
                .replace("%24", "$")
                .replace("%26","&")
                .replace("%60", "`")
                .replace("%3A",":")
                .replace("%3C","<")
                .replace("%3E",">")
                .replace("%5B","[")
                .replace("%5D","]")
                .replace("%7B","{")
                .replace("%7D","}")
                .replace("%22","“")
                .replace("%2B","+")
                .replace("%23","#")
                .replace("%25","%")
                .replace("%40","@")
                .replace("%2F","/")
                .replace("%3B",";")
                .replace("%3D","=")
                .replace("%3F","?")
                .replace("%5C","\\")
                .replace("%5E","^")
                .replace("%7C","|")
                .replace("%7E","~")
                .replace("%27","‘")
                .replace("%2C",",");
	}

	String getUnfixedLocalPath(com.etn.beans.Contexte Etn, String url, boolean returnPrimaryKey, String dbname)
	{
		if(url.toLowerCase().startsWith("https://")) url = url.substring(url.toLowerCase().indexOf("https:") + 8);
		else if(url.toLowerCase().startsWith("http://") ) url = url.substring(url.toLowerCase().indexOf("http:") + 7);

		String path = url;
		if(path.indexOf("/") > -1) path = path.substring(0, path.lastIndexOf("/"));

		path = path.trim();
		if(!path.endsWith("/")) path = path + "/";
		path = path.replace("?","_").replace("&","_").replace(":","_").replace("//","_");
		
		return getFolderId(Etn, path, returnPrimaryKey, dbname);
	}

	String getFolderId(com.etn.beans.Contexte Etn, String path, String dbname)
	{
		return getFolderId(Etn, path, false, dbname);
	}

	String getFolderId(com.etn.beans.Contexte Etn, String path, boolean returnPrimaryKey, String dbname)
	{
		Set rs = Etn.execute("select *, case when coalesce(name2,'') = '' then id else name2 end as displayname from "+dbname+"folders where name = " + com.etn.sql.escape.cote(path) + " ");
		String r = "";
		if(rs.next())	
		{
			if(returnPrimaryKey)	r = rs.value("id");
			else r = rs.value("displayname");
		}
		else 
		{
			int ar = Etn.executeCmd("insert into "+dbname+"folders (name, hex_name) values ("+com.etn.sql.escape.cote(path)+",hex(sha("+com.etn.sql.escape.cote(path)+"))) ");
			r = "" + ar;
			if(ar <= 0)//means unique key is violated which could be case 2 threads adding same name at same time so try again fetching the id
			{
				rs = Etn.execute("select *, case when coalesce(name2,'') = '' then id else name2 end as displayname  from "+dbname+"folders where name = " + com.etn.sql.escape.cote(path) + " ");
				if(rs.next()) 
				{
					if(returnPrimaryKey)	r = rs.value("id");
					else r = rs.value("displayname");
					System.out.println("-------------- FOLDERS unique key violated : found id : " + r);
				}
			}
		}
		return r + "/";
	}

	String getLocalPath(com.etn.beans.Contexte Etn, String url, boolean returnPrimaryKey, String dbname)
	{
		return fixpath(getUnfixedLocalPath(Etn, url, returnPrimaryKey, dbname));
	}
	
	String getLocalPath(com.etn.beans.Contexte Etn, String url, String dbname)
	{
		return fixpath(getUnfixedLocalPath(Etn, url, false, dbname));
	}
	
	String getUnfixedLocalFilename(String url)
	{
		if(url.toLowerCase().startsWith("https://")) url = url.substring(url.toLowerCase().indexOf("https:") + 8);
		else if(url.toLowerCase().startsWith("http://") ) url = url.substring(url.toLowerCase().indexOf("http:") + 7);

		String[] s = url.split("/");
		String fname = "";
		if(s == null) fname = url;
		else fname = s[s.length-1];
		if(fname.indexOf("?") > -1) fname = fname.substring(0, fname.indexOf("?"));
		return fname.trim().replace("?","_").replace("&","_").replace(":","_").replace("//","_");
	}

	String getLocalFilename(String url)
	{
		return fixpath(getUnfixedLocalFilename(url));
	}

%>