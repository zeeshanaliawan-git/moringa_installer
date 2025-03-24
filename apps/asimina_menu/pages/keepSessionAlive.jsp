<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="java.util.Map,org.json.JSONObject,org.json.JSONArray"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="com.etn.beans.app.GlobalParm"%>

<%!
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
%>
<%
    int STATUS_SUCCESS =1;
    int STATUS_ERROR =0;
    int status = STATUS_ERROR;
    String message ="";

    String requestType = parseNull(request.getParameter("requestType"));
    if("addToShortcut".equalsIgnoreCase(requestType)){
        try{
            String siteId = session.getAttribute("SELECTED_SITE_ID").toString();
            String pagePath = parseNull(request.getParameter("pagePath"));
            String pageName = parseNull(request.getParameter("pageName"));
            
            Set rsAddShortCut = Etn.execute("select * from shortcuts where site_id="+escape.cote(siteId)+" and created_by="+escape.cote(""+ Etn.getId())+
                "and name="+escape.cote(pageName));
            if(rsAddShortCut.rs.Rows>0){
                int i = Etn.executeCmd("delete from shortcuts where site_id="+escape.cote(siteId)+" and created_by="+escape.cote(""+ Etn.getId())+
                "and name="+escape.cote(pageName));
                
                if(i>0){
                    message ="deleted";
                    status = STATUS_SUCCESS;
                }
            }else{
                rsAddShortCut = Etn.execute("select * from shortcuts where site_id="+escape.cote(siteId)+" and created_by="+escape.cote(""+ Etn.getId()));
                if(rsAddShortCut.rs.Rows>=10){
                    message ="Error: Your shortcuts limit reached for this site.";
                    status = STATUS_ERROR;
                }else{
                    int i = Etn.executeCmd("insert into shortcuts (name,url,created_by,site_id) values ("+escape.cote(pageName)+","+escape.cote(pagePath)+
                        ","+escape.cote(""+ Etn.getId())+","+escape.cote(siteId)+")");
                    
                    if(i>0){
                        message ="added";
                        status = STATUS_SUCCESS;
                    }else{
                        status = STATUS_ERROR;
                    }
                }
            }
        }//try
        catch(Exception ex){
            throw new Exception("Error adding in shortcuts.",ex);
        }
    }else{
        status = 0;
        message ="Success";
    }
    JSONObject jsonResponse = new JSONObject();
    jsonResponse.put("status",status);
    jsonResponse.put("message",message);
    out.write(jsonResponse.toString());
%>