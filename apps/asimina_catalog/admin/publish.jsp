<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm, com.etn.asimina.util.ActivityLog, java.lang.Exception, org.json.JSONObject"%>
<%@ include file="common.jsp"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%!
    String convertToUpperCaseWords(String str)
    {
        char ch[] = str.toCharArray();
        for (int i = 0; i < str.length(); i++) {
            if (i == 0 && ch[i] != ' ' ||
                ch[i] != ' ' && ch[i - 1] == ' ') {
                if (ch[i] >= 'a' && ch[i] <= 'z') {
                    ch[i] = (char)(ch[i] - 'a' + 'A');
                }
            }
            else if (ch[i] >= 'A' && ch[i] <= 'Z')
                ch[i] = (char)(ch[i] + 'a' - 'A');
        }
        String st = new String(ch);
        return st;
    }

    String getNames(com.etn.beans.Contexte Etn,String ids,String type){
        try{
            if(ids.charAt(ids.length()-1) == ',')  ids = ids.substring(0, ids.length() - 1);
            Set rs = null;
            String names = "";
            String q = "";
            if(type.equals("catalogs")){
                q =  "select name from catalogs where id in ("+ids+")";
            }
            else if(type.equals("products")){
                q =  "select lang_1_name from products where id in ("+ids+")";
            }
            else if(type.equals("additionalfees")){
                q =  "select additional_fee from additionalfees where id in ("+ids+")";
            }
            else if(type.equals("comewiths")){
                q =  "select name from comewiths where id in ("+ids+")";
            }
            else if(type.equals("deliveryfees")){
                q =  "select name from deliveryfees where id in ("+ids+")";
            }
            else if(type.equals("deliverymins")){
                q =  "select name from deliverymins where id in ("+ids+")";
            }
            else if(type.equals("families") || type.equals("familie") ){
                q =  "select name from familie where id in ("+ids+")";
            }
            else if(type.equals("promotions")){
                q =  "select name from promotions where id in ("+ids+")";
            }
            else if(type.equals("quantitylimits")){
                q =  "select name from quantitylimits where id in ("+ids+")";
            }
            else if(type.equals("subsidies")){
                q =  "select name from subsidies where id in ("+ids+")";
            }
            //else if(type.equals("resources")){
            //    q =  "select name from resources where id in ("+ids+")";
            //}
            else if(type.equals("cartrules") || type.equals("cart_promotion")){
                q =  "select name from cart_promotion where id in ("+ids+")";
            }
            else if(type.equals("landingpages") || type.equals("landing_pages")){
                q =  "select page_name from landing_pages where id in ("+ids+")";
            }

            if(q.length()>0)   rs = Etn.execute(q);
            else return "";

            while(rs.next()){
                if(names.length()>0) names += ", ";
                names += parseNull(rs.value(0));
            }
            return names;
        }catch(Exception e){
            return "";
        }
    }

    void publishProductOnAlgolia(com.etn.beans.Contexte Etn,String id,String process,String siteId,String action,String actionDate){
        String query="";
        String query2="";
        String actionTime="";
        String actionTime2=" c.end_date ";
        String prodPortaldb = GlobalParm.getParm("PROD_PORTAL_DB")+".";
        String prodCatalogdb = GlobalParm.getParm("PROD_DB")+".";

        if(action.equalsIgnoreCase("delete")){
            action ="unpublish";
            if(!actionDate.equalsIgnoreCase("-1")){
                actionTime = actionDate;
            }else{
                actionTime = " now() ";
            }
        }else{
            action ="publish";
            actionTime = " DATE_SUB(c.start_date, INTERVAL 3 MINUTE) ";
        }

        if(actionDate.equalsIgnoreCase("-1")){
            actionDate=" now() ";
        }

        String productId="";
        if(process.equalsIgnoreCase("comewiths"))
        {
            query ="select cr.associated_to_value as prod_id,"+escape.cote(siteId)+","+escape.cote(action)+",'marketing_rules',"+actionTime+
                " as action_time from "+prodCatalogdb+"comewiths_rules cr left join "+prodCatalogdb+"comewiths c on c.id=cr.comewith_id where cr.comewith_id="+
                escape.cote(id);
            Set rsTemp=Etn.execute(query);
            if(rsTemp.next())
            {

                if(!parseNull(rsTemp.value("prod_id")).matches("\\d+"))
                {
                    query="select pv.product_id, "+escape.cote(siteId)+","+escape.cote(action)+",'marketing_rules',"+escape.cote(parseNull(rsTemp.value("action_time")))+
                    " from "+prodCatalogdb+"product_variants pv left join "+prodCatalogdb+"products p on p.id=pv.product_id left join "+prodCatalogdb+"catalogs c on c.id=p.catalog_id where sku="+
                    escape.cote(parseNull(rsTemp.value("prod_id")))+" and c.site_id="+escape.cote(siteId);
                }
                else
                {
                    Set rsProdValid = Etn.execute("select * from "+prodCatalogdb+"products where id="+escape.cote(parseNull(rsTemp.value("prod_id"))));
                    if(!rsProdValid.next()){
                        query="";
                    }
                }

            }
            if(action.equalsIgnoreCase("publish"))
            {
                query2 ="select cr.associated_to_value as prod_id,"+escape.cote(siteId)+",'unpublish','marketing_rules',"+actionTime2+
                " as action_time from "+prodCatalogdb+"comewiths_rules cr left join "+prodCatalogdb+"comewiths c on c.id=cr.comewith_id where cr.comewith_id="+escape.cote(id);

                rsTemp=Etn.execute(query2);
                if(rsTemp.next())
                {
                    if(!parseNull(rsTemp.value("prod_id")).matches("\\d+"))
                    {
                        query2="select product_id, "+escape.cote(siteId)+",'unpublish','marketing_rules',"+escape.cote(parseNull(rsTemp.value("action_time")))+
                        " from "+prodCatalogdb+"product_variants pv left join "+prodCatalogdb+"products p on p.id=pv.product_id left join "+prodCatalogdb+"catalogs c on c.id=p.catalog_id where sku="+
                        escape.cote(parseNull(rsTemp.value("prod_id")))+" and c.site_id="+escape.cote(siteId);
                    }
                }
            }
        }
        else if(process.equalsIgnoreCase("promotions"))
        {
            query ="select cr.applied_to_value as prod_id,"+escape.cote(siteId)+","+escape.cote(action)+",'marketing_rules',"+actionTime+
                " as action_time from "+prodCatalogdb+"promotions_rules cr left join "+prodCatalogdb+"promotions c on c.id=cr.promotion_id where cr.promotion_id="+escape.cote(id);
            Set rsTemp=Etn.execute(query);
            if(rsTemp.next())
            {
                if(!parseNull(rsTemp.value("prod_id")).matches("\\d+"))
                {
                    query="select product_id, "+escape.cote(siteId)+","+escape.cote(action)+",'marketing_rules',"+escape.cote(parseNull(rsTemp.value("action_time")))+
                    " from "+prodCatalogdb+"product_variants pv left join "+prodCatalogdb+"products p on p.id=pv.product_id left join "+prodCatalogdb+"catalogs c on c.id=p.catalog_id where sku="+
                    escape.cote(parseNull(rsTemp.value("prod_id")))+" and c.site_id="+escape.cote(siteId);
                }
                else
                {
                    Set rsProdValid = Etn.execute("select * from "+prodCatalogdb+"products where id="+escape.cote(parseNull(rsTemp.value("prod_id"))));
                    if(!rsProdValid.next())
                    {
                        query="";
                    }
                }

            }
            if(action.equalsIgnoreCase("publish"))
            {
                query2 ="select cr.applied_to_value as prod_id,"+escape.cote(siteId)+",'unpublish','marketing_rules',"+actionTime2+
                " as action_time from "+prodCatalogdb+"promotions_rules cr left join "+prodCatalogdb+"promotions c on c.id=cr.promotion_id where cr.promotion_id="+escape.cote(id);
                
                rsTemp=Etn.execute(query2);
                if(rsTemp.next())
                {
                    if(!parseNull(rsTemp.value("prod_id")).matches("\\d+"))
                    {
                        query2="select product_id, "+escape.cote(siteId)+",'unpublish','marketing_rules',"+escape.cote(parseNull(rsTemp.value("action_time")))+
                        " from "+prodCatalogdb+"product_variants pv left join "+prodCatalogdb+"products p on p.id=pv.product_id left join "+prodCatalogdb+
                        "catalogs c on c.id=p.catalog_id where sku="+escape.cote(parseNull(rsTemp.value("prod_id")))+" and c.site_id="+escape.cote(siteId);
                    }

                }

            }
        }
        else if(process.equalsIgnoreCase("subsidies"))
        {
            query ="select cr.associated_to_value as prod_id,"+escape.cote(siteId)+","+escape.cote(action)+",'marketing_rules',"+actionTime+
                " as action_time from "+prodCatalogdb+"subsidies_rules cr left join "+prodCatalogdb+"subsidies c on c.id=cr.subsidy_id  where cr.subsidy_id="+escape.cote(id);
            Set rsTemp=Etn.execute(query);

            if(rsTemp.next())
            {
                if(!parseNull(rsTemp.value("prod_id")).matches("\\d+"))
                {
                    query="select product_id, "+escape.cote(siteId)+","+escape.cote(action)+",'marketing_rules',"+escape.cote(parseNull(rsTemp.value("action_time")))+
                    " from "+prodCatalogdb+"product_variants pv left join "+prodCatalogdb+"products p on p.id=pv.product_id left join "+prodCatalogdb+
                    "catalogs c on c.id=p.catalog_id where sku="+escape.cote(parseNull(rsTemp.value("prod_id")))+" and c.site_id="+escape.cote(siteId);
                }
                else
                {
                    Set rsProdValid = Etn.execute("select * from "+prodCatalogdb+"products where id="+escape.cote(parseNull(rsTemp.value("prod_id"))));
                    if(!rsProdValid.next())
                    {
                        query="";
                    }
                }

            }
            if(action.equalsIgnoreCase("publish"))
            {
                query2 ="select cr.associated_to_value as prod_id,"+escape.cote(siteId)+",'unpublish','marketing_rules',"+actionTime2+
                " as action_time from "+prodCatalogdb+"subsidies_rules cr left join "+prodCatalogdb+"subsidies c on c.id=cr.subsidy_id  where cr.subsidy_id="+escape.cote(id);
                rsTemp=Etn.execute(query2);

                if(rsTemp.next())
                {
                    if(!parseNull(rsTemp.value("prod_id")).matches("\\d+"))
                    {
                        query2="select product_id, "+escape.cote(siteId)+",'unpublish','marketing_rules',"+escape.cote(parseNull(rsTemp.value("action_time")))+
                        " from "+prodCatalogdb+"product_variants pv left join "+prodCatalogdb+"products p on p.id=pv.product_id left join "+prodCatalogdb+
                        "catalogs c on c.id=p.catalog_id where sku="+escape.cote(parseNull(rsTemp.value("prod_id")))+" and c.site_id="+escape.cote(siteId);
                    }

                }

            }
        }


        if(query.length()>0){
            query="insert into "+prodPortaldb+"publish_content (cid,site_id,publication_type,ctype,action_dt) "+query;
            Etn.executeCmd(query);
            
            if(query2.length()>0){
                query2="insert into "+prodPortaldb+"publish_content (cid,site_id,publication_type,ctype,action_dt) "+query2;
                Etn.executeCmd(query2);
            }

            Set rsNew=Etn.execute("select val from "+prodPortaldb+"config where code='SEMAPHORE'");
            if(rsNew!=null && rsNew.rs.Rows>0 && rsNew.next()){
                Etn.execute("SELECT semfree("+escape.cote(rsNew.value("val"))+")");
            }
        }

    }

    boolean isCatalogPublished(com.etn.beans.Contexte Etn,String catalogId){
        String PROD_CATALOG_DB = GlobalParm.getParm("PROD_DB")+".";
        Set rsCatalogV2 = Etn.execute("select * from catalogs where id="+escape.cote(catalogId));
        Set rsProdCatalogV2 = Etn.execute("select * from "+PROD_CATALOG_DB+"catalogs where id="+escape.cote(catalogId));

        if(rsProdCatalogV2.next()){
            if(parseNull(rsProdCatalogV2.value("version")).isEmpty() || !rsProdCatalogV2.value("version").equals(rsCatalogV2.value("version"))) return false;
        }else return false;
        return true;
    }

%>
<%
	String itemType = parseNull(request.getParameter("type"));
	String id = parseNull(request.getParameter("id"));
    String itemName = parseNull(request.getParameter("name"));
	String on = parseNull(request.getParameter("on"));
	String publishtype = parseNull(request.getParameter("publishtype"));
    String siteId =  getSelectedSiteId(session);
    String date = on;
    String action ="";

    if(date.equals("-1")) date = "";
    else date = " for "+ date;
    if(publishtype.equals("multi"))
    {
        action = "PUBLISHED";
    }else if(publishtype.equals("multidelete"))
    {
        action = "UNPUBLISHED";
    }else if(publishtype.equals("ordering"))
    {
        action = "PUBLISHED-ORDER";
    }else if(publishtype.equals("publish"))
    {
        action = "PUBLISHED";
    }else if(publishtype.equals(""))
    {
        action = "PUBLISHED";
    }else if(publishtype.equals("delete"))
    {
        action = "UNPUBLISHED";
    }

    //publishType possible values = {publish, delete, multi, multidelete, ordering } , default i.e. "" -> "publish"
	String _d = "";
	String process = getProcess(itemType);
	boolean dosemfree = false;
    String STATUS_SUCCESS = "success", STATUS_ERROR = "error";
    String message = "Success";
    String status = STATUS_SUCCESS;
    String publishon = "";

    if(!"-1".equals(on))
    {
        if(on.length() != 16)
        {
            status = STATUS_ERROR;
            message = "Invalid date/time format. Format must be dd/mm/yyyy hh:mm";
        }
        on = on + ":00";
        try {
            on =  ItsDate.stamp(ItsDate.getDate(on));
        } catch(Exception e) {
            status = STATUS_ERROR;
            message = "Invalid date/time format. Format must be dd/mm/yyyy hh:mm";
        }
    }

    if(status.equals(STATUS_SUCCESS)){

    	if("multi".equals(publishtype) || "ordering".equals(publishtype) || "multidelete".equals(publishtype)) {
    		String phase = "publish";
    		if("ordering".equals(publishtype)) phase = "publish_ordering";
    		if("multidelete".equals(publishtype)) phase = "delete";
    		String[] ids = id.split(",");

    		if(ids != null) {
    			for(int i=0; i<ids.length; i++) {
    				if(parseNull(ids[i]).length() == 0) continue;

                    if(process.equalsIgnoreCase("products")){
                        Set rsProdV2 = Etn.execute("select * from products where id="+escape.cote(ids[i]));
                        rsProdV2.next();
                        if(rsProdV2.value("product_version").equalsIgnoreCase("v2")){
                            if(!isCatalogPublished(Etn,rsProdV2.value("catalog_id"))) movephase(Etn, rsProdV2.value("catalog_id"), "catalogs", "publish", on);
                        }
                    }

                    dosemfree = movephase(Etn, ids[i], process, phase, on);
                    publishProductOnAlgolia(Etn, ids[i], process,siteId,phase,on);
    			}
    		}
            if(itemName.length()>0) ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),id,action,convertToUpperCaseWords(process),itemName+date,siteId);
            else ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),id,action,convertToUpperCaseWords(process),getNames(Etn,id,process)+date,siteId);
    	}
    	else {
    		String phase = "publish";
    		if("delete".equals(publishtype)) phase = "delete";

    		dosemfree = movephase(Etn, id, process, phase, on);

    		if(!dosemfree)
    		{
    			status = STATUS_ERROR;
    			message = "Publish already in process";
    		}
            publishProductOnAlgolia(Etn, id, process,siteId,phase,on);
    		Set rs = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s') from post_work where status = 0 and phase = 'publish' and client_key = "+escape.cote(id)+" and proces = " +escape.cote(process));
    		if(rs.next()) publishon = "Next publish on : " + parseNull(rs.value(0));

            if(itemName.length()>0)
            {
                ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),id,action,convertToUpperCaseWords(process),itemName+date,siteId);
            }
            else{
              ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),id,action,convertToUpperCaseWords(process),getNames(Etn,id,process)+date,siteId);
            }
    	}
    }

    JSONObject jsonResponse = new JSONObject();
    jsonResponse.put("response",status);
    jsonResponse.put("msg",message);
    jsonResponse.put("next_publish_on",publishon);

    out.write(jsonResponse.toString());
	if(dosemfree) Etn.execute("select semfree('"+GlobalParm.getParm("SEMAPHORE")+"') ");

%>
