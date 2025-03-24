<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, com.etn.beans.app.GlobalParm, java.util.*, java.net.*, java.text.SimpleDateFormat, org.apache.commons.lang3.*, com.google.gson.*, com.google.gson.reflect.TypeToken, java.lang.reflect.Type"%>
<%@ include file="lib_msg.jsp"%>
<%@ include file="common.jsp"%>
<%!
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
        String product_uuid = parseNull(request.getParameter("product_uuid"));
        String calendar_start = parseNull(request.getParameter("start"));
        String calendar_end = parseNull(request.getParameter("end"));
        int min_time = parseNullInt(request.getParameter("min_time"));
        int max_time = parseNullInt(request.getParameter("max_time"));
        String client_id = com.etn.asimina.session.ClientSession.getInstance().getLoginClientId(Etn, request);

        SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd"); 
        SimpleDateFormat wf = new SimpleDateFormat("E", Locale.US); 
        Date date = (Date)df.parse(calendar_start);           
        Calendar c = Calendar.getInstance();        


        LinkedHashMap<String, HashMap<Integer, String>> exclusionMap = new LinkedHashMap<String, HashMap<Integer, String>>();

	Set rs = Etn.execute(" select p.* from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".products p where p.product_uuid  = " + escape.cote(product_uuid));
        rs.next();
        
        Gson gson = new Gson();
        Type stringObjectMap = new TypeToken<LinkedHashMap<String, Map<String,List<String>>>>(){}.getType();
        LinkedHashMap<String, Map<String,List<String>>> scheduleMap = gson.fromJson(rs.value("service_schedule"), stringObjectMap);
        for (String key : scheduleMap.keySet()) {
            HashMap<Integer, String> tempMap = new HashMap<Integer, String>();
            System.out.println(key+parseNull(scheduleMap.get(key)));
            Map<String,List<String>> dayMap = (Map)scheduleMap.get(key);
            List<String> scheduleStartTime = dayMap.get("startTime");
            List<String> scheduleEndTime = dayMap.get("endTime");
            for(int i=0; i<scheduleStartTime.size(); i++){
                int tempStartTime = Integer.parseInt(scheduleStartTime.get(i));
                int tempEndTime = Integer.parseInt(scheduleEndTime.get(i));
                for(int slotstart_time = tempStartTime; slotstart_time < tempEndTime; slotstart_time+=15){ 
                    tempMap.put(slotstart_time, "");
                }                
            }            
            exclusionMap.put(key,tempMap);
        }

        String product_refs = escape.cote(product_uuid);
        String resources = "";
        Set rsResource = Etn.execute("select case when coalesce(p.link_id,'') <> '' then pl.resources else ps.resources end as resources "+
            " from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".products p left outer join "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_stocks ps on ps.product_id = p.id "+
            " left outer join "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_link pl on pl.id = p.link_id "+
            " where p.product_uuid = " + product_refs);
        int resourceCount = 0;
        if(rsResource.next()){
            String[] tempResources = rsResource.value(0).split(",");
            for(String s : tempResources){
                if(!s.trim().equals("")) resourceCount++;
            }
            //out.write("asad"+resourceCount);
            resources = escape.cote(rsResource.value(0)).replaceAll(",","','");
        }

        String stock_query = "";
        if(rs.value("link_id").equals("")){
            stock_query = "select * from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_stocks where product_id ="+escape.cote(rs.value("id"))+" and attribute_values=''";
        }
        else {
            stock_query = "select * from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_link where id ="+escape.cote(rs.value("link_id"));
            Set rslink = Etn.execute("SELECT GROUP_CONCAT(id), GROUP_CONCAT(CONCAT('\\\'',product_uuid,'\\\'')) FROM "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".products where link_id="+rs.value("link_id")+" group by link_id");
            rslink.next();
            product_refs = rslink.value(1);
        }
        Set stock_rs = Etn.execute(stock_query);
        String stock ="0";
        if(stock_rs.next()) stock = stock_rs.value("stock");
        int intStock = Integer.parseInt(stock);
        

        HashMap<String, HashMap<Integer, HashSet<String>>> occupiedMap = new HashMap<String, HashMap<Integer, HashSet<String>>>();

        StringBuffer json = new StringBuffer();
        String query = "SELECT pw.phase, p.displayName, p.color, o.name, o.orderRef, oi.id as customerid, product_name, product_ref, resource, secondary_resource, service_start_time, service_duration, quantity,"
            + " DATE_FORMAT(STR_TO_DATE(oi.service_date, '%d-%m-%Y'),'%Y-%m-%d') as service_date, DATE_FORMAT(STR_TO_DATE(oi.service_end_date, '%d-%m-%Y'), '%Y-%m-%d') as service_end_date"
            + " FROM "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".order_items oi INNER JOIN "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".post_work pw ON oi.id = pw.client_key INNER JOIN "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".orders o ON oi.parent_id=o.parent_uuid INNER JOIN "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".phases p ON pw.proces=p.process AND pw.phase=p.phase  WHERE oi.product_type LIKE 'service%'"
            + " AND pw.STATUS IN ('0','9') and pw.phase <> 'Cancel' AND pw.is_generic_form = 0 AND ( product_ref IN ("+product_refs +") OR resource IN ("+resources +") ) AND STR_TO_DATE(oi.service_date, '%d-%m-%Y') >= "+escape.cote(calendar_start)+ "AND STR_TO_DATE(oi.service_date, '%d-%m-%Y') < "+escape.cote(calendar_end)
            + " GROUP BY customerid, product_name, resource, service_start_time, service_duration, service_date, service_end_date ORDER BY STR_TO_DATE(oi.service_date, '%d-%m-%Y') ";
        //System.out.println(query);
        Set rsSchedule = Etn.execute(query);

        String startDate = "";
        String endDate = "";

        //if(rs.rs.Rows > 0)
        json.append("[");
        boolean addComma = false;
        String currentDate = "";        
        
        while(rsSchedule.next()){
            startDate = parseNull(rsSchedule.value("service_date"));

            endDate = startDate;
            int service_start_time = parseNullInt(rsSchedule.value("service_start_time"));
            //int service_start_time = time+parseNullInt(rs.value("service_duration"));
            int service_end_time = service_start_time+(parseNullInt(rsSchedule.value("quantity"))*parseNullInt(rsSchedule.value("service_duration")));
            System.out.println(service_start_time + " "+ service_end_time + " "+rsSchedule.value("service_date")+ " "+rsSchedule.value("product_name")+ " "+rsSchedule.value("phase"));        

            for(int slotstart_time = service_start_time; slotstart_time < service_end_time; slotstart_time+=15){ // moved down to first print the calendar for previous date
                HashMap<Integer, HashSet<String>> tempMap = occupiedMap.get(startDate);

                if(tempMap==null) tempMap = new HashMap<Integer, HashSet<String>>();

                HashSet<String> tempSet = tempMap.get(slotstart_time);
                if(tempSet==null) tempSet = new HashSet<String>();

                tempSet.add((rsSchedule.value("customerid").equals("")?rsSchedule.value("customerid"):rsSchedule.value("resource")));
                tempMap.put(slotstart_time, tempSet);
                occupiedMap.put(startDate, tempMap);
            }
        }

        HashSet<String> holidaySet = new HashSet<String>();
        String calendar_query = "select DATE_FORMAT(date, '%Y-%m-%d'), HOUR(start_time)*60+MINUTE(start_time), HOUR(end_time)*60+MINUTE(end_time), resources, type from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".calendar where (type=2 AND product_id ="+escape.cote(rs.value("id"))+" OR type=1) AND date >= "+escape.cote(calendar_start)+ " AND date < "+escape.cote(calendar_end);
        Set rscal = Etn.execute(calendar_query);
        //System.out.println(calendar_query);
        while(rscal.next()){
            /*int minus_stock = parseNullInt(rscal.value(0));
            System.out.println(minus_stock+" " + rscal.value(1) + " " + rscal.value(2));*/

            startDate = rscal.value(0);

            endDate = rscal.value(0);
            
            if(rscal.value("type").equals("1")){
                holidaySet.add(startDate);
                occupiedMap.put(startDate, new HashMap<Integer, HashSet<String>>());
            }
            else{                
                int service_start_time = parseNullInt(rscal.value(1));
                //int service_start_time = time+parseNullInt(rs.value("service_duration"));
                int service_end_time = parseNullInt(rscal.value(2));
                //System.out.println(service_start_time + " "+ service_end_time + " ");        

                for(int slotstart_time = service_start_time; slotstart_time < service_end_time; slotstart_time+=15){ 
                    HashMap<Integer, HashSet<String>> tempMap = occupiedMap.get(startDate);
                    if(tempMap==null) tempMap = new HashMap<Integer, HashSet<String>>();

                    HashSet<String> tempSet = tempMap.get(slotstart_time);
                    if(tempSet==null) tempSet = new HashSet<String>();

                    tempSet.add(rscal.value("resources"));
                    tempMap.put(slotstart_time, tempSet);
                    occupiedMap.put(startDate, tempMap);
                }  
            }                
        }         

        if(!client_id.equals("")){
            query = "SELECT pw.phase, p.displayName, p.color, o.name, o.orderRef, oi.id as customerid, product_name, product_ref, resource, secondary_resource, service_start_time, service_duration, quantity,"
            + " DATE_FORMAT(STR_TO_DATE(oi.service_date, '%d-%m-%Y'),'%Y-%m-%d') as service_date, DATE_FORMAT(STR_TO_DATE(oi.service_end_date, '%d-%m-%Y'), '%Y-%m-%d') as service_end_date"
            + " FROM "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".order_items oi INNER JOIN "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".post_work pw ON oi.id = pw.client_key INNER JOIN "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".orders o ON oi.parent_id=o.parent_uuid INNER JOIN "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".phases p ON pw.proces=p.process AND pw.phase=p.phase  WHERE oi.product_type = 'service'"
            + " AND pw.STATUS IN ('0','9') AND pw.is_generic_form = 0 AND oi.product_type LIKE 'service%' AND client_id = "+escape.cote(client_id)
            + " GROUP BY customerid, product_name, resource, service_start_time, service_duration, service_date, service_end_date ORDER BY STR_TO_DATE(oi.service_date, '%d-%m-%Y') ";
            rs = Etn.execute(query);

            while(rs.next()){
                startDate = parseNull(rs.value("service_date"));
                endDate = startDate; //parseNull(rs.value("service_end_date"));
                int service_start_time = parseNullInt(rs.value("service_start_time"));
                //int service_start_time = time+parseNullInt(rs.value("service_duration"));
                int service_end_time = service_start_time+(parseNullInt(rs.value("quantity"))*parseNullInt(rs.value("service_duration")));
                HashMap<Integer, HashSet<String>> tempMap = occupiedMap.get(startDate);
                if(tempMap!=null) {
                    for(int slotstart_time = service_start_time; slotstart_time < service_end_time; slotstart_time+=15){ 
                        tempMap.remove(slotstart_time);
                    }
                    occupiedMap.put(startDate, tempMap);
                }  

                String startTime = getTime(service_start_time);
                String endTime = getTime(service_end_time);

                String start = startDate+"T"+startTime;
                String end = endDate+"T"+endTime;

                if(addComma) json.append(",");
                json.append(getEventJson(rs.value("product_name"),"red",start,end));
                addComma = true;
            }
        }

        for (String key : occupiedMap.keySet()){
            //String key = entry.getKey();
            //HashMap<Integer, HashSet<String>> value = entry.getValue();
            HashMap<Integer, HashSet<String>> tempMap = occupiedMap.get(key);
            //for (Integer key1 : tempMap.keySet()) {System.out.println(key1+"" );}
            Date tempDate = (Date)df.parse(key);
            String dayOfWeek = wf.format(tempDate).toLowerCase();

            if(holidaySet.contains(key)){
                if(addComma) json.append(",");
                json.append(getEventJson("","gray",key+"T"+getTime(min_time),key+"T"+getTime(max_time)));
                addComma = true;
            }
            else{
                HashMap<Integer, String> currentDayMap = exclusionMap.get(dayOfWeek);
                //exclusionMap.put("mon",null);
                int block_start_time = min_time;
                int block_end_time = min_time;
                boolean flip = false;
                for(int i=min_time; i<=max_time; i+=15){
                    HashSet<String> tempSet = tempMap.get(i);
                    if(!flip){
                        if(((tempSet!=null&&tempSet.size()>=intStock)||currentDayMap.get(i)==null)||i==max_time){
                            block_end_time = i;
                            //if(addComma) json.append(",");
                            //json.append(getEventJson("Available","green",currentDate+"T"+getTime(block_start_time),currentDate+"T"+getTime(block_end_time)));
                            //addComma = true;
                            block_start_time = block_end_time;
                            flip = true;
                        }
                    }
                    else{
                        if(((tempSet==null||tempSet.size()<intStock)&&currentDayMap.get(i)!=null)||i==max_time){
                            block_end_time = i;
                            if(addComma) json.append(",");
                            json.append(getEventJson("","gray",key+"T"+getTime(block_start_time),key+"T"+getTime(block_end_time)));
                            addComma = true;
                            block_start_time = block_end_time;
                            flip = false;
                        }
                    }
                }
            }  
            exclusionMap.remove(dayOfWeek);
        }

        for(int dayNumber=0; dayNumber<7; dayNumber++){
            c.setTime(date); 
            c.add(Calendar.DATE, dayNumber);
            String dayOfWeek = wf.format(c.getTime()).toLowerCase();    
            String dateString = df.format(c.getTime());
            if(exclusionMap.containsKey(dayOfWeek)){
                HashMap<Integer, String> currentDayMap = exclusionMap.get(dayOfWeek);
                int block_start_time = min_time;
                int block_end_time = min_time;
                boolean flip = false;
                for(int i=min_time; i<=max_time; i+=15){
                    if(!flip){
                        if(currentDayMap.get(i)==null||i==max_time){
                            block_end_time = i;
                            //if(addComma) json.append(",");
                            //json.append(getEventJson("Available","green",currentDate+"T"+getTime(block_start_time),currentDate+"T"+getTime(block_end_time)));
                            //addComma = true;
                            block_start_time = block_end_time;
                            flip = true;
                        }
                    }
                    else{
                        if(currentDayMap.get(i)!=null||i==max_time){
                            block_end_time = i;
                            if(addComma) json.append(",");
                            json.append(getEventJson("","gray",dateString+"T"+getTime(block_start_time),dateString+"T"+getTime(block_end_time)));
                            addComma = true;
                            block_start_time = block_end_time;
                            flip = false;
                        }
                    }
                }
            }            
        }

        //if(rs.rs.Rows > 0)
        json.append("]");
        out.write(json.toString());
%>