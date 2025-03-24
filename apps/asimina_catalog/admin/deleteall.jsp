<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm, com.etn.asimina.util.ActivityLog, java.lang.Exception, org.json.*, com.etn.asimina.util.ProductImageHelper, com.etn.asimina.util.ProductEssentialsImageHelper, com.etn.asimina.util.ProductShareBarImageHelper "%>
<%@ include file="common.jsp"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>

<%
    String processName = parseNull(request.getParameter("type"));
    String ids = parseNull(request.getParameter("id"));
    String siteId =  getSelectedSiteId(session);
    String STATUS_SUCCESS ="1", STATUS_ERROR ="0";
    String process = getProcess(processName);
    Set rs = null;
    String q = "";
    String message ="";
    String status = STATUS_ERROR;
    String action = "DELETED";

    if(process.equals("catalogs")){
        int counter = 0;
        String itemNames = "";
        try{
            for(String delete_id : ids.split(",")){
                if(parseNull(delete_id).length() == 0) continue;

                rs = Etn.execute("select id from catalogs where id = " + escape.cote(delete_id));
                if(rs.rs.Rows <  1)// not valid id
                    continue;

                rs = Etn.execute("select id from "+GlobalParm.getParm("PROD_DB")+".catalogs where id = " + escape.cote(delete_id));
                if(rs.rs.Rows > 0){
                    continue;
                }
                else
                {
                    Set rsCatalog = Etn.execute("select name, site_id from catalogs where id = " + escape.cote(delete_id));
                    if(rsCatalog.next())
                        itemNames += parseNull(rsCatalog.value("name"))+", ";
                    Etn.executeCmd("delete from catalog_descriptions where catalog_id = "+escape.cote(delete_id)+" ");
                    Etn.executeCmd("delete from product_tabs where product_id in (select id from products where catalog_id = "+escape.cote(delete_id)+") ");
                    Etn.executeCmd("delete from share_bar where ptype = "+escape.cote("product")+" and id in (select id from products where catalog_id = "+escape.cote(delete_id)+") ");
                    Etn.executeCmd("delete from products where catalog_id = "+escape.cote(delete_id)+" ");
                    Etn.executeCmd("delete from catalogs where id = "+escape.cote(delete_id)+" ");
                    counter++;

                }
            }
            if(counter>0){
                status = STATUS_SUCCESS;
                message = counter+" catalogs deleted";
                ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),ids,action,process.substring(0, 1).toUpperCase()+process.substring(1),itemNames,siteId);
            }else{
                message = "No valid ids found";
            }

        }catch(Exception ex){
                throw new SimpleException("Error in saving "+process+". Please try again.",ex);
        }
    }else if(process.equals("products")){

        int counter = 0;
        String itemNames = "";
        try{
            for(String delete_id : ids.split(",")){
				if(parseNull(delete_id).length() == 0) continue;

                Set rsProduct = Etn.execute("select id, lang_1_name as name from products where id = " + escape.cote(delete_id));
                if(rsProduct.rs.Rows <  1)// not valid id
                    continue;
                rs = Etn.execute("select id from "+GlobalParm.getParm("PROD_DB")+".products where id = " + escape.cote(delete_id));
                if(rs.rs.Rows > 0)
                   continue;
                else
                {
                    if(rsProduct.next())
                        itemNames += parseNull(rsProduct.value("name"))+", ";

                    Etn.executeCmd("DELETE FROM share_bar WHERE id = " + escape.cote(delete_id));
                    Etn.executeCmd("DELETE FROM product_attribute_values WHERE product_id = " + escape.cote(delete_id));
                    Etn.executeCmd("DELETE FROM product_descriptions WHERE product_id = " + escape.cote(delete_id));
                    Etn.executeCmd("DELETE FROM product_tabs WHERE product_id = " + escape.cote(delete_id));
                    Etn.executeCmd("DELETE FROM product_tags WHERE product_id = " + escape.cote(delete_id));
                    Etn.executeCmd("DELETE FROM product_essential_blocks WHERE product_id = " + escape.cote(delete_id));
                    Etn.executeCmd("DELETE FROM product_images WHERE product_id = " + escape.cote(delete_id));

                    //variants
                    String deleteQ = null;
                    deleteQ = " DELETE d "
                        + " FROM product_variant_details d "
                        + " JOIN product_variants v ON d.product_variant_id = v.id "
                        + " AND v.product_id = " + escape.cote(delete_id);
                    Etn.executeCmd(deleteQ);

                    deleteQ = " DELETE r "
                        + " FROM product_variant_ref r "
                        + " JOIN product_variants v ON r.product_variant_id = v.id "
                        + " AND v.product_id = " + escape.cote(delete_id);
                    Etn.executeCmd(deleteQ);

                    deleteQ = " DELETE r "
                        + " FROM product_variant_resources r "
                        + " JOIN product_variants v ON r.product_variant_id = v.id "
                        + " AND v.product_id = " + escape.cote(delete_id);
                    Etn.executeCmd(deleteQ);

                    Etn.executeCmd("DELETE FROM product_variants WHERE product_id = " + escape.cote(delete_id));

                    Etn.executeCmd("DELETE FROM products WHERE id = " + escape.cote(delete_id));

                    //now delete product image directories
                    ProductShareBarImageHelper sbImageHelper = new ProductShareBarImageHelper(delete_id);
                    deleteDirectoryWithContent(sbImageHelper.getImageDirectory());

                    ProductEssentialsImageHelper essImageHelper = new ProductEssentialsImageHelper(delete_id);
                    deleteDirectoryWithContent(essImageHelper.getImageDirectory());

                    ProductImageHelper prodImageHelper = new ProductImageHelper(delete_id);
                    deleteDirectoryWithContent(prodImageHelper.getImageDirectory());

                    //old legacy code
                    Etn.executeCmd("DELETE FROM tarif_category_items WHERE tarif_category_id in (select id from tarif_categories WHERE product_id = " + escape.cote(delete_id) + " ) ");
                    Etn.executeCmd("DELETE FROM tarif_categories WHERE product_id = " + escape.cote(delete_id));
                    Etn.executeCmd("DELETE FROM product_stocks WHERE product_id = " + escape.cote(delete_id));
                    Etn.executeCmd("DELETE FROM product_relationship WHERE product_id = " + escape.cote(delete_id) + " or related_product_id = " + escape.cote(delete_id));
                    counter++;
                }
            }
            if(counter>0)
            {
               status = STATUS_SUCCESS;
                message = counter+" products deleted";
                ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),ids,action,process.substring(0, 1).toUpperCase()+process.substring(1),itemNames,siteId);


            }else
            {
                message = "No valid ids found";
            }
        }catch(Exception ex){
                throw new SimpleException("Error in saving "+process+". Please try again.",ex);
        }
    }else if(process.equals("comewiths") || process.equals("quantitylimits") || process.equals("subsidies") || process.equals("promotions")|| process.equals("cartrules") || process.equals("deliveryfees") || process.equals("deliverymins") || process.equals("additionalfees")   )
    {
        int counter = 0;
        String itemNames = "";
        String colName  = "name";
        String tableName  = process;
        if(process.equals("cartrules")) tableName = "cart_promotion";
        if(process.equals("additionalfees")) colName = "additional_fee";

        try{
            for(String delete_id : ids.split(",")){
				if(parseNull(delete_id).length() == 0) continue;

                Set rsRule = Etn.execute("select id,"+colName+" as _name from "+tableName+" where id = " + escape.cote(delete_id));
                if(rsRule.rs.Rows <  1)// not valid id
                    continue;

                rs = Etn.execute("select id from "+GlobalParm.getParm("PROD_DB")+"."+tableName+" where id = " + escape.cote(delete_id));
                if(rs.rs.Rows > 0)
                   continue;
                else
                {
                    if(rsRule.next())
                        itemNames += parseNull(rsRule.value("_name"))+", ";
                    Etn.executeCmd("DELETE FROM "+tableName+"_rules WHERE "+tableName+"_id = " + escape.cote(delete_id));
                    Etn.executeCmd("DELETE FROM "+tableName+" WHERE id = " + escape.cote(delete_id));
                    counter++;
                }
            }
            if(counter>0){
                status = STATUS_SUCCESS;
                message = counter+" "+process+" deleted";
                ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),ids,action,process.substring(0, 1).toUpperCase()+process.substring(1),itemNames,siteId);

            }else{
                message = "No valid ids found";
            }
        }catch(Exception ex){
                throw new SimpleException("Error in saving "+process+". Please try again.",ex);
        }
    }

    JSONObject jsonResponse = new JSONObject();
    jsonResponse.put("response",status);
    jsonResponse.put("msg",message);
    out.write(jsonResponse.toString());
%>