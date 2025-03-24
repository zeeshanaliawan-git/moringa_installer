<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.Contexte, com.etn.beans.app.GlobalParm, org.json.*, java.util.*,com.etn.pages.PagesGenerator"%>
<%!
    String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

    String getBlocId(Contexte Etn, String blocUuid)
    {
        Set rs = Etn.execute("SELECT id FROM blocs where uuid="+escape.cote(blocUuid));
        rs.next();
        if(rs.rs.Rows > 0) return parseNull(rs.value("id"));
        return "";
    }

    String getLangId(Contexte Etn, String langCode)
    {
        Set rs = Etn.execute("SELECT langue_id from "+GlobalParm.getParm("CATALOG_DB")+".language where langue_code="+escape.cote(langCode));
        rs.next();
        if(rs.rs.Rows > 0) return parseNull(rs.value("langue_id"));
        return "";
    }
%>

<%
    int status = 0;
    String message = "";
    String err_code = "";

    JSONObject json = new JSONObject();
    JSONObject data = new JSONObject();

    final String blocUuid = parseNull(request.getParameter("bloc_uuid"));
    final String langCode = parseNull(request.getParameter("lang_code"));
    final String method = parseNull(request.getMethod());
    
	String strIsGenerateForProd = parseNull(request.getParameter("isGenerateForProd"));
	//this api is being called from external resources so we isGenerateForProd must be true by default
	if(strIsGenerateForProd.length() == 0) strIsGenerateForProd = "1";
	boolean isGenerateForProd = "1".equals(strIsGenerateForProd);
	System.out.println("api/getBlocHtml.jsp::isGenerateForProd="+isGenerateForProd);
	
    if(method.length() > 0  && method.equalsIgnoreCase("GET")){
        
        final String langId = getLangId(Etn,langCode);
        if(langCode.length()>0)
        {
            if(blocUuid.length() > 0)
            {
                final String blocId = getBlocId(Etn, blocUuid);
                if(blocId.length() > 0){
                    try{
                        data = (new PagesGenerator(Etn)).getBlocHtmlByLang(blocId,langId,isGenerateForProd);
                    } 
                    catch(Exception ex){
                        status = 30;
                        err_code = "SOMETHING_WRONG";
                        message = "SOMETHING WENT WRONG";
                    }
                }
                else{
                    status = 10;
                    err_code = "INVALID_CREDENTIALS";
                    message = "BLOC UUID IS NOT VALID";
                }
            }else{
                status = 20;
                err_code = "REQUIRED_FIELD_MISSING";
                message = "BLOC UUID IS REQUIRED";
            }
        }else{
            status = 20;
            err_code = "REQUIRED_FIELD_MISSING";
            message = "LANG CODE IS REQUIRED";
        }   
    }
    else{
        status = 100;
        err_code = "NOT_FOUND";
        message = "getblocHtml.jsp doesnot supports "+method+" method";
    }
    
    
    if(err_code.length() > 0 && status > 0)
    {
        json.put("err_code",err_code);
        json.put("err_msg",message);
    }else{
        json.put("data",data);
    }
    json.put("status",status);

    out.write(json.toString());

%>