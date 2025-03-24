<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.*, org.json.*, java.text.*" %>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ include file="/common2.jsp" %>
<%
// java.text is utility provides funciton for date number,messaging etc. funciton "independent of natural language"

    String portaldb = com.etn.beans.app.GlobalParm.getParm("PORTAL_DB");
    String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");

    JSONObject mainChartOptions = new JSONObject("{maintainAspectRatio: false,legend: {display: true},scales: {xAxes: [{gridLines: {drawOnChartArea: false}}]},elements: {point: {radius: 0,hitRadius: 10,hoverRadius: 4,hoverBorderWidth: 3}}}");

   String startTime = request.getParameter("start");
   String endTime = request.getParameter("end");

   DateFormat formatter = new SimpleDateFormat("yyyyMMdd");
   Date startDate  =   formatter.parse(startTime);
   Calendar start =  Calendar.getInstance();
   start.setTime(startDate);

   Date endDate  =   formatter.parse(endTime);
   Calendar end =  Calendar.getInstance();
   end.setTime(endDate);

   int numberOfDays = ((int)((endDate.getTime()-startDate.getTime())/(1000*24*60*60)))+1;

   String keyColumn = "";
   Map<String,Object> lastDaysMap =  new LinkedHashMap<String, Object>();;
   JSONArray lastDays = new JSONArray();

   if(numberOfDays<60)
   {
        keyColumn =  "DATE_FORMAT(date_l, '%Y-%c-%e')";
        while(start.compareTo(end)<1)
        {
            int tempMonth = start.get(Calendar.MONTH)+1; // because January is 0 in Calendar while in mysql January is 1
            String key = start.get(Calendar.YEAR)+"-"+tempMonth+"-"+start.get(Calendar.DAY_OF_MONTH);
            lastDaysMap.put(key, 0);
            lastDays.put(start.getDisplayName(Calendar.DAY_OF_WEEK, Calendar.SHORT, request.getLocale()));
            start.add(Calendar.DAY_OF_MONTH, 1);
        }

   }
    else if(numberOfDays<1000){
        keyColumn = "DATE_FORMAT(date_l, '%Y-%c')";
        while(start.get(Calendar.YEAR)<end.get(Calendar.YEAR) || (start.get(Calendar.YEAR)==end.get(Calendar.YEAR) && start.get(Calendar.MONTH)<=end.get(Calendar.MONTH))){
            int tempMonth = start.get(Calendar.MONTH)+1; // because January is 0 in Calendar while in mysql January is 1
            String key = start.get(Calendar.YEAR)+"-"+tempMonth;
            lastDaysMap.put(key, 0);
            lastDays.put(start.getDisplayName(Calendar.MONTH, Calendar.LONG, request.getLocale()));
            start.add(Calendar.MONTH, 1);
        }
    }
    else{
        keyColumn = "DATE_FORMAT(date_l, '%Y')";
        while(start.get(Calendar.YEAR)<=end.get(Calendar.YEAR)){
            String key = start.get(Calendar.YEAR)+"";
            lastDaysMap.put(key, 0);
            lastDays.put(key);
            start.add(Calendar.YEAR, 1);
        }
    }


   Set rs =  Etn.execute("select  GROUP_CONCAT(compare_type), GROUP_CONCAT(url),label,color from dashboard_urls where url_group = 'funnel' group by url_type order by sort_order ");

    JSONArray dataList = new JSONArray();
    JSONArray labels = new JSONArray();
    JSONArray colors = new JSONArray();

    String whereClause =  "";
   System.out.println("5555555555555555555555555555555555555555555555");
   while(rs.next())
   {
       labels.put(rs.value(2));
       colors.put(rs.value(3));
       whereClause = "";
        String[] compareTypes = rs.value(0).split(",");
        String[] urls = rs.value(1).split(",");
        for(int i=0; i<compareTypes.length; i++){
            if(whereClause.length()>0) whereClause += " OR ";
            whereClause += " page_c like "+escape.cote((compareTypes[i].equals("starting_from")?"":"%")+urls[i]+"%");
        }

        Set rs2 =  Etn.execute("select  "+keyColumn+" , count(distinct session_j) from "+portaldb+".`stat_log` where (Date(date_l) between "+escape.cote(startTime)+" and "+escape.cote(endTime)+") and  ("+whereClause+") group by 1 order by date_l desc  ");

        System.out.println("select  "+keyColumn+" , count(distinct session_j) from "+portaldb+".`stat_log` where (Date(date_l) between "+escape.cote(startTime)+" and "+escape.cote(endTime)+") and  ("+whereClause+") group by 1 order by date_l desc  ");

        while(rs2.next())
        {
            lastDaysMap.put(rs2.value(0),rs2.value(1));
        }
        JSONArray visitsPerDay = new JSONArray();
        for (Map.Entry<String, Object> entry : lastDaysMap.entrySet()) {
            String key = entry.getKey();
            Object value = entry.getValue();
            visitsPerDay.put(parseNullInt(value));
        }
        dataList.put(visitsPerDay);
    }


JSONArray datasets = new JSONArray();
   for(int i=0; i<labels.length();i++)
   {
        JSONObject obj = new JSONObject();
        obj.put("label",labels.get(i));
        obj.put("borderColor",colors.get(i));
        obj.put("backgroundColor",colors.get(i));
        obj.put("fill",false);
        obj.put("pointHoverBackgroundColor","#fff");
        obj.put("borderWidth",2);
        obj.put("data",dataList.get(i));
        datasets.put(obj);
   }

    JSONObject mainChartMainData = new JSONObject();
    JSONObject mainChart = new JSONObject();
    mainChart.put("type","line");
    mainChartMainData.put("labels",lastDays);
    mainChartMainData.put("datasets",datasets);
    mainChart.put("options",mainChartOptions);
    mainChart.put("data",mainChartMainData);

 out.write(mainChart.toString());

%>