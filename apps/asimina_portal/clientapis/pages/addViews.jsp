<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.Contexte, com.etn.asimina.session.PortalSession ,com.etn.asimina.session.ClientSession, com.etn.asimina.beans.Client , org.apache.http.HttpRequest, com.etn.beans.app.GlobalParm, org.json.*, java.util.*,javax.servlet.http.Cookie"%>
<%!

    String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

    int insertQuery(Contexte Etn, String tableName ,Map<String,String> params)
    {
        String query = "INSERT "+tableName+" SET ";
        int counter = 1;

        for (Map.Entry<String, String> param : 
             params.entrySet())
        {
            if(counter > 1) query += " , ";
            query += " "+param.getKey()+"="+escape.cote(param.getValue())+" ";
            counter++ ;
        }
        return Etn.executeCmd(query);
    }

    boolean checkIfExists(Contexte Etn, String tableName, Map<String,String> params)
    {
        String query = "SELECT * FROM "+tableName+" WHERE ";
        int counter = 1 ;
        for (Map.Entry<String, String> param : 
             params.entrySet())
        {
            if(counter > 1) query += " AND ";
            query += " "+param.getKey()+"="+escape.cote(param.getValue())+" ";
            counter++;
        }
        Set rs = Etn.execute(query);
        return (rs.rs.Rows > 0)? true : false;
    }

    boolean verifyBloc(Contexte Etn, String value,String siteId)
    {
        Map<String, String> params = new HashMap<String, String>();
        params.put("id",value);
        params.put("site_id",siteId);

        return checkIfExists(Etn,GlobalParm.getParm("PAGES_DB")+"."+"blocs",params);
    }

    boolean verifyPage(Contexte Etn, String value, String siteId)
    {
        Map<String, String> params = new HashMap<String, String>();
        params.put("uuid",value);
        params.put("site_id",siteId);

        return checkIfExists(Etn,GlobalParm.getParm("PAGES_DB")+"."+"pages",params);
    }

    boolean insertViewer(Contexte Etn,Map<String,String> params)
    {
        return (insertQuery(Etn,"bloc_viewers",params)>0)? true: false;
    }

    String returnViewerCount(Contexte Etn, String pageId, String blocId)
    {
        String viewers = "0";
        Set rs = Etn.execute("SELECT count(*) as viewers FROM bloc_viewers where bloc_id="+escape.cote(blocId)+" AND page_uuid="+escape.cote(pageId));
        if(rs.next())  viewers = rs.value("viewers");
        return viewers;
    }

    String getSiteId(Contexte Etn,String suid)
    {
        String siteId = "";
        Set rs = Etn.execute("SELECT * from sites where suid="+escape.cote(suid));
        if(rs.next()) siteId = parseNull(rs.value("id"));
        return siteId;
    }

%>
<%
    String message = "";
    String err_code = "";
    int status = 0;
    
    final String method = parseNull(request.getMethod());
    JSONObject json = new JSONObject();
	if("POST".equalsIgnoreCase(method) == false)
	{
		json.put("status", 100);
		json.put("err_code", "METHOD_NOT_SUPPORTED");
		json.put("err_msg", "Method '"+method+"' is not supported");
		out.write(json.toString());
		return;
	}

    JSONObject resp = new JSONObject();
    final String siteUuid = parseNull(request.getParameter("suid"));
    final Client client = ClientSession.getInstance().getLoggedInClient(Etn, request);
    final String blocId = parseNull(request.getParameter("blocid"));
    final String pageUuid = parseNull(request.getParameter("pageid"));
    final String siteId = getSiteId(Etn,siteUuid);
    try
    {
		final String sessionJ = PortalSession.getInstance().getId(Etn, request);
		if(blocId.length() == 0)
		{
			json.put("status", 50);
			json.put("err_code", "BLOC_ID_MISSING");
			json.put("message", "BLOC ID is REQUIRED");
			out.write(json.toString());
			return;
		}
		if(verifyBloc(Etn,blocId,siteId) == false)
		{
			json.put("status", 60);
			json.put("err_code", "BLOC_ID_IS_INVALID");
			json.put("message", "BLOC ID is invalid");
			out.write(json.toString());
			return;
		}
		if(pageUuid.length() == 0)
		{
			json.put("status", 70);
			json.put("err_code", "PAGE_ID_MISSING");
			json.put("message", "PAGE ID is REQUIRED");
			out.write(json.toString());
			return;
		}
		if(verifyPage(Etn,pageUuid,siteId) == false)
		{
			json.put("status", 40);
			json.put("err_code", "PAGE_ID_INVALID");
			json.put("message", "PAGE ID is invalid");
			out.write(json.toString());
			return;
		}
		
		Map<String,String> updateValues = new HashMap<String,String>();
		updateValues.put("bloc_id",blocId);
		updateValues.put("page_uuid",pageUuid);
		
		if(client != null)
		{
			updateValues.put("client_id",client.getProperty("client_uuid"));
		}

		if(sessionJ.length() > 0)
		{
			updateValues.put("session_j",sessionJ);
		}

		if(insertViewer(Etn,updateValues))
		{
			resp.put("nb_viewers",returnViewerCount(Etn,pageUuid,blocId));
			message = "Success";
		}
		else
		{
			status = 20;
			err_code = "SERVER_ERROR";
			message = "ERROR OCCURRED WHILE UPDATING";
		}		
    }
    catch(Exception e)
    {
        status = 90;
        err_code = "SERVER_ERROR";
        message = "Something went wrong"; 
    }
    json.put("status",status);
	json.put("message",message);
    if(err_code.length() > 0 && status > 0)
    {
        json.put("err_code",err_code);
    }
	else
	{
		json.put("data",resp);
	}
    
    out.write(json.toString());
%>

