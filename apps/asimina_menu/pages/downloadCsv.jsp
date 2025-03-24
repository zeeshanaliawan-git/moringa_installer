<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" /><%@page import="com.etn.lang.ResultSet.Set, java.util.List, java.util.Arrays,java.util.ArrayList, java.net.URLEncoder,java.io.*"%><%!
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
	String filteredColumns = parseNull(session.getAttribute("filterCol"));
	String filename = "ClientLogs.csv";
	
	Set rs = Etn.execute(qry);		
  response.setContentType("text/csv");
  response.setHeader("Content-Disposition", "attachment; filename=" + filename);

	String header = "";
  List<String> filterCol = Arrays.asList(filteredColumns.split(","));
  String concatCols = "";
  String headers = "";

  for (String col : rs.ColName) {
      if (!filterCol.contains(col.toLowerCase())) {
          continue;
      }
      headers += "\"" + col.replace("_", " ") + "\",";
  }
  headers = headers.substring(0, headers.length() - 1);
  out.write(headers + "\n");

  while (rs.next()) {
      StringBuilder rowBuilder = new StringBuilder();
      for (String col : rs.ColName) {
          if (!filterCol.contains(col.toLowerCase())) {
              continue;
          }
          rowBuilder.append("\"").append(rs.value(col.toLowerCase())).append("\",");
      }
      String row = rowBuilder.toString();
      out.write(row.substring(0, row.length() - 1) + "\n");
  }

  out.flush();
%>