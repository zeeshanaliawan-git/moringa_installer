<%@ page import="java.util.*"%>
<%@ page import="com.etn.beans.app.GlobalParm"%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.lang.ResultSet.Xdr2Json"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="java.io.ByteArrayOutputStream"%>
<%@ page import="java.io.OutputStream"%>
<%@ page import="org.json.*,java.lang.reflect.*"%>

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

	public static JSONObject newJSONObject(){
        JSONObject jsonObject = new JSONObject() {
        @Override
            public JSONObject put(String key, Object value) throws JSONException {
                try {
                    Field map = JSONObject.class.getDeclaredField("map");
                    map.setAccessible(true);
                    Object mapValue = map.get(this);
                    if (!(mapValue instanceof LinkedHashMap)) {
                        map.set(this, new LinkedHashMap<>());
                    }
                } catch (NoSuchFieldException | IllegalAccessException e) {
                    throw new RuntimeException(e);
                }
                return super.put(key, value);
            }
        };
        return jsonObject;

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

   void writeFile(java.io.File aFile, String aContents) throws Exception {
        if (aFile == null) {
          throw new IllegalArgumentException("File should not be null.");
        }
        if (!aFile.exists()) {
          throw new java.io.FileNotFoundException ("File does not exist: " + aFile);
        }
        if (!aFile.isFile()) {
          throw new IllegalArgumentException("Should not be a directory: " + aFile);
        }
        if (!aFile.canWrite()) {
          throw new IllegalArgumentException("File cannot be written: " + aFile);
        }

        //use buffering
        java.io.Writer output = new java.io.BufferedWriter(new java.io.FileWriter(aFile));
        try {
          //FileWriter always assumes default encoding is OK!
          output.write( aContents );
        }
        finally {
          output.close();
        }
    }


	public class MyPojo {
		String key;
		Map<String, Object> data;

		public MyPojo() {
			data = new LinkedHashMap<String, Object>();
		}

		@Override
		public boolean equals(Object obj) {
			if (obj == null) {
				return false;
			}
			if (getClass() != obj.getClass()) {
				return false;
			}
			final MyPojo other = (MyPojo) obj;
			if ((this.key == null) ? (other.key != null) : !this.key.equals(other.key)) {
				return false;
			}
			return true;
		}

		@Override
		public int hashCode() {
			int hash = 5;
			hash = 89 * hash + (this.key != null ? this.key.hashCode() : 0);
			hash = 89 * hash + (this.data != null ? this.data.hashCode() : 0);
			return hash;
		}

	}

	String getSelectedSiteId(javax.servlet.http.HttpSession session)
	{
       	return parseNull(session.getAttribute("SELECTED_SITE_ID"));
	}

	public String escapeCoteValue(String str)
	{
		return com.etn.asimina.util.CommonHelper.escapeCoteValue(str);
	}

	String getJsonObjectName(String qryDescription, String qryType)
	{
		if(parseNull(qryType).equals("5")) return "d3json_" + qryDescription;
		else if(parseNull(qryType).equals("6")) return "d3mapjson_" + qryDescription;
		else if(parseNull(qryType).equals("7")) return "d3mapchljson_" + qryDescription;
		else if(parseNull(qryType).equals("4")) return "c3json_" + qryDescription;
		return qryDescription;
	}

	public String getJsonFromQueries(com.etn.beans.Contexte Etn, Map<String, String> result, String queryId, String queryFormat, String queryCategory) {

		String _out = "";
		OutputStream bOut = null;

		try
		{
			int i = 0;
			bOut = new ByteArrayOutputStream();
			Xdr2Json json = new Xdr2Json( bOut );
			if(i++ > 0) _out += ",";
			boolean reactCall = false;

			String query = parseNull(result.get("qry"));
			int totalRecords = 0;

			Set rs = Etn.executeWithCount(query);
			int nbRes = Etn.UpdateCount;

			JSONObject jsonObject = new JSONObject();

			int fmt = 0;

			totalRecords = Etn.UpdateCount;
			if(queryFormat.equals("2"))
			{	
				fmt = 2;				
				JSONArray jarr = getJSONArray(rs);				

				jsonObject.put("result", jarr.length());
				jsonObject.put("fmt", fmt);
				jsonObject.put("cols", rs.Cols);
				jsonObject.put("key", queryId);
				jsonObject.put("data", (new JSONObject()).put(queryCategory, jarr));
				jsonObject.put("total_records", Etn.UpdateCount);

				JSONObject finalJSONObject = new JSONObject();

				finalJSONObject.put("results", jsonObject);

				return finalJSONObject.toString();

			} 
			else if(queryCategory.equals("forms") || queryFormat.equals("3"))
			{
				if(queryFormat.equals("1") && queryCategory.equals("forms"))
					fmt = 10;
				else 
					fmt = 20;
				
				JSONArray jarr = getJSONArrayWithLabel(rs);

				jsonObject.put("result", jarr.length());
				jsonObject.put("fmt", fmt);
				jsonObject.put("cols", rs.Cols);
				jsonObject.put("key", queryId);				
				jsonObject.put("data", (new JSONObject()).put(queryCategory, jarr));
				jsonObject.put("total_records", Etn.UpdateCount);

				JSONObject finalJSONObject = new JSONObject();

				finalJSONObject.put("results", jsonObject);

				return finalJSONObject.toString();

			}
			else if(queryFormat.equals("5"))
			{
				fmt = 3;
				_out += "\"" + getJsonObjectName(queryCategory, queryFormat) + "\":";
			}
			else if(queryFormat.equals("6"))
			{
				fmt = 6;
				_out += "\"" + getJsonObjectName(queryCategory, queryFormat) + "\":";
			}
			else if(queryFormat.equals("7"))
			{
				fmt = 7;
				_out += "\"" + getJsonObjectName(queryCategory, queryFormat) + "\":";
			}
			else if(queryFormat.equals("4"))
			{
				String jsonName = getJsonObjectName(queryCategory, queryFormat);
				fmt = 4;
				_out += "\"" + jsonName + "\":";
			}

			json.getJson(rs, queryId, fmt, true, reactCall);
			_out += bOut.toString().trim();

			if(bOut != null) bOut.close();
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		finally
		{
			try { if(bOut != null) bOut.close(); } catch(Exception e) {}
		}

		return "{"+_out+"}";
	}

	JSONArray getJSONArrayWithLabel(Set rs) throws Exception 
	{
		JSONArray ja = new JSONArray();

		while(rs.next()){
	
			JSONObject jo = newJSONObject();

			for(int i=0; i<rs.Cols; i++)
			{	
				jo.put(rs.ColName[i], rs.value(i));
			}
	
			ja.put(jo);
		}

		return ja;
	}

	JSONArray getJSONArray(Set rs) throws Exception 
	{
		JSONArray jaa = new JSONArray();
		while(rs.next()){

			JSONArray ja = new JSONArray();
			for(int i=0; i<rs.Cols; i++)
			{
				ja.put(rs.value(i));
			}

			jaa.put(ja);
		}

		return jaa;
	}

	void fillObject(com.etn.beans.Contexte Etn, MyPojo cObject, Set rs, String levelId, String levelKey, String levelColumns, boolean propertiesFilled) throws Exception
	{
		//when we are filling child objects, we have current node's properties coming in as well so we don't have to fill those as those were already filled first time
		if(propertiesFilled == false)
		{	
			String[] cols = levelColumns.split(",");
			for(int i=0;i<cols.length;i++)
			{
				String col = parseNull(cols[i]).replace("<key>", parseNull(rs.value(levelKey)));
				String colLabel = col;
				if(col.indexOf(":") > -1) 
				{
					colLabel = parseNull(col.substring(0, col.indexOf(":")));
					col = parseNull(col.substring(col.indexOf(":") + 1));
				}
				boolean colExists = false;
				for(int j=0;j<rs.ColName.length;j++)
				{
					if((rs.ColName[j]).equals(col.toUpperCase()))
					{
						colExists = true;
						break;
					}
				}			
				if(cObject.data.get(colLabel) == null && colExists)
				{
					cObject.data.put(colLabel, parseNull(rs.value(col)));
				}
			}
		}

		Set rsLevels = Etn.execute("select * from es_query_levels where parent_level_id = "+escape.cote(levelId));
		while(rsLevels.next())
		{			
			if(parseNull(rs.value(rsLevels.value("j_object_key"))).length() == 0) continue;
			if("spec_attribs".equals(rsLevels.value("j_object_key")))//special case where we have json built in the query to improve performance
			{
				JSONArray jArray = new JSONArray(parseNull(rs.value(rsLevels.value("j_object_key"))).replaceAll("[\\t\\n\\r]+"," "));
				if(cObject.data.get(parseNull(rsLevels.value("j_object"))) == null)
				{
					cObject.data.put(parseNull(rsLevels.value("j_object")), jArray);
				}
			}
			else
			{									
				if(cObject.data.get(parseNull(rsLevels.value("j_object"))) == null)
				{
					cObject.data.put(parseNull(rsLevels.value("j_object")), new LinkedHashMap<String, Object>());
				}
				boolean childPropertiesAlreadyFilled = false;
				Map<String, Object> nObject = (Map<String, Object>)cObject.data.get(parseNull(rsLevels.value("j_object")));
				if(nObject.get(parseNull(rs.value(rsLevels.value("j_object_key")))) == null)
				{
					nObject.put(parseNull(rs.value(rsLevels.value("j_object_key"))), new MyPojo());
				}
				else childPropertiesAlreadyFilled = true;
				MyPojo nextObject = (MyPojo)nObject.get(parseNull(rs.value(rsLevels.value("j_object_key"))));
				
				fillObject(Etn, nextObject, rs, parseNull(rsLevels.value("id")), parseNull(rsLevels.value("j_object_key")), parseNull(rsLevels.value("j_object_columns")), childPropertiesAlreadyFilled);
			}
		}
	}
	
	JSONObject getJSONObject(MyPojo objects) throws Exception 
	{
		JSONObject jo = new JSONObject();
		for(String k : objects.data.keySet())
		{				
			try {
				Map<String, Object> cObject = (Map<String, Object>)objects.data.get(k);
				JSONArray jarray = new JSONArray();
				for(String k2 : cObject.keySet())
				{
					JSONObject nextObject = getJSONObject((MyPojo)cObject.get(k2));
					if(nextObject.length() > 0) jarray.put(nextObject);
				}
				if(jarray.length() > 0) jo.put(k, jarray);					
			}
			catch(Exception e) {
				jo.put(k, objects.data.get(k));
			}				
		}
		return jo;
	}

	String getWhereClause(com.etn.beans.Contexte Etn, String queryName, JSONArray filterSettings, Map<String, List<String>> requestParameters, boolean isPublicCall) throws Exception
	{
		String qrySettingsTbl = "query_settings";
		if(isPublicCall) qrySettingsTbl = "query_settings_published";

		String whereClause = " WHERE 1 = 1 ";
		String filterColumn = "";
		String filterType = "";
		String filterValue = "";

		for(int i=0; i < filterSettings.length(); i++){

			JSONObject filterJsonObject = (JSONObject) filterSettings.get(i);

			filterColumn = filterJsonObject.get("filter_column_name").toString();
			filterType = filterJsonObject.get("filter_type").toString();
			filterValue = filterJsonObject.get("filter_value").toString();

			Set rsMapping = Etn.execute("select * from es_query_col_mapping where query_name = "+escape.cote(queryName) + " and col = "+escape.cote(parseNull(filterColumn)));

			if(rsMapping.next())
			{
				String[] mappedCols = parseNull(rsMapping.value("mapped_cols")).split(",");
				if(mappedCols != null)
				{
					whereClause += " AND ( ";
					int j=0;
					for(String mc : mappedCols)
					{
						if(j++>0) whereClause += " OR ";

						if(filterType.equalsIgnoreCase("start")){
							whereClause += mc + " like " + escape.cote(filterValue+"%");
						}else if(filterType.equalsIgnoreCase("contains")){
							whereClause += mc + " like " + escape.cote("%"+filterValue+"%");
						}else if(filterType.equalsIgnoreCase("end")){
							whereClause += mc + " like " + escape.cote("%"+filterValue);
						}else{
							whereClause += mc + " = " + escape.cote(filterValue);
						}

					}
					whereClause += " ) ";
				}
			}
			else 
			{
				if(filterColumn.startsWith("$")){
					filterColumn = "JSON_EXTRACT(content_data, "+escape.cote(filterColumn)+")";
				}
				
				whereClause += " AND " + filterColumn;

				if(filterJsonObject.get("is_variable").equals("1") && isPublicCall){

					String v = "";
					if(null != requestParameters){
 
 						for(String val : requestParameters.get(filterColumn)){

							v += val + ",";
						}
					}

					if(v.length() > 0) {

						v = v.substring(0, v.length()-1);

						if(requestParameters.get(filterColumn).size() > 1){

							whereClause = whereClause + " in (" + v + ")" ;

						} else {
							if(filterType.equalsIgnoreCase("start")){
								whereClause += " like " + escape.cote(v+"%");
							}else if(filterType.equalsIgnoreCase("contains")){
								whereClause += " like " + escape.cote("%"+v+"%");
							}else if(filterType.equalsIgnoreCase("end")){
								whereClause += " like " + escape.cote("%"+v);
							}else{
								whereClause = whereClause + " " + filterType + " " + v;
							}
						}
					}

				} else {
					if(filterType.equalsIgnoreCase("start")){
						whereClause += " like " + escape.cote(filterValue+"%");
					}else if(filterType.equalsIgnoreCase("contains")){
						whereClause += " like " + escape.cote("%"+filterValue+"%");
					}else if(filterType.equalsIgnoreCase("end")){
						whereClause += " like " + escape.cote("%"+filterValue);
					}else{
						whereClause += " " + filterType + " " + escape.cote(filterValue);
					}
				}
			}
		}
		return whereClause;
	}

	String getOrderByClause(com.etn.beans.Contexte Etn, String queryName, JSONArray sortingSettings) throws Exception
	{
		String orderByClause = "";
		String sortColumn = "";
		String sortType = "";

		for(int i=0; i < sortingSettings.length(); i++){

			JSONObject sortingJsonObject = (JSONObject) sortingSettings.get(i);

			sortColumn = sortingJsonObject.get("sort_column_name").toString();
			sortType = sortingJsonObject.get("sort_type").toString();

			Set rsMapping = Etn.execute("select * from es_query_col_mapping where query_name = "+escape.cote(queryName) + " and col = "+escape.cote(parseNull(sortColumn)));

			if(rsMapping.next())
			{
				String[] mappedCols = parseNull(rsMapping.value("mapped_cols")).split(",");
				if(mappedCols != null)
				{
					int j=0;
					for(String mc : mappedCols)
					{
						if(j++>0) orderByClause += ", ";
						orderByClause += mc + " " + sortType;
					}
				}
			}
			else 
			{
				orderByClause += " " + sortColumn + " " + sortType;
			}

			if(i != sortingSettings.length()-1) orderByClause += ", ";			
		}

		if(orderByClause.length() > 0)
			orderByClause = " ORDER BY " + orderByClause;

		return orderByClause;
	}

	Map<String, String> getQuery(com.etn.beans.Contexte Etn, String queryName, String qsuuid, String siteid, Map<String, String> dbs, Map<String, String> paramMap, JSONArray filterSettings, JSONArray sortingSettings, boolean isPagination, int nPageNo, int nRecordsPerPage, Map<String, List<String>> requestParameters, String queryCategory, boolean isPublicCall, boolean isPreview) throws Exception
	{
		String qrySettingsTbl = "query_settings";
		if(isPublicCall) qrySettingsTbl = "query_settings_published";

		String preprodcatalogdb = dbs.get("preprod_catalog_db");
		String catalogdb = dbs.get("catalog_db");
		String portaldb = dbs.get("portal_db");
		String shopdb = dbs.get("shop_db");
		String qry = "select ";		

		String selCols = paramMap.get("selectCol");
		String[] selectedCols = null;

		if(selCols.length() > 0)
			selectedCols = selCols.split(",");

		int i=0;		
		if(selectedCols != null)
		{
			String likeClause = "";
			for(String sc : selectedCols)
			{
				Set rsMapping = Etn.execute("select * from es_query_col_mapping where query_name = "+escape.cote(queryCategory) + " and col = "+escape.cote(parseNull(sc)));
				if(rsMapping.next())
				{
					String[] mappedCols = parseNull(rsMapping.value("mapped_cols")).split(",");
					if(mappedCols != null)
					{
						for(String mc : mappedCols)
						{
							if(i++ > 0) qry += ", ";
							qry += mc;
						}
					}
				}
				else 
				{
					if(i++ > 0) qry += ", ";
					qry += sc;
				}
				if(likeClause.length() > 0) likeClause += " or ";
				likeClause += " j_object_columns like "+escape.cote(sc+",%")+" or j_object_columns like "+escape.cote("%,"+sc)+" or j_object_columns like "+escape.cote("%,"+sc+",%");
				likeClause += " or j_object_columns like "+escape.cote("%:"+sc+",%")+" or j_object_columns like "+escape.cote("%:"+sc);
				likeClause += " or j_object_columns like "+escape.cote(sc+":%")+" or j_object_columns like "+escape.cote("%,"+sc+":%");

			}
			Set rs1 = Etn.execute("Select distinct j_object_key from es_query_levels where query_name = "+escape.cote(queryCategory) + " and ("+likeClause+") ");
			while(rs1.next())
			{
				if(i++ > 0) qry += ", ";				
				qry += parseNull(rs1.value("j_object_key"));
			}			
		}
		//get the parent object row and always add its column to selected columns otherwise we cannot identify the object
		Set rsQ = Etn.execute("select * from es_query_levels where query_name = "+escape.cote(queryCategory) + " and coalesce(parent_level_id,0) = 0");
		if(rsQ.next())
		{
			if(i++>0) qry += ", ";
			qry += rsQ.value("j_object_key");
		}
		System.out.println("IsPubliCall " + isPublicCall + " qrySettingsTbl : " + qrySettingsTbl)		;
		Set rs = Etn.execute("Select esq.name as query_category, esq.*, qs.* from es_queries esq, "+qrySettingsTbl+" qs, query_types qt where qt.id = qs.query_type_id and esq.name = qt.query_name and qs.qs_uuid = "+escape.cote(qsuuid));
		rs.next();
		String paginationCol = rs.value("pagination_col");
		String querySubType = rs.value("query_sub_type_id");
		String innerQuery = getInnerQuery(Etn, dbs, paramMap, queryCategory, siteid, querySubType);

		qry += " from ( " + innerQuery + ") t ";
		String whereClause = getWhereClause(Etn, queryCategory, filterSettings, requestParameters, isPublicCall);
		String orderByClause = getOrderByClause(Etn, queryCategory, sortingSettings);

		Map<String, String> result = new HashMap<String, String>();
		if(isPagination)
		{
			Map<String, List<String>> pagination = getPagination(Etn, paginationCol, siteid, querySubType, dbs, paramMap, filterSettings, nPageNo, nRecordsPerPage, requestParameters, queryCategory, isPublicCall);
			for(String s : pagination.keySet())
			{
				if(s.equals("total_records")) result.put("total_records", pagination.get(s).get(0));
				else
				{
					String inClause = "";
					for(int k=0;k<pagination.get(s).size();k++)
					{
						if(k > 0) inClause += ", ";
						inClause += escape.cote(pagination.get(s).get(k));
					}
					//this is the case where lets say total records to show per page are 10 and there are total 19 records .. so page index 0, 1 will have 
					//data whereas if user passes pageNo = 3
					if(inClause.length() == 0) whereClause += " and 0 = 1";//this case we dont want to show any results as no results are availble according to pagination					
					else whereClause += " and " + s + " in ("+inClause+") ";
				}
			}
		}
				
		qry += whereClause;
		//adding sorting columns here 
		if(orderByClause.length() > 0) qry += orderByClause;
		result.put("qry", qry);
		result.put("query_category", rs.value("query_category"));
		return result;
	}

	Map<String, List<String>> getPagination(com.etn.beans.Contexte Etn, String paginationCol, String siteid, String querySubType, Map<String, String> dbs, Map<String, String> paramMap, JSONArray filterSettings, int nPageNo, int nRecordsPerPage, Map<String, List<String>> requestParameters, String queryCategory, boolean isPublicCall) throws Exception
	{
		String qrySettingsTbl = "query_settings";
		if(isPublicCall) qrySettingsTbl = "query_settings_published";

		String preprodcatalogdb = dbs.get("preprod_catalog_db");
		String catalogdb = dbs.get("catalog_db");
		String portaldb = dbs.get("portal_db");
		String shopdb = dbs.get("shop_db");
		
		String qry = " select distinct " + paginationCol;

		String innerQuery = getInnerQuery(Etn, dbs, paramMap, queryCategory, siteid, querySubType);

		qry += " from ( " + innerQuery + ") t ";
		
		qry += getWhereClause(Etn, queryCategory, filterSettings, requestParameters, isPublicCall);
		
		qry += " limit " + (nPageNo * nRecordsPerPage) + ", " + nRecordsPerPage;
		Set rs = Etn.executeWithCount(qry);
		int nbRes = Etn.UpdateCount;
		
		Map<String, List<String>> result = new HashMap<String, List<String>>();
		result.put("total_records", new ArrayList<String>());
		result.get("total_records").add(""+nbRes);

		result.put(paginationCol, new ArrayList<String>());
		while(rs.next())
		{
			result.get(paginationCol).add(rs.value(0));
		}

		return result;
	}

	public String getJSONStructureFromQueries(com.etn.beans.Contexte Etn, Set rs, String siteid, Map<String, String> dbs, String qsuuid, String pageNo, Map<String, List<String>> requestParameters, boolean isPublicCall, String queryCategory, String queryId, String queryFormat, boolean isPreview) throws Exception {

		String qrySettingsTbl = "query_settings";
		if(isPublicCall) qrySettingsTbl = "query_settings_published";

		String preprodcatalogdb = dbs.get("preprod_catalog_db");
		String catalogdb = dbs.get("catalog_db");
		String portaldb = dbs.get("portal_db");
		String shopdb = dbs.get("shop_db");

		Map<String, Object> objects = new LinkedHashMap<String, Object>();	
		Map<String, String> qryResult = new HashMap<String, String>();
		JSONObject json = new JSONObject();
		Set rsQry = null;

		String totalRecords = "";
		int count = 0;

		JSONArray selectedColumns = null;
		JSONObject jo = new JSONObject();
		
		rs.moveFirst();
		if(rs.next()){

			String _colSettings = rs.value("column_settings");
			if(_colSettings.length() == 0) _colSettings = "{}";			
	        JSONObject columnSettings = new JSONObject(_colSettings);
			
			String _sortSettings = rs.value("sorting_settings");
			if(_sortSettings.length() == 0) _sortSettings = "[]";			
			JSONArray sortingSettings = new JSONArray(_sortSettings);
			
			String _filterSettings = rs.value("filter_settings");
			if(_filterSettings.length() == 0) _filterSettings = "[]";			
			JSONArray filterSettings = new JSONArray(_filterSettings);
			
			String _selectedCols = rs.value("selected_columns");
			if(_selectedCols.length() == 0) _selectedCols = "[]";			
			selectedColumns = new JSONArray(_selectedCols);
			
			String queryName = parseNull(rs.value("name"));
			String recordsPerPage = parseNull(rs.value("items_per_page"));;

			String pagination = parseNull(rs.value("paginate"));

			Map<String, String> requestMap = new HashMap<String, String>();

			requestMap.put("selectCol", getSelectedCols(selectedColumns, queryCategory));

			boolean isPagination = (pagination.equals("1"))?true:false;
			if(isPreview) isPagination = true;

			Map<String, Map<String, Object>> jsonList = new LinkedHashMap<String, Map<String, Object>>();
							
			//this will come from request 
			//we are assuming user will start page no from 1 .. so we will always subtract 1 from it
			if(pageNo.length() == 0) pageNo = "0";
			int nPageNo = 0;
			try {
				nPageNo = Integer.parseInt(pageNo);
				nPageNo = nPageNo - 1;
				if(nPageNo < 0) nPageNo = 0;
			} catch (Exception e) { nPageNo = 0; }

			//these will come from table or maybe in request
			if(recordsPerPage.length() == 0) recordsPerPage = "10";
			int nRecordsPerPage = 10;
			try {
				nRecordsPerPage = Integer.parseInt(recordsPerPage);
			} catch (Exception e) { nRecordsPerPage = 10; }
			
			if(isPreview)
			{
				nRecordsPerPage = 10;
				nPageNo = 0;
			}
			
			qryResult = getQuery(Etn, queryName, qsuuid, siteid, dbs, requestMap, filterSettings, sortingSettings, isPagination, nPageNo, nRecordsPerPage, requestParameters, queryCategory, isPublicCall, isPreview);

			String qry = qryResult.get("qry");
			Set rsLevels = Etn.execute("select * from es_query_levels where query_name = "+escape.cote(qryResult.get("query_category"))+" and coalesce(parent_level_id,'0') = 0");

			rsQry = Etn.execute(qry);
			totalRecords = qryResult.get("total_records");

			while(rsLevels.next())
			{
				objects = new LinkedHashMap<String, Object>();	
				while(rsQry.next())
				{
					boolean propertiesFilled  = false;
					if(objects.get(parseNull(rsQry.value(rsLevels.value("j_object_key")))) == null)
					{
						objects.put(parseNull(rsQry.value(parseNull(rsLevels.value("j_object_key")))), new MyPojo());
					}
					else propertiesFilled = true;
					MyPojo cObject = (MyPojo)objects.get(parseNull(rsQry.value(rsLevels.value("j_object_key"))));
					fillObject(Etn, cObject, rsQry, parseNull(rsLevels.value("id")), parseNull(rsLevels.value("j_object_key")), parseNull(rsLevels.value("j_object_columns")), propertiesFilled);
				}
				
				jsonList.put(rsLevels.value("j_object"), objects);		
			}

			for(String s : jsonList.keySet() )
			{
				JSONArray jarray = new JSONArray();
				for(String k : jsonList.get(s).keySet())
				{
					jarray.put(getJSONObject((MyPojo)jsonList.get(s).get(k)));
				}
				json.put(s, jarray);
				count++;
			}

			if(!isPagination) totalRecords = objects.size()+"";
			
			if(isPreview == false && isPagination) jo.put("page_no", (nPageNo+1));
		}

		
		JSONObject finalJson = new JSONObject();

		jo.put("result", objects.size());
		jo.put("data", json);
		jo.put("fmt", 10);
		jo.put("cols", selectedColumns.length());
		jo.put("key", queryId);
		jo.put("total_results", parseNullInt(totalRecords));

		finalJson.put("results", jo);

		return finalJson.toString();
	}

	public Map<String, String> getPlainStructureQuery(com.etn.beans.Contexte Etn, Map<String, List<String>> requestParameters, Set rs, String siteid, String qsuuid, String queryCategory, String pageNo, Map<String, String> dbs, boolean isPublicCall, boolean isPreview) throws Exception {

		String qrySettingsTbl = "query_settings";
		if(isPublicCall) qrySettingsTbl = "query_settings_published";

		String preprodcatalogdb = dbs.get("preprod_catalog_db");
		String catalogdb = dbs.get("catalog_db");
		String portaldb = dbs.get("portal_db");
		String shopdb = dbs.get("shop_db");

		Map<String, String> result = new HashMap<String, String>();

		rs.moveFirst();
		if(rs.next()){

			String queryName = parseNull(rs.value("name"));
			String recordsPerPage = parseNull(rs.value("items_per_page"));
			String queryTypeId = parseNull(rs.value("query_type_id"));
			String querySubTypeId = parseNull(rs.value("query_sub_type_id"));

			String _colSettings = rs.value("column_settings");
			if(_colSettings.length() == 0) _colSettings = "{}";			
	        JSONObject columnSettings = new JSONObject(_colSettings);
			
			String _sortSettings = rs.value("sorting_settings");
			if(_sortSettings.length() == 0) _sortSettings = "[]";			
			JSONArray sortingSettings = new JSONArray(_sortSettings);
			
			String _filterSettings = rs.value("filter_settings");
			if(_filterSettings.length() == 0) _filterSettings = "[]";			
			JSONArray filterSettings = new JSONArray(_filterSettings);
			
			String _selectedCols = rs.value("selected_columns");
			if(_selectedCols.length() == 0) _selectedCols = "[]";			
			JSONArray selectedColumns = new JSONArray(_selectedCols);
			
			boolean isPagination = (parseNull(rs.value("paginate")).equals("1"))?true:false;			

			Map<String, String> requestMap = new HashMap<String, String>();

			requestMap.put("selectCol", getSelectedCols(selectedColumns, queryCategory));

			//this will come from request 
			//we are assuming user will start page no from 1 .. so we will always subtract 1 from it
			if(pageNo.length() == 0) pageNo = "0";
			int nPageNo = 0;
			try {
				nPageNo = Integer.parseInt(pageNo);
				nPageNo = nPageNo - 1;
				if(nPageNo < 0) nPageNo = 0;
			} catch (Exception e) { nPageNo = 0; }

			//these will come from table or maybe in request
			if(recordsPerPage.length() == 0) recordsPerPage = "10";
			int nRecordsPerPage = 10;
			try {

				if(isPagination) nRecordsPerPage = Integer.parseInt(recordsPerPage);

			} catch (Exception e) { nRecordsPerPage = 10; }

			if(isPreview)
			{
				isPagination = true;//in preview mode we will always do pagination				
				nRecordsPerPage = 10;
				nPageNo = 0;
			}

			String jsonSelectedColQuery = getInnerQuery(Etn, dbs, requestMap, queryCategory, siteid, querySubTypeId);

			if(queryCategory.equals("forms") && isPreview == false)
			{
				com.etn.util.Logger.info("expert_system::common.jsp","FORM inner QRY " + jsonSelectedColQuery);
				jsonSelectedColQuery += " where portalurl not like '%_portal/' ";
				com.etn.util.Logger.info("expert_system::common.jsp","FORM inner QRY " + jsonSelectedColQuery);
			}

			String whereClause = getWhereClause(Etn, queryCategory, filterSettings, requestParameters, isPublicCall);

			String outerCols = "";
			String selCols = requestMap.get("selectCol");
			String[] selectedCols = null;

			if(selCols.length() > 0)
				selectedCols = selCols.split(",");

			int i=0;		
			if(selectedCols != null)
			{
				String likeClause = "";
				for(String sc : selectedCols)
				{
					Set rsMapping = Etn.execute("select * from es_query_col_mapping where query_name = "+escape.cote(queryCategory) + " and col = "+escape.cote(parseNull(sc)));
					if(rsMapping.next())
					{
						String[] mappedCols = parseNull(rsMapping.value("mapped_cols")).split(",");
						if(mappedCols != null)
						{
							for(String mc : mappedCols)
							{
								if(i++ > 0) outerCols += ", ";
								outerCols += "t." + mc;
							}
						}
					}
					else 
					{
						if(i++ > 0) outerCols += ", ";
						outerCols += "t." + sc;
					}
					if(likeClause.length() > 0) likeClause += " or ";
					likeClause += " j_object_columns like "+escape.cote(sc+",%")+" or j_object_columns like "+escape.cote("%,"+sc)+" or j_object_columns like "+escape.cote("%,"+sc+",%");
					likeClause += " or j_object_columns like "+escape.cote("%:"+sc+",%")+" or j_object_columns like "+escape.cote("%:"+sc);
					likeClause += " or j_object_columns like "+escape.cote(sc+":%")+" or j_object_columns like "+escape.cote("%,"+sc+":%");

				}
				
				Set rs1 = Etn.execute("Select distinct j_object_key from es_query_levels where query_name = "+escape.cote(queryCategory) + " and ("+likeClause+") ");
				while(rs1.next())
				{
					if(i++ > 0) outerCols += ", ";				
					outerCols += "t." + parseNull(rs1.value("j_object_key"));
				}
				
			}

			if(jsonSelectedColQuery.length() > 0){

				jsonSelectedColQuery = "select " + outerCols + " from (" + jsonSelectedColQuery + ") t " + whereClause + " " + getOrderByClause(Etn, queryCategory, sortingSettings);
				if(isPagination) jsonSelectedColQuery += " limit " + (nPageNo * nRecordsPerPage) + ", " + nRecordsPerPage;
			}
			result.put("qry", jsonSelectedColQuery);

		}

		return result;
	}

	private String getSelectedCols(JSONArray selectedColumns, String queryCategory) throws Exception 
	{
		String selectedCols = "";

		for(int i=0; i < selectedColumns.length(); i++)
		{
			if(selectedCols.length() > 0) selectedCols += ",";
			selectedCols += selectedColumns.get(i);
		}

		if(queryCategory.equals("forms")){
			if(selectedCols.length() > 0) selectedCols += ",";
			selectedCols += "form_id";
		} 

		return selectedCols;
	}

	public String getJSONPlainStructureFromQuery(com.etn.beans.Contexte Etn, String siteid, String qsuuid, String pageNo, Map<String, String> dbs, boolean isPublicCall, boolean isPreview) throws Exception {

		return getJSONPlainStructureFromQuery(null, Etn, siteid, qsuuid, pageNo, dbs, isPublicCall, isPreview);
	}

	public String getJSONPlainStructureFromQuery(Map<String, List<String>> requestParameters, com.etn.beans.Contexte Etn, String siteid, String qsuuid, String pageNo, Map<String, String> dbs, boolean isPublicCall) throws Exception {

		return getJSONPlainStructureFromQuery(requestParameters, Etn, siteid, qsuuid, pageNo, dbs, isPublicCall, false);
	}

	public String getJSONPlainStructureFromQuery(Map<String, List<String>> requestParameters, com.etn.beans.Contexte Etn, String siteid, String qsuuid, String pageNo, Map<String, String> dbs, boolean isPublicCall, boolean isPreview) throws Exception {

		String qrySettingsTbl = "query_settings";
		if(isPublicCall) qrySettingsTbl = "query_settings_published";
			
		String preprodcatalogdb = dbs.get("preprod_catalog_db");
		String catalogdb = dbs.get("catalog_db");
		String portaldb = dbs.get("portal_db");
		String shopdb = dbs.get("shop_db");

		System.out.println("IsPubliCall " + isPublicCall + " qrySettingsTbl : " + qrySettingsTbl)		;
		Set rs = Etn.execute("select qs.*, qt.query_type, qt.query_name as query_category_name from "+qrySettingsTbl+" qs inner join query_types qt on qs.query_type_id = qt.id where qs.qs_uuid="+escape.cote(qsuuid)+" and site_id="+escape.cote(siteid));

		if(rs.next())
		{
			String queryId = parseNull(rs.value("query_id"));
			String queryFormat = parseNull(rs.value("query_format"));
			String queryCategory = parseNull(rs.value("query_category_name"));

			if(queryId.length() > 0)
				queryId = queryId.replaceAll(" ", "_");

			if(queryFormat.equals("1") && !queryCategory.equals("forms"))
			{
				return getJSONStructureFromQueries(Etn, rs, siteid, dbs, qsuuid, pageNo, requestParameters, isPublicCall, queryCategory, queryId, queryFormat, isPreview);
			} 
			else 
			{
				Map<String, String> result = getPlainStructureQuery(Etn, requestParameters, rs, siteid, qsuuid, queryCategory, pageNo, dbs, isPublicCall, isPreview);
				return getJsonFromQueries(Etn, result, queryId, queryFormat, queryCategory);
			}
		}

		return "";
	}

	String getInnerQuery(com.etn.beans.Contexte Etn, Map<String, String> dbs, Map<String, String> paramMap, String queryCategory, String siteid, String querySubType)
	{
		String preprodcatalogdb = dbs.get("preprod_catalog_db");
		String catalogdb = dbs.get("catalog_db");
		String commonsdb = GlobalParm.getParm("COMMONS_DB");
		String portaldb = dbs.get("portal_db");
		String shopdb = dbs.get("shop_db");

		String selectedCols = parseNull(paramMap.get("selectCol"));

		String formTableName = "";
		if(queryCategory.equals("forms"))
		{
			Set formRs = Etn.execute("select * from " + com.etn.beans.app.GlobalParm.getParm("FORMS_DB") + ".process_forms where site_id = " + escape.cote(siteid) + " and form_id = " + escape.cote(parseNull(querySubType)));
			if(formRs.next())
			{
				formTableName = parseNull(formRs.value("table_name"));
			}
		}
		
		Set rs = Etn.execute("Select * from es_queries where name = "+escape.cote(queryCategory));
		rs.next();				
		if(parseNull(rs.value("distinct_keys_query")).length() > 0)
		{
			int u=0;
			String qry = "";
			Set rsK = Etn.execute(parseNull(rs.value("distinct_keys_query")).replace("##delivery_fee_id##", escape.cote(querySubType)).replace("##subsidy_id##", escape.cote(querySubType)).replace("##sc_uuid##", escape.cote(querySubType)).replace("##site_id##", escape.cote(siteid)).replace("##PREPROD_CATALOG_DB##", preprodcatalogdb).replace("##CATALOG_DB##", catalogdb).replace("##COMMONS_DB##", commonsdb).replace("##PAGES_DB##", GlobalParm.getParm("PAGES_DB")).replace("##catalog_type##", escape.cote(querySubType)).replace("##PORTAL_DB##", portaldb).replace("##SHOP_DB##", shopdb));

			while(rsK.next())
			{
				if(u++ > 0) qry += " union ";
				qry += parseNull(rs.value("query")).replace("##delivery_fee_id##", rsK.value(0)).replace("##subsidy_id##", rsK.value(0)).replace("##product_id##", rsK.value(0)).replace("##bloc_id##", escape.cote(querySubType)).replace("##sc_uuid##", escape.cote(querySubType)).replace("##site_id##", escape.cote(siteid)).replace("##PREPROD_CATALOG_DB##", preprodcatalogdb).replace("##CATALOG_DB##", catalogdb).replace("##COMMONS_DB##", commonsdb).replace("##PAGES_DB##", GlobalParm.getParm("PAGES_DB")).replace("##page_id##", rsK.value(0)).replace("##SELECTED_COLUMN##", selectedCols).replace("##FORM_DB##", com.etn.beans.app.GlobalParm.getParm("FORMS_DB")).replace("##FORM_CUSTOM_TABLE##", formTableName).replace("##catalog_type##", escape.cote(querySubType)).replace("##PORTAL_DB##", portaldb).replace("##SHOP_DB##", shopdb);

			}
			return qry;
		}
		return parseNull(rs.value("query")).replace("##delivery_fee_id##", escape.cote(querySubType)).replace("##subsidy_id##", escape.cote(querySubType)).replace("##bloc_id##", escape.cote(querySubType)).replace("##sc_uuid##", escape.cote(querySubType)).replace("##site_id##", escape.cote(siteid)).replace("##PREPROD_CATALOG_DB##", preprodcatalogdb).replace("##CATALOG_DB##", catalogdb).replace("##COMMONS_DB##", commonsdb).replace("##PAGES_DB##", GlobalParm.getParm("PAGES_DB")).replace("##SELECTED_COLUMN##", selectedCols).replace("##FORM_DB##", com.etn.beans.app.GlobalParm.getParm("FORMS_DB")).replace("##FORM_CUSTOM_TABLE##", formTableName).replace("##catalog_type##", escape.cote(querySubType)).replace("##PORTAL_DB##", portaldb).replace("##SHOP_DB##", shopdb);
	}

	private static void extractPaths(Object obj, String path, List<String> paths) {
		try{
			if (obj instanceof JSONObject) {
				JSONObject jsonObject = (JSONObject) obj;
				String[] keys = JSONObject.getNames(jsonObject);
				if (keys != null) {
					for (String key : keys) {
						String newPath = path + "." + key;
						extractPaths(jsonObject.get(key), newPath, paths);
					}
				}
			}else if (obj instanceof JSONArray) {
				JSONArray jsonArray = (JSONArray) obj;
				for (int i = 0; i < jsonArray.length(); i++) {
					String newPath = path + "[" + i + "]";
					extractPaths(jsonArray.get(i), newPath, paths);
				}
			} else {
				paths.add(path);
			}
		}catch(Exception e){
			e.printStackTrace();
		}
    }

    List<String> getSelectableColumns(com.etn.beans.Contexte Etn, String qryName,String querySubType)
    {
		String pagesDb = parseNull(GlobalParm.getParm("PAGES_DB"))+".";
        Set rs = Etn.execute("Select * from es_queries where name = "+escape.cote(qryName));
        List<String> ignoreCols = new ArrayList<String>();
        while(rs.next())
        {
            String[] cols = parseNull(rs.value("ignore_selectable_col")).split(",");
            if(cols != null)
            {
                for(String col : cols)
                {
                    col = parseNull(col);
                    if(ignoreCols.contains(col) == false) ignoreCols.add(col);
                }
            }
        }

        rs = Etn.execute("Select * from es_query_levels where query_name = "+escape.cote(qryName));

        List<String> selectableCols = new ArrayList<String>();
        
        List<String> mappedCols = new ArrayList<String>();
        Set rsM = Etn.execute("Select * from es_query_col_mapping where query_name = " + escape.cote(qryName));
        while(rsM.next())
        {
            String[] mcols = parseNull(rsM.value("mapped_cols")).split(",");
            if(mcols != null)
            {
                if(selectableCols.contains(parseNull(rsM.value("col"))) == false && ignoreCols.contains(parseNull(rsM.value("col"))) == false) selectableCols.add(parseNull(rsM.value("col")));
                for(String mcol : mcols)
                {
                    mcol = parseNull(mcol);
                    if(mappedCols.contains(mcol) == false) mappedCols.add(mcol);
                }
            }
        }

        while(rs.next())
        {
            String[] cols = parseNull(rs.value("j_object_columns")).split(",");
            
            if(cols != null)
            {
                for(String col : cols)
                {
                    col = parseNull(col);
                    if(col.indexOf(":") > -1) col = col.substring(col.indexOf(":") + 1);
                    if(col.contains("<key>")) continue;
                    if(selectableCols.contains(col) == false && mappedCols.contains(col) == false && ignoreCols.contains(col) == false) selectableCols.add(col);

					if(col.equals("content_data")){
						
						Set rsStructured = Etn.execute("select content_data from "+pagesDb+"structured_contents_details scd where content_id in (select id from "+pagesDb+
							"structured_contents where template_id="+escape.cote(querySubType)+") limit 1");
						if(rsStructured.next()){
							try{
								extractPaths(new JSONObject(parseNull(rsStructured.value("content_data"))), "$", selectableCols);
							}catch(Exception e){
								e.printStackTrace();
							}
						}
					}
                }
            }
        }
        return selectableCols;
    }
	
	List<String> getFormSelectableCols(com.etn.beans.Contexte Etn, String formid)
	{
		Set rsF = Etn.execute("select * from " + com.etn.beans.app.GlobalParm.getParm("FORMS_DB") + ".process_forms where form_id = "+escape.cote(formid));
		rsF.next();
		
		List<String> selectableCols = new ArrayList<String>();
		//label type has db column which actually is not in table but its used as a class on ui but stored in db_column_name in table
        Set rs = Etn.execute("select db_column_name from " + com.etn.beans.app.GlobalParm.getParm("FORMS_DB") + ".process_form_fields where `type` <> 'label' and form_id = " + escape.cote(formid));

		selectableCols.add(rsF.value("table_name").toLowerCase() + "_id");
		selectableCols.add("created_on".toLowerCase());
        while(rs.next())
		{
            selectableCols.add(rs.value("db_column_name").toLowerCase());
        }
		return selectableCols;
	}
%>