<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map,java.util.List, com.etn.beans.app.GlobalParm"%>
<%@ include file="../../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../common.jsp"%>
<%!
	// public static String escapeDblCote(String str){
 //        return "\"" + str.replace("\"","\\\"") +"\"";
 //    }
%>
<%
	String STATUS_SUCCESS = "SUCCESS", STATUS_ERROR = "ERROR";
	String message = "";
    String status = STATUS_ERROR;
    String requestType = request.getParameter("requestType");
    StringBuffer data = new StringBuffer();

    if("getDataForLinkedProducts".equalsIgnoreCase(requestType)){
    	String prodType = parseNull(request.getParameter("prodType"));

		data.append("{ \"catalogs\" : [ ");

		String q = " SELECT DISTINCT c.id , c.name FROM catalogs c"
					+ " JOIN products p ON p.catalog_id = c.id "
					+ " AND p.product_type = " + escape.cote(prodType);
					//+ " AND p.product_type IN ('service','service_day','service_night') ";
		Set rs = Etn.execute(q);
		String comma = "";
		while(rs.next()){
			data.append(comma);

			data.append("{ \"id\" : " + escapeDblCote(rs.value("id")) + ", \"name\" : " + escapeDblCote(rs.value("name")) + "}");

			comma = ",";
		}

		data.append("] , \"products\" : [");

		q = "SELECT p.id, p.catalog_id, p.lang_1_name AS name , c.name AS catalog_name, IFNULL(pl.id,'') AS link_id FROM products p "
			+ " JOIN catalogs c ON c.id = p.catalog_id "
			+ " LEFT JOIN product_link pl ON pl.id = p.link_id  "
			+ " WHERE p.product_type = " + escape.cote(prodType);
			//+ " WHERE p.product_type IN ('service','service_day','service_night') ";
		rs = Etn.execute(q);
		comma = "";
		while(rs.next()){
			data.append(comma);

			data.append("{ \"id\" : " + escapeDblCote(rs.value("id"))
							+ ", \"name\" : " + escapeDblCote(rs.value("name"))
							+ ", \"catalog_id\" : " + escapeDblCote(rs.value("catalog_id"))
							+ ", \"catalog_name\" : " + escapeDblCote(rs.value("catalog_name"))
							+ ", \"link_id\" : " + escapeDblCote(rs.value("link_id"))
							+ "}");

			comma = ",";
		}

		data.append("] }");

		status = STATUS_SUCCESS;

	}
	else if("getProductRelationships".equalsIgnoreCase(requestType)){

		String prodId = "" +parseInt(request.getParameter("prodId"));
		String mandatory = "";
		String suggested = "";

		String q = " SELECT pr.related_product_id AS related_id, "
		+ " pr.relationship_type , p.lang_1_name AS name "
		+ " FROM product_relationship pr "
		+ " JOIN products p on pr.related_product_id = p.id  "
		+ " WHERE pr.product_id = " + escape.cote(prodId);

		Set rs = Etn.execute(q);
		String obj = "";
		while(rs.next()){
			obj = "{ \"id\" : " + rs.value("related_id")
					+ ", \"name\" : \"" + rs.value("name").replace("\"","\\\"") + "\" "
					+ " }";
			if("mandatory".equals(rs.value("relationship_type")) ){
				if(mandatory.length() > 0){
					mandatory += ",";
				}

				mandatory += obj;

			}
			else{
				if(suggested.length() > 0){
					suggested += ",";
				}

				suggested += obj;
			}

		}

		mandatory = "[" + mandatory + "]";
		suggested = "[" + suggested + "]";
		data.append("{ \"mandatory\" : ").append(mandatory)
			.append("  , \"suggested\" : ").append(suggested)
			.append(" }");

		status = STATUS_SUCCESS;
		message = "";
	}
	else if("dProducts".equalsIgnoreCase(requestType)){
		String productIds[] = request.getParameterValues("productId[]");
		data.append(productIds.length);
		for(String delete_id : productIds){
			Etn.executeCmd("UPDATE products_tbl SET is_deleted='1',updated_on=now(),updated_by= "+escape.cote(""+Etn.getId())+" WHERE id = "+ escape.cote(delete_id));
		}
	}
	else if("orderCatProducts".equalsIgnoreCase(requestType)){
		try{
			String catId = parseNull(request.getParameter("catId"));
			String prodIds = parseNull(request.getParameter("prodIds"));

			String prodIdList[] = prodIds.split(",");
			//String prodIdList[] = request.getParameterValues("prodIds");

			if( parseInt(catId) <= 0 || prodIdList.length == 0 ){
				throw new Exception("");
			}

			String q = "";
			for(int i=0; i<prodIdList.length; i++){
				q = "UPDATE products SET order_seq = " + (i+1)
					+ " WHERE catalog_id = " + escape.cote(catId)
					+ " AND id = " + escape.cote(prodIdList[i]);

				Etn.executeCmd(q);
			}

			status = STATUS_SUCCESS;
			message = "";
		}
		catch(Exception ex){
			status = STATUS_ERROR;
		}

	}
	else if("orderFamilies".equalsIgnoreCase(requestType)){
		try{

			String catIds = request.getParameter("catIds");

			String catIdList[] = catIds.split(",");

			if( catIdList.length == 0 ){
				throw new Exception("");
			}

			for(String catId : catIdList){

				String famIdList[] =  request.getParameter("cat_"+catId).split(",");

				if(famIdList.length == 0) continue;

				String q = "";
				for(int i=0; i<famIdList.length; i++){

					q = "UPDATE familie SET order_seq = " + (i+1)
						+ " WHERE id = " + escape.cote(famIdList[i]);

					Etn.executeCmd(q);
				}

			}

			status = STATUS_SUCCESS;
			message = "";
		}
		catch(Exception ex){
			status = STATUS_ERROR;
		}

	}

	// else if("test".equalsIgnoreCase(requestType)){
	// 	String productId = parseNull(request.getParameter("productId"));
	// 	data.append("{ \"newId\" : \""+productId+"0\" }");
	// 	if(!"27".equals(productId))
	// 		status = STATUS_SUCCESS;
	// }

    if(data.length() == 0){
		data.append("\"\"");
	}

	response.setContentType("application/json");
  	out.write("{\"status\":\""+status+"\",\"message\":\""+message+"\",\"data\":"+data+"}");

%>
