<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm"%>
<%@ include file="../../../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../../common.jsp"%>

<%!
	String getProductName(com.etn.lang.ResultSet.Set rs)
	{
		if(rs == null) return "";
		if(parseNull(rs.value("lang_1_name")).length() > 0) return parseNull(rs.value("lang_1_name"));
		if(parseNull(rs.value("lang_2_name")).length() > 0) return parseNull(rs.value("lang_2_name"));		
		if(parseNull(rs.value("lang_3_name")).length() > 0) return parseNull(rs.value("lang_3_name"));
		if(parseNull(rs.value("lang_4_name")).length() > 0) return parseNull(rs.value("lang_4_name"));
		if(parseNull(rs.value("lang_5_name")).length() > 0) return parseNull(rs.value("lang_5_name"));
		return "";
	}

%>
<%
 
        String cid = parseNull(request.getParameter("cid"));
        Set rs = Etn.execute("select * from products where product_type IN ('product','offer_prepaid','offer_postpaid') and catalog_id="+escape.cote(cid));
        out.write("<option value=''>---- Select ----</option>");
        while(rs.next()){
            out.write("<option value='"+rs.value("id")+"'>"+getProductName(rs)+"</option>");
        }
        

%>