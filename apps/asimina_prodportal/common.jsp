<%!
	public String getMimeType(String filename)
	{
		String ext = filename;
		if(filename.indexOf(".") > -1) ext = filename.substring(filename.lastIndexOf("."));

		if(ext.equalsIgnoreCase(".css")) return "text/css";
		else if(ext.equalsIgnoreCase(".htc")) return "text/x-component";
		else if(ext.equalsIgnoreCase(".js")) return "application/x-javascript";
		else if(ext.equalsIgnoreCase(".axd")) return "application/x-javascript";
		else if(ext.equalsIgnoreCase(".json")) return "application/json";
		else if(ext.equalsIgnoreCase(".zip")) return "application/zip";
		else if(ext.equalsIgnoreCase(".gzip")) return "application/x-gzip";
		else if(ext.equalsIgnoreCase(".tgz")) return "application/tgz";
		else if(ext.equalsIgnoreCase(".doc")) return "application/msword";
		else if(ext.equalsIgnoreCase(".docx")) return "application/msword";
		else if(ext.equalsIgnoreCase(".pdf")) return "application/pdf";
		else if(ext.equalsIgnoreCase(".xls")) return "application/vnd.ms-excel";
		else if(ext.equalsIgnoreCase(".xlsx")) return "application/vnd.ms-excel";
		else if(ext.equalsIgnoreCase(".bmp")) return "image/bmp";
		else if(ext.equalsIgnoreCase(".cgm")) return "image/cgm";
		else if(ext.equalsIgnoreCase(".gif")) return "image/gif";
		else if(ext.equalsIgnoreCase(".ief")) return "image/ief";
		else if(ext.equalsIgnoreCase(".jpg")) return "image/jpeg";
		else if(ext.equalsIgnoreCase(".jpeg")) return "image/jpeg";
		else if(ext.equalsIgnoreCase(".tiff")) return "image/tiff";
		else if(ext.equalsIgnoreCase(".png")) return "image/png";
		else if(ext.equalsIgnoreCase(".svg")) return "image/svg+xml";
		else if(ext.equalsIgnoreCase(".djv")) return "image/vnd.djvu";
		else if(ext.equalsIgnoreCase(".djvu")) return "image/vnd.djvu";
		else if(ext.equalsIgnoreCase(".wbmp")) return "image/vnd.wap.wbmp";
		else if(ext.equalsIgnoreCase(".ras")) return "image/x-cmu-raster";
		else if(ext.equalsIgnoreCase(".ico")) return "image/x-icon";
		else if(ext.equalsIgnoreCase(".pnm")) return "image/x-portable-anymap";
		else if(ext.equalsIgnoreCase(".pbm")) return "image/x-portable-bitmap";
		else if(ext.equalsIgnoreCase(".pgm")) return "image/x-portable-graymap";
		else if(ext.equalsIgnoreCase(".ppm")) return "image/x-portable-pixmap";
		else if(ext.equalsIgnoreCase(".rgb")) return "image/x-rgb";
		else if(ext.equalsIgnoreCase(".au")) return "audio/basic";
		else if(ext.equalsIgnoreCase(".snd")) return "audio/basic";
		else if(ext.equalsIgnoreCase(".kar")) return "audio/midi";
		else if(ext.equalsIgnoreCase(".mid")) return "audio/midi";
		else if(ext.equalsIgnoreCase(".midi")) return "audio/midi";
		else if(ext.equalsIgnoreCase(".mp3")) return "audio/mpeg";
		else if(ext.equalsIgnoreCase(".mp2")) return "audio/mpeg";
		else if(ext.equalsIgnoreCase(".mp1")) return "audio/mpeg";
		else if(ext.equalsIgnoreCase(".mpga")) return "audio/mpeg";
		else if(ext.equalsIgnoreCase(".aifc")) return "audio/x-aiff";
		else if(ext.equalsIgnoreCase(".aif")) return "audio/x-aiff";
		else if(ext.equalsIgnoreCase(".aiff")) return "audio/x-aiff";
		else if(ext.equalsIgnoreCase(".m3u")) return "audio/x-mpegurl";
		else if(ext.equalsIgnoreCase(".ra")) return "audio/x-pn-realaudio";
		else if(ext.equalsIgnoreCase(".ram")) return "audio/x-pn-realaudio";
		else if(ext.equalsIgnoreCase(".wav")) return "audio/x-wav";
		else if(ext.equalsIgnoreCase(".rtf")) return "text/rtf";
		else if(ext.equalsIgnoreCase(".rtx")) return "text/richtext";
		else if(ext.equalsIgnoreCase(".sgm")) return "text/sgml";
		else if(ext.equalsIgnoreCase(".sgml")) return "text/sgml";
		else if(ext.equalsIgnoreCase(".mov")) return "video/quicktime";
		else if(ext.equalsIgnoreCase(".qt")) return "video/quicktime";
		else if(ext.equalsIgnoreCase(".mpeg")) return "video/mpeg";
		else if(ext.equalsIgnoreCase(".mpg")) return "video/mpeg";
		else if(ext.equalsIgnoreCase(".mpe")) return "video/mpeg";
		else if(ext.equalsIgnoreCase(".abs")) return "video/mpeg";
		else if(ext.equalsIgnoreCase(".m4u")) return "video/vnd.mpegurl";
		else if(ext.equalsIgnoreCase(".mxu")) return "video/vnd.mpegurl";
		else if(ext.equalsIgnoreCase(".avi")) return "video/x-msvideo";
		else if(ext.equalsIgnoreCase(".wmv")) return "video/x-ms-wmv";
		else if(ext.equalsIgnoreCase(".movie")) return "video/x-sgi-movie";
		else return "text/html";
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

/*	private String fixfilenameforurl(String path)
	{
		//% must be replaced first as all other special chars has % in it
		return path.replace("%", "%25")
		  .replace(" ", "%20")
                .replace("$", "%24")
                .replace("&", "%26")
                .replace("`", "%60")
                .replace(":", "%3A")
                .replace("<", "%3C")
                .replace(">", "%3E")
                .replace("[", "%5B")
                .replace("]", "%5D")
                .replace("{", "%7B")
                .replace("}", "%7D")
                .replace("“", "%22")
                .replace("+", "%2B")
                .replace("#", "%23")
                .replace("@", "%40")
                .replace("/", "%2F")
                .replace(";", "%3B")
                .replace("=", "%3D")
                .replace("?", "%3F")
                .replace("\\", "%5C")
                .replace("^", "%5E")
                .replace("|", "%7C")
                .replace("~", "%7E")
                .replace("‘", "%27")
                .replace(",", "%2C");
	}*/

	String getUnfixedLocalPath(com.etn.beans.Contexte Etn, String url)
	{
		if(url.toLowerCase().startsWith("https://")) url = url.substring(url.toLowerCase().indexOf("https:") + 8);
		else if(url.toLowerCase().startsWith("http://") ) url = url.substring(url.toLowerCase().indexOf("http:") + 7);

		String path = url;
		if(path.indexOf("/") > -1) path = path.substring(0, path.lastIndexOf("/"));

		path = path.trim();
		if(!path.endsWith("/")) path = path + "/";
		path = path.replace("?","_").replace("&","_").replace(":","_").replace("//","_");
		
		return getFolderId(Etn, path);
	}

	String getFolderId(com.etn.beans.Contexte Etn, String path)
	{
		Set rs = Etn.execute("select *, case when coalesce(name2,'') = '' then id else name2 end as displayname from folders where name = " + com.etn.sql.escape.cote(path) + " ");
		String r = "";
		if(rs.next())	
		{
			r = rs.value("displayname");
		}
		else 
		{
			int ar = Etn.executeCmd("insert into folders (name, hex_name) values ("+com.etn.sql.escape.cote(path)+",hex(sha("+com.etn.sql.escape.cote(path)+"))) ");
			r = "" + ar;
			if(ar <= 0)//means unique key is violated which could be case 2 threads adding same name at same time so try again fetching the id
			{
				rs = Etn.execute("select *, case when coalesce(name2,'') = '' then id else name2 end as displayname  from folders where name = " + com.etn.sql.escape.cote(path) + " ");
				if(rs.next()) 
				{
					r = rs.value("displayname");
					System.out.println("-------------- FOLDERS unique key violated : found id : " + r);
				}
			}
		}
		return r + "/";
	}

	String getLocalPath(com.etn.beans.Contexte Etn, String url)
	{
		return fixpath(getUnfixedLocalPath(Etn, url));
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
		if(fname.indexOf("#") > -1) fname = fname.substring(0, fname.indexOf("#"));
		return fname.trim().replace("?","_").replace("&","_").replace(":","_").replace("//","_");
	}

	String getLocalFilename(String url)
	{
		return fixpath(getUnfixedLocalFilename(url));
	}

	String escapeCoteValue(String str)
	{
		return com.etn.asimina.util.PortalHelper.escapeCoteValue(str);
	}

	String escapeCoteValue(String str, String skipChar)
	{
		return com.etn.asimina.util.PortalHelper.escapeCoteValue(str, skipChar);
	}

    String encodeJSONStringDB(String str){
        return com.etn.asimina.util.PortalHelper.encodeJSONStringDB(str);
    }

    String decodeJSONStringDB(String str){
		return com.etn.asimina.util.PortalHelper.decodeJSONStringDB(str);
    }

    /***
    * updated escape cote to preserve slashes (\)
    * which are removed by escape.cote() function
    */
    String escapeCote2(String str){
		return com.etn.asimina.util.PortalHelper.escapeCote2(str);
    }
	
    String getImageUrlVersion(String file)
    {		
		return com.etn.asimina.util.PortalHelper.getImageUrlVersion(file);
    }


%>