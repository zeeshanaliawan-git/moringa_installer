<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="/admin/common.jsp"%>
<%

        String term = "%"+parseNull(request.getParameter("term"))+"%";
        String type = parseNull(request.getParameter("type"));
        String langId = parseNull(request.getParameter("langid"));
        String selectedsiteid = parseNull(getSelectedSiteId(session));
        out.write("[");
        boolean addComma = false;
        String params = "";
        String pagePath = "";

        if(langId.length() > 0){

            if(type.equals("product") || type.equals("sku")){

                params = ", (select page_path from product_descriptions pd where pd.product_id = p.id and pd.langue_id = " + escape.cote(langId) + " ) as page_path ";

            } else if(type.equals("catalog") || type.equals("manufacturer")){

                params = ", (select page_path from catalog_descriptions cd where cd.catalog_id = c.id and cd.langue_id = " + escape.cote(langId) + " ) as page_path ";
            }
        }

        if(type.equals("product")){
            Set rs = Etn.execute("select p.id, p.lang_1_name " + params + " from products p inner join catalogs c on c.id=p.catalog_id where c.site_id = "+escape.cote(selectedsiteid)+" and p.lang_1_name LIKE "+escape.cote(term));
            while(rs.next()){

                if(addComma) out.write(",");

                if(langId.length() > 0){

                    pagePath = parseNull(rs.value("page_path"));
                }

                out.write("{\"id\":\""+rs.value(0)+"\",\"value\":\""+rs.value(1)+"\",\"page_path\":\""+pagePath+"\"}");
                addComma = true;
            }
        }
        else if(type.equals("catalog")){
            Set rs = Etn.execute("select c.id, c.name " + params + " from catalogs c where c.site_id = "+escape.cote(selectedsiteid)+" and c.name LIKE "+escape.cote(term));
            while(rs.next()){

                if(addComma) out.write(",");

                if(langId.length() > 0){

                    pagePath = parseNull(rs.value("page_path"));
                }

                out.write("{\"id\":\""+rs.value(0)+"\",\"value\":\""+rs.value(1)+"\",\"page_path\":\""+pagePath+"\"}");
                addComma = true;
            }
        }
        else if(type.equals("sku")){
            Set rs = Etn.execute("select pv.sku as id, pv.sku " + params + " from product_variants pv inner join products p on p.id=pv.product_id inner join catalogs c on c.id=p.catalog_id where c.site_id = "+escape.cote(selectedsiteid)+" and pv.sku LIKE "+escape.cote(term));
            while(rs.next()){

                if(addComma) out.write(",");

                if(langId.length() > 0){

                    pagePath = parseNull(rs.value("page_path"));
                }

                out.write("{\"id\":\""+rs.value(0)+"\",\"value\":\""+rs.value(1)+"\",\"page_path\":\""+pagePath+"\"}");
                addComma = true;
            }
        }
        else if(type.equals("product_type")){
            Set rs = Etn.execute("select value, name from catalog_types where name LIKE "+escape.cote(term));
            while(rs.next()){
                if(addComma) out.write(",");
                out.write("{\"id\":\""+rs.value(0)+"\",\"value\":\""+rs.value(1)+"\"}");
                addComma = true;
            }
        }
        else if(type.equals("manufacturer")){
            Set rs = Etn.execute("select distinct p.brand_name " + params + " from products p inner join catalogs c on c.id=p.catalog_id where c.site_id = "+escape.cote(selectedsiteid)+" and p.brand_name LIKE "+escape.cote(term));
            while(rs.next()){

                if(addComma) out.write(",");

                if(langId.length() > 0){

                    pagePath = parseNull(rs.value("page_path"));
                }

                out.write("{\"id\":\""+rs.value(0)+"\",\"value\":\""+rs.value(0)+"\",\"page_path\":\""+pagePath+"\"}");
                addComma = true;
            }
        }
        else if(type.equals("delivery_method")){

            Set rs = Etn.execute("select method, displayName from delivery_methods where site_id = "+escape.cote(selectedsiteid) + " AND displayName LIKE " + escape.cote(term));

            while(rs.next()){

                if(addComma) out.write(",");

                out.write("{\"id\":\""+rs.value(0)+"\",\"value\":\""+rs.value(1)+"\"}");
                addComma = true;
            }
        }
        else if(type.equals("payment_method")){

            Set rs = Etn.execute("select method, displayName from payment_methods where site_id = "+escape.cote(selectedsiteid) + " AND displayName LIKE " + escape.cote(term) );

            while(rs.next()){

                if(addComma) out.write(",");

                out.write("{\"id\":\""+rs.value(0)+"\",\"value\":\""+rs.value(1)+"\"}");
                addComma = true;
            }
        }
        else if(type.equals("tag")){

            Set rs = Etn.execute("select id, label from tags where site_id = " + escape.cote(selectedsiteid) + " and label like " + escape.cote(term));
            while(rs.next()){
                if(addComma) out.write(",");
                out.write("{\"id\":\""+rs.value(0)+"\",\"value\":\""+rs.value(1)+"\"}");
                addComma = true;
            }
        }

        out.write("]");



%>