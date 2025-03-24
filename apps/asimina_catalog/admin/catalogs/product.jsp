<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.List, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm, com.etn.asimina.data.LanguageFactory"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%
	String isprod = parseNull(request.getParameter("isprod"));
	boolean bIsProd = "1".equals(isprod);
	String dbname = "";
	if(bIsProd){
		dbname = GlobalParm.getParm("PROD_DB") + ".";
	}

	String lang_tab = parseNull(request.getParameter("lang_tab"));
	String cid = parseNull(request.getParameter("cid"));
	
	String folderUuid = parseNull(request.getParameter("folder_id"));
	
	String selectedsiteid = getSelectedSiteId(session);
	List<Language> langsList = getLangs(Etn,selectedsiteid);

	if(cid.length() == 0)
	{
		response.sendRedirect("/catalogs.jsp?cid="+cid); // changed here
		return;
	}
	Set rscat = Etn.execute("select * from "+dbname+"catalogs where id = " + escape.cote(cid));
	if(rscat == null || rscat.rs.Rows == 0)
	{
		//response.sendRedirect("catalogs.jsp");
		response.sendRedirect("catalogs.jsp"); // changed here
		return;
	}
    if(folderUuid.length()>0 && folderUuid.equals("0")){
        Set rsFolder = Etn.execute("select id from "+dbname+"products_folders where uuid = " + escape.cote(folderUuid));
        if(rsFolder == null || rsFolder.rs.Rows == 0)
        {
            //response.sendRedirect("catalogs.jsp?cid="+cid);
			response.sendRedirect("catalogs.jsp?cid="+cid); // changed here
            return;
        }
    }

	rscat.next();

	if(!selectedsiteid.equals(parseNull(rscat.value("site_id"))))
	{
		//response.sendRedirect("catalogs.jsp");
		response.sendRedirect("catalogs.jsp"); // changed here
		return;
	}

    String catalogType = parseNull(rscat.value("catalog_type"));
	String id = parseNull(request.getParameter("id"));

	Set rs = null;
	if(id.length() > 0){
		rs = Etn.execute("SELECT product_type FROM "+dbname+"products  WHERE id =  " + escape.cote(id));
		rs.next();
	}

    String prodType = getRsValue(rs,"product_type");
    if(prodType.length()==0){
        Set rsCatalogTypes = Etn.execute("select product_type from "+dbname+"catalog_types where value="+escape.cote(catalogType));
        if(rsCatalogTypes.next()) prodType = getRsValue(rsCatalogTypes,"product_type");
    }

    String pageName = "product"; //default version

    pageName = "product_body_" + pageName + ".jsp";
System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> pageName::"+pageName);
    RequestDispatcher rd = request.getRequestDispatcher(pageName);
    rd.forward(request,response);

%>
