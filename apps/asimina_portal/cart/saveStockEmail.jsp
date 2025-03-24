<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, com.etn.beans.app.GlobalParm, java.util.*"%>
<%!
    String parseNull(Object o){
        if( o == null ) return("");
        String s = o.toString();
        if("null".equals(s.trim().toLowerCase())) return("");
        else return(s.trim());
    }
%>
<%
    String email = parseNull(request.getParameter("email"));
    String product_id = parseNull(request.getParameter("product_id")); // uuid
    String muid = parseNull(request.getParameter("muid"));
    String variant_id = parseNull(request.getParameter("variant_id"));
    //Set rsProduct = Etn.execute("select id from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".products where product_uuid="+escape.cote(product_id));
    /*if(rsProduct.next()) */Etn.executeCmd("insert into "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".stock_mail set email="+escape.cote(email)+", variant_id="+escape.cote(variant_id)+", menu_uuid="+escape.cote(muid)+", product_id=(select id from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".products where product_uuid="+escape.cote(product_id)+")");
    
%>