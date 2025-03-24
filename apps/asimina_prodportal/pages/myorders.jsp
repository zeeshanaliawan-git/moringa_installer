<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ include file="../clientcommon.jsp" %>

<%@ include file="../common2.jsp" %>
<%@ include file="/common.jsp" %>
<%@ include file="../lib_msg.jsp" %>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape,com.etn.beans.app.GlobalParm"%>
<%@ page import="java.util.*, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken" %>

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

String getTime(String timeString){
    int time = parseNullInt(timeString);
    String hour = (time/60)+"";
    String mins = (time%60)+"";

    if(hour.length() != 2)
    hour = "0"+hour;

    if(mins.length() != 2)
    mins = "0"+mins;

    return hour+":"+mins;
}

String formatJson(String json){
    if(json.startsWith("[")) return "";
    Gson gson = new Gson();
    Type stringObjectMap = new TypeToken<Map<String,String>>(){}.getType();
    Map<String,String> map = gson.fromJson(json, stringObjectMap);

    if(map.size()==0) return "";
    String html = "<div class=\"row border-bottom py-2 mt-2\">";
    for (Map.Entry<String, String> entry : map.entrySet()) {
        String key = entry.getKey();
        String value = entry.getValue();
        html+="<div class=\"col-12 col-sm\"><span style=\"color:gray;\">"+key+"</span> : <span> "+value+"</span></div>";
    }
    html+="</div>";
    return html;
}

%>

<%
	if(com.etn.asimina.session.ClientSession.getInstance().isClientLoggedIn(Etn, request) == false)
	{
		response.sendRedirect(com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK") + "pages/sessionexpired.jsp?muid="+	parseNull(request.getParameter("muid")));
		return;		
	}

	String _error_msg = libelle_msg(Etn, request, "Your session is expired. Please login again");
	//this is used in headerfooter.jsp and logofooter.jsp
	String __pageTemplateType = "default";	

%>
<%@ include file="../headerfooter.jsp"%>
<!doctype html>
<html lang="<%=_lang%>" dir="<%=langDirection%>">
<head>
  <%=_headhtml%>
  <style>
  .etn-orange-portal-- table.o-results tr td{
    padding: 15px;
  }
  .etn-orange-portal-- .fc-time-grid .fc-bgevent,
  .etn-orange-portal-- .fc-time-grid .fc-event{
    color: #fff;
  }
  .product-information .o-row{
    border-bottom: 1px solid gray; padding-bottom: 15px;
    padding-top: 15px;
  }
  .product-information .o-row:last-child{
    border-bottom: none;
  }
</style>

</head>
<body>
  <div class="etn-orange-portal--">
    <%=_headerHtml%>
    <link rel="stylesheet" type="text/css" href="../css/fullcalendar.min.css">
    <link rel="stylesheet" type="text/css" href="../menu_resources/css/boosted.min.css">
    <script src="../js/jquery.min.js"></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/bootstrap.js"></script>
    <script src="../js/moment.min.js"></script>
    <script src="../js/fullcalendar.min.js"></script>
    <div id="container" class="container">
     <h1><%=libelle_msg(Etn, request, "Mon Orders")%></h1>
     <div>
<style>
  .container{
    width: 100% !important;
    max-width: 960px !important;
    padding: 0 10px !important;
  }
  .complaint-form{
    display: none;
  }
  .complaint-form.active{
    display: block;
  }
  @media all and (max-width: 768px) {
    .etn-orange-portal-- nav{

    }
    
            .ratings{
              vertical-align: middle;
              display: inline-block;
            }
              .ratings .star{
                background-image: url('../img/star0.png');
                background-repeat: no-repeat;
                background-position: center center;
                width: 16px;
                height: 16px;
                display: inline-block;
                cursor: pointer;
              }
              .ratings .star.highlight,
              .ratings .star.full{
                background-image: url('../img/star100.png');
              }
</style>
<%
    String cachedResourcesFolder = getCachedResourcesUrl(Etn, _menuRs.value("id"));
    
    String langue_id = "1";
	//if incoming lang was empty or not found in the language table, we will get the first language by default
    Set __rs1 = Etn.execute("select '0' as _a, langue_code, langue_id from language where langue_code = " + escape.cote(_lang) + " union select '1' as _a, langue_code, langue_id from language where langue_id = 1 order by _a ");
    if(__rs1.next()){
        _lang = parseNull(__rs1.value("langue_code"));
        langue_id = parseNull(__rs1.value("langue_id"));
    }
        
    String client_id = com.etn.asimina.session.ClientSession.getInstance().getLoginClientId(Etn, request);
    String timePeriod = parseNull(request.getParameter("period"));
    if(timePeriod.equals("")) timePeriod = "3";
	
	int nTimePeriod = 0;
	try {
		nTimePeriod = Integer.parseInt(timePeriod);
	} catch(Exception e) {}
	
    String status = parseNull(request.getParameter("status"));
    if(status.equals("")) status = "open";
    int num = parseNullInt(request.getParameter("num"));
    if(num<1) num = 1;

%>
<div class="" style="margin-bottom: 30px; " data-spy="affix" data-offset-top="60" >
  <div class="row justify-content-end">
      <%--<div class="form-group" >
           <button id="openSchedule" class="btn black color-white"><%=libelle_msg(Etn, request, "Open Schedule")%></button> 
      </div>--%>
      <div class="form-group col-2" >
        <label for="period"><%=libelle_msg(Etn, request, "Period")%></label>
        <select class="form-control" id="period" name="period" onchange="loadOrders(1, false);">
            <option <%=(timePeriod.equals("all")?"selected":"")%> value="all"><%=libelle_msg(Etn, request, "All")%></option>
            <option <%=(timePeriod.equals("1")?"selected":"")%> value="1"><%=libelle_msg(Etn, request, "1 Month")%></option>
            <option <%=(timePeriod.equals("3")?"selected":"")%> value="3"><%=libelle_msg(Etn, request, "3 Months")%></option>
            <option <%=(timePeriod.equals("6")?"selected":"")%> value="6"><%=libelle_msg(Etn, request, "6 Months")%></option>
            <option <%=(timePeriod.equals("12")?"selected":"")%> value="12"><%=libelle_msg(Etn, request, "1 Year")%></option>
          </select>
      </div>
      <div class="form-group col-2" >
        <label for="status"><%=libelle_msg(Etn, request, "Status")%></label>
        <select class="form-control" id="status" name="status" onchange="loadOrders(1, false);">
            <option <%=(status.equals("all")?"selected":"")%> value="all"><%=libelle_msg(Etn, request, "All")%></option>
            <option <%=(status.equals("open")?"selected":"")%> value="open"><%=libelle_msg(Etn, request, "Open")%></option>
            <option <%=(status.equals("completed")?"selected":"")%> value="completed"><%=libelle_msg(Etn, request, "Completed")%></option>
            <!--<option <%=(status.equals("cancelled")?"selected":"")%> value="cancelled"><%=libelle_msg(Etn, request, "Cancelled")%></option>-->
          </select>
      </div>
    </div>
</div>
      <div class="portal-cart">
        <ul class="orders pl-0" id="orders_container">
        <%

    String whereClause = "";
    if(nTimePeriod > 0) {
        whereClause += " AND o.tm > (DATE_SUB(CURDATE(), INTERVAL "+nTimePeriod+" MONTH))";
    }
    if(status.equals("open")){
        whereClause += " AND pw.status IN (0)";
    }
    else if(status.equals("completed")){
        whereClause += " AND pw.status IN (9)";
    }
    else{
        whereClause += " AND pw.status IN (0,9)";
    }

    Set rsu = Etn.execute("Select oi.*, p.product_type, o.orderRef, o.creationdate, o.id as client_key, pv.id as variant_id from "+GlobalParm.getParm("SHOP_DB")+".orders o inner join "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".order_items oi on o.parent_uuid=oi.parent_id inner join "+GlobalParm.getParm("CATALOG_DB")+".product_variants pv on pv.id=oi.product_ref inner join "+GlobalParm.getParm("CATALOG_DB")+".products p on pv.product_id = p.id inner join "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".post_work pw on o.id=pw.client_key "+whereClause+" and pw.is_generic_form=0 where o.client_id = " + escape.cote(client_id));
    //System.out.println("Select oi.*, p.image_name, o.orderRef, o.creationdate, oi.service_start_time+(oi.service_duration*oi.quantity) as service_end_time from "+GlobalParm.getParm("SHOP_DB")+".orders o inner join "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".order_items oi on o.parent_uuid=oi.parent_id inner join "+GlobalParm.getParm("CATALOG_DB")+".products p on p.product_uuid=oi.product_ref inner join "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".post_work pw on oi.id=pw.client_key "+whereClause+" and pw.is_generic_form=0 where o.client_id = " + escape.cote(client_id));
    int total_orders = rsu.rs.Rows;
    int page_size = 10;
    int total_pages = total_orders/page_size;
    if(total_orders%page_size!=0) total_pages++;
    out.write("<input id='total_pages' type='hidden' value='"+total_pages+"' />");
    String query;
    rsu = Etn.execute(query = "Select oi.*, p.product_type, p.id as product_id, pv.id as variant_id, o.orderRef, o.creationdate, pw.id as post_work_id, pw.status, pw.proces, pw.phase, IF(COALESCE(ph.displayName"+langue_id+",'')<>'',ph.displayName"+langue_id+",ph.displayName) as phaseDisplayName from "+GlobalParm.getParm("SHOP_DB")+".orders o inner join "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".order_items oi on o.parent_uuid=oi.parent_id inner join "+GlobalParm.getParm("CATALOG_DB")+".product_variants pv on pv.id=oi.product_ref inner join "+GlobalParm.getParm("CATALOG_DB")+".products p on pv.product_id = p.id inner join "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".post_work pw on o.id=pw.client_key "+whereClause+" and pw.is_generic_form=0 inner join "+GlobalParm.getParm("SHOP_DB")+".phases ph on pw.proces = ph.process and pw.phase = ph.phase where o.client_id = " + escape.cote(client_id)+" order by oi.id desc limit "+(num-1)*page_size+","+page_size);
    //System.out.println(query);
    while(rsu.next()){
        if(rsu.value("product_type").equals("offer_postpaid")||rsu.value("product_type").equals("offer_prepaid")){
            query = " select image_file_name as path, image_label as label from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_images where product_id = " + escape.cote(rsu.value("product_id")) + " and langue_id = " + escape.cote(langue_id) + " order by sort_order limit 1; ";
        }
        else{
            query = "select * from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_variant_resources where type='image' and product_variant_id="+escape.cote(rsu.value("variant_id"))+" and langue_id="+escape.cote(langue_id)+" order by sort_order limit 1";
        } 
        System.out.println(query);
        String imagePathPrefix = GlobalParm.getParm("PAGES_UPLOAD_DIRECTORY") + "img/4x3/";
        String imageUrlPrefix = GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL");
        if("1".equals(GlobalParm.getParm("IS_PRODUCTION_ENV")))
        {
                imageUrlPrefix = cachedResourcesFolder;
        }
        imageUrlPrefix = imageUrlPrefix + "img/4x3/";
        Set rsVariantImage = Etn.execute(query);
        String variantImagePath = "";
        String variantImageAlt = "";
        if(rsVariantImage.next()){                    
            String imageName = rsVariantImage.value("path");
            String imagePath = imagePathPrefix + imageName;
            String imageUrl = imageUrlPrefix + imageName;
            String _version = getImageUrlVersion(imagePath);
            variantImagePath = imageUrlPrefix+imageName+_version;
            variantImageAlt = rsVariantImage.value("label");
        }
        
        boolean allowCancel = false;
        boolean customerCancel = false;
        Set rsCancel = Etn.execute("select * from "+GlobalParm.getParm("SHOP_DB")+".rules where next_phase='CancelAppointment' and start_proc="+escape.cote(rsu.value("proces"))+" and start_phase="+escape.cote(rsu.value("phase")));
        if(rsCancel.next()) allowCancel = true;
        Set rsCustomerCancel = Etn.execute("select * from "+GlobalParm.getParm("SHOP_DB")+".post_work where operador='portal' and nextid=(select id from "+GlobalParm.getParm("SHOP_DB")+".post_work where client_key = "+escape.cote(rsu.value("client_key"))+" and phase = 'CancelAppointment')");
        if(rsCustomerCancel.next()) customerCancel = true;
        String id = rsu.value("id");
        int rating = parseNullInt(rsu.value("product_rating"));
    %>
     <li class="order" style="position: relative;border-bottom: 2px solid gray;margin-bottom: 15px;padding-bottom: 15px;overflow: hidden;clear: both;">
        <div class="product-details col-sm-1 col-4 col-md-2  clearfix" style="padding-left: 0;">
          <div class="product-thumb" style="width: 112px;height: 148px;display: inline-block;">
            <a style="height: 100%;">
              <img src="<%=variantImagePath%>" alt="<%=variantImageAlt%>" style="max-width:180px !important; width:100% !important;height:auto;">
            </a></div>
          </div>
          <div class="order-details col-sm-10 col-8 col-md-8" style="padding-right: 0">
           <div class="product-information" style="overflow: hidden;">
            <p class="product-name mb-0" style="font-size:1.5em"><strong><%=rsu.value("product_name")%></strong>
            </p>
            <small><span style="color:gray;"><%=libelle_msg(Etn, request, "Order Date")%>:</span> <%=rsu.value("creationdate")%></small> | <small><span style="color:gray;"><%=libelle_msg(Etn, request, "Order Ref")%>:</span> <%=rsu.value("orderRef")%></small> | <small><span style="color:gray;<%=(rsu.value("status").equals("9")?"":"display:none;")%>"><%=libelle_msg(Etn, request, "Phase")%>:</span><%=rsu.value("phaseDisplayName")%></small> |

            <small class="ratings ratings_<%=id%>">
                <span class="star <%=(rating>=1?"full":"")%>" data-toggle="tooltip" data-placement="top" title="<%=libelle_msg(Etn, request, "Poor")%>" onclick="saveRatings(<%=id%>,1, true)" onmouseover="highlightRatings(<%=id%>,1, true)" onmouseout="highlightRatings(<%=id%>,1, false)"></span><span class="star <%=(rating>=2?"full":"")%>" data-toggle="tooltip" data-placement="top" title="<%=libelle_msg(Etn, request, "Fair")%>" onclick="saveRatings(<%=id%>,2, true)" onmouseover="highlightRatings(<%=id%>,2, true)" onmouseout="highlightRatings(<%=id%>,2, false)"></span><span class="star <%=(rating>=3?"full":"")%>" data-toggle="tooltip" data-placement="top" title="<%=libelle_msg(Etn, request, "Good")%>" onclick="saveRatings(<%=id%>,3, true)" onmouseover="highlightRatings(<%=id%>,3, true)" onmouseout="highlightRatings(<%=id%>,3, false)"></span><span class="star <%=(rating>=4?"full":"")%>" data-toggle="tooltip" data-placement="top" title="<%=libelle_msg(Etn, request, "Very Good")%>" onclick="saveRatings(<%=id%>,4, true)" onmouseover="highlightRatings(<%=id%>,4, true)" onmouseout="highlightRatings(<%=id%>,4, false)"></span><span class="star <%=(rating>=5?"full":"")%>" data-toggle="tooltip" data-placement="top" title="<%=libelle_msg(Etn, request, "Excellent")%>" onclick="saveRatings(<%=id%>,5, true)" onmouseover="highlightRatings(<%=id%>,5, true)" onmouseout="highlightRatings(<%=id%>,5, false)"></span>
            </small>
              <!-- <div style="margin-bottom: 30px;"></div> -->
              <%
              if(rsu.value("product_type").equals("service")){
              %>
              <div class="row border-bottom py-2">
                <div class="col-12 col-sm-4" style="">
                 <span style="color:gray;"><%=libelle_msg(Etn, request, "Start Time")%></span> :
                 <span class=""> <%=getTime(rsu.value("service_start_time"))%></span>
               </div>
               <div class="col-12 col-sm-4" style="">
                 <span style="color:gray;"><%=libelle_msg(Etn, request, "End Time")%></span> :
                 <span class=""> <%=getTime(rsu.value("service_end_time"))%></span>
               </div>
               <div class="col-12 col-sm-4" style="">
                 <span style="color:gray;"><%=libelle_msg(Etn, request, "Date")%></span> :
                 <span class=""> <%=rsu.value("service_date")%></span>
               </div>
              </div>
              <%}%>
              <%=formatJson(rsu.value("attributes"))%>
             <div class="row py-2">
                <div class="col-12 col-sm-4" style="">
                 <strong style="color:gray;"><%=libelle_msg(Etn, request, "Price")%></strong> :
                 <strong class=""> <%=rsu.value("price")%></strong>
               </div>
               <div class="col-12 col-sm-4" style="">
                 <strong style="color:gray;"><%=libelle_msg(Etn, request, "Quantity")%></strong> :
                 <strong class=""> <%=rsu.value("quantity")%></strong>
               </div>
             </div>
              <%
              if(customerCancel&&false){
              %>
             <div class="row border-bottom py-2">
                <div class="col-12 col-sm-12" style="">
                    <%=libelle_msg(Etn, request, "Commande/demande annulée")%>
               </div>
             </div>
              <%}
              if(false){
              %>
             <div class="row py-2">
                 <div class="col-12 col-sm-4" style=""></div><div class="col-12 col-sm-4" style=""></div><div class="col-12 col-sm-4" style="">
                    <button id="cancelOrder" onclick="cancelOrder('<%=rsu.value("id")%>', '<%=rsu.value("proces")%>', '<%=rsu.value("phase")%>', '<%=rsCancel.value("next_proc")%>', '<%=rsCancel.value("next_phase")%>', '<%=rsu.value("post_work_id")%>', '<%=rsCancel.value("errCode")%>')" class="btn black color-white pull-right <%=(allowCancel?"":"disabled")%>" <%=(allowCancel?"":"disabled")%>><%=libelle_msg(Etn, request, "Cancel")%></button>
               </div>
             </div>
              <%}%>

          </div>
        </div>
        <%
        if(rsu.value("status").equals("9") && rsu.value("complaint").equals("")){ //  && !rsu.value("phase").equalsIgnoreCase("cancel") && !rsu.value("phase").equalsIgnoreCase("cancel30") && !rsu.value("phase").equalsIgnoreCase("complaints")
        %>
        <a href="#" class="col-sm-12 complaint-link" ><small><%=libelle_msg(Etn, request, "Complaint")%></small></a>
        <div id="complaint_container<%=id%>" class="complaint-form col-sm-12">
          <hr>
          <form action="" method="POST" role="form">

            <div class="form-group">
              <label for="complaint<%=id%>"><%=libelle_msg(Etn, request, "Describe your complaint")%></label>
              <textarea id="complaint<%=id%>" cols="30" rows="10" class="form-control" style="resize:none;margin-bottom: 15px;" placeholder="<%=libelle_msg(Etn, request, "Describe your complaint here")%>..."></textarea>
            </div>
            <button type="button" class="btn black color-white pull-right" style="margin-left: 15px;" onclick="submitComplaint(<%=id%>)" ><%=libelle_msg(Etn, request, "Submit Complaint")%></button>
            <button type="button" class="btn pull-right btn-cancel" onclick="$('#complaint_container<%=id%>').hide('slow');" ><%=libelle_msg(Etn, request, "Cancel")%></button>
          </form>
        </div>
        <%}%>
    </li>
    <%}%>
      </ul>
    </div>
   

    <nav role="navigation" aria-label="Pagination example with icons">
      <ul id='pagination_container' class="pagination">
        <li class="page-item">
          <a class="page-link" href="#" aria-label="Previous">
            <span class="sr-only">Previous</span>
          </a>
        </li>
        <li class="page-item"><a class="page-link" href="#">1</a></li>
        <li class="page-item"><a class="page-link" href="#">2</a></li>
        <li class="page-item"><a class="page-link" href="#">3</a></li>
        <li class="page-item">
          <a class="page-link" href="#" aria-label="Next">
            <span class="sr-only">Next</span>
          </a>
        </li>
      </ul>
    </nav>
         <div id="scheduleDialog" style="visibility: hidden;height: 10px;width: 10px;">
        <div class="col-sm-12" style="background: #d6d6d6; padding: 4px;overflow:hidden">
          <div class="pull-right">
            <button type="button" class="close"  aria-label="<%=libelle_msg(Etn, request, "Close")%>"><span aria-hidden="true">&times;</span></button>
          </div>
        </div>
        <div style="margin-top: 1%;" id='calendar'></div>
  </div>
<!--         <div id="scheduleDialog"><div style="margin-top: 1%;" id='calendar'></div></div>-->
  </div>
</div>
</div>

<%=_footerHtml%>

<%=_endscriptshtml%>
</body>
<script>
    var currentOrdersPage=<%=num%>;
    var totalPages = 0;
    $(document).ready(function(){
         $('[data-toggle="tooltip"]').tooltip();
         // $('[data-toggle="tooltip"]').tooltip('show');
        loadPagination();
        $('a.o-complaint-link').click(function(e){
          e.preventDefault();
          $(this).next('.complaint-form').toggle('fast');
        });
        $('.complaint-form .o-btn-cancel').click(function(){
          $(this).parent('.complaint-form').hide('fast');
        })
//        $('#openSchedule').click(function(){
//            var btnPosition = $(this).offset();
//            var calendarHalf = $('#scheduleDialog').outerHeight()/2;
//            var verticalCenter =  btnPosition.top - calendarHalf ;
//            $('#scheduleDialog').css({'top':verticalCenter}).show('fast');
//        });
//
//        initializeCalendar();
//        $('#scheduleDialog').removeAttr('style').hide().css({'position':'absolute','top':0,'left':0,'width':'100%','z-index':99999,'background':'white'});
//        $('#scheduleDialog button.o-close').click(function(){
//            $('#scheduleDialog').hide('fast');
//        });
    });

    function submitComplaint(id){
        var complaint = $("#complaint"+id).val();
        if(complaint==""){
            alert("<%=libelle_msg(Etn, request, "Please enter your complaint!")%>");
            return;
        }
        jQuery.ajax({
            url : '<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>pages/calls/saveComplaint.jsp',
            type: 'POST',
            data: {
                id: id,
                complaint: complaint
            },
            success : function(data)
            {
                alert(data);
                loadOrders(currentOrdersPage, false);
            }
        });
    }

    function saveRatings(id, rating, save){
        if(save){
            jQuery.ajax({
                url : '<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>pages/calls/saveRatings.jsp',
                type: 'POST',
                data: {
                    id: id,
                    rating: rating
                },
                success : function(data)
                {

                }
            });
        }
        var counter = 0;
        $('.ratings_'+id).children('span').each(function () {
            counter++;
            if(rating>=counter) $(this).addClass("full");
            else $(this).removeClass("full");
             // "this" is the current element in the loop
        });
    }

    function highlightRatings(id, rating, hover){
        var counter = 0;
        $('.ratings_'+id).children('span').each(function () {
            counter++;
            if(rating>=counter && hover) $(this).addClass("highlight");
            else $(this).removeClass("highlight");
             // "this" is the current element in the loop
        });
    }

    function loadOrders(num, next_prev){
        if(next_prev&&(num<1||num>totalPages)) return;
        $('<form method="POST" action="myorders.jsp?muid=<%=___muuid%>"><input type="hidden" name="num" value="'+num+'" ><input type="hidden" name="period" value="'+$("#period").val()+'" ><input type="hidden" name="status" value="'+$("#status").val()+'" ></form>').appendTo('body').submit();
    }

    function loadPagination(){
        totalPages = parseInt($("#total_pages").val());
        if(totalPages<1) $("#pagination_container").hide();
        else $("#pagination_container").show();
        var html="<li id='prevOrdersPage' class='page-item'><a class='page-link' href='javascript:loadOrders(currentOrdersPage-1, true)' aria-label='Previous'><span aria-hidden='true'></span></a></li>";
        for(var i = 1; i<=totalPages; i++){
            html+="<li id='ordersPagination"+i+"' class='ordersPagination page-item'><a class='page-link' href='javascript:loadOrders("+i+", false)'>"+i+"</a></li>";
        }
        html+="<li id='nextOrdersPage' class='page-item'><a class='page-link' href='javascript:loadOrders(currentOrdersPage+1, true)' aria-label='Next'><span aria-hidden='true'></span></a></li>";
        $("#pagination_container").html(html);


        if(<%=num%>==1) $("#prevOrdersPage").addClass("disabled");
        else $("#prevOrdersPage").removeClass("disabled");

        if(<%=num%>>=totalPages) $("#nextOrdersPage").addClass("disabled");
        else $("#nextOrdersPage").removeClass("disabled");
        $(".ordersPagination").removeClass("active");
        $(".ordersPagination").removeClass("active");
        $("#ordersPagination<%=num%>").addClass("active");
        $("#ordersPagination<%=num%>").addClass("active");
    }

//    function initializeCalendar(){
//        jQuery('#calendar').fullCalendar({
//            header: {
//                left: '',
//                center: 'title',
//                right: 'prev,next'
//            },
//            buttonText: {
//                prev: 'Prev',
//                next: 'Next'
//            },
//            defaultView: 'agendaWeek',
//            allDaySlot: false,
//            slotDuration: '01:00:00',
//            height: 'auto',
//            selectable: true,
//            events: { // ajax call to populate the data from db
//                url: '<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>pages/calls/getSchedule.jsp',
//                type: 'POST',
//                data: {
//                    min_time: 0,
//                    max_time: 1440
//                },
//                error: function() {
//                    alert('there was an error while fetching events!');
//                }
//            },
//            eventClick: function(calEvent, jsEvent, view) {
//                /*calEvent.title = "TEST";
//                $('#calendar').fullCalendar('updateEvent', calEvent);*/
//
//                // change the border color just for fun
//                //$(this).css('border-color', 'red');
//            }
//        });
//    }

    function cancelOrder(customerId, process, currentPhase, nextProcess, nextPhase, post_work_id, _errCode ){ // should be moved to shop.
        if(!confirm("Are you sure you want to cancel this order?")) return;
        jQuery.ajax({
            url : '<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>pages/calls/cancelOrder.jsp',
            type: 'POST',
            dataType: 'json',
            data: {
                customerId: customerId,
                process: process,
                oldPhase: currentPhase,
                nextProcess: nextProcess,
                nextPhase: nextPhase,
                post_work_id: post_work_id,
                errCode: _errCode
            },
            success : function(data)
            {
                //alert(data.response);
                if(data.response=='success'){
                    alert("Order Cancelled");
                    loadOrders(1, false);
                }
                else{
                    alert("Some error Occured");
                }
            }
        });
    }
</script>
</html>
