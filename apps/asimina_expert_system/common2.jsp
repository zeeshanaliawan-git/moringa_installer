<%@ page import="java.util.*"%>
<%@ page import="com.etn.beans.app.GlobalParm"%>

<%!

	class JsonToHtml
	{
		String id;
		String tag;
		String parentTag;
		String htmlTag;
		String maxRows;
		String showCol;
		String colHeader;
		String colSeqNum;	
		String functions;
		Map<String, JsonToHtml> childs = new LinkedHashMap<String, JsonToHtml>();
		boolean hasVisibleCols = false;
		String fieldType; 
		String fieldName;
		String fillFrom;
		String pagination;
		String colCss;
		String colHeaderCss;
		String d3chart;
		String c3chart;
		String xaxis;
		String xcols;
		String ycols;
		String c3col_graph_type;
		String c3_col_groups;
		String extras;

		public boolean hasClickFunction()
		{
			if(this.functions == null || this.functions.equals("")) return false;
			boolean s = false;
			if(this.functions.toLowerCase().indexOf("onclick") > -1) 
			{
				String[] funcs = this.functions.split(",");
				for(String f : funcs)
				{
					f = f.trim();
					if(f.toLowerCase().startsWith("onclick") && f.indexOf(":") > -1) s = true;
				}
			}
			return s;
		}
	}


    String parseNull(Object o)
    {
      if( o == null )
        return("");
      String s = o.toString();
      if("null".equals(s.trim().toLowerCase()))
        return("");
      else
        return(s.trim());
    }
	
	int parseNullInt(Object o)
    {
        if (o == null) return 0;
        String s = o.toString();
        if (s.equals("null")) return 0;
        if (s.equals("")) return 0;
        return Integer.parseInt(s);
    }

	private String getActualParent(String parentJsonTag)
	{
		String p = parseNull(parentJsonTag);
		if(p.indexOf(".") == -1) return p;
		else return p.substring(p.lastIndexOf(".") + 1);
	}

	List<String> getValues( String s , String tag)
	{
		List<String> _v = new ArrayList<String>();
		while(s.indexOf( "<"+tag+">" ) > -1)
		{

		int i = s.indexOf( "<"+tag+">" );
//		if( i == -1 ) return("");
		i += tag.length()+2;
		int j = s.indexOf( "</"+tag, i);
		if( j == -1 ) _v.add("");
		else _v.add(s.substring(i,j).trim());
		j += tag.length()+3;
		s = s.substring(j); 
		}
		return _v;
	}

	String getValue( String s , String tag)
	{
		List<String> ss = getValues(s, tag);
		if(ss != null && !ss.isEmpty()) return ss.get(0);
		return "";
	}

	String getLocalPath(com.etn.beans.Contexte Etn, String url)
	{
		return fixpath(getUnfixedLocalPath(Etn, url));
	}

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
		Set rs = Etn.execute("select * from " + GlobalParm.getParm("CKEDITOR_DB_NAME") + ".folders where name = " + com.etn.sql.escape.cote(path) + " ");
		String r = "";
		if(rs.next())	r = rs.value("id");
		else
		{
			int ar = Etn.executeCmd("insert into " + GlobalParm.getParm("CKEDITOR_DB_NAME") + ".folders (name, hex_name) values ("+com.etn.sql.escape.cote(path)+",hex(sha("+com.etn.sql.escape.cote(path)+"))) ");
			r = "" + ar;
			if(ar <= 0)//means unique key is violated which could be case 2 threads adding same name at same time so try again fetching the id
			{
				rs = Etn.execute("select * from " + GlobalParm.getParm("CKEDITOR_DB_NAME") + ".folders where name = " + com.etn.sql.escape.cote(path) + " ");
				if(rs.next()) r = rs.value("id");
			}
		}
		return r + "/";
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

   void writeFile(File aFile, String aContents) throws Exception {
        if (aFile == null) {
          throw new IllegalArgumentException("File should not be null.");
        }
        if (!aFile.exists()) {
          throw new FileNotFoundException ("File does not exist: " + aFile);
        }
        if (!aFile.isFile()) {
          throw new IllegalArgumentException("Should not be a directory: " + aFile);
        }
        if (!aFile.canWrite()) {
          throw new IllegalArgumentException("File cannot be written: " + aFile);
        }

        //use buffering
        Writer output = new BufferedWriter(new FileWriter(aFile));
        try {
          //FileWriter always assumes default encoding is OK!
          output.write( aContents );
        }
        finally {
          output.close();
        }
    }

%>