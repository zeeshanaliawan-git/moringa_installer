<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" /><%@page import="com.etn.lang.ResultSet.Set"%><%@page import="java.io.*"%>
<%@ page import="com.etn.asimina.util.*, com.etn.asimina.cart.*,com.etn.sql.escape, com.etn.beans.app.GlobalParm,javax.servlet.http.HttpServletResponse" %>

<%!
String parseNull(Object o) {
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
  String _jsp = "/cart/default_kyc_error.jsp";
  boolean isKycJsp=parseNull(com.etn.beans.app.GlobalParm.getParm("KYC_SERVER_ERROR_JSP")).length() > 0;
  if(isKycJsp) _jsp = parseNull(com.etn.beans.app.GlobalParm.getParm("KYC_SERVER_ERROR_JSP"));

  String ___muuid = CartHelper.getCartMenuUuid(request);
  
  // add column for error page into the configuration 

  /*if(parseNull(___muuid).length()>0){
    Set rs=Etn.execute("SELECT sd.error_page_url,m.id FROM site_menus m "+
      "LEFT JOIN language l ON l.langue_code=m.lang "+
      "LEFT JOIN sites_details sd ON sd.site_id = m.site_id AND sd.langue_id=l.langue_id "+
      "where m.menu_uuid="+escape.cote(___muuid));
      
    if(rs!=null && rs.next()){
      if(parseNull(rs.value("error_page_url")).length()>0){
        response.sendRedirect(com.etn.asimina.util.PortalHelper.getMenuPath(Etn, parseNull(rs.value("id")))+parseNull(rs.value("error_page_url"))); 
        return; 
      }
    }
  }*/
  
	request.getRequestDispatcher(_jsp).forward(request,response);
%>