<%@ page import="java.util.*"%>

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

	String getSelectedSiteId(javax.servlet.http.HttpSession session)
	{
       	return parseNull(session.getAttribute("SELECTED_SITE_ID"));
	}

	public String escapeCoteValue(String str)
	{
		return com.etn.asimina.util.CommonHelper.escapeCoteValue(str);
	}

    private static final int ESC_CHAR = (int) '\\';
    private static final String ESC_STR = "\\\\";
    private static final String ESC_PLCHOLDR = "#SLS#";
    /***
     * a function to fix the issue of escape.cote()
     * where it removes \ characters from the string instead of properly escaping it
    * */
    String escapeCote(String str) {
        if (str == null || str.trim().length() == 0) {
            return escape.cote(str);
        }
        else if (str.indexOf(ESC_CHAR) >= 0) {
            //only do the extra replaces if needed, atleast one \ character is present
            String retStr = escape.cote(str.replaceAll(ESC_STR, ESC_PLCHOLDR));
            retStr = retStr.replaceAll(ESC_PLCHOLDR, ESC_STR + ESC_STR);
            return retStr;
        }
        else {
            return escape.cote(str);
        }
    }
%>