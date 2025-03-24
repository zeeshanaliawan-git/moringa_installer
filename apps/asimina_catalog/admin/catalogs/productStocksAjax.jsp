<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, com.etn.util.Logger, org.json.JSONObject, com.etn.asimina.util.ActivityLog ,org.json.JSONArray, java.util.LinkedHashMap, org.json.JSONException, java.net.URLEncoder"%>
<%@ page import="org.apache.commons.io.FileUtils, java.io.File, org.json.CDL,java.io.IOException,java.text.SimpleDateFormat" %>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>

<%!
    int json2Csv(JSONArray jArray, String filename) {
    try {
        File file = new File(GlobalParm.getParm("PRODUCTS_UPLOAD_DIRECTORY")  + filename);
        String csv = CDL.toString(jArray);
        csv = csv.replaceAll(",","\",\"");
        csv = "\""+csv.replaceAll("\n","\"\n\"");
        csv = csv.substring(0, csv.length() - 1);
        FileUtils.writeStringToFile(file,csv);
        return 0;
    } catch (Exception e) {
        return 1;
    } 
}
%>

<%
    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    String SHOP_DB = GlobalParm.getParm("SHOP_DB") + ".";

    int status = STATUS_ERROR;
    String message = "";
    JSONObject data = new JSONObject();

    String q = "";
    Set rs = null;

    String requestType = parseNull(request.getParameter("requestType"));

    String siteId = getSelectedSiteId(session);

    boolean isProd = "1".equals(request.getParameter("isProd"));

    String dbName = "";

    if(isProd){
        dbName = com.etn.beans.app.GlobalParm.getParm("PROD_DB") + ".";
        SHOP_DB = GlobalParm.getParm("SHOP_PROD_DB") + ".";
    }

	String thumbnailUrlPrefix = GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL") + siteId + "/img/thumb/";
	String imageUrlPrefix = GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL") + siteId + "/img/4x3/";

    try{
        if("getStockList".equalsIgnoreCase(requestType)){
						
            try{
                String catalogId = parseNull(request.getParameter("catalogId"));

                JSONArray stockList = new JSONArray();

                q = " SELECT p.id, p.lang_1_name as name, p.order_seq AS sort_order, v.sku as sku "
                    + " , v.id AS variant_id, vd.name AS variant_name, v.stock AS variant_stock, v.stock_thresh as minimum_threshold "
                    + " , vr.path AS image_path "
                    + " , v.updated_on , lg.name as updated_by "
                    + " FROM "+dbName+"products p "
                    + "	JOIN "+dbName+"catalogs c ON c.id = p.catalog_id "
                    + " JOIN "+dbName+"product_variants v ON v.product_id = p.id "
                    + " LEFT JOIN "+dbName+"product_variant_details vd ON v.id = vd.product_variant_id AND langue_id = '1' "
                    + " LEFT JOIN "+dbName+"product_variant_resources vr ON v.id = vr.product_variant_id AND sort_order = '0' "
                    + " LEFT JOIN login lg ON lg.pid = v.updated_by "
                    + " WHERE p.catalog_id = " + escape.cote(catalogId)
                    + " AND c.site_id = " + escape.cote(siteId)
                    + " AND p.show_basket = 1 "
					+ " AND p.product_type not in ('simple_virtual_product','configurable_virtual_product') "
                    + " GROUP BY p.id,v.id "
                    + " ORDER BY p.id,v.id ASC";

                rs = Etn.execute(q);
                JSONObject curObj = null;
                String prevProductId = "";
                while(rs.next()){

                    if( ! prevProductId.equals(rs.value("id"))){
                        prevProductId = rs.value("id");

                        curObj =  new JSONObject();
                        curObj.put("id",rs.value("id"));
                        curObj.put("name",rs.value("name"));
                        curObj.put("sort_order",rs.value("sort_order"));
                        curObj.put("image_path",rs.value("image_path"));
                        curObj.put("updated_on",rs.value("updated_on"));
                        curObj.put("updated_by",rs.value("updated_by"));
                        curObj.put("variants", new JSONArray());
                        

                        stockList.put(curObj);
                    }

                    JSONObject variantObj = new JSONObject();
                    variantObj.put("id",rs.value("variant_id"));
                    variantObj.put("name",rs.value("variant_name"));
                    variantObj.put("stock",rs.value("variant_stock"));
					variantObj.put("sku",rs.value("sku"));
                    variantObj.put("minimum_threshold",rs.value("minimum_threshold"));
					
					if(parseNull(rs.value("image_path")).length() > 0)
					{
						variantObj.put("thumbnail", thumbnailUrlPrefix + rs.value("image_path"));	
						variantObj.put("image_path", imageUrlPrefix + rs.value("image_path"));	
					}
					else 
					{
						variantObj.put("thumbnail","");
						variantObj.put("image_path","");
					}

                    curObj.getJSONArray("variants").put(variantObj);
                }
                status = STATUS_SUCCESS;
                data.put("stocks",stockList);
            }//try
            catch(Exception ex){
                message = "Error in getting stock list. Please try again.";
                throw new SimpleException(message, ex);
            }


        }
        else if("getProductStock".equalsIgnoreCase(requestType)){
            try{

                String productId = parseNull(request.getParameter("productId"));

                JSONArray variantsList = new JSONArray();

                q = " SELECT v.id, vd.name AS name, v.stock, v.sku, vr.path as image_path, v.stock_thresh as minimum_threshold "
                    + " FROM "+dbName+"product_variants v "
                    + " LEFT JOIN "+dbName+"product_variant_details vd ON v.id = vd.product_variant_id AND langue_id = '1' "
					+ " LEFT JOIN "+dbName+"product_variant_resources vr ON v.id = vr.product_variant_id AND sort_order = '0' "
                    + " WHERE v.product_id = " + escape.cote(productId)
                    + " GROUP BY v.id "
                    + " ORDER BY v.id ";

                // Logger.info(q);
                rs = Etn.execute(q);
                JSONObject curObj = null;
                while(rs.next()){

                    curObj = new JSONObject();
					for(String colName : rs.ColName){
						
						if(colName.equalsIgnoreCase("image_path"))
						{
							if(parseNull(rs.value(colName)).length() > 0)
							{
								curObj.put("thumbnail", thumbnailUrlPrefix + rs.value(colName));	
								curObj.put("image_path", imageUrlPrefix + rs.value(colName));	
							}
							else 
							{
								curObj.put("thumbnail","");
								curObj.put("image_path","");
							}							
						}
						else
						{
							curObj.put(colName.toLowerCase(), rs.value(colName));
						}
					}

                    variantsList.put(curObj);
                }

                status = STATUS_SUCCESS;
                data.put("variants",variantsList);

            }//try
            catch(Exception ex){
                message = "Error in getting product variants stock. Please try again.";
                throw new SimpleException(message, ex);
            }

        }
        else if("saveProductStock".equalsIgnoreCase(requestType)){
            try{

                String productId = parseNull(request.getParameter("productId"));
                String variantIds[] = request.getParameterValues("variant_id");
                String stockValues[] = request.getParameterValues("stock_value");
                String stockThresh[] = request.getParameterValues("minimum_stock_thresh");


                if(variantIds.length > 0 && variantIds.length == stockValues.length){

                	for (int i=0; i<variantIds.length ; i++ ) {

                		String curVariantId = variantIds[i];

                        int newStock = parseInt(stockValues[i]);
                        int newStockThresh = parseInt(stockThresh[i]);
                        int oldStock = 0;
                        int oldStockThresh = 0;

                        String curStockValue = ""+ newStock;
                        String curStockThreshValue = ""+ newStockThresh;
                        //get oldStock
                        q = "SELECT v.stock,v.stock_thresh "
                            + " FROM "+dbName+"product_variants v "
                            + " JOIN "+dbName+"products p ON p.id = v.product_id "
                            + " JOIN "+dbName+"catalogs c ON c.id = p.catalog_id "
                            + " WHERE v.id = " + escape.cote(curVariantId)
                            + " AND v.product_id = " + escape.cote(productId)
                            + " AND c.site_id = " + escape.cote(siteId);
                        rs = Etn.execute(q);
                        if(rs.next()){
                            oldStock = parseInt(rs.value("stock"));
                            oldStockThresh = parseInt(rs.value("stock_thresh"));
                        }

                		q = "UPDATE "+dbName+"product_variants v "
                			+ " JOIN "+dbName+"products p ON p.id = v.product_id "
                			+ " JOIN "+dbName+"catalogs c ON c.id = p.catalog_id "
                			+ " SET v.stock = " + escape.cote(curStockValue)
                            + " , v.stock_thresh = " + escape.cote(curStockThreshValue)
                			+ " WHERE v.id = " + escape.cote(curVariantId)
                			+ " AND v.product_id = " + escape.cote(productId)
                			+ " AND c.site_id = " + escape.cote(siteId);
                		Etn.executeCmd(q);

                        String isStockAlert = null;
                        String MiStockAlert = null;
                        if(newStock > 0 && oldStock == 0){
                            isStockAlert = "1";
                        }
                        else if(newStock == 0 && oldStock > 0){
                            isStockAlert = "0";
                        }
                        if(isStockAlert != null){
                            q = "UPDATE "+SHOP_DB+"stock_mail SET is_stock_alert = " + escape.cote(isStockAlert)
                                + " WHERE product_id = "+ escape.cote(productId)
                                + " AND variant_id = " + escape.cote(curVariantId);
                            Etn.executeCmd(q);
                        }
                	}

                }
                status = STATUS_SUCCESS;
                rs = Etn.execute("select lang_1_name from "+dbName+"products where id = "+escape.cote(productId));
                rs.next();
                ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),productId,"UPDATED","Product Stock",rs.value(0),siteId);

            }//try
            catch(Exception ex){
                message = "Error in saving product variants stock. Please try again.";
                throw new SimpleException(message, ex);
            }

        }else if("exportStockList".equalsIgnoreCase(requestType))
        {
            final String catalogId = parseNull(request.getParameter("catalogId"));
            JSONArray stockList = new JSONArray();
            
            q = " SELECT p.id, p.lang_1_name as name, p.order_seq AS sort_order, v.sku as sku "
                + " , v.id AS variant_id, vd.name AS variant_name, v.stock AS variant_stock "
                + " , vr.path AS image_path "
                + " , v.updated_on , lg.name as updated_by "
                + " FROM "+dbName+"products p "
                + "	JOIN "+dbName+"catalogs c ON c.id = p.catalog_id "
                + " JOIN "+dbName+"product_variants v ON v.product_id = p.id "
                + " LEFT JOIN "+dbName+"product_variant_details vd ON v.id = vd.product_variant_id AND langue_id = '1' "
                + " LEFT JOIN "+dbName+"product_variant_resources vr ON v.id = vr.product_variant_id AND sort_order = '0' "
                + " LEFT JOIN login lg ON lg.pid = v.updated_by "
                + " WHERE p.catalog_id = " + escape.cote(catalogId)
                + " AND c.site_id = " + escape.cote(siteId)
                + " AND p.show_basket = 1 "
                + " GROUP BY p.id,v.id "
                + " ORDER BY p.id,v.id ASC";

            rs = Etn.execute(q);

            String [] cols = {"id", "name", "sku","variant_id", "variant_name","variant_stock","image_path","updated_on","updated_by"};
            final String filename = "catalog-stock"+new SimpleDateFormat("ddMMyyyy-HH-mm-ss").format(new java.util.Date())+".csv";
            while(rs.next())
            {
                JSONObject resData = new org.json.JSONObject();
                for(String colName : cols)
                    resData.put(toCamelCase(colName),rs.value(colName));
                stockList.put(resData);
            }

            int resp = json2Csv(stockList,filename);
            if(resp == 0){
                status = STATUS_SUCCESS;
                data.put("url",URLEncoder.encode(filename,"UTF-8"));
            }
            else{
                status = STATUS_ERROR;
                message = "Error Occured While Exporting File";
            }
            
        }
    }
    catch(SimpleException ex){
        message = ex.getMessage();
        ex.print();
    }

    JSONObject jsonResponse = new JSONObject();
    jsonResponse.put("status",status);
    jsonResponse.put("message",message);
    jsonResponse.put("data",data);
    out.write(jsonResponse.toString());
%>