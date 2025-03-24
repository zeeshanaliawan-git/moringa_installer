<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm, java.util.*"%>
<%!
    String parseNull(Object o)
    {
        if( o == null )
        return("");
        String s = o.toString();
        if("null".equals(s.trim().toLowerCase()))
        return("");
        else
        return(s.trim());
    }

    int parseNullInt(Object o)
    {
        if (o == null) return 0;
        String s = o.toString();
        if (s.equals("null")) return 0;
        if (s.equals("")) return 0;
        return Integer.parseInt(s);
    }

%>
<%
        String id = parseNull(request.getParameter("id"));
        int rating = parseNullInt(request.getParameter("rating"));

        int j=0;
        if(!id.equals("") && rating!=0){
            Set rs = Etn.execute("select product_rating, product_ref from "+GlobalParm.getParm("SHOP_DB")+".order_items where id="+escape.cote(id));
            if(rs.next()){
                int previous_rating = parseNullInt(rs.value(0));
                if(parseNullInt(rs.value(0))==0){
                    Etn.executeCmd("update "+GlobalParm.getParm("CATALOG_DB")+".products set rating_count=IFNULL(rating_count,0)+1, rating_score=IFNULL(rating_score,0)+"+rating+" where product_uuid="+escape.cote(rs.value(1)));
                }
                else{
                    Etn.executeCmd("update "+GlobalParm.getParm("CATALOG_DB")+".products set rating_score=(IFNULL(rating_score,0)+"+rating+")-"+previous_rating+" where product_uuid="+escape.cote(rs.value(1)));
                }
                j = Etn.executeCmd("update "+GlobalParm.getParm("SHOP_DB")+".order_items set product_rating="+rating+" where id="+escape.cote(id));
            }          
        }
%>