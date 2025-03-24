<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" /><%@page import="com.etn.lang.ResultSet.Set, java.util.List, java.util.Arrays,java.util.ArrayList, java.net.URLEncoder,com.etn.asimina.util.FileUtil"%><%!
String parseNull(Object o) {
  if( o == null )
    return("");
  String s = o.toString();
  if("null".equals(s.trim().toLowerCase()))
    return("");
  else
    return(s.trim());
}
%><%
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");

	String qry = parseNull(session.getAttribute("qry"));
	String filteredColumns = parseNull(session.getAttribute("filteredColumns"));
	String filename = parseNull(request.getParameter("filename")).replace(" ","-").replaceAll("/", "").replaceAll("\\\\", "").toLowerCase() + ".csv";
   	String selectedIds = parseNull(request.getParameter("selectedids"));
   	String formid = parseNull(request.getParameter("formid"));

   	if(selectedIds.length() > 0)
	{
		Set rsF = Etn.execute("select * from process_forms where form_id = "+com.etn.sql.escape.cote(formid));
		if(rsF.next())
		{
			String tablename = rsF.value("table_name");
			String inclause = "";
			for(String sid : selectedIds.split(","))
			{
				if(inclause.length() > 0) inclause += ",";
				inclause += com.etn.sql.escape.cote(sid);
			}
			qry = "select * from " + tablename + " ct where 1 = 1 and " + tablename + "_id in (" + inclause + ")  order by created_on desc";
			//System.out.println(qry);
		}
   	}

	String cqry = "select * from ("+qry+") t limit 1";	
	
	Set rs = Etn.execute(cqry);		

	String header = "";
	String delimiter = ";";
	List<String> filterCol = Arrays.asList(filteredColumns.split(","));
	
	List<String> ignoreCols = new ArrayList<String>();
	
	ignoreCols.add("rule_id");
	ignoreCols.add("form_id");
	ignoreCols.add("created_by");
	ignoreCols.add("updated_on");
	ignoreCols.add("updated_by");
	ignoreCols.add("lastid");
	ignoreCols.add("menu_lang");
	ignoreCols.add("mid");
	ignoreCols.add("portalurl");
	ignoreCols.add("userip");

	String concatCols = "";

	List<Integer> ignoredColsPos = new ArrayList<Integer>();
	for(int i=0; i<rs.ColName.length; i++)
	{
		if(ignoreCols.contains((rs.ColName[i]).toLowerCase()))
		{
			ignoredColsPos.add(i);
			continue;
		}
		String colname = rs.ColName[i].toLowerCase();
		if(colname.startsWith("_etn_")){ 
			/*if(!filterCol.contains(rs.ColName[i].toLowerCase()))
			{
				ignoredColsPos.add(i);
				continue;
			}*/
			colname = colname.substring("_etn_".length());
		}
		header += "\"" + colname + "\"";
		header += delimiter;
		
		if(i>0) concatCols += ",";
		concatCols += "'\"'";
		concatCols += ",";
		concatCols += "replace(replace(replace(coalesce(t."+rs.ColName[i].toLowerCase()+",''),'\\r\\n',''),'\\n',''),'\"','\\\"')";
		concatCols += ",";
		concatCols += "'\"'";
		concatCols += ",";
		concatCols += "'"+delimiter+"'";
	}
	
	cqry = " select c from (select 0 as p, '"+header+"' as c union "+
		" select 1 as p, concat("+concatCols+") as c from ("+qry+") t) t2 "+
		" order by t2.p ";
	
	String tmpDir = com.etn.beans.app.GlobalParm.getParm("export_csv_dir");
	FileUtil.mkDir(tmpDir);//change
	// java.io.File tDir = new java.io.File(tmpDir);
	// if(tDir.exists() == false) tDir.mkdir();
	
	String exportScript = com.etn.beans.app.GlobalParm.getParm("EXPORT_SCRIPT");
	
	String[] cmd = new String[3];
	cmd[0] = exportScript;
	cmd[1] = tmpDir + filename;
	cmd[2] = cqry.replace("\"","\\\"");
	
//	System.out.println(cmd[0]);
//	System.out.println(cmd[1]);
//	System.out.println(cmd[2]);
	
	Process proc = Runtime.getRuntime().exec(cmd);
	int r = proc.waitFor();
	String encodedUrl = URLEncoder.encode(filename,"UTF-8"); 
	response.sendRedirect(com.etn.beans.app.GlobalParm.getParm("export_csv_url") + encodedUrl);
	
%>