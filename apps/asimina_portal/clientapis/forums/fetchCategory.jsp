<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>


<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape,com.etn.beans.app.GlobalParm,com.etn.asimina.util.PortalHelper"%>
<%@ page import="org.json.JSONObject,org.json.JSONArray, java.util.*"%>

<%
    String message="";
    int status=0;

    JSONObject obj = new JSONObject();

	String siteuuid = PortalHelper.parseNull(request.getParameter("suid"));
	
	if(siteuuid.length() == 0)
	{
		message="Site uuid is required";
		status = 10;						
		obj.put("msg",message);
		obj.put("status", status);

		out.write(obj.toString());
		return;		
	}
	Set rsSite = Etn.execute("Select * from sites where suid = "+escape.cote(siteuuid));
	if(rsSite.rs.Rows == 0)
	{
		message="Invalid site uuid provided";
		status = 10;						
		obj.put("msg",message);
		obj.put("status", status);

		out.write(obj.toString());
		return;
	}
	
	rsSite.next();
	String siteid = rsSite.value("id");

	try{
        List<String> respObjArray = new ArrayList<>();

		String qry = "select distinct category from client_reviews where is_deleted=0 and source_type='forum' and type='forum' and site_id="+
			escape.cote(siteid)+" order by created_dt desc ";
		
		Set rs = Etn.executeWithCount(qry);

		if(rs!=null){ 
			while(rs.next()){
				if(PortalHelper.parseNull(rs.value("category")).length() > 0){
					respObjArray.add(PortalHelper.parseNull(rs.value("category")));
				}
			}
		}

        if(respObjArray.size()>0){
            obj.put("data",respObjArray);
        }else{
            message = "No category found.";
        }

	}catch(Exception e){
        message="Some  error occured while getting data.";
        status=2;
	}

	obj.put("msg",message);
    obj.put("status", status);
    

    out.write(obj.toString());
%>