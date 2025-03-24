<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm, java.util.*"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%
    int num = 0;
    String variantId = parseNull(request.getParameter("variant_id"));
    String sku = parseNull(request.getParameter("sku"));
    String siteId = getSelectedSiteId(session);
    String[] skuList  =  sku.split(",");
    String inClause = "(";
    for (String s : skuList){
        inClause += escape.cote(s)+",";
    }
    inClause =  inClause.substring(0, inClause.length() - 1);
    inClause += ")";
    String q = "SELECT count(pv.id) num_of_records  "
                + " FROM product_variants pv "
                + " JOIN products p ON p.id = pv.product_id "
                + " JOIN catalogs c ON c.id = p.catalog_id  "
                + " WHERE c.site_id = " + escape.cote(siteId)
                + " AND pv.sku in " + inClause
                + " AND pv.id != " + escape.cote(variantId);
    // Logger.debug(q);
    Set rs = Etn.execute(q);
    if(rs != null && rs.next()){
        num = Integer.parseInt(rs.value("num_of_records"));
    }
    out.write("{\"numberOfRecords\":" + num + "}");
%>