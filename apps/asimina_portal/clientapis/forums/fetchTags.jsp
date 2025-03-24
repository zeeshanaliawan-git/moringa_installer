<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>


<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape,com.etn.beans.app.GlobalParm,com.etn.asimina.util.PortalHelper"%>
<%@ page import="org.json.*, java.util.*"%>

<%
    String message="";
    int status=0;

    JSONObject obj = new JSONObject();
    JSONObject tagObj = new JSONObject();
    JSONArray tagsArray = new JSONArray();

	String searchTag = PortalHelper.parseNull(request.getParameter("tag")).toLowerCase();
	String siteuuid = PortalHelper.parseNull(request.getParameter("suid"));
	try{
		
		Set rsSite = Etn.execute("Select * from sites where suid = "+escape.cote(siteuuid));
		if(rsSite.rs.Rows == 0)
		{
			message="Invalid site uuid provided";
			status = 10;						
		}
		else
		{
			rsSite.next();
			String siteid = rsSite.value("id");
			String query ="SELECT tag_id as id, tag_name as label FROM "+com.etn.beans.app.GlobalParm.getParm("COMMONS_DB")+".forum_tags WHERE site_id = "+
				escape.cote(siteid);
			if(searchTag.length()>0){
				query += " and tag_name like "+escape.cote("%"+searchTag+"%");
			}
			Set rs = Etn.execute(query);
			while(rs.next()){
				JSONObject tagsObj = new JSONObject();
				for(String colName: rs.ColName){
					tagsObj.put(colName.toLowerCase(),rs.value(colName));
				}
				tagsArray.put(tagsObj);
			}
			tagObj.put("tags", tagsArray);
			obj.put("data",tagObj);
		}
	}catch(Exception e){
		message="Some  error occured while getting data.";
		status=2;
	}

	obj.put("msg",message);
    obj.put("status", status);

    out.write(obj.toString());
%>