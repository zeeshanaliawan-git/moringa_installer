<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, com.etn.beans.app.GlobalParm, java.util.*, java.net.*, java.text.SimpleDateFormat, org.apache.commons.lang3.*, com.google.gson.*, com.google.gson.reflect.TypeToken, java.lang.reflect.Type"%>
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
        String getTime(int time){        
            String hour = (time/60)+"";
            String mins = (time%60)+"";

            if(hour.length() != 2)
                hour = "0"+hour;

            if(mins.length() != 2)
                mins = "0"+mins;

            return hour+":"+mins;

        }
        
        String getEventJson(String title, String backgroundColor, String start, String end){
            StringBuffer json = new StringBuffer();
            json.append("{\"title\": \"");
                            //json.append("");
                            //json.append("\\n");
            json.append(title);
            json.append("\",\"backgroundColor\":\"");
            json.append(backgroundColor);
            json.append("\",\"start\": \"");
            json.append(start);
            json.append("\",\"end\": \"");
            json.append(end);
            json.append("\"}");
            return json.toString();
        }

%>
<%
        String calendar_start = parseNull(request.getParameter("start"));
        String calendar_end = parseNull(request.getParameter("end"));
        int min_time = parseNullInt(request.getParameter("min_time"));
        int max_time = parseNullInt(request.getParameter("max_time"));
        String client_id = com.etn.asimina.session.ClientSession.getInstance().getLoginClientId(Etn, request);

        StringBuffer json = new StringBuffer();

        String startDate = "";
        String endDate = "";

        //if(rs.rs.Rows > 0)
        json.append("[");
        boolean addComma = false;      

        if(!client_id.equals("")){
            String query = "SELECT pw.phase, p.displayName, p.color, o.name, o.orderRef, oi.id as customerid, product_name, product_ref, resource, secondary_resource, service_start_time, service_duration, quantity,"
            + " DATE_FORMAT(STR_TO_DATE(oi.service_date, '%d-%m-%Y'),'%Y-%m-%d') as service_date, DATE_FORMAT(STR_TO_DATE(oi.service_end_date, '%d-%m-%Y'), '%Y-%m-%d') as service_end_date,"
            + " CASE WHEN DATE_ADD(STR_TO_DATE(oi.service_date, '%d-%m-%Y'), interval oi.service_start_time+(oi.service_duration*oi.quantity) MINUTE) < NOW() THEN 'gray' ELSE 'green' END as eventColor"
            + " FROM "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".order_items oi INNER JOIN "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".post_work pw ON oi.id = pw.client_key INNER JOIN "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".orders o ON oi.parent_id=o.parent_uuid INNER JOIN "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".phases p ON pw.proces=p.process AND pw.phase=p.phase  WHERE oi.product_type = 'service'"
            + " AND pw.STATUS IN ('0','9') AND pw.is_generic_form = 0 AND oi.product_type LIKE 'service%' AND client_id = "+escape.cote(client_id)+" AND STR_TO_DATE(oi.service_date, '%d-%m-%Y') >= "+escape.cote(calendar_start)+ "AND STR_TO_DATE(oi.service_date, '%d-%m-%Y') < "+escape.cote(calendar_end)
            + " GROUP BY customerid, product_name, resource, service_start_time, service_duration, service_date, service_end_date ORDER BY STR_TO_DATE(oi.service_date, '%d-%m-%Y') ";
            Set rs = Etn.execute(query);

            while(rs.next()){
                startDate = parseNull(rs.value("service_date"));
                endDate = startDate; //parseNull(rs.value("service_end_date"));
                int service_start_time = parseNullInt(rs.value("service_start_time"));
                //int service_start_time = time+parseNullInt(rs.value("service_duration"));
                int service_end_time = service_start_time+(parseNullInt(rs.value("quantity"))*parseNullInt(rs.value("service_duration")));

                String startTime = getTime(service_start_time);
                String endTime = getTime(service_end_time);

                String start = startDate+"T"+startTime;
                String end = endDate+"T"+endTime;

                if(addComma) json.append(",");
                json.append(getEventJson(rs.value("product_name"),rs.value("eventColor"),start,end));
                addComma = true;
            }
        }

        //if(rs.rs.Rows > 0)
        json.append("]");
        out.write(json.toString());
%>