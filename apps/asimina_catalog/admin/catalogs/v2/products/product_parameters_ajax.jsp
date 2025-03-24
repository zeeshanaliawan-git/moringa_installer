<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.lang.ResultSet.Set,com.etn.sql.escape,org.json.*, com.etn.util.Base64, com.etn.asimina.util.ActivityLog, com.etn.asimina.beans.Language,com.etn.asimina.util.SiteHelper"%>
<%@ include file="../../../common.jsp"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>

<%!
    public static String encodeJSONStringDB(String str){
        return str.replaceAll("\\\\", "#slash#");
    }

    public static String decodeJSONStringDB(String str){
        return str.replaceAll("#slash#","\\\\");
    }

    public static String escapeCote2(String str){
        if(str == null || str.trim().length() == 0){
            return escape.cote(str);
        }

        String retStr = escape.cote(encodeJSONStringDB(str));
        retStr = retStr.replaceAll("#slash#","#slash##slash#");
        retStr = decodeJSONStringDB(retStr);

        return retStr;
    }

    void inesrtProductTypeRelatedData(Contexte Etn,JSONArray categories,JSONArray attributes,JSONObject specifications,String productTypeUuid){
        for(int i=0;i<categories.length();i++){
            Etn.executeCmd("insert into product_v2_categories_and_attributes (reference_uuid,product_type_uuid,reference_type) values ("+
            escape.cote(categories.getString(i))+","+escape.cote(productTypeUuid)+",'category')");
        }

        for(int i=0;i<attributes.length();i++){
            Etn.executeCmd("insert into product_v2_categories_and_attributes (reference_uuid,product_type_uuid,reference_type) values ("+
            escape.cote(attributes.getString(i))+","+escape.cote(productTypeUuid)+",'attribute')");
        }

        String specificationVal = "";

        if(specifications.get("specifications") instanceof JSONArray){
            specificationVal = escapeCote2(specifications.getJSONArray("specifications").toString());
        }else{
            specificationVal = escape.cote(specifications.getString("specifications"));
        }
        String query = "insert into product_v2_specifications (product_type_uuid,data_entry_type,data_type,specification) values ("+escape.cote(productTypeUuid)
            +","+escape.cote(specifications.getString("data_entry_type"))+","+escape.cote(specifications.getString("data_type"))+","
            +specificationVal+")";

        Etn.executeCmd(query);
    }

    void addAttributeValues(Contexte Etn, int atrId, JSONObject atrJson){
        JSONArray values = atrJson.getJSONArray("values");
        for(Object o : values){
            JSONObject obj = (JSONObject)o;
            Etn.executeCmd("insert into attributes_values_v2 (label,value,attr_id) values ("+escape.cote(obj.getString("atrValLabel"))+","+
            escape.cote(obj.getString("atrValue"))+","+escape.cote(""+atrId)+")");
        }
    }
    
    JSONObject getProductTypes(Contexte Etn, String siteId,String pagesDb){

        JSONObject rspObj = new JSONObject();
        JSONArray productTypeAry = new JSONArray();
        Set rs = Etn.execute("select pv.*,bt.name as 'template' from product_types_v2 pv join "+pagesDb+"bloc_templates bt on bt.id=pv.template_id where pv.site_id="+escape.cote(siteId)+" order by id"); 
        while(rs.next()){
            JSONObject pvObj = new JSONObject();

            for(String colName : rs.ColName){
                pvObj.put(colName.toLowerCase(),rs.value(colName));

                if(colName.equalsIgnoreCase("created_by") || colName.equalsIgnoreCase("updated_by")){
                    Set rsUser  = Etn.execute("select first_name from person where person_id="+escape.cote(rs.value(colName)));
                    if(rsUser.next()){
                        pvObj.put(colName.toLowerCase()+"_user",rsUser.value("first_name"));
                    }
                }else if(colName.equalsIgnoreCase("uuid")){
                    JSONArray tempArray = new JSONArray();
                    
                    Set rsItems = Etn.execute("select cv.* from product_v2_categories_and_attributes pv left join categories_v2 cv on pv.reference_uuid=cv.uuid where pv.reference_type='category' and pv.product_type_uuid="+escape.cote(rs.value(colName))+" order by id"); 
                    while(rsItems.next()){
                        tempArray.put(new JSONObject().put("uuid",rsItems.value("uuid")).put("name",rsItems.value("name")));
                    }
                    pvObj.put("categories",tempArray);
                    
                    rsItems = Etn.execute("select cv.* from product_v2_categories_and_attributes pv left join attributes_v2 cv on pv.reference_uuid=cv.uuid where pv.reference_type='attribute' and pv.product_type_uuid="+escape.cote(rs.value(colName))+" order by id"); 
                    tempArray = new JSONArray();
                    while(rsItems.next()){
                        tempArray.put(new JSONObject().put("uuid",rsItems.value("uuid")).put("name",rsItems.value("name")));
                    }
                    pvObj.put("attributes",tempArray);
                    
                    rsItems = Etn.execute("select * from product_v2_specifications where product_type_uuid="+escape.cote(rs.value(colName))+" order by id"); 
                    while(rsItems.next()){
                        pvObj.put("specifications",new JSONObject().put("uuid",parseNull(rsItems.value("uuid"))).put("data_entry_type",parseNull(rsItems.value("data_entry_type"))).
                            put("data_type",parseNull(rsItems.value("data_type"))).put("specification",parseNull(rsItems.value("specification"))));
                    }
                }else if(colName.equalsIgnoreCase("id")){
                    Set rsCount = Etn.execute("select * from products_definition where product_type="+escape.cote(rs.value("id")));
                    pvObj.put("nb_uses",rsCount.rs.Rows);
                }
            }
            productTypeAry.put(pvObj);
        }
        rspObj.put("product_types",productTypeAry);

        return rspObj;
    }

    JSONObject getAttributes(Contexte Etn, String siteId){

        JSONObject rspObj = new JSONObject();
        JSONArray atrArray = new JSONArray();

        Set rs = Etn.execute("select * from attributes_v2 where site_id="+escape.cote(siteId)+" order by id");
        while(rs.next()){
            JSONObject atrObj = new JSONObject();
            atrObj.put("atrId",rs.value("id"));
            atrObj.put("atrName",rs.value("name"));
            atrObj.put("atrType",rs.value("type"));
            atrObj.put("atrUnit",rs.value("unit"));
            atrObj.put("atrIcon",rs.value("icon"));
            atrObj.put("uuid",rs.value("uuid"));

            JSONArray atrVal = new JSONArray();
            Set rsValues = Etn.execute("select * from attributes_values_v2 where attr_id="+escape.cote(rs.value("id"))+" order by id");
            while(rsValues.next()){
                JSONObject atrValObj = new JSONObject();
                atrValObj.put("atrValLabel",rsValues.value("label"));
                atrValObj.put("atrValue",rsValues.value("value"));

                atrVal.put(atrValObj);
            }

            atrObj.put("values",atrVal);
            atrArray.put(atrObj);
        }
        rspObj.put("attributes",atrArray);

        return rspObj;
    }

    JSONObject getCategories(Contexte Etn, String siteId, String parentId){

        JSONObject rspObj = new JSONObject();
        JSONArray categoryAray = new JSONArray();
        
        Set rs = Etn.execute("select * from categories_v2 where parent_id="+escape.cote(parentId)+" and site_id="+escape.cote(siteId)+" order by name"); 
        while(rs.next()){
            JSONObject obj = new JSONObject();

            for(String colName : rs.ColName){
                obj.put(colName.toLowerCase(),rs.value(colName));

                if(colName.equalsIgnoreCase("id")){
                    Set rsSubCategories = Etn.execute("select * from categories_v2 where parent_id="+escape.cote(rs.value(colName))+" and site_id="+escape.cote(siteId)+
                    " order by name"); 
                    if(rsSubCategories.rs.Rows>0){
                        obj.put("sub_categories",getCategories(Etn,siteId,rs.value(colName)).getJSONArray("categories"));
                    }
                }
            }
            categoryAray.put(obj);
        }
        rspObj.put("categories",categoryAray);

        return rspObj;
    }

    int deleteCategories(Contexte Etn,String siteId, String id){
        Set rs = Etn.execute("select * from categories_v2 where parent_id="+escape.cote(id)+" and site_id="+escape.cote(siteId));
        if(rs.rs.Rows>0){
            while(rs.next()) {
                deleteCategories(Etn,siteId,rs.value("id"));
            }
        }
        return Etn.executeCmd("delete from categories_v2 where id="+escape.cote(id)+" and site_id="+escape.cote(siteId));
    }

    void onUpdateAttribute(Contexte Etn,String atrId,String updatedBy,String pagesDb){
        Set rs = Etn.execute("select id from product_types_v2 where uuid in (select product_type_uuid from product_v2_categories_and_attributes where reference_uuid=(select uuid from attributes_v2 where id="+escape.cote(atrId)+") and reference_type='attribute')");
        while(rs.next()){
            onUpdateProductTypePages(Etn,rs.value("id"),updatedBy,pagesDb);
        }
    }

    void onUpdateProductTypePages(Contexte Etn,String productTypeId,String updatedBy, String pagesDb){
        Set rs = Etn.execute("select id from products_definition where product_type="+escape.cote(productTypeId));
        while(rs.next()){
            Etn.executeCmd("update products_definition set updated_by="+escape.cote(updatedBy)+" where id="+escape.cote(rs.value("id")));
            Etn.executeCmd("update products set version=version+1,updated_by="+escape.cote(updatedBy)+",updated_on=now() where product_definition_id="+escape.cote(rs.value("id")));
            
            Etn.executeCmd("update "+pagesDb+"structured_contents set updated_by="+escape.cote(updatedBy)+
            ",updated_ts=now() where id=(select page_id from "+pagesDb+"products_map_pages where product_id=(select id from products where product_definition_id="+escape.cote(rs.value("id"))+"))");
        }
    }
%>
<%
    String siteId = parseNull(getSiteId(request.getSession()));
    String requestType = parseNull(request.getParameter("requestType"));
    String COMMONS_DB = GlobalParm.getParm("COMMONS_DB") + ".";
    String PAGES_DB = GlobalParm.getParm("PAGES_DB") + ".";

    JSONObject respnoseObj = new JSONObject();

    int userId = Etn.getId();

    String msg = "";
    int status=1;

    try{
        if(requestType.equals("getAttributes")) respnoseObj.put("data",getAttributes(Etn,siteId));
        else if(requestType.equals("saveAttribute")){
            JSONObject atrJson = new JSONObject(parseNull(request.getParameter("atrJson")));
            int atrId = 0;
            if(atrJson.has("atrId")){
                atrId = Integer.parseInt(atrJson.getString("atrId"));
                
                Set rsVerifyAtr = Etn.execute("select * from attributes_v2 where name="+escape.cote(atrJson.getString("atrName"))+" and site_id="+escape.cote(siteId)+
                " and id !="+escape.cote(""+atrId));
                if(rsVerifyAtr.rs.Rows==0){
                    
                    int updatedId = Etn.executeCmd("update attributes_v2 set name="+escape.cote(atrJson.getString("atrName"))+",type="+escape.cote(atrJson.getString("atrType"))+
                    ",unit="+escape.cote(parseNull(atrJson.getString("atrUnit")))+",icon="+escape.cote(parseNull(atrJson.getString("atrIcon")))+
                    " ,updated_by="+escape.cote(""+userId)+" where id="+escape.cote(""+atrId));

                    if(updatedId>0) Etn.executeCmd("delete from attributes_values_v2 where attr_id="+escape.cote(""+atrId));

                    addAttributeValues(Etn,atrId,atrJson);
                    onUpdateAttribute(Etn,atrId+"",userId+"",PAGES_DB);
                }else{
                    status = 0;
                    msg="Duplicate attribute name "+atrJson.getString("atrName")+".";
                }
            }else{
                Set rsVerifyAtr = Etn.execute("select * from attributes_v2 where name="+escape.cote(atrJson.getString("atrName"))+" and site_id="+escape.cote(siteId));
                if(rsVerifyAtr.rs.Rows==0){
                    atrId = Etn.executeCmd("insert into attributes_v2 (name,type,unit,icon,site_id,created_by,updated_by) values ("+escape.cote(atrJson.getString("atrName"))+","+
                        escape.cote(atrJson.getString("atrType"))+","+escape.cote(parseNull(atrJson.getString("atrUnit")))+","+escape.cote(parseNull(atrJson.getString("atrIcon")))+
                        ","+escape.cote(siteId)+","+escape.cote(""+userId)+","+escape.cote(""+userId)+")");
                        
                    addAttributeValues(Etn,atrId,atrJson);
                }else{
                    status = 0;
                    msg="Duplicate attribute name "+atrJson.getString("atrName")+".";
                }
            }
        }else if(requestType.equals("deleteAttribute")){
            String id = parseNull(request.getParameter("id"));
            Set rs = Etn.execute("select id,uuid from attributes_v2 where id="+escape.cote(id)+" and site_id="+escape.cote(siteId));
            if(rs.next()){
                Set rsCount = Etn.execute("select * from product_v2_categories_and_attributes where reference_uuid="+escape.cote(rs.value("uuid"))+" and reference_type='attribute'");
                if(rsCount.rs.Rows==0){
                    Etn.executeCmd("delete from attributes_values_v2 where attr_id="+escape.cote(id));
                    Etn.executeCmd("delete from attributes_v2 where id="+escape.cote(id)+" and site_id="+escape.cote(siteId));
                }else{
                    status=0;
                    msg = "Cannot delete this attribute it is being used in product type.";
                }
            }else{
                status=0;
                msg = "Invalid attribute id.";
            }
        }else if(requestType.equals("getCategories")) respnoseObj.put("data",getCategories(Etn,siteId,"0"));
        else if(requestType.equals("deleteCategories")) deleteCategories(Etn, siteId, parseNull(request.getParameter("categoryId")));
        else if(requestType.equals("saveCategory")){
            JSONObject category = new JSONObject(parseNull(request.getParameter("category")));
            
            String saveType = parseNull(category.getString("saveType"));

            String parentCategoryId = parseNull(category.getString("parentCategoryId"));
            String categoryLevel = parseNull(category.getString("categoryLevel"));
            String categoryName = parseNull(category.getString("categoryName"));
            
            Set rsCatName = Etn.execute("select * from categories_v2 where name="+escape.cote(categoryName)+ " and parent_id="+escape.cote(parentCategoryId)+
                " and site_id="+escape.cote(siteId));

            if(rsCatName.rs.Rows<=0){
                if(saveType.equals("update")){
                    String categoryId = parseNull(category.getString("categoryId"));
                    Etn.executeCmd("update categories_v2 set name="+escape.cote(categoryName)+", updated_by="+escape.cote(""+userId)+" where id="+escape.cote(categoryId));
                }else{
                    if(Integer.parseInt(categoryLevel) < Integer.parseInt(GlobalParm.getParm("max_category_level"))){
                        Etn.executeCmd("insert ignore into categories_v2 (name,level,parent_id,site_id,created_by,updated_by) values ("+escape.cote(categoryName)+","+escape.cote(categoryLevel)+
                        ","+escape.cote(parentCategoryId)+","+escape.cote(siteId)+","+escape.cote(""+userId)+","+escape.cote(""+userId)+")");
                    }else{
                        status=0;
                        msg="Max herarchy limit reached.";
                    }
                }
            }else{
                status=0;
                msg="Category already exist as its sibling.";
            }
        }else if(requestType.equals("getProductDefaultData")){

            JSONObject defaultData = new JSONObject();

            JSONArray rsp = new JSONArray();
            Set rs = Etn.execute("SELECT id,name from "+PAGES_DB+"bloc_templates where type in ('simple_product','simple_virtual_product','configurable_product','configurable_virtual_product') and site_id="+escape.cote(siteId));
            while(rs.next()){
                rsp.put(new JSONObject().put("id", rs.value("id")).put("name", rs.value("name")));
            }

            defaultData.put("templates",rsp);
            defaultData.put("categories",getCategories(Etn,siteId,"0").getJSONArray("categories"));
            defaultData.put("attributes",getAttributes(Etn,siteId).getJSONArray("attributes"));

            respnoseObj.put("data",defaultData);

        }else if(requestType.equals("getProductTypes")) respnoseObj.put("data",getProductTypes(Etn,siteId,PAGES_DB));
        else if(requestType.equals("deleteProductType")){
            String productUuid = parseNull(request.getParameter("productId"));
            Set rs = Etn.execute("select id,uuid from product_types_v2 where site_id="+escape.cote(siteId)+" and uuid="+escape.cote(productUuid));
            if(rs.next()){
                Set rsCount = Etn.execute("select * from products_definition where product_type="+escape.cote(rs.value("id")));
                if(rsCount.rs.Rows>0){
                    status=0;
                    msg="Cannot delete this product type, it is used in one or more products.";
                }else{
                    Etn.executeCmd("delete from product_v2_categories_and_attributes where product_type_uuid="+escape.cote(productUuid));
                    Etn.executeCmd("delete from product_v2_specifications where product_type_uuid="+escape.cote(productUuid));
                    Etn.executeCmd("delete from product_types_v2 where uuid="+escape.cote(productUuid));
                }
            }else{
                status=0;
                msg="Invalid product tpe id.";
            }
        }else if(requestType.equals("saveProductType")){
            JSONObject productType = new JSONObject(parseNull(request.getParameter("productType")));
            String productName = productType.getString("productName");

            String productTypeUuid = "";
            if(productType.has("productTypeUuid")){
                productTypeUuid = parseNull(productType.getString("productTypeUuid"));
            }

            if(!productTypeUuid.isEmpty()){
                Set rsCheckProduct = Etn.execute("select * from product_types_v2 where type_name="+escape.cote(productName)+" and site_id="+escape.cote(siteId)+
                    " and uuid !="+escape.cote(productTypeUuid));

                if(rsCheckProduct.rs.Rows>0){
                    status=0;
                    msg="Product type already exist with name "+productName;
                }else{
                    Set rsProductType = Etn.execute("select id from product_types_v2 where uuid="+escape.cote(productTypeUuid));
                    if(rsProductType.rs.Rows>0){
                        rsProductType.next();
                        String productTypeId = rsProductType.value("id");
                    
                        Etn.executeCmd("update product_types_v2 set type_name= "+escape.cote(productType.getString("productName"))+",template_id="+
                            escape.cote(productType.getString("templateId"))+",site_id="+escape.cote(siteId)+",created_by="+escape.cote(""+userId)
                            +",updated_by="+escape.cote(""+userId)+" where id="+escape.cote(productTypeId));

                        Etn.executeCmd("delete from product_v2_categories_and_attributes where product_type_uuid="+escape.cote(productTypeUuid));
                        Etn.executeCmd("delete from product_v2_specifications where product_type_uuid="+escape.cote(productTypeUuid));

                        inesrtProductTypeRelatedData(Etn,productType.getJSONArray("categories"),productType.getJSONArray("attributes"),productType.getJSONObject("specJson"),productTypeUuid);

                        onUpdateProductTypePages(Etn,productTypeId,userId+"",PAGES_DB);
                    }else{
                        status=0;
                        msg="Invalid uuid passed.";
                    }
                }
            }else{
                String msgError = "";
                Set rsCheckProduct = Etn.execute("select * from product_types_v2 where type_name="+escape.cote(productName)+" and site_id="+escape.cote(siteId));
                if(rsCheckProduct.rs.Rows>0){
                    msgError+="Product type already exist with name "+productName+".";
                }else{
                    int insertId = Etn.executeCmd("insert into product_types_v2 (type_name,template_id,site_id,created_by,updated_by) values ("+
                        escape.cote(productType.getString("productName"))+","+escape.cote(productType.getString("templateId"))+","+escape.cote(siteId)+
                        ","+escape.cote(""+userId)+","+escape.cote(""+userId)+")");
                
                    Set rsUuid = Etn.execute("select uuid from product_types_v2 where id="+escape.cote(""+insertId));
                    rsUuid.next();

                    productTypeUuid = rsUuid.value("uuid");
                    inesrtProductTypeRelatedData(Etn,productType.getJSONArray("categories"),productType.getJSONArray("attributes"),productType.getJSONObject("specJson"),productTypeUuid);
                    msg+="Product Type added successfully.";
                }

                if(!msgError.isEmpty()){
                    status=0;
                    msg+=msgError;
                }
            }
        }
    }catch(Exception e){
        status=0;
        msg=e.getMessage();
    }

    respnoseObj.put("status",status);
    respnoseObj.put("message",msg);

    out.write(respnoseObj.toString());
%>