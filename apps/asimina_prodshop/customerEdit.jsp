<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.asimina.util.UIHelper,org.apache.tika.*"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="java.io.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.util.regex.*"%>
<%@ page import="com.etn.asimina.util.PriceFormatter"%>
<%@ page import="com.etn.beans.app.GlobalParm"%>
<%@ page import="org.json.*, java.math.BigDecimal"%>
<%@ include file="common2.jsp" %>

<%!
final static int UC16Latin1ToAscii7[] = {
'A','A','A','A','A','A','A','C',
'E','E','E','E','I','I','I','I',
'D','N','O','O','O','O','O','X',
'0','U','U','U','U','Y','S','Y',
'a','a','a','a','a','a','a','c',
'e','e','e','e','i','i','i','i',
'o','n','o','o','o','o','o','/',
'0','u','u','u','u','y','s','y' };

int  toAscii7( int c )
{ if( c < 0xc0 || c > 0xff )
     return(c);
  return( UC16Latin1ToAscii7[ c - 0xc0 ] );
}

String ascii7( String  s )
{
  char c[] = s.toCharArray();
  for( int i = 0 ; i < c.length ; i++ )
   if( c[i] >= 0xc0 && c[i] < 256 ) c[i] = (char)toAscii7( c[i] );
  return( new String( c ) );
}

int compAscii7( String a , String b )
{ if( a==null) return( b==null?0:1);
  if( b == null ) return(-1);
  return(  ascii7(a).compareTo( ascii7(b) ) );
}

boolean equals7( String a , String b )
{ return( compAscii7( a ,b ) == 0 ); }

String round( double f , int p )
{
    String k = ""+f ;
    String r;
    int i = k.indexOf('.');
    if( i == -1 ) return( k );
    r = k.substring(0,i+1);
    for (int j = i+1 ; p > 0 &&  j < k.length()  ; j++ , p--)
       r += k.charAt(j);

    return(r);

}

String getSlotDisplay(String startHour, String startMin, String endHour, String endMin)
{
	if(startHour.length() < 2) startHour = "0"+startHour;
	if(startMin.length() < 2) startMin = "0"+startMin;
	if(endHour.length() < 2) endHour = "0"+endHour;
	if(endMin.length() < 2) endMin = "0"+endMin;
	
	return startHour+"H"+startMin+" - "+endHour+"H"+endMin;
}

    String addSelectControl(String id, String name, Map<String,String> map, String selectedItem, boolean isSelectedId, String events)
    {
    		// Let's allow inclusion of JavaScript events
			if (events == null) events = "";
            String html = "<select name='" + name + "' id='" + id + "' "+ events + ">";

            if (map == null) return "Map " + name + " is null!";
            if (map.isEmpty()) return "Map " + name + " is empty!";

            for(String key : map.keySet())
            {
                    String val = map.get(key);
                    if (ascii7(key).equalsIgnoreCase(ascii7(selectedItem)) && isSelectedId)
                        html = html + "<option value='" + key + "' SELECTED>"+val+"</option>";
					else if(!isSelectedId && ascii7(val).equalsIgnoreCase(ascii7(selectedItem)))
                        html = html + "<option value='" + key + "' SELECTED>"+val+"</option>";
                    else
                        html = html + "<option value='" + key + "'>"+val+"</option>";

            }
            html = html + "</select>";
           //debug html = html + "<b>"+"select name='" +selectedItem+ map +"' "+"</b>";
            return html;
    }

    Map<String, String> getResourcesMap(String listresources)
    {

	Map<String, String> resourceMap = new HashMap<String, String>();

	String[] token = parseNull(listresources).split(",");
	for(int i=0; i < token.length; i++)
	{
		resourceMap.put(token[i],token[i]);
	}
	return resourceMap;
    }

    Map<String, String> getHashMap(Set resultSet)
    {

		Map<String, String> hashMap = new HashMap<String, String>();

		while(resultSet.next()){

			hashMap.put(parseNull(resultSet.value(0)),parseNull(resultSet.value(1)));
		}
		return hashMap;
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

	boolean isFrequencyApplicable(String productType, String productVersion)
	{
		//frequency is only applicable for these type of products but in database all products have a default value set so we must use it accordingly
		if("offer_postpaid".equals(productType)) 
		{
			return true;
		}
		if(parseNull(productVersion).length() > 0 && "V1".equals(productVersion) == false)
		{
			return true;
		}
		
		return false;
	}

	boolean hasFrequency(String productType, String frequency, String productVersion)
	{
		//for v1 products we always assume price given for product has a frequency attached to it so we must return true for old products
		if("offer_postpaid".equals(productType))
		{
			return true;
		}
		//frequency is only applicable for these type of products but in database all products have a default value set so we must use it accordingly
		if(isFrequencyApplicable(productType, productVersion) && parseNull(frequency).length() > 0)
		{
			return true;
		}
		
		return false;
	}

%>

<%!


	//following functions generate html for fields according to if they are editable or readonly.
	//Incase of some field types like checkbox, select, radio we cannot make them readonly.
	//we need to make them disabled. Disabled means their values will not be posted which is an issue.
	//To fix this, we add hidden field instead with the given name and on front end the field is disabled.
	//For group of checkboxes/radio buttons, there will always be 1 hidden field having the value set in it.
	//So to keep track if a hidden field is already added with the given name, we maintain a list in the calling jsp. It should be of type List<String>

	String generateFieldHtml (List<String> editableFields, List<String> mandatoryFields, String userProfile, String profileColor, String fieldName, String fieldId, String fieldValue, String fieldType, String events, String maxlengthOrRows, String sizeOrCols, String styles, Map<String, String> values)
	{
		return generateFieldHtml (editableFields, mandatoryFields, userProfile, profileColor, fieldName, fieldId, fieldValue, fieldType, events, maxlengthOrRows, sizeOrCols, styles, values, null);
	}
	String generateFieldHtml (List<String> editableFields, List<String> mandatoryFields, String userProfile, String profileColor, String fieldName, String fieldId, String fieldValue, String fieldType, String events, String maxlengthOrRows, String sizeOrCols, String styles, Map<String, String> values, List<String> hiddenFieldsAdded)
	{
		String html = "";
		boolean isReadonly = true;

		if(editableFields != null && editableFields.contains(fieldName)) isReadonly = false;
		//if(userProfile.equals("ADMIN") || userProfile.startsWith("SUPER_ADMIN")) isReadonly = false;
		if(events == null) events = "";
		if(styles == null) styles = "";

		if(isReadonly)
		{
			profileColor = "#bcbcbc";
			styles = "color: gray; " + styles;
		}
		if(fieldType.equalsIgnoreCase("text"))
		{
			if(profileColor != null && !profileColor.equals("")) styles = "border:1px solid "+profileColor+"; " + styles;
			html = "<input class='form-control' type='text' name='"+UIHelper.escapeCoteValue(fieldName)+"' ";
			if(fieldId != null && !fieldId.equals("")) html += " id='"+fieldId+"' ";
			if(maxlengthOrRows != null && !maxlengthOrRows.equals("")) html += " maxlength='"+maxlengthOrRows+"' ";
			if(sizeOrCols != null && !sizeOrCols.equals("")) html += " size='"+sizeOrCols+"' ";		
			if(fieldValue != null && !fieldValue.equals("")) html += " value='"+UIHelper.escapeCoteValue(fieldValue)+"' title='"+UIHelper.escapeCoteValue(fieldValue)+"' ";
			html += events;
			if(isReadonly) html += " readonly ";
			if(!styles.equals("")) html += " style='"+styles+"' ";
			html += " />";
		}
		else if(fieldType.equalsIgnoreCase("textarea"))
		{
			if(profileColor != null && !profileColor.equals("")) styles = "border:1px solid "+profileColor+"; " + styles;
			html = "<textarea class='form-control' name='"+UIHelper.escapeCoteValue(fieldName)+"' ";
			if(fieldId != null && !fieldId.equals("")) html += " id='"+fieldId+"' ";
			if(maxlengthOrRows != null && !maxlengthOrRows.equals("")) html += " rows='"+maxlengthOrRows+"' ";
			if(sizeOrCols != null && !sizeOrCols.equals("")) html += " cols='"+sizeOrCols+"' ";
			html += events;
			if(!styles.equals("")) html += " style='"+styles+"' ";
			if(isReadonly) html += " readonly ";
			html += ">";
			if(fieldValue != null && !fieldValue.equals("")) html += UIHelper.escapeCoteValue(fieldValue);
			html += "</textarea>";
		}
		else if(fieldType.equalsIgnoreCase("radio"))
		{
			if(!isReadonly && profileColor != null && !profileColor.equals("")) styles = "border:1px solid "+profileColor+"; " + styles;
			for(String key : values.keySet())
			{
				if(isReadonly)
				{
					if(!hiddenFieldsAdded.contains(fieldName))
					{
						html += "<input type='hidden' name='"+UIHelper.escapeCoteValue(fieldName)+"' value='"+UIHelper.escapeCoteValue(fieldValue)+"'/>";
						hiddenFieldsAdded.add(fieldName);
					}
					html += "<input type='radio' ";
				}
				else html += "<input type='radio' name='"+UIHelper.escapeCoteValue(fieldName)+"' ";
				if(fieldId != null && !fieldId.equals("")) html += " id='"+fieldId+"' ";
				html += events;
				if(!styles.equals("")) html += " style='"+styles+"' ";
				html += " value='"+UIHelper.escapeCoteValue(key)+"' ";
				if(fieldValue != null && fieldValue.equals(key)) html += " checked ";
				if(isReadonly) html += " disabled ";
				html += "/> ";
				html += values.get(key) + "&nbsp;";
			}
		}
		else if(fieldType.equalsIgnoreCase("checkbox"))
		{
			if(!isReadonly && profileColor != null && !profileColor.equals("")) styles = "border:1px solid "+profileColor+"; " + styles;
			for(String key : values.keySet())
			{
				if(isReadonly)
				{
					if(!hiddenFieldsAdded.contains(fieldName))
					{
						html += "<input type='hidden' name='"+UIHelper.escapeCoteValue(fieldName)+"' value='"+UIHelper.escapeCoteValue(fieldValue)+"'/>";
						hiddenFieldsAdded.add(fieldName);
					}
					html += "<input type='checkbox' ";
				}
				else html += "<input type='checkbox' name='"+UIHelper.escapeCoteValue(fieldName)+"' ";
				if(fieldId != null && !fieldId.equals("")) html += " id='"+fieldId+"_"+key+"' ";
				html += events;
				if(!styles.equals("")) html += " style='"+styles+"' ";
				html += " value='"+UIHelper.escapeCoteValue(key)+"' ";
				if(fieldValue != null && fieldValue.equals(key)) html += " checked ";
				if(isReadonly) html += " disabled ";
				html += "/>";
				html += values.get(key) + "&nbsp;";

			}
		}
		else if(fieldType.equalsIgnoreCase("select"))
		{
			//select field does not show border in IE so we will add a div on top of it
			String divStyle = "";
			if(profileColor != null && !profileColor.equals("")) divStyle = "border:1px solid "+profileColor;
			if(isReadonly)
			{
				html = "<input class='form-control' type='hidden' name='"+UIHelper.escapeCoteValue(fieldName)+"' value='"+UIHelper.escapeCoteValue(fieldValue)+"' />";
				html += "<select class='form-control' disabled";
				if(!styles.equals("")) html += " style='"+styles+"' ";
				html += ">";
				html += "<option value=''>---select---</option>";
				for(String key : values.keySet())
				{
					String val = values.get(key);
					if (ascii7(key).equalsIgnoreCase(ascii7(fieldValue))) html += "<option selected value='"+UIHelper.escapeCoteValue(key)+"'>"+UIHelper.escapeCoteValue(val)+"</option>";
					else html += "<option value='"+UIHelper.escapeCoteValue(key)+"'>"+UIHelper.escapeCoteValue(val)+"</option>";
				}
				html += "</select>";
			}
			else
			{
				if(!divStyle.equals("")) html = "<div style='"+divStyle+"; float:left; ' >";
				html += "<select class='form-control' name='"+UIHelper.escapeCoteValue(fieldName)+"' "+events;
				if(!styles.equals("")) html += " style='"+styles+"' ";
				if(fieldId != null && !fieldId.equals("")) html += " id='"+fieldId+"' ";
				html += ">";
				html += "<option value=''>---select---</option>";
				for(String key : values.keySet())
				{
					String val = values.get(key);
					if (ascii7(key).equalsIgnoreCase(ascii7(fieldValue))) html += "<option selected value='"+UIHelper.escapeCoteValue(key)+"'>"+UIHelper.escapeCoteValue(val)+"</option>";
					else html += "<option value='"+key+"'>"+val+"</option>";
				}
				html += "</select>";
				if(!divStyle.equals("")) html += "</div>";
			}
		}

		return html;
	}


%>

<%
	Etn.setSeparateur(2, '\001', '\002');
    String orderId="";
		
	String customerid = parseNull(request.getParameter("customerId"));
	if(customerid.length() == 0)
	{
		String parentUuid = request.getParameter("parentUuid");
		Set rsCustomer = Etn.execute("select customerid from customer where parent_uuid="+escape.cote(parentUuid));
		rsCustomer.next();
		customerid = parseNull(rsCustomer.value("customerid"));		
	}

    String post_work_id = null;//request.getParameter("post_work_id");
    Set _rs1 = null;
    if( customerid.length() > 0 )
	{
        _rs1 = Etn.execute("select orderid from customer where customerid="+escape.cote(customerid));
        if( post_work_id == null ){
            Set rsPw = Etn.execute("select p.id from customer c inner join "+
                "post_work p on p.client_key = c.customerid and p.is_generic_form = 0 and p.status in ('0','9') where c.customerid="+escape.cote(customerid));
            if(rsPw.next()) post_work_id = rsPw.value(0);
        }
    }

    if( _rs1 != null && _rs1.next() && _rs1.value(0).length() > 0 ) orderId= _rs1.value(0);

    String calendarPhase = parseNull(request.getParameter("calendarPhase"));
    String identidad = request.getParameter("identidad");
    String d1 = request.getParameter("d1");
    String d2 = request.getParameter("d2");
    String code = request.getParameter("code");
    String estadoP = request.getParameter("estadoP");
    String tipoP = request.getParameter("tipoP");
    String numP = request.getParameter("numP");
    String p = request.getParameter("p")+"";
    String message = parseNull(request.getParameter("message"));
    if (p.equals("undefined") || p.equals("")) {
        p = "0";
    }
    String unlockOrder = request.getParameter("unlockOrder");

    String fromDialog = request.getParameter("fromDialog");
    String isAdmin = request.getParameter("isAdmin");
	if(fromDialog == null || fromDialog.equals("")) fromDialog = "false";
	if(isAdmin == null || isAdmin.equals("")) isAdmin = "false";

	List<String> hiddenFields = new ArrayList<String>();
	List<String> editableFields = new ArrayList<String>();
	List<String> mandatoryFields = new ArrayList<String>();

	java.util.Calendar c = java.util.Calendar.getInstance();
	int nYear = c.get(java.util.Calendar.YEAR);
	HashMap<String, String> years = new LinkedHashMap<String, String>();
	years.put("","--");
	for(int i=nYear-12; i<nYear+20;i++)
	{
		String y = ""+(i-2000);
		if(y.length() < 2) y = "0" + y;
		years.put(y,y);
	}


	Set rsUser = Etn.execute("select u.*, pb.phases as bannedPhases, p.profil from login u, profil p left join profil_banned_phases pb on pb.profil_id = p.profil_id and pb.site_id = "+escape.cote(parseNull((String)session.getAttribute("SELECTED_SITE_ID")))+
						", profilperson pp where u.pid = pp.person_id and pp.profil_id = p.profil_id and u.pid = "+escape.cote(""+Etn.getId())+" ");
	rsUser.next();
        String userProfile = rsUser.value("profil");
	Map<String, List<String>> bannedPhases = new HashMap<String, List<String>>();

	Set rsUiPref = Etn.execute("select * from uipreferences where user = "+escape.cote((String)session.getAttribute("LOGIN"))+" and screen = 'customerEdit' ");
	HashMap<String, String> uipreferencesMap = new LinkedHashMap<String, String>();

	while(rsUiPref.next()){

		uipreferencesMap.put(rsUiPref.value("uiItem"), rsUiPref.value("value"));
	}

	String completeURL = request.getRequestURL().toString();
	String contextPath = request.getContextPath();

	int indexOf = completeURL.indexOf(contextPath);
	String hostUrl = completeURL.substring(0,indexOf);

	boolean alreadyCancelled = false;

	//in mariadb monday is 0 so we make that as standard
	//whereas in javascript sunday is 0 so we will handle it in javascript
	List<String> excludeDayNos = new ArrayList<>();
	excludeDayNos.add("0");//monday
	excludeDayNos.add("1");//
	excludeDayNos.add("2");
	excludeDayNos.add("3");
	excludeDayNos.add("4");
	excludeDayNos.add("5");
	excludeDayNos.add("6");//sunday
	
	List<String> localholidays = new ArrayList<>();
	Set rsH = Etn.execute("select date_format(h_date,'%d/%m/%Y') as h_date from "+GlobalParm.getParm("COMMONS_DB")+".local_holidays where h_date > date(now())");
	while(rsH.next())
	{
		localholidays.add(rsH.value("h_date"));
	}

    if (customerid != null)
    {
        Set rsOrder = Etn.execute("Select c.*, ph.displayName as phase, p.insertion_date as insertionDate from customer c inner join post_work p ON p.client_key = c.customerId AND p.status in ('0','9') inner join phases ph ON p.proces = ph.process AND p.phase = ph.phase where c.customerId = " + escape.cote(customerid) + " and p.id="+ escape.cote(post_work_id));
	 if(rsOrder.rs.Rows == 0)
	 {
%>
<script>
	window.location=window.location; //alert("The status of the order is already changed");
	//parent.refreshScreen();
</script>
<%
        }
        Set rsStatus = null;
		String siteid= "", lang="";
        if (rsOrder.next())
        {

            boolean isStatusFound = false;
            rsStatus = Etn.execute("SELECT DISTINCT p.id, p.proces, p.phase, p.priority, p.attempt, p.errMessage, p.errCode, p.insertion_date,"
                                        + " p.operador,p.client_key,p.flag,p.nextid, ph.displayName, p.status pw_status, ph.oprType, c.*"
                                        + " FROM post_work p, customer c, phases ph "
                                        + " WHERE p.client_key = c.customerId "
                                        + " AND p.status in ('0','9') "
                                        + " AND p.client_key=" + escape.cote(customerid)
                                        + " AND p.id=" + escape.cote(post_work_id)
                                        + " AND p.proces = ph.process "
                                        + " AND p.phase = ph.phase "
                                        + " GROUP BY(client_key)");
            if(rsStatus.next()) isStatusFound = true;

			siteid = parseNull(rsStatus.value("site_id"));
			lang = parseNull(rsStatus.value("lang"));

            boolean canReverse = false;
            Set rs3 = Etn.execute("select * from post_work where is_generic_form = 0 and nextid = "+escape.cote(post_work_id)+" ");
            if(rs3.rs.Rows > 0) canReverse = true;

            //String statusMotivoIdeupDetails = "";
            String statusMotivoIdeupId = "";

            boolean modif = false;

			String qry = "";
			Set rsMaps = null;


			boolean showCancelButton = true;
			Set rsPhase = Etn.execute("select count(0) as c from phases where process = "+escape.cote(rsStatus.value("proces"))+" and phase in ('Cancel','Cancel30') ");
			rsPhase.next();
			if(Integer.parseInt(rsPhase.value("c")) == 0) showCancelButton = false;


			String query = "select * from phases where phase = "+escape.cote(rsStatus.value("phase"))+" and process = "+escape.cote(rsStatus.value("proces"))+" ";
			rsPhase = Etn.execute(query);
			boolean showRulesButtons = false;
			if(rsPhase.next() && (rsPhase.value("rulesVisibleTo")).indexOf(userProfile) > -1) showRulesButtons = true;
			if(parseNull(rsPhase.value("oprType")).equals("T"))
			{
				showRulesButtons = false;
				showCancelButton = false;
			}

			if((userProfile).startsWith("SUPER_ADMIN") || (userProfile).equalsIgnoreCase("ADMIN")) showRulesButtons = true;
			Set rsRules = null;
			if(showRulesButtons)
			{
				query = "select distinct ph.phase,  ph.displayName, r.next_proc, r.next_phase, r.next_proc from rules r, phases ph where ph.oprType = 'O' and r.next_proc = ph.process and r.next_phase = ph.phase and start_phase = "+escape.cote(rsStatus.value("phase"))+" and start_proc = "+escape.cote(rsStatus.value("proces"))+" ";
				rsRules = Etn.execute(query);
			}

			String delvPostalCode = parseNull(rsStatus.value("dapostalCode"));
			String delvTitle = parseNull(rsStatus.value("datitle"));
			String delvFirstname = parseNull(rsStatus.value("dafirstname"));
			String delvLastname = parseNull(rsStatus.value("dalastname"));
			String delvAddrLine1 = parseNull(rsStatus.value("daline1"));
			String delvAddrLine2 = parseNull(rsStatus.value("daline2"));
			String delvTownCity = parseNull(rsStatus.value("datowncity"));
			String delvCountry = parseNull(rsStatus.value("dacountry"));

			StringTokenizer st = new StringTokenizer(parseNull(rsUser.value("bannedPhases")),",");
			while(st.hasMoreTokens())
			{
				StringTokenizer st2 = new StringTokenizer(st.nextToken(),":");
				String start_proc = st2.nextToken();
				String start_phase = st2.nextToken();
				String next_proc = st2.nextToken();
				String next_phase = st2.nextToken();
				if(start_proc.equals(rsStatus.value("proces")) && start_phase.equals(rsStatus.value("phase")))
				{
					List<String> list = bannedPhases.get(next_proc);
					if(list == null)
					{
						list = new ArrayList<String>();
					}
					if(!list.contains(next_phase)) list.add(next_phase);
					bannedPhases.put(next_proc, list);
				}
			}
		Set rsAccess = Etn.execute("select * from field_settings where screenName = 'CUSTOMER_EDIT' and process = "+escape.cote(rsStatus.value("proces"))+" and phase = "+escape.cote((calendarPhase.equals("assignresource")?calendarPhase:rsStatus.value("phase")))+" ");

		while(rsAccess.next())
		{
			//this is to make sure if any fields is marked as hidden, it should not be added as editable or mandatory. Although this is taken care of in fieldsettings screen but just to be on safe side
			if(Integer.parseInt(rsAccess.value("isHidden")) > 0) hiddenFields.add(rsAccess.value("fieldName"));
			else
			{
				if(Integer.parseInt(rsAccess.value("isEditable")) > 0) editableFields.add(rsAccess.value("fieldName"));


				if(Integer.parseInt(rsAccess.value("isMandatory")) > 0) mandatoryFields.add(rsAccess.value("fieldName"));

			}
		}

//		if(!editableFields.contains("msisdn_existente")) editableFields.add("msisdn_existente");

		if(rsStatus.value("phase").equalsIgnoreCase("Cancel") || rsStatus.value("phase").equalsIgnoreCase("Cancel30")) alreadyCancelled = true;
		
		JSONObject additionalOrderInfo = null;
		String deliveryDate = "";
		int deliveryDateWeekDay = 0;
		String deliveryStartSlotHour = "";
		String deliveryStartSlotMin = "";
		String deliveryEndSlotHour = "";
		String deliveryEndSlotMin = "";
		try {
			Set rsAddInfo = Etn.execute("Select additional_info, weekday(delivery_date) as week_day, date_format(delivery_date,'%d/%m/%Y') as delivery_date, delivery_start_hour, delivery_start_min, delivery_end_hour, delivery_end_min "+
				" from orders where id = "+escape.cote(customerid));
				System.out.println("Select additional_info, weekday(delivery_date) as week_day, date_format(delivery_date,'%d/%m/%Y') as delivery_date, delivery_start_hour, delivery_start_min, delivery_end_hour, delivery_end_min "+
				" from orders where id = "+escape.cote(customerid));
			if(rsAddInfo.next()) 
			{
				if(parseNull(rsAddInfo.value("additional_info")).length() > 0)
				{
					additionalOrderInfo = new JSONObject(parseNull(rsAddInfo.value("additional_info")));				
				}
				deliveryDate = parseNull(rsAddInfo.value("delivery_date"));
				deliveryDateWeekDay = parseNullInt(rsAddInfo.value("week_day"));
				deliveryStartSlotHour = parseNull(rsAddInfo.value("delivery_start_hour"));
				deliveryStartSlotMin = parseNull(rsAddInfo.value("delivery_start_min"));
				deliveryEndSlotHour = parseNull(rsAddInfo.value("delivery_end_hour"));
				deliveryEndSlotMin = parseNull(rsAddInfo.value("delivery_end_min"));
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
		
%>
<html>
<head>

<script>
	<% if(!isStatusFound) { %>
		window.location=window.location; //alert("Le statut de la commande est en cours de changement");
		//parent.refreshScreen();
		//self.close();
	<% } %>
	<% if(parseNull(request.getParameter("_refresh")).equals("1")) { %>
		<% if(parseNull(request.getParameter("message")).length() > 0) { %>
			alert("<%=UIHelper.escapeCoteValue(parseNull(request.getParameter("message")))%>");
		<% } %>
		//parent.refreshScreen();
	<% } %>
</script>

<!-- <link rel="stylesheet" type="text/css" href="css/general2.css"> -->

<style>
body {
	 /* padding-top: 70px; */
	 background-color: #fff !important;
	}
th { text-align:left; }

div.tab { height:16px; cursor:pointer; float:left; margin-left:3px; border-left: 1px solid <%=ORANGE%>; border-right: 1px solid <%=ORANGE%>; border-top: 1px solid <%=ORANGE%>; padding-left: 2px; padding-right:2px; color:white; font-weight:bold; background-color:<%=ORANGE%>}
div.selectedTab { height:16px; float:left; margin-left:3px; border-left: 1px solid <%=ORANGE%>; border-right: 1px solid <%=ORANGE%>; border-top: 1px solid <%=ORANGE%>; padding-left: 2px; padding-right:2px; color:white; font-weight:bold; background-color:#ffc602}
div.toolbarButton {padding-left:1px; margin-top:2px; margin-bottom:1px; cursor:pointer; background-color:<%=ORANGE%>; color:white; border-right:1px solid #bc3a00; border-bottom:1px solid #bc3a00}
a.tabLink {text-decoration:none; color:white;}
#tabs {height:16px; margin-top:10px;  border-bottom:1px solid <%=ORANGE%>}
div.tooltip {
	border:1px solid black;
	background:#fef9c3;
	padding-left:2px;
	padding-right:2px;
	z-index:999999;
	font-size:10px;
	position:absolute;
	white-space:nowrap;
	display:none;
}
.nav-tabs{
	border-bottom:none !important;
}
.nav.nav-tabs li a{
	padding:10px;
}
.navbar-toggle .icon-bar {
    background-color: #557cb7;
}
</style>
	<%-- <link href="css/jquery/jquery-ui-1.8.4.custom.css" rel="stylesheet" type="text/css" /> --%>
	<%-- <link rel="stylesheet" type="text/css" href="css/jquery-ui.css"> --%>
	<link href="<%=request.getContextPath()%>/css/coreui.css" rel="stylesheet">
	<link href="<%=request.getContextPath()%>/css/my.css" rel="stylesheet">
	<link href="<%=request.getContextPath()%>/css/coreui-icons.min.css" rel="stylesheet">
	<link href="<%=request.getContextPath()%>/css/font-awesome.min.css" rel="stylesheet">
	<link href="<%=request.getContextPath()%>/css/simple-line-icons.css" rel="stylesheet">
	<link href="<%=request.getContextPath()%>/css/moringa-cui.css" rel="stylesheet">
	
	<script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
	
	<script src="<%=request.getContextPath()%>/js2/common.js"></script>
	<script src="<%=request.getContextPath()%>/js/popper.min.js"></script>
	<script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>
	<script src="<%=request.getContextPath()%>/js/coreui.min.js"></script>
	<script src="<%=request.getContextPath()%>/js/feather.js"></script>
	<script src="<%=request.getContextPath()%>/js/moment.min.js"></script>
	<script src="<%=request.getContextPath()%>/js/feather.min.js?v=2.28.0"></script>
	
	<link href="<%=request.getContextPath()%>/css/flatpickr.min.css" rel="stylesheet">
	<script src="<%=request.getContextPath()%>/js/flatpickr.min.js"></script>

<SCRIPT LANGUAGE="JavaScript" SRC="js/common.js"></script>


	<SCRIPT src="js/draw2d/wz_jsgraphics.js"></SCRIPT>
	<SCRIPT src="js/draw2d/draw2d.js"></SCRIPT>

    <!-- undo/redo support (all times required too) -->
	<SCRIPT src="js/draw2d/mootools.js"></SCRIPT>
	<SCRIPT src="js/draw2d/moocanvas.js"></SCRIPT>
        <!--REGEXP_END_REMOVE-->

        <!-- example specific imports -->
	<SCRIPT src="js/draw2d/GizmoConnection.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoInputPort.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoOutputPort.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoFigure.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoWorkflow.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoResizeHandle.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoConnectionRouter.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoConnectionDecorator.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoConnectionSourceDecorator.js"></SCRIPT>
	


	<!--<link rel="stylesheet" type="text/css" href="css/colorpicker.css" />-->
	<%-- <link rel="stylesheet" href="css/style.css"> --%>
	<link rel="stylesheet" type="text/css" href="css/dashboard.css">
	<!--<script type="text/javascript" src="js/colorpicker.js"></script>-->

<!--script type="text/javascript" src="js/bing.js"></script-->
 <!--script type="text/javascript" src="http://ecn.dev.virtualearth.net/mapcontrol/mapcontrol.ashx?v=6.2"></script-->


<script type="text/javascript">
	var needLock = true;
        var calendarPhase = '<%=calendarPhase%>';
	function tryLock()
	{
		if(needLock)
		{
			jQuery.ajax({
				url : 'lockRecord.jsp',
				type: 'POST',
				dataType: 'json',
				data: {customerId: '<%=UIHelper.escapeCoteValue(customerid)%>'},
				success : function(json)
				{
					if(json.STATUS == "ERROR" && json.STATUS_CODE == "1")
					{
						var message = 'Attention, this order is opened by another user';
						parent.alertModal(message);
						needLock = false;
					}
					if(json.STATUS == "ERROR" && json.STATUS_CODE == "0") parent.alertModal("Some error occurred while locking the record");
					else needLock = false;
				}
			});
		}
	}

	function supplierDetails(input_type){

		tryLock();

		var value = "";
		if(input_type==="radio") value = jQuery("#supplier_id:checked").val()
		else if (input_type==="select") value = jQuery("#supplier_id").val()

		jQuery.ajax({
			url : 'fetchSupplier.jsp',
			type: 'POST',
			dataType: 'json',
			data: {supplierId: value},
			success : function(json)
			{
				if(json.RESPONSE == "SUCCESS"){

					jQuery("#supplier").text(json.DATA["supplier"]);
					jQuery("#category").text(json.DATA["category"]);
					jQuery("#address").text(json.DATA["address"]);
					jQuery("#supplier_email").text(json.DATA["email"]);
					jQuery("#phone_number").text(json.DATA["phone_number"]);
					jQuery("#supplier_detail").text(json.DATA["supplier_detail"]);
				}
			}
		});
	}
	//end for bing

		function cancel(orderId)
        {
			window.location.href= 'cli.jsp?id_pedido='+orderId;
        }

		function onViewContract(customerId)
		{
			window.location.href= 'contrat.jsp?customerid='+customerId;
		}

		function onViewInvoice(customerId, invoiceCode)
		{
			var prop = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
			prop += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
			prop += ",width=900" + ",height=800";
			//window.open('http://gedfew.si.orange.es/ConsGuizmo.asp?Sistema=14&Usuario=33942727V&1=Facturas&2='+invoiceCode,"Invoice", prop);
			window.open('PdfFact.jsp?customerid='+customerId,"Invoice", prop);
			//window.location.href= 'PdfFact.jsp?outType=pdf&customerid='+customerId;
			//window.location.href= 'contrat.jsp?customerid='+customerId;
		}

		function onViewRectificativa(customerId, invoiceCode)
		{
			var prop = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
			prop += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
			prop += ",width=900" + ",height=800";
			//window.open('http://gedfew.si.orange.es/ConsGuizmo.asp?Sistema=14&Usuario=33942727V&1=Facturas&2='+invoiceCode,"Invoice", prop);
			window.open('PdfRFact.jsp?customerid='+customerId,"Invoice", prop);
			//window.location.href= 'PdfRFact.jsp?outType=pdf&customerid='+customerId;
			//window.location.href= 'contrat.jsp?customerid='+customerId;
		}

		function onModify()
		{
			var prop = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
			prop += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
			prop += ",width=900" + ",height=800";
		}

        function validateData()
        {
			<%
			for(String field : mandatoryFields)
			{ %>
				if(typeof document.editForm.<%=field%> !== "undefined" && document.editForm.<%=field%>.value == '')
				{
					alert("Enter <%=field%>");
					document.editForm.<%=field%>.focus();
					return false;
				}
			<%
			}//end for

			if(editableFields.contains("email")) { %>
			var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
            if(document.editForm.email.value != '' && !document.editForm.email.value.match(re))
			{
                    alert("Enter a valid customer email");
                    document.editForm.email.focus();
                    return false;
			}
			<%}%>
			var contactNumberRegExp = /^((\+)\d+|\d+)$/;
			<% if(editableFields.contains("contactPhoneNumber1")) 
			{ %>
              if(document.editForm.contactPhoneNumber1.value != '' && !document.editForm.contactPhoneNumber1.value.match(contactNumberRegExp))
                  {
                    alert("Invalid contact number 1");
                    document.editForm.contactPhoneNumber1.focus();
                    return false;
                  }
			<% 
			}//end if %>
			return true;
        }

		function onSave()
		{
			if(validateData()) document.editForm.submit();
		}

		function toggleDiv(divId)
		{
			var val = "EXPANDED";

			if(jQuery("#"+divId).hasClass("show")) val = "COLLAPSED";

			jQuery.ajax({
				url : 'updateUiPref.jsp',
				type: 'POST',
				data: {screen:'customerEdit', uiItem:divId, value:val}
			});
		}

		function onOkChangePhase(orderId, customerId, process, currentPhase, nextProcess, nextPhase, fromDialog,post_work_id, _errCode )
		{
			var errCode = "";
			if(_errCode)//means automatically calling this in case where there is only 1 err code
			{
				errCode = _errCode;
			}
			else
			{
				document.getElementById('changePhaseErrMsg').innerHTML = "";
				var anySelected = false;

				for(var i=0; i<document.getElementsByName("changePhaseErrCode").length; i++)
				{
					if(document.getElementsByName("changePhaseErrCode")[i].checked)
					{
						anySelected = true;
						errCode = document.getElementsByName("changePhaseErrCode")[i].value;
						break;
					}
				}
				if(!anySelected)
				{
					document.getElementById('changePhaseErrMsg').innerHTML = "Seleccionar un c&oacute;digo de error";
					return;
				}
			}
			if(calendarPhase=="") window.location='changeOrderPhase.jsp?post_work_id='+post_work_id+'&orderId='+orderId+'&customerId='+customerId+'&oldPhase='+currentPhase+'&process='+process+'&nextProcess='+nextProcess+'&nextPhase='+nextPhase+'&errCode='+errCode+'&fromDialog='+fromDialog+'&isFromEditScreen=1';
			else
			{
				jQuery.ajax({
					url : 'changeOrderPhase.jsp?post_work_id='+post_work_id+'&orderId='+orderId+'&customerId='+customerId+'&oldPhase='+currentPhase+'&process='+process+'&nextProcess='+nextProcess+'&nextPhase='+nextPhase+'&errCode='+errCode+'&fromDialog='+fromDialog,
					type: 'POST',
					dataType: 'json',
					success : function(data)
					{
						if(data.response=="success")
						{
							alert("Success");
							jQuery.ajax({
								url: 'unlockRecord.jsp',
								type: 'POST',
								data: {customerId : customerId},
								async: false,
								success: function(resp) {}
							});
							parent.refreshCalendar();
						}
						else{
							alert(data.errorMsg);
						}
					}
				});
			}
		}
		
		function onChangePhaseBtn(orderId, customerId, process, currentPhase, nextProcess, nextPhase, fromDialog, post_work_id)
		{
			console.log("change phase");
			if(!validateData()) return;
			if(!confirm("Are you sure to change the phase?")) return;
			jQuery.ajax({
				url : 'customerUpdate.jsp',
				type: 'POST',
				async:false,
				data:jQuery(document.editForm).serialize(),
				success : function(resp)
				{
					if(resp.indexOf("Data updated successfully") > -1)
					{
						jQuery.ajax({
							url : 'showChangePhase.jsp',
							type: 'POST',
							data: {post_work_id:post_work_id, orderId: orderId, customerId: customerId, process: process, currentPhase: currentPhase, nextProcess: nextProcess, nextPhase:nextPhase, fromDialog:fromDialog, isFromEditScreen: '1', client_key: (calendarPhase==""?"":customerId)},
							success : function(resp)
							{
								jQuery("#dialogWindow").find(".modal-body").html(resp);
								if(resp.indexOf("changePhaseErrMsg") > -1) //this will be only in case there were multiple errcodes so we show them in dialog window
								{
									
									jQuery("#dialogWindow").find(".modal-title").html("Change Phase");
									jQuery("#dialogWindow").modal('show');
								}
							}
						});
					}
					else if(resp.indexOf("reason") > -1)
					{
						var json = JSON.parse(resp);
						jQuery("#errMsgDiv").html(json.reason);
						jQuery("#errMsgDiv").fadeIn();
						jQuery('#errMsgDiv').delay(2000).fadeOut();
					}
				},
				error : function(resp)
				{
					alert("Some error while saving the client information");
				}
			});
		}

		function onCancel()
		{
			document.getElementById('cancelErrMsg').innerHTML = "";
			var anySelected = false;

			for(var i=0; i<document.getElementsByName("cancelErrCode").length; i++)
			{
				if(document.getElementsByName("cancelErrCode")[i].checked)
				{
					anySelected = true;
					errCode = document.getElementsByName("cancelErrCode")[i].value;
					break;
				}
			}
			if(!anySelected)
			{
				document.getElementById('cancelErrMsg').innerHTML = "Select an error code";
				return;
			}
			else
			{
				if(confirm("Are you sure to cancel order?"))
				{
					window.location="cancelOrder.jsp?customerId=<%=rsStatus.value("customerId")%>&orderId=<%=orderId%>&errCode="+errCode;
				}
			}
		}

		function onManualCancel(customerId, orderId)
		{
			jQuery.ajax({
				url: 'showCancelMotivos.jsp',
				type: 'POST',
				cache: false,
				success: function(resp) {
					resp = jQuery.trim(resp);
					jQuery("#dialogWindow").find(".modal-title").html("Cancel order");
					jQuery("#dialogWindow").find(".modal-body").html(resp);
					jQuery("#dialogWindow").modal('show');
				}
			});
		}
		function onviewflow(customerId)
		{
			jQuery.ajax({
				url: 'orderFlow.jsp',
				type: 'POST',
				data: {customerId : customerId, fromDialog: true},
				success: function(resp) {
					resp = jQuery.trim(resp);
					jQuery("#dialogWindow").find(".modal-title").html("Order flow");
					jQuery("#dialogWindow").find(".modal-body").html(resp);
					jQuery("#dialogWindow").modal('show');
				}
			});

		}

		function findPosX(obj)
		{
			var curleft = 0;
			if(obj.offsetParent)
			while(1)
			{
				curleft += obj.offsetLeft;
				if(!obj.offsetParent)
				break;
				obj = obj.offsetParent;
			}
			else if(obj.x)
			curleft += obj.x;
			return curleft;
		}


		function findPosY(obj)
		{
			var curtop = 0;
			if(obj.offsetParent)
			while(1)
			{
				curtop += obj.offsetTop;
				if(!obj.offsetParent)
				break;
				obj = obj.offsetParent;
			}
			else if(obj.y)
			curtop += obj.y;
			return curtop;
		}

		function onReverse(customerId, orderId, isFull, post_work_id)
		{
			if(confirm("Are you sure you want to go back to previous phase?"))
			{
				jQuery.ajax({
					url: 'reverseOrder.jsp',
					type: 'POST',
					data: {post_work_id:post_work_id, customerId : customerId, orderId: orderId, isFull: isFull},
					async: false,
					dataType: 'json',
					success: function(resp)
					{
						if(resp.STATUS == 'SUCCESS')
						{
							jQuery.ajax({
								url: 'unlockRecord.jsp',
								type: 'POST',
								data: {customerId : customerId},
								async: false,
								success: function(resp) {
								}
							});
							parent.refreshScreen();
						}
						else alert(resp.MESSAGE);
					}
				});
			}
		}

		function showToolTip(toolTipId, tooltip)
		{

			document.getElementById(toolTipId).title = tooltip;
		}

		function showToolTipSFF(obj, toolTipId)
		{
			document.getElementById(toolTipId).style.left=30+findPosX(obj);
			document.getElementById(toolTipId).style.top=5+findPosY(obj);
			document.getElementById(toolTipId).style.display="block";
		}

		function onSaveComments()
		{

			if(document.editForm.comments.value == "")
			{
				alert("Enter comments");
				return;
			}
			document.editForm.action = "saveComments.jsp";
			document.editForm.submit();
		}
		function closeIt()
		{
			jQuery.ajax({
				url: 'unlockRecord.jsp',
				type: 'POST',
				data: {customerId : '<%=customerid%>'},
				async: false,
				success: function(resp) {
					window.location.href="ibo.jsp"
				}
			});
		}

		function unlockRecord()
		{
			jQuery.ajax({
				url: 'unlockRecord.jsp',
				type: 'POST',
				data: {customerId : '<%=customerid%>'},
				async: false,
				success: function(resp) {

				}
			});
		}

</script>
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
<style>
	@media(max-width:768px){
		table {
			display: block;
			overflow-x: auto;
			white-space: nowrap;
		}

	}
	.table{
		font-size: 12px ;
	}
</style>
</head>
<body  class="c-app" style="background-color:#efefef" >
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
	<div class="c-wrapper c-fixed-components">
		<%@ include file="/WEB-INF/include/header.jsp" %>
		<div class="c-body">
			<main class="c-main"  style="padding:0px 30px">
	
<header>
        <nav class="navbar navbar-expand navbar-light flex-column flex-md-row bd-navbar" style="background-color: #e3f2fd;">
            <div class="container-fluid">
			   <!-- Brand and toggle get grouped for better mobile display -->
    <div class="navbar-header">
      <button type="button" class="navbar-toggler collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1" aria-expanded="false">
        <span class="sr-only">Toggle navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
    </div>
		<div class="navbar-nav-scroll" id="bs-example-navbar-collapse-1">
		<ul class="navbar-nav bd-navbar-nav flex-row">
		<%
            if(!calendarPhase.equals("")){
		%>
			<li class="nav-item" role="presentation" ><a href="javascript:onChangePhaseBtn('<%=orderId%>','<%=rsStatus.value("customerId")%>','<%=rsStatus.value("proces")%>','<%=rsStatus.value("phase")%>','<%=rsStatus.value("proces")%>','<%=UIHelper.escapeCoteValue(calendarPhase)%>','<%=UIHelper.escapeCoteValue(fromDialog)%>','<%=UIHelper.escapeCoteValue(post_work_id)%>');" class="nav-link">Done</a></li>
		<%
		} else {
		%>
			<% if(rsStatus.value("pw_status").equals("0")  && !rsOrder.value("lastId").equals("0")) { %>
			<li class="nav-item" role="presentation" ><a href="javascript:onReverse('<%=rsStatus.value("customerId")%>','<%=orderId%>',false,'<%=UIHelper.escapeCoteValue(post_work_id)%>')" class="nav-link">Reverse</a></li>
		<% } %>
		<% if(false && rsStatus.value("pw_status").equals("0")  && (userProfile.equals("ADMIN") || userProfile.startsWith("SUPER_ADMIN"))) { %>
			<% if(showCancelButton && !alreadyCancelled) { %>
			<li class="nav-item" role="presentation" ><a href="javascript:onManualCancel('<%=rsStatus.value("customerId")%>','<%=UIHelper.escapeCoteValue(orderId)%>')" class="nav-link">Cancel</a></li>
			<% } %>
		<% } %>
		<% if(userProfile.equals("ADMIN") || userProfile.startsWith("SUPER_ADMIN")) { %>
			<li class="nav-item" role="presentation" ><a href="javascript:onviewflow('<%=rsStatus.value("client_key")%>')" class="nav-link">View Process flow</a></li>
		<% } %>
		<% if( !(rsOrder.value("spaymentmean").equals("cash_on_delivery")||rsOrder.value("spaymentmean").equals("cash_on_pickup")) && "1".equals(parseNull(GlobalParm.getParm("no_admin_bill_download"))) == false) {
			String downloadBillUrl = GlobalParm.getParm("CART_URL")+"downloadTrackingBill.jsp";
		%>
			<li class="nav-item"role="presentation" ><a href="javascript:window.location = '<%=UIHelper.escapeCoteValue(downloadBillUrl)%>?id=<%=rsOrder.value("parent_uuid")%>&doc=<%=rsOrder.value("orderRef")%>';" class="nav-link">Download Bill</a></li>
		<% } %>
		<% if(rsStatus.value("pw_status").equals("0")  && showRulesButtons) { %>
			<li class="nav-item" role="presentation" ><a href="javascript:onSave()" class="nav-link">Save</a></li>
		<% } %>

		<% if(rsStatus.value("pw_status").equals("0")  && rsRules != null) {
			int index = 0;
			boolean separatorShown = false;
			while(rsRules.next()) {
				List<String> banned = bannedPhases.get(rsRules.value("next_proc"));
				if(banned != null && banned.contains(rsRules.value("next_phase"))) continue;
		%>
		<%		String buttonLabel = rsRules.value("displayName");
				boolean showTooltip = false;
				if( buttonLabel.length() > 30)
				{
					buttonLabel = buttonLabel.substring(0,29) + "..";
					showTooltip = true;
				}
		%>
			<% if(!separatorShown) {
				separatorShown = true;
			%>
			<li class="dropdown nav-item">
				<a href="#" class="dropdown-toggle mr-md-2 nav-item nav-link" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Change Phase <span class="caret"></span></a>
				<ul class="dropdown-menu">
		<% } %>
			<li id="<%=index%>_button" <%if(showTooltip){%>onmouseover="showToolTip('<%=index%>_button', '<%=rsRules.value("displayName")%>')" <%}%> class="toolbarButton dropdown-item">
				<a href="javascript:onChangePhaseBtn('<%=UIHelper.escapeCoteValue(orderId)%>','<%=rsStatus.value("customerId")%>','<%=rsStatus.value("proces")%>','<%=rsStatus.value("phase")%>','<%=rsRules.value("next_proc")%>','<%=rsRules.value("next_phase")%>','<%=UIHelper.escapeCoteValue(fromDialog)%>','<%=UIHelper.escapeCoteValue(post_work_id)%>');"><%=buttonLabel%></a>
			</li>
		<%
				index++;
			}
			if(separatorShown) {
		%>
			</ul>
			</li>
		<% }
		}
			}
		%>
		</ul>
		</div>
			<ul class="navbar-nav flex-row ml-md-auto d-none d-md-flex">
				<li class="nav-item">
					<% if(parseNull(rsStatus.value("oprType")).equals("T")) { %>
						<a class="nav-link" href="#" role="button" aria-haspopup="true" aria-expanded="false">
							<span style="color:RED; font-size:10pt;"> No modifications allowed </span>
						</a>
					<% } %>
				</li>
				<button class="btn btn-secondary" onclick="closeIt()">Back</button>
				
				
			</ul>
			<%-- /.navbar-collapse --%>
            </div>
             <%-- /.container-fluid --%>
        </nav>
    </header>
                <!-- Collect the nav links, forms, and other content for toggling -->

<span id="top"></span>
<!-- Fab : balise pour le retour haut de page -->
<div id="dv" onclick="style.display='none';"></div>
<div id="dv2" onclick="style.display='none';"></div>
<!-- div de d�but de cadrage -->
<form name="editForm" id="editForm" method="post" action='customerUpdate.jsp'>

	<input type='hidden' name='post_work_id' value='<%=UIHelper.escapeCoteValue(post_work_id)%>'/>
	<input type="hidden" name="customerId" value="<%=UIHelper.escapeCoteValue(customerid)%>">
	<input type="hidden" name="phase" value="<%=UIHelper.escapeCoteValue(parseNull(rsStatus.value("phase")))%>">
	<input type="hidden" name="phaseDisplayName" value="<%=UIHelper.escapeCoteValue(parseNull(rsStatus.value("displayName")))%>">
	<input type="hidden" name="orderId" value="<%=UIHelper.escapeCoteValue(orderId)%>">
	<input type="hidden" name="calendarPhase" value="<%=UIHelper.escapeCoteValue(calendarPhase)%>">

<main class="container-fluid">

	<div class="alert alert-success" id="succMsgDiv" role="alert" style="display:none"></div>
	<div class="alert alert-danger" id="errMsgDiv" role="alert" style="display:none"></div>

    <div class="row">

	    <aside class="col-sm-3 toolbar" style="display:none">

            <ul class="nav nav-pills nav-stacked">
                <li role="presentation"><strong>Action</strong></li>
                <li role="presentation" class="divider"></li>
            <%
            if(!calendarPhase.equals("")){
            %>
                <li role="presentation" onclick="onChangePhaseBtn('<%=UIHelper.escapeCoteValue(orderId)%>','<%=rsStatus.value("customerId")%>','<%=rsStatus.value("proces")%>','<%=rsStatus.value("phase")%>','<%=rsStatus.value("proces")%>','<%=UIHelper.escapeCoteValue(calendarPhase)%>','<%=UIHelper.escapeCoteValue(fromDialog)%>','<%=UIHelper.escapeCoteValue(post_work_id)%>');"><a href="#">Done</a></li>
            <%
            } else {
            %>
				<% if(rsStatus.value("pw_status").equals("0")  && (userProfile.equals("MGR_ACTIVE") || userProfile.equals("ADMIN") || userProfile.startsWith("SUPER_ADMIN")) && !rsOrder.value("lastId").equals("0")) { %>
				<li role="presentation" onclick="onReverse('<%=rsStatus.value("customerId")%>','<%=UIHelper.escapeCoteValue(orderId)%>',false,'<%=UIHelper.escapeCoteValue(post_work_id)%>')"><a href="#">Reverse</a></li>
		<% } %>
		<% if(false && rsStatus.value("pw_status").equals("0")  && (userProfile.equals("ADMIN") || userProfile.startsWith("SUPER_ADMIN"))) { %>
			<% if(showCancelButton && !alreadyCancelled) { %>
				<li role="presentation" onclick="onManualCancel('<%=rsStatus.value("customerId")%>','<%=UIHelper.escapeCoteValue(orderId)%>')"><a href="#">Cancel</a></li>
			<% } %>
		<% } %>
		<% if(userProfile.equals("ADMIN") || userProfile.startsWith("SUPER_ADMIN")) { %>
				<li role="presentation" onclick="onviewflow('<%=rsStatus.value("client_key")%>')"><a href="#">View Process flow</a></li>
		<% } %>
		<% if(rsStatus.value("pw_status").equals("0")  && showRulesButtons) { %>
				<li role="presentation" onclick="onSave()"><a href="#">Save</a></li>
		<% } %>
		<% if(rsStatus.value("pw_status").equals("0")  && rsRules != null) {
				int index = 0;
				boolean separatorShown = false;
				while(rsRules.next()) {
					List<String> banned = bannedPhases.get(rsRules.value("next_proc"));
					if(banned != null && banned.contains(rsRules.value("next_phase"))) continue;
		%>
				<%	String buttonLabel = rsRules.value("displayName");
					boolean showTooltip = false;
					if( buttonLabel.length() > 30)
					{
						buttonLabel = buttonLabel.substring(0,29) + "..";
						showTooltip = true;
					}
				%>
					<% if(!separatorShown) {
						separatorShown = true;
					%>
							<li role="presentation"><strong>Change Phase</strong></li>
					<% } %>
							<li id="<%=index%>_button" <%if(showTooltip){%>onmouseover="showToolTip('<%=index%>_button', '<%=rsRules.value("displayName")%>')" <%}%> onclick="onChangePhaseBtn('<%=UIHelper.escapeCoteValue(orderId)%>','<%=rsStatus.value("customerId")%>','<%=rsStatus.value("proces")%>','<%=rsStatus.value("phase")%>','<%=rsRules.value("next_proc")%>','<%=rsRules.value("next_phase")%>','<%=UIHelper.escapeCoteValue(fromDialog)%>','<%=UIHelper.escapeCoteValue(post_work_id)%>');" class="toolbarButton">
								<a href="#"><%=buttonLabel%></a>
							</li>
		<%
					index++;
				}
			}
		}
		%>
		</ul>
	    </aside>
		<div class="col-sm-12">
			<!-- Nav tabs -->
			<ul class="nav nav-tabs" role="tablist">
				<li role="presentation" class="nav-item"><a href="#customer_info" aria-controls="customer_info" id="customer_info_tab" name="customerData" onclick="toggleDiv('customerInfoCollapse');" class="nav-link">Customer Information</a></li>
				<% if(additionalOrderInfo != null && additionalOrderInfo.has("sections")){%>
				<li role="presentation" class="nav-item"><a href="#additional_info" aria-controls="additional_info" id="additional_info_tab" name="additionalInfoData" onclick="toggleDiv('additionalInfoCollapse');" class="nav-link">Additional Information</a></li>
				<%}%>
				<li role="presentation" class="nav-item"><a href="#order_information" aria-controls="order_information"  id="order_info_tab" name="orderData" onclick="toggleDiv('orderInfoCollapse');" class="nav-link">Order Information</a></li>
				<%if(calendarPhase.equals("")){%>
				<li role="presentation" class="nav-item"><a href="#status_history" aria-controls="status_history"  id="status_history_tab" name="statusHistoryData" onclick="toggleDiv('statusHistoryCollapse');" class="nav-link">Status History</a></li>
				<li role="presentation" class="nav-item"><a href="#observations" aria-controls="observations"  id="observation_tab" name="observationData" onclick="toggleDiv('observationCollapse');" class="nav-link">Observations</a></li>
				<%}%>
				<%--<li role="presentation"><a href="#supplierDetails" aria-controls="supplierDetails"  id="supplier_details_tab" name="supplierDetailData" onclick="toggleDiv('supplierDetailsCollapse');">Supplier Details</a></li>--%>
			</ul>
	    	
	    	<div class="card card-primary tab-pane active" id="customer_info" role="tabpanel" >

	    		<div class="card-header" role="tab" id="customerInfoHeading">
                    <h4 class="card-title">
                        <a role="button" data-toggle="collapse"  href="#customerInfoCollapse" aria-expanded="true" aria-controls="customerInfoCollapse" onclick="toggleDiv('customerInfoCollapse')">
                          Customer Information
                        </a>
                    </h4>
                </div>

                <div id="customerInfoCollapse" class='panel-collapse collapse <% if(parseNull(uipreferencesMap.get("customerInfoCollapse")).equalsIgnoreCase("EXPANDED")) { %> show <% } %>' role="tabpanel" aria-labelledby="customerInfoHeading">

                	<div class="card-body">
                        <div class="row">
                	<%
                        Set rsCustomerInfo = Etn.execute("select fn.*, isEditable, isHidden, isMandatory from field_names fn left join field_settings fs on fn.fieldName=fs.fieldName and fn.screenName=fs.screenName and process = "+escape.cote(rsStatus.value("proces"))+" and phase="+escape.cote(rsStatus.value("phase"))+"  where fn.screenName = 'CUSTOMER_EDIT' and tab = 'Customer Information' and isLabel = 1 and COALESCE(isHidden,0)<>1 order by sectionDisplaySeq, fieldDisplaySeq;");
                        while(rsCustomerInfo.next()){
                        %>
                            <div class="col-sm-4">
                                <strong><%=UIHelper.escapeCoteValue(rsCustomerInfo.value("displayName"))%></strong>
                                <p>
                                    <span style="display:block"><%=UIHelper.escapeCoteValue(rsOrder.value(rsCustomerInfo.value("fieldName")))%></span>
                                </p>
                            </div>
                        <%
                        }
                        %>
                        </div>


                            <div class="form-horizontal row">
                        <%
							Set rsSlotDays = Etn.execute("select distinct n_day from "+GlobalParm.getParm("COMMONS_DB")+".delivery_slots where site_id = "+escape.cote(siteid) + " order by n_day ");
							
                            String portaldb = GlobalParm.getParm("PORTAL_DB");
                            String catalogdb = GlobalParm.getParm("CATALOG_DB");
                            String previousSection = "";
                            rsCustomerInfo = Etn.execute("select fn.*, isEditable, isHidden, isMandatory from field_names fn left join field_settings fs on fn.fieldName=fs.fieldName and fn.screenName=fs.screenName and process = "+escape.cote(rsStatus.value("proces"))+" and phase="+escape.cote(rsStatus.value("phase"))+"  where fn.screenName = 'CUSTOMER_EDIT' and tab = 'Customer Information' and isLabel = 0 and COALESCE(isHidden,0)<>1 order by sectionDisplaySeq, fieldDisplaySeq;");
                            while(rsCustomerInfo.next()){
								
								if(rsSlotDays.rs.Rows == 0 && rsCustomerInfo.value("section").equalsIgnoreCase("Home delivery")) continue;
								if("home_delivery".equals(rsOrder.value("shipping_method_id")) == false && rsCustomerInfo.value("section").equalsIgnoreCase("Home delivery")) continue;
								
                                if(!previousSection.equals(rsCustomerInfo.value("section"))) out.write("<h3 class=\"col-12 h4\">"+rsCustomerInfo.value("section")+"<hr></h3>");
                                previousSection = rsCustomerInfo.value("section");

                                Map<String, String> selectMap = null;
                                String imageUrl = "";
                                if(rsCustomerInfo.value("section").equalsIgnoreCase("Home delivery"))
								{
									if(rsCustomerInfo.value("fieldName").equals("delivery_date"))
									{
										boolean isReadonly = false;
										if(editableFields.contains("delivery_date") == false) isReadonly = true;
									%>
                                    <div class="col-sm-6">
										<div class="form-group row">
											<p class="col-sm-4 control-label" style="text-align: left;"><%=UIHelper.escapeCoteValue(rsCustomerInfo.value("displayName"))%> <% if(mandatoryFields.contains(rsCustomerInfo.value("fieldName"))) %><span style="color: red;">*</span></p>
											<div class="col-sm-8">
												<input type="text" name="delivery_date" class="form-control delivery_date" <%=(isReadonly?"readonly":"")%> value="<%=deliveryDate%>">
											</div>
										</div>
                                    </div>									
                                    <%										
									}
									if(rsCustomerInfo.value("fieldName").equals("delivery_slot"))
									{
										boolean isReadonly = false;
										if(editableFields.contains("delivery_slot") == false) isReadonly = true;
																				
									%>
									<input type='hidden' value='<%=UIHelper.escapeCoteValue(deliveryStartSlotHour)%>' name='delivery_start_hour'>
									<input type='hidden' value='<%=UIHelper.escapeCoteValue(deliveryStartSlotMin)%>' name='delivery_start_min'>
									<input type='hidden' value='<%=UIHelper.escapeCoteValue(deliveryEndSlotHour)%>' name='delivery_end_hour'>
									<input type='hidden' value='<%=UIHelper.escapeCoteValue(deliveryEndSlotMin)%>' name='delivery_end_min'>
									<div class="d-none">
										<input type="text" class="hidden_delivery_slot" name="delivery_slot" value="<%=getSlotDisplay(deliveryStartSlotHour, deliveryStartSlotMin, deliveryEndSlotHour, deliveryEndSlotMin)%>">
									</div>
                                    <div class="col-sm-6">
										<div class="form-group row">
											<p class="col-sm-4 control-label" style="text-align: left;"><%=UIHelper.escapeCoteValue(rsCustomerInfo.value("displayName"))%> <% if(mandatoryFields.contains(rsCustomerInfo.value("fieldName"))) %><span style="color: red;">*</span></p>
											<div class="col-sm-8">
												<%
												while(rsSlotDays.next())
												{
													//IMPORTANT:n_day 0 means sunday
													excludeDayNos.remove(rsSlotDays.value("n_day"));
													boolean containerVisible = false;
													if(rsSlotDays.value("n_day").equals(""+deliveryDateWeekDay)) containerVisible = true;

													Set rsSlots = Etn.execute("select distinct * from "+GlobalParm.getParm("COMMONS_DB")+".delivery_slots "+
														" where n_day = "+escape.cote(rsSlotDays.value("n_day"))+" and site_id = "+escape.cote(siteid) + " order by start_hour, start_min, end_hour, end_min ");
												%>
												<div class='delivery_slots_container <%=(containerVisible?"":"d-none")%>' data-day='<%=UIHelper.escapeCoteValue(rsSlotDays.value("n_day"))%>'>
													<%if(isReadonly){%>
													<input type='text' readonly class='form-control' value='<%=getSlotDisplay(deliveryStartSlotHour, deliveryStartSlotMin, deliveryEndSlotHour, deliveryEndSlotMin)%>' >
													<%}else{%>
													<select class='delivery_slots form-control'>
														<option value='-1'>--------------</option>
												<%while(rsSlots.next()){
													boolean isSelected = false;
													if(deliveryStartSlotHour.equals(rsSlots.value("start_hour")) && deliveryStartSlotMin.equals(rsSlots.value("start_min"))
														&& deliveryEndSlotHour.equals(rsSlots.value("end_hour")) && deliveryEndSlotMin.equals(rsSlots.value("end_min")))
														{
															isSelected = true;
														}
												%>
														<option <%=(isSelected?"selected":"")%> data-s-day='<%=rsSlots.value("start_hour")%>' data-s-min='<%=rsSlots.value("start_min")%>' data-e-day='<%=rsSlots.value("end_hour")%>' data-e-min='<%=rsSlots.value("end_min")%>' value=''><%=getSlotDisplay(rsSlots.value("start_hour"), rsSlots.value("start_min"), rsSlots.value("end_hour"), rsSlots.value("end_min"))%></option>
												<%}%>
													</select>
													<%}%>
												</div>
												<%}%>
											</div>
										</div>
                                    </div>									
                                    <%										
									}
                                }
                                else if(parseNull(rsCustomerInfo.value("input_type")).equals("image")){
                                    Set rsPortalImage = Etn.execute("select * from "+portaldb+".files where file_uuid="+escape.cote(rsOrder.value(rsCustomerInfo.value("fieldName"))));
                                    if(rsPortalImage.next()) imageUrl = GlobalParm.getParm("funnel_documents_base_url")+"cart_documents/"+rsOrder.value(rsCustomerInfo.value("fieldName"))+"."+rsPortalImage.value("file_extension");
                                    %>
                                    <div class="col-sm-6">
										<div class="form-group row">
											<p class="col-sm-4 control-label" style="text-align: left;"><%=UIHelper.escapeCoteValue(rsCustomerInfo.value("displayName"))%><% if(mandatoryFields.contains(rsCustomerInfo.value("fieldName"))) %><span style="color: red;">*</span></p>
											<div class="col-sm-8">
												<p style="display:inline-block;cursor:pointer;padding:2px;border:1px solid gray;border-radius:4px" onclick="openImage('<%=UIHelper.escapeCoteValue(imageUrl)%>')">
												<%if(imageUrl.endsWith("pdf")){%>
													<object data="<%=imageUrl%>" type="application/pdf" style="width: auto; height: 400px;">
														<a href="<%=imageUrl%>">
													</object>
												<%}else{%>
													<img src="<%=imageUrl%>" style="width: auto; height: 40px;border-radius:4px;">
												<%}%>
												</p>
											</div>
										</div>
                                    </div>
                                    <%
                                }
                                else if(parseNull(rsCustomerInfo.value("input_type")).equals("jsontext")){
									String _qry = parseNull(rsCustomerInfo.value("query"));
									if(_qry.length() > 0 && _qry.startsWith("order_snapshot."))
									{
										JSONObject _jObj = new JSONObject(parseNull(rsOrder.value("order_snapshot")));
										String _val = parseNull(_jObj.getString(_qry.replace("order_snapshot.","")));
									%>
                                    <div class="col-sm-6">
										<div class="form-group row">
											<p class="col-sm-4 control-label" style="text-align: left;"><%=UIHelper.escapeCoteValue(rsCustomerInfo.value("displayName"))%></p>
											<div class="col-sm-8">
												<input type="text" class="form-control" readonly value="<%=_val%>">
											</div>
										</div>
                                    </div>									
                                    <%
									}
                                }
                                else{
                                    String selectQuery = rsCustomerInfo.value("query");
                                    if(!selectQuery.equals("")){
                                        selectQuery = selectQuery.replaceAll("GlobalParm_CATALOG_DB",catalogdb).replaceAll("Orders_SITE_ID",rsOrder.value("site_id"));
                                        Pattern pattern = Pattern.compile("\\$(.*?)\\$");
                                        Matcher matcher = pattern.matcher(selectQuery);
                                        while(matcher.find())
                                        {
                                            selectQuery = selectQuery.replace(matcher.group(0), escape.cote(rsOrder.value(matcher.group(1))));
                                        }
                                        //out.write(selectQuery);

                                        Set selectRs = Etn.execute(selectQuery);
                                        if(rsCustomerInfo.value("fieldName").contains("resource")){
                                            selectRs.next();
                                            selectMap = getResourcesMap(parseNull(selectRs.value(0)));
                                        }
                                        else selectMap = getHashMap(selectRs);

                                        //selectMap = getHashMap(Etn.execute(selectQuery)); // getResourcesMap(parseNull(selectRs.value(0)))
                                    }
                                    %>
                        <div class="col-sm-6">
							<div class="form-group row">
								<p class="col-sm-4 control-label" style="text-align: left;"><%=UIHelper.escapeCoteValue(rsCustomerInfo.value("displayName"))%><% if(mandatoryFields.contains(rsCustomerInfo.value("fieldName"))) %><span style="color: red;">*</span></p>
								<div class="col-sm-8">
									<p>
										<%=generateFieldHtml(editableFields, mandatoryFields, userProfile, "", rsCustomerInfo.value("fieldName"), rsCustomerInfo.value("fieldName"), rsOrder.value(rsCustomerInfo.value("fieldName")), parseNull(rsCustomerInfo.value("input_type")), "onchange='tryLock()'", "32", "30", "", selectMap)%>
									</p>
								</div>
							</div>
                        </div>
                                    <%
                                }
                        %>
                        <%
                        }
                        %>

                            </div>

                	</div>
                </div>
	    	</div>
			<%
				Set kycRs = Etn.execute("SELECT * FROM order_kyc_info where order_id="+escape.cote(orderId));
				if(kycRs.next()){
					if(parseNull(kycRs.value("kyc_uid")).length() > 0) {
			%>
			<div class="card card-primary tab-pane active" id="kyc_info" role="tabpanel" >
                <div class="card-header" role="tab" id="kycInfoHeading">

                    <h4 class="card-title">
                        <a class="collapsed" role="button" data-toggle="collapse"  href="#kycInfoCollapse" aria-expanded="false" aria-controls="kycInfoCollapse" onclick="toggleDiv('kycInfoCollapse')">
                          KYC
                        </a>
                  </h4>
                </div>

				<div id="kycInfoCollapse" class='card-collapse collapse' role="tabcard" aria-labelledby="kycInfoHeading">
					<div class="card-body">
						<div class="row">
						<%
							try{
								Map<String,String> docTypes= new HashMap<>();
								docTypes.put("ID","National ID card");
								docTypes.put("P","Passport");
								docTypes.put("V","Visa");
								docTypes.put("DL","Driving License");
								docTypes.put("HC","Health card");
								docTypes.put("RP","Residence permit");
								docTypes.put("SELFIE","User Picture");
								docTypes.put("LIVENESS","Liveness Detection");
								docTypes.put("CAR_REG","French Vehicle Registration");
								docTypes.put("KBIS","French corporate certificate");
								docTypes.put("RIB","Bank details");
								docTypes.put("ADR_PROOF","French Proof of address");
								docTypes.put("PAY_SHEET","French Payslip");
								docTypes.put("TAX_SHEET","French Tax Statement");
								docTypes.put("Other","Other type of document");

								JSONObject kycResp = new JSONObject(kycRs.value("kyc_resp"));
								JSONObject analysisResults =  kycResp.getJSONObject("result").getJSONArray("analysisResults").getJSONObject(0);
								JSONObject owner = analysisResults.getJSONObject("analysisData").getJSONObject("owner");

								String docType = analysisResults.getJSONObject("analysisData").getString("docType");
								String kycStatus = kycResp.getString("status");

								JSONArray listCaptDocs = analysisResults.getJSONArray("listCapturedDocs");

								String kycLastName = "";
								String kycFirstName = "";
								
								JSONArray lastNames = owner.getJSONArray("lastNames");
								JSONArray firstNames = owner.getJSONArray("firstNames");

								int day = owner.getJSONObject("birthDate").getInt("day");
								int month = owner.getJSONObject("birthDate").getInt("month");
								int year = owner.getJSONObject("birthDate").getInt("year");

								String dob = day+"/"+month+"/"+year;

								

								for (int i = 0; i < lastNames.length(); i++) {
									kycLastName += lastNames.getString(i);
									if (i < lastNames.length() - 1) {
										kycLastName += " "; 
									}
								}

								for (int i = 0; i < firstNames.length(); i++) {
									kycFirstName += firstNames.getString(i);
									if (i < firstNames.length() - 1) {
										kycFirstName += " "; 
									}
								}

						%>
							<div class="col-sm-6">
								<div class="form-group row">
									<p class="col-sm-4 control-label" style="text-align: left;">Last Name</p>
									<div class="col-sm-8">
										<input type="text" class="form-control" readonly value="<%= UIHelper.escapeCoteValue(kycLastName) %>">
									</div>
								</div>
							</div>

							<div class="col-sm-6">
								<div class="form-group row">
									<p class="col-sm-4 control-label" style="text-align: left;">First Name</p>
									<div class="col-sm-8">
										<input type="text" class="form-control" readonly value="<%= UIHelper.escapeCoteValue(kycFirstName) %>">
									</div>
								</div>
							</div>

							<div class="col-sm-6">
								<div class="form-group row">
									<p class="col-sm-4 control-label" style="text-align: left;">DOB</p>
									<div class="col-sm-8">
										<input type="text" class="form-control" readonly value="<%= UIHelper.escapeCoteValue(dob) %>">
									</div>
								</div>
							</div>

							<div class="col-sm-6">
								<div class="form-group row">
									<p class="col-sm-4 control-label" style="text-align: left;">Identity Type</p>
									<div class="col-sm-8">
										<input type="text" class="form-control" readonly value="<%= UIHelper.escapeCoteValue(docTypes.get(docType)) %>">
									</div>
								</div>
							</div>
							<%
								for (int i = 0; i < listCaptDocs.length(); i++) {
									
									byte[] decodedBytes = Base64.getDecoder().decode(listCaptDocs.getString(i));
									ByteArrayInputStream inputStream = new ByteArrayInputStream(decodedBytes);
									Tika tika = new Tika();
									String mimeType = tika.detect(inputStream);
									System.out.println("MIME Type: " + mimeType);
									%>
									<div class="col-sm-6">
										<div class="form-group row">
											<p class="col-sm-4 control-label" style="text-align: left;">Identity Photo</p>
											<div class="col-sm-8">
												<% if(mimeType.contains("/pdf")) {%>
													<a href="<%= UIHelper.escapeCoteValue("data:"+mimeType+";base64, "+listCaptDocs.getString(i)) %>" target="_blank" class="btn btn-primary">Open</a>
												<% }else{%>
													<img src="<%= UIHelper.escapeCoteValue("data:"+mimeType+";base64, "+listCaptDocs.getString(i)) %>"  style="width: auto; height: 40px;border-radius:4px;" onclick="openImage(this.getAttribute('src'))" />
												<% }%>
											</div>
										</div>
									</div>
								<%	
								}		
							}catch(JSONException e)
							{

							}

						%>
					</div>
					</div>
				</div>
			</div>
			<%
					}
				}
			%>

			<% if(additionalOrderInfo != null && additionalOrderInfo.has("sections")){%>
			<div class="card card-primary tab-pane active" id="additional_info" role="tabpanel" >
                <div class="card-header" role="tab" id="additionalInfoHeading">

                    <h4 class="card-title">
                        <a class="collapsed" role="button" data-toggle="collapse"  href="#additionalInfoCollapse" aria-expanded="false" aria-controls="additionalInfoCollapse" onclick="toggleDiv('additionalInfoCollapse')">
                          Additional Information
                        </a>
                  </h4>
                </div>
                <div id="additionalInfoCollapse" class='card-collapse collapse <% if(parseNull(uipreferencesMap.get("additionalInfoCollapse")).equalsIgnoreCase("EXPANDED")) { %> show <% } %>' role="tabcard" aria-labelledby="oderInfoHeading">
                    <div class="card-body">
						<% for(int s=0;s<additionalOrderInfo.getJSONArray("sections").length();s++)
						{
							JSONObject cSection = additionalOrderInfo.getJSONArray("sections").getJSONObject(s);
							out.write("<div class='row form-horizontal mb-3'>");
							
							if(cSection.has("name") && parseNull(cSection.getString("name")).length() > 0) out.write("<h3 class='col-12 h4'>"+UIHelper.escapeCoteValue(parseNull(cSection.getString("display_name")))+"</h3>");
							if(cSection.has("fields"))
							{
								for(int f=0;f<cSection.getJSONArray("fields").length();f++)
								{
									JSONObject sField = cSection.getJSONArray("fields").getJSONObject(f);
									if(parseNull(sField.getString("type")).equals("hidden")) continue;
									
									if(parseNull(sField.getString("value")).length() == 0) continue;
									
									JSONArray jValues = null;
									try{
										jValues = new JSONArray(parseNull(sField.getString("value")));
									} catch(Exception e) {e.printStackTrace();}
									
									if(jValues != null)
									{
										for(int jt=0;jt<jValues.length();jt++)
										{		
											//get as string and check if length == 0 just continue
											if(parseNull(jValues.optString(jt,"")).length() == 0) continue;
											String sFieldHtml = "<div class='col-6'>";
											sFieldHtml += "<div class='form-group row'>";
											sFieldHtml += "<div class='col-4'>"+UIHelper.escapeCoteValue(sField.getString("display_name"))+"</div>";
											if(sField.getString("type").equals("file"))
											{
												JSONObject jValue = jValues.getJSONObject(jt);
												
												String fUrl = parseNull(jValue.getString("base_url")) + parseNull(jValue.getString("filename"));
												if(parseNull(jValue.getString("content_type")).toLowerCase().startsWith("image/"))
												{
													sFieldHtml += "<div class='col-8'><a target='_blank' href='"+UIHelper.escapeCoteValue(fUrl)+"'><img style='max-width:80px;max-height:80px' src='"+UIHelper.escapeCoteValue(fUrl)+"'></img></a></div>";
												}
												else
												{
													sFieldHtml += "<div class='col-8'><a target='_blank' href='"+UIHelper.escapeCoteValue(fUrl)+"'><img style='max-width:50px;max-height:50px' src='"+request.getContextPath()+"/img/ident.png'></img></a></div>";
												}
											}
											else
											{
												sFieldHtml += "<div class='col-8'><input type='text' class='form-control' readonly value='"+UIHelper.escapeCoteValue(parseNull(jValues.getString(jt)))+"'></div>";
											}
											
											sFieldHtml += "</div>";
											sFieldHtml += "</div>";
											
											out.write(sFieldHtml);
										}
									}
								}
							}
							
							out.write("</div>");//row form-horizontal
						}%>
                    </div>
				</div>
			</div>
			<%}%>
			
            <div role="tabpanel" id="order_information" class="card card-primary tab-pane">

                <div class="card-header" role="tab" id="oderInfoHeading">

                    <h4 class="card-title">
                        <a class="collapsed" role="button" data-toggle="collapse"  href="#orderInfoCollapse" aria-expanded="false" aria-controls="orderInfoCollapse" onclick="toggleDiv('orderInfoCollapse')">
                          Order Information
                        </a>
                  </h4>
                </div>

                <div id="orderInfoCollapse" class='card-collapse collapse <% if(parseNull(uipreferencesMap.get("orderInfoCollapse")).equalsIgnoreCase("EXPANDED")) { %> show <% } %>' role="tabcard" aria-labelledby="oderInfoHeading">
                    <div class="card-body">
                        <table class="table" >
                            <thead class="thead-dark">
                                <tr>
                                    <th>SKU</th>
                                    <th>Product Name</th>
                                    <th>Quantity</th>
                                    <th>Price before discount</th>
                                    <th>Price after discount</th>
                                    <th>Delivery Fee</th>
                                    <th>Recurring price before discount</th>
                                    <th>Recurring price after discount</th>
                                    <th>Commitment</th>
                                    <th>Discount recurring duration</th>
                                </tr>
                            </thead>

                            <tbody>

                            <%

                                    Set rsMateriels;
                                    if(parseNull(GlobalParm.getParm("POST_WORK_SPLIT_ITEMS")).equals("0")){
                                        rsMateriels = Etn.execute("Select oi.* from order_items oi inner join orders o on o.parent_uuid = oi.parent_id where o.id = " + escape.cote(rsOrder.value("customerid")));
                                    }
                                    else{
                                        rsMateriels = Etn.execute("Select oi.* from order_items oi where oi.id = " + escape.cote(rsOrder.value("customerid")));
                                    }
                                    int totalQuantity = 0;
                                    double totalPriceAfterDiscount = 0;
                                    double totalRecurringPriceAfterDiscount = 0;
                                    //out.write("Select oi.* from order_items oi inner join orders o on o.parent_uuid = oi.parent_id where o.id = " + escape.cote(rsOrder.value("customerid")));
                                    while (rsMateriels.next()) {
                                        JSONObject productSnapshot = new JSONObject(rsMateriels.value("product_snapshot"));
                                        JSONObject promotion = new JSONObject(rsMateriels.value("promotion"));
                                        JSONArray attributes = new JSONArray(parseNull(productSnapshot.get("attributes")));
										
										boolean hasRecurringPrice = false;
										if(hasFrequency(rsMateriels.value("product_type"), productSnapshot.optString("frequency",""), productSnapshot.optString("product_version",""))) hasRecurringPrice = true;

                                        totalQuantity += parseNullInt(rsMateriels.value("quantity"));
                                        if(!hasRecurringPrice) totalPriceAfterDiscount += parseNullDouble(rsMateriels.value("price_value"));
                                        else totalRecurringPriceAfterDiscount += parseNullDouble(rsMateriels.value("price_value"));

                                        String attributesString = "";
                                        for(int i=0; i<attributes.length(); i++){
											String _attribValue = attributes.getJSONObject(i).optString("label","");
											if(_attribValue.length() == 0) _attribValue = attributes.getJSONObject(i).optString("value");
                                            attributesString += " "+_attribValue;
                                        }

                            %>
                                <tr>
                                    <td style="width: 100px;word-wrap: anywhere;"><%=UIHelper.escapeCoteValue((productSnapshot.has("sku")?productSnapshot.optString("sku"):""))%></td>
                                    <td><%=UIHelper.escapeCoteValue((rsMateriels.value("product_type").startsWith("offer_")?rsMateriels.value("product_name")+" "+productSnapshot.opt("variantName"):rsMateriels.value("product_full_name")+attributesString))%></td>
                                    <td><%=UIHelper.escapeCoteValue(rsMateriels.value("quantity"))%></td>
                                    <td><%=UIHelper.escapeCoteValue((!hasRecurringPrice && parseNullDouble(rsMateriels.value("price_old_value"))!=parseNullDouble(rsMateriels.value("price_value")))?PriceFormatter.formatPrice(Etn, siteid, lang, rsMateriels.value("price_old_value")):"")%></td>
                                    <td><%=UIHelper.escapeCoteValue(!hasRecurringPrice?PriceFormatter.formatPrice(Etn, siteid, lang, rsMateriels.value("price_value")):"")%></td>
									<td>
									<% if(productSnapshot.has("deliveryFeePerItem") == false) {%>
										&nbsp;
									<%}else{%>
										<%=UIHelper.escapeCoteValue((parseNullDouble(productSnapshot.opt("deliveryFeePerItem"))>0?PriceFormatter.formatPrice(Etn, siteid, lang, parseNullDouble(productSnapshot.opt("deliveryFeePerItem"))*parseNullInt(rsMateriels.value("quantity"))+""):""))%>
									<%}%>
									</td>
                                    <td><%=UIHelper.escapeCoteValue((hasRecurringPrice && parseNullDouble(rsMateriels.value("price_old_value"))!=parseNullDouble(rsMateriels.value("price_value")))?PriceFormatter.formatPrice(Etn, siteid, lang, rsMateriels.value("price_old_value"))	 + " /" + productSnapshot.optString("frequency",""):"")%></td>
                                    <td><%=UIHelper.escapeCoteValue(hasRecurringPrice?PriceFormatter.formatPrice(Etn, siteid, lang, rsMateriels.value("price_value")) + " /" + productSnapshot.optString("frequency",""):"")%></td>
                                    <td><%=UIHelper.escapeCoteValue((hasRecurringPrice && parseNullInt(productSnapshot.opt("duration"))!=0)?productSnapshot.optString("duration"):(hasRecurringPrice?"Sans Engagement":""))%></td>
                                    <td><%=UIHelper.escapeCoteValue(promotion.has("duration")&&parseNullInt(promotion.opt("duration"))>0?promotion.optString("duration"):"")%></td>
                                </tr>
                                <%
									JSONArray additionalFee = new JSONArray(rsMateriels.value("additionalfees"));
									for(int i=0; i<additionalFee.length(); i++)
									{
										if(parseNullDouble(additionalFee.getJSONObject(i).optString("price"))==0) continue;
										totalPriceAfterDiscount += parseNullDouble(additionalFee.getJSONObject(i).optString("price"));
                                %>
                                <tr style="color: gray">
                                    <td></td>
                                    <td><%=UIHelper.escapeCoteValue(additionalFee.getJSONObject(i).optString("name"))%></td>
                                    <td></td>
                                    <td></td>
                                    <td><%=UIHelper.escapeCoteValue(PriceFormatter.formatPrice(Etn, siteid, lang, additionalFee.getJSONObject(i).optString("price")))%></td>
                                    <td></td>
                                    <td></td>
                                    <td></td>
                                    <td></td>
                                    <td></td>
                                </tr>
                                <%}
                                        JSONArray comewith = new JSONArray(rsMateriels.value("comewiths"));
                                        for(int i=0; i<comewith.length(); i++){
                                            String priceLabel = "";
											String recurringPriceLabel = "";
                                            double comewithPrice = parseNullDouble(comewith.getJSONObject(i).getJSONObject("variant").optString("price"));
                                            if(!comewith.getJSONObject(i).getString("comewith").equals("label") && comewithPrice>0){
												
												if("offer_postpaid".equals(comewith.getJSONObject(i).getJSONObject("variant").optString("productType")) || (comewith.getJSONObject(i).getJSONObject("variant").optString("frequency","")).length() > 0)
												{
													totalRecurringPriceAfterDiscount += comewithPrice;
													recurringPriceLabel = PriceFormatter.formatPrice(Etn, siteid, lang, comewith.getJSONObject(i).getJSONObject("variant").optString("price")) + " /" + (comewith.getJSONObject(i).getJSONObject("variant").optString("frequency",""));
												}
												else
												{		
													totalPriceAfterDiscount += comewithPrice;                                                
													priceLabel = PriceFormatter.formatPrice(Etn, siteid, lang, comewith.getJSONObject(i).getJSONObject("variant").optString("price"));
												}
                                            }
											
											String comewithType = parseNull(comewith.getJSONObject(i).optString("variant_type"));
											if(comewithType.equals("select"))
											{
                                %>
                                <tr style="color: #00aaff">
                                    <td><%=UIHelper.escapeCoteValue(comewith.getJSONObject(i).getJSONObject("variant").optString("sku"))%></td>
                                    <td><%=UIHelper.escapeCoteValue(comewith.getJSONObject(i).optString("productName"))%>&nbsp;<%=UIHelper.escapeCoteValue(comewith.getJSONObject(i).optString("variantName"))%>&nbsp;<a href="<%=parseNull(comewith.getJSONObject(i).optString("imageUrl")).replace("/img/thumb/","/img/4x3/")%>" target="_blank"><img src='<%=comewith.getJSONObject(i).optString("imageUrl")%>' style='max-width:40px;max-height:40px'></a></td>
                                    <td></td>
                                    <td></td>
                                    <td><%=UIHelper.escapeCoteValue(priceLabel)%></td>
                                    <td></td>
                                    <td></td>
                                    <td><%=UIHelper.escapeCoteValue(recurringPriceLabel)%></td>
                                    <td></td>
                                    <td></td>
                                </tr>
								<%
											}
											else
											{
                                %>
                                <tr style="color: #00aaff">
                                    <td></td>
                                    <td><%=UIHelper.escapeCoteValue(comewith.getJSONObject(i).optString("title"))%></td>
                                    <td></td>
                                    <td></td>
                                    <td><%=UIHelper.escapeCoteValue(priceLabel)%></td>
                                    <td></td>
                                    <td></td>
                                    <td><%=UIHelper.escapeCoteValue(recurringPriceLabel)%></td>
                                    <td></td>
                                    <td></td>
                                </tr>
								<%	}//else
								}//for
                                    }//while (rsMateriels.next())

                                    double paymentFees = parseNullDouble(rsOrder.value("payment_fees"));
                                    double deliveryFees = parseNullDouble(rsOrder.value("delivery_fees"));
                                %>
                                <tr>
                                    <th></th>
                                    <th>sub-total</th>
                                    <th><%=totalQuantity%></th>
                                    <th></th>
                                    <th><%=UIHelper.escapeCoteValue(PriceFormatter.formatPrice(Etn, siteid, lang, new BigDecimal(totalPriceAfterDiscount+"").toPlainString()))%></th>
                                    <th></th>
                                    <th></th>
                                    <th><%=UIHelper.escapeCoteValue(totalRecurringPriceAfterDiscount>0?PriceFormatter.formatPrice(Etn, siteid, lang, new BigDecimal(totalRecurringPriceAfterDiscount+"").toPlainString()):"")%></th>
                                    <th></th>
                                    <th></th>
                                </tr>
                                <%
                                    JSONObject orderSnapshot = new JSONObject(rsOrder.value("order_snapshot"));									
									String totalTax = parseNull(orderSnapshot.optString("totalTax"));
									String totalToPay = parseNull(orderSnapshot.optString("grandTotal"));
									boolean hasShippingDiscountCartRule = false;
									JSONObject promoCodeDiscountObj = null;
                                    if(orderSnapshot.has("calculatedCartDiscounts")){
                                        JSONArray calculatedCartDiscounts = orderSnapshot.optJSONArray("calculatedCartDiscounts");
                                        for(int i=0; i<calculatedCartDiscounts.length(); i++){
											if(calculatedCartDiscounts.getJSONObject(i).optString("couponCode","").length() > 0) promoCodeDiscountObj = calculatedCartDiscounts.getJSONObject(i);
											if(calculatedCartDiscounts.getJSONObject(i).optString("elementOn").equals("shipping_fee")) 
											{
												hasShippingDiscountCartRule = true;
												continue;
											}
                                %>
                                <tr>
                                    <th></th>
                                    <th>
										<% if(calculatedCartDiscounts.getJSONObject(i).optString("couponCode").length()>0){
											out.write(UIHelper.escapeCoteValue("promo code discount '"+calculatedCartDiscounts.getJSONObject(i).optString("couponCode")+"'"));
										}
										else
										{
											out.write("cart discount "+parseNull(calculatedCartDiscounts.getJSONObject(i).optString("ruleAppliedOn")));											
										}
										%>
									</th>
                                    <th></th>
                                    <th></th>
                                    <th>-<%=UIHelper.escapeCoteValue(calculatedCartDiscounts.getJSONObject(i).optString("discountValue"))%></th>
                                    <th></th>
                                    <th></th>
                                    <th></th>
                                    <th></th>
                                    <th></th>
                                </tr>
                                <%
                                        }
                                    }
                                %>
                                <tr>
                                    <th></th>
                                    <th>
										delivery fees
										<% if(hasShippingDiscountCartRule){%>
										<div style='color:red;font-size:11px'>After discount</div>
										<%}%>
									</th>
                                    <th></th>
                                    <th></th>
                                    <th><%=PriceFormatter.formatPrice(Etn, siteid, lang, new BigDecimal(deliveryFees+"").toPlainString())%></th>
                                    <th></th>
                                    <th></th>
                                    <th></th>
                                    <th></th>
                                    <th></th>
                                </tr>
                                <tr>
                                    <th></th>
                                    <th>payment fees</th>
                                    <th></th>
                                    <th></th>
                                    <th><%=PriceFormatter.formatPrice(Etn, siteid, lang, new BigDecimal(paymentFees+"").toPlainString())%></th>
                                    <th></th>
                                    <th></th>
                                    <th></th>
                                    <th></th>
                                    <th></th>
                                </tr>
								<%if(parseNullDouble(totalTax) > 0){%>
                                <tr>
                                    <th></th>
                                    <th>tax</th>
                                    <th></th>
                                    <th></th>
                                    <th><%=PriceFormatter.formatPrice(Etn, siteid, lang, totalTax)%></th>
                                    <th></th>
                                    <th></th>
                                    <th></th>
                                    <th></th>
                                    <th></th>
                                </tr>
								<%}%>
                                <tr>
                                    <th></th>
                                    <th>total <%=(rsOrder.value("spaymentmean").equals("cash_on_delivery")||rsOrder.value("spaymentmean").equals("cash_on_pickup"))?"to pay":"paid"%></th>
                                    <th></th>
                                    <th></th>
                                    <th><%=PriceFormatter.formatPrice(Etn, siteid, lang, new BigDecimal(totalToPay).toPlainString())%></th>
                                    <th></th>
                                    <th></th>
                                    <th></th>
                                    <th></th>
                                    <th></th>
                                </tr>

                            </tbody>
                        </table>
<!--                        <div class="row">-->
                            <div class="row form-horizontal">
                                <%
                                    previousSection = "";
                                    //Set rsMateriels = Etn.execute("Select oi.* from order_items oi, orders o where o.parent_uuid = oi.parent_id and o.id = " + escape.cote(rsOrder.value("customerid")));
                                    //rsMateriels.next();
                                    Set rsOrderInfo = Etn.execute("select fn.*, isEditable, isHidden, isMandatory from field_names fn left join field_settings fs on fn.fieldName=fs.fieldName and fn.screenName=fs.screenName and phase="+escape.cote(rsStatus.value("phase"))+"  where fn.screenName = 'CUSTOMER_EDIT' and tab = 'Order Information' and COALESCE(isHidden,0)<>1 order by sectionDisplaySeq, fieldDisplaySeq;");
                                    while(rsOrderInfo.next()){
                                        if(!previousSection.equals(rsOrderInfo.value("section"))) out.write("<h3 class=\"col-12 h4\">"+rsOrderInfo.value("section")+"<hr></h3>");
                                        previousSection = rsOrderInfo.value("section");
										
									if(parseNull(rsOrderInfo.value("input_type")).equals("jsontext")){
										String _qry = parseNull(rsOrderInfo.value("query"));
										if(_qry.length() > 0 && _qry.startsWith("order_snapshot."))
										{
											JSONObject _jObj = new JSONObject(parseNull(rsOrder.value("order_snapshot")));
											String _val = parseNull(_jObj.getString(_qry.replace("order_snapshot.","")));
										%>
										<div class="col-sm-6">
											<div class="form-group row">
												<p class="col-sm-4 control-label" style="text-align: left;"><%=UIHelper.escapeCoteValue(rsOrderInfo.value("displayName"))%></p>
												<div class="col-sm-8">
													<input type="text" class="form-control" readonly value="<%=_val%>">
												</div>
											</div>
										</div>									
										<%
										}
									}
									else
									{
                                        Map<String, String> selectMap = null;
                                        String selectQuery = rsOrderInfo.value("query");
                                        if(!selectQuery.equals("")){
                                            selectQuery = selectQuery.replaceAll("GlobalParm_CATALOG_DB",catalogdb).replaceAll("Orders_SITE_ID",rsOrder.value("site_id"));
                                            Pattern pattern = Pattern.compile("\\$(.*?)\\$");
                                            Matcher matcher = pattern.matcher(selectQuery);
                                            while(matcher.find())
                                            {
                                                selectQuery = selectQuery.replace(matcher.group(0), escape.cote(rsOrder.value(matcher.group(1))));
                                            }
                                            //out.write(selectQuery);

                                            Set selectRs = Etn.execute(selectQuery);
                                            if(rsOrderInfo.value("fieldName").contains("resource")){
                                                selectRs.next();
                                                selectMap = getResourcesMap(parseNull(selectRs.value(0)));
                                            }
                                            else selectMap = getHashMap(selectRs);

                                            //selectMap = getHashMap(Etn.execute(selectQuery)); // getResourcesMap(parseNull(selectRs.value(0)))
                                        }

                                        String fieldValue = "";
                                        if(rsOrderInfo.value("fieldName").indexOf("_time")!=-1) fieldValue = getTime(parseNullInt(fieldValue));
										else if(rsOrderInfo.value("fieldName").equals("remaining_promo_value")){											
											if(promoCodeDiscountObj != null)
											{
												fieldValue = ""+(parseNullDouble(promoCodeDiscountObj.optString("originalRuleValue")) - parseNullDouble(promoCodeDiscountObj.optString("discountValue")));
												fieldValue = PriceFormatter.formatPrice(Etn, siteid, lang, fieldValue);
											}
										}
										else fieldValue = rsOrder.value(rsOrderInfo.value("fieldName"));
                                %>
                                <div class="col-sm-6">
                                <div class="form-group row">
                                    <p class="col-sm-4 control-label" style="text-align: left;"><%=UIHelper.escapeCoteValue(rsOrderInfo.value("displayName"))%></p>
                                    <div class="col-sm-8">
                                    	<p>
											<% if(rsOrderInfo.value("isLabel").equals("1")){%>
											<span style="display:block"><%=UIHelper.escapeCoteValue(fieldValue)%></span>
											<%} else {%>
                                    		<%=generateFieldHtml(editableFields, mandatoryFields, userProfile, "", rsOrderInfo.value("fieldName"), rsOrderInfo.value("fieldName"), fieldValue, parseNull(rsOrderInfo.value("input_type")), "onchange='tryLock()'", "32", "30", "", selectMap)%>
											<%}%>
                                    	</p>
                                    </div>
                                </div>
                                </div>
                                <%
									}//else
                                }
                                %>
                            </div>
<!--                        </div>-->
                    </div>
                </div>
            </div>
	    <%
            if(calendarPhase.equals("")){
            %>
            <div role="tabpanel" id="status_history" class="card card-primary tab-pane">

                <div class="card-header" role="tab" id="statusHistoryHeading">

                    <h4 class="card-title">
                        <a class="collapsed" role="button" data-toggle="collapse"  href="#statusHistoryCollapse" aria-expanded="false" aria-controls="statusHistoryCollapse" onclick="toggleDiv('statusHistoryCollapse')">
                          Status History
                        </a>
                    </h4>
                </div>

                <div id="statusHistoryCollapse" class='panel-collapse collapse <% if(parseNull(uipreferencesMap.get("statusHistoryCollapse")).equalsIgnoreCase("EXPANDED")) { %> show <% } %>' role="tabpanel" aria-labelledby="statusHistoryHeading">

                    <div class="card-body">

                        <table class="table">

                            <thead class="thead-dark">
                                <tr>
                                    <th>Date</th>
                                    <th>Phase</th>
                                    <th>Operator</th>
                                    <th>Message</th>
                                </tr>
                            </thead>

                            <tbody>

							<%
								qry = "SELECT *, ph.displayName from post_work pw, phases ph where pw.is_generic_form = 0 and pw.proces = ph.process and pw.phase = ph.phase and client_key = " + escape.cote(rsOrder.value("customerId")) + " ";
								if(!userProfile.equals("ADMIN") && !userProfile.startsWith("SUPER_ADMIN")) qry += " and ph.oprType = 'O' ";
								if(!userProfile.startsWith("SUPER_ADMIN")) qry += " and ph.visc=1 ";
								qry += " order by insertion_date ASC, id ASC ";

								Set rsHistoricStatus = Etn.execute(qry);

								String prevLineErrMsg = "";
								String prevLineOperador = "";

								while (rsHistoricStatus.next()) {
							%>
                                <tr>
                                    <td><%=UIHelper.escapeCoteValue(rsHistoricStatus.value("insertion_date"))%></td>
                                    <td><%=UIHelper.escapeCoteValue(rsHistoricStatus.value("displayName"))%></td>
                                    <td><%=UIHelper.escapeCoteValue(prevLineOperador)%></td>
                                    <td>
									<%
										if("".equals(prevLineErrMsg) && "0".equals(rsHistoricStatus.value("nextid")) && !"0".equals(rsHistoricStatus.value("errcode"))) out.write(UIHelper.escapeCoteValue(parseNull(rsHistoricStatus.value("errMessage"))));
										else out.write(UIHelper.escapeCoteValue(prevLineErrMsg));
									%>
                                    </td>
                                </tr>
							<%
								prevLineErrMsg = parseNull(rsHistoricStatus.value("errMessage"));
								prevLineOperador = parseNull(rsHistoricStatus.value("operador"));
							}
							%>

                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div role="tabpanel" id="observations" class="card card-primary tab-pane">
                <div class="card-header" role="tab" id="observationHeading">
                    <h4 class="card-title">
                        <a class="collapsed" role="button" data-toggle="collapse"  href="#observationCollapse" aria-expanded="false" aria-controls="observationCollapse" onclick="toggleDiv('observationCollapse')">
                          Observations
                        </a>
                    </h4>
                </div>
                <div id="observationCollapse" class='card-collapse collapse <% if(parseNull(uipreferencesMap.get("observationCollapse")).equalsIgnoreCase("EXPANDED")) { %> show <% } %>' role="tabpanel" aria-labelledby="observationHeading">
                    <div class="card-body">
                        <div class="form-group row">
                            <textarea class="form-control" name="comments" id="comments" cols="30" rows="4" placeholder="Insert your comments here."></textarea>
                        </div>
                        <button onclick="onSaveComments()" type="button" class="btn btn-primary">Save Comments</button>
                        <hr>
                        <div class="responsive-table">
                            <table class="table">
                                <thead class="thead-dark">
                                    <tr>
                                        <th>Date</th>
                                        <th>Phase</th>
                                        <th>Operator</th>
                                        <th>Observation</th>
                                    </tr>
                                </thead>
                                <tbody>
                                	<%=(parseNull(rsStatus.value("comments")))%>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            <%
            }
            %>
		</div>
    </div>
</main>
  <%
      } else {
                out.write("Error order");
            }
  %>
<div style="clear:both"></div>

</form>
<%
    } else {
        out.write("Error, no order found");
%><meta http-equiv='refresh' content="2;URL=ibo.jsp" >
<%
    }
%>

<div class="modal fade" id="dialogWindow" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="exampleModalLabel">Order flow</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body overflow-auto">
      </div>
	  <div class="modal-footer">
      </div>
    </div>
  </div>
</div>

<div class="modal fade" id="imagemodal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" style="text-align:center;">
  <div class="modal-dialog" style="width: auto;display:inline-block">
    <div class="modal-content">
      <div class="modal-header">
	  	Image
        <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
      </div>
      <div class="text-center modal-body" style="padding:0">
        <img src="" id="imagepreview" class="w-100">
      </div>
    </div>
  </div>
</div>

<script src="js/bootstrap.min.js"></script>
			</main>
		</div>
	</div>
</body>

    <script type="text/javascript">
		function onDeliveryDateChange()
		{			
			let dateString = jQuery(".delivery_date").val();
			let [day, month, year] = dateString.split('/')
			const dateObj = new Date(+year, +month - 1, +day);
			let _day = dateObj.getDay() - 1;
			if(_day < 0) _day = 6;
			
			console.log(dateObj);
			console.log(_day);
			
			jQuery(":hidden[name=delivery_start_hour]").val("");
			jQuery(":hidden[name=delivery_start_min]").val("");
			jQuery(":hidden[name=delivery_end_hour]").val("");
			jQuery(":hidden[name=delivery_end_min]").val("");
			
			jQuery(".delivery_slots_container").removeClass("d-none");
			jQuery(".delivery_slots_container").addClass("d-none");
			jQuery(".delivery_slots_container[data-day='"+_day+"'").removeClass("d-none");
			jQuery(".delivery_slots_container[data-day='"+_day+"'").find(".delivery_slots").val("-1");
			jQuery(".hidden_delivery_slot").val("");
		}
		
		function disableDays(date)
		{
			//we go with mariadb standard where monday is 0 and sunday is 6
			let _day = date.getDay() - 1;
			if(_day < 0) _day = 6;
			<%for(String ed : excludeDayNos){
				out.write("if(_day === "+parseNullInt(ed)+") return true;\n");
			}%>			
		}
		
		jQuery(document).ready(function() {
			
			jQuery(".delivery_slots").change(function(){
				jQuery(".hidden_delivery_slot").val("");
				if(jQuery(this).val() != "-1")
				{
					let sd = jQuery(this).find(":selected").attr("data-s-day");
					let sm = jQuery(this).find(":selected").attr("data-s-min");
					let ed = jQuery(this).find(":selected").attr("data-e-day");
					let em = jQuery(this).find(":selected").attr("data-e-min");
					
					jQuery(":hidden[name=delivery_start_hour]").val(sd);
					jQuery(":hidden[name=delivery_start_min]").val(sm);
					jQuery(":hidden[name=delivery_end_hour]").val(ed);
					jQuery(":hidden[name=delivery_end_min]").val(em);

					if(sd.length < 2) sd = "0"+sd;
					if(sm.length < 2) sm = "0"+sm;
					if(ed.length < 2) ed = "0"+ed;
					if(em.length < 2) em = "0"+em;
					jQuery(".hidden_delivery_slot").val(sd+"H"+sm+" - " +ed+"H"+em);					
				}
			});
			
			if(jQuery(".delivery_date").attr("readonly") ==  undefined)
			{
				const aYearFromNow = new Date();
				aYearFromNow.setFullYear(aYearFromNow.getFullYear() + 1);				
				flatpickr(".delivery_date", {
					minDate: "today",
					maxDate: aYearFromNow,
					dateFormat: 'd/m/Y',
					onClose: onDeliveryDateChange,
					shorthandCurrentMonth: true,
					"disable": [ disableDays, 
					<%for(String ed : localholidays) { out.write("\""+ ed + "\","); }%>
					],
				});

			}
			jQuery(".delivery_date").on("click",function(e){
				e.preventDefault();
			})    
			
			jQuery("#pop").on("click", function(e) {
				e.preventDefault();
				jQuery('#imagepreview').attr('src', jQuery('#imageresource').attr('src'));
				jQuery('#imagemodal').modal('show');
			});
			<% if(parseNull(request.getParameter("_phasechangesucc")).equals("1")) {%>
				jQuery("#succMsgDiv").html("Order phase changed successfully");
				jQuery("#succMsgDiv").fadeIn();
				jQuery('#succMsgDiv').delay(2000).fadeOut();
			<%}%>

			<% if(message.length() > 0) {%>
				jQuery("#succMsgDiv").html("<%=message%>");
				jQuery("#succMsgDiv").fadeIn();
				jQuery('#succMsgDiv').delay(2000).fadeOut();
			<%}%>

			<% if(userProfile.equals("CSR_TELE") || userProfile.equals("MGR_TELE")) { %>
					document.getElementById("customerData").style.display = 'none';
					document.getElementById('customerDataLbl').innerHTML = '+';
					document.getElementById("statusData").style.display = 'none';
					document.getElementById('statusDataLbl').innerHTML = '+';
					document.getElementById("commentsData").style.display = 'none';
					document.getElementById('commentsDataLbl').innerHTML = '+';
			<% } %>

			<% if(userProfile.equals("CSR_ACTIVE") || userProfile.equals("MGR_ACTIVE")) { %>
					document.getElementById("customerData").style.display = 'block';
					document.getElementById('customerDataLbl').innerHTML = '-';
					document.getElementById("statusData").style.display = 'none';
					document.getElementById('statusDataLbl').innerHTML = '+';
					document.getElementById("commentsData").style.display = 'none';
					document.getElementById('commentsDataLbl').innerHTML = '+';
			<% } %>


			<% for(String f : hiddenFields) {
			%>
				if(jQuery('#<%=f%>_label').length > 0) jQuery('#<%=f%>_label').hide();
				else if (jQuery('.<%=f%>_label').length > 0) jQuery('.<%=f%>_label').hide();

				if(jQuery('#<%=f%>_val').length > 0) jQuery('#<%=f%>_val').hide();
				else if (jQuery('.<%=f%>_val').length > 0) jQuery('.<%=f%>_val').hide();
			<% } %>

			<% if(userProfile.equals("ADMIN") || userProfile.startsWith("SUPER_ADMIN")) { %>
				jQuery("#someinfoforadmins").show();
			<% } %>

		jQuery(".nav.nav-tabs li a").click(function(e){
			var href = jQuery(this).attr("href");
			var dataDivId = jQuery(this).attr("id");
			var tabId = jQuery(this).attr("name");
			e.preventDefault();

			jQuery(href+" .panel-collapse").collapse('toggle');

			jQuery('html, body').animate({
				scrollTop: jQuery(href+" .panel-collapse").offset().top
			}, 300);
		});

		tryLock();


                    jQuery(window).on('beforeunload', function(){
                        unlockRecord();
                    });
		});

                function openImage(src){
                    jQuery('#imagepreview').attr('src', src);
                    jQuery('#imagemodal').modal('show');
                }
// 				function selesectTab(){
// //			$(".panel-collapse").collapse("show");
// 			jQuery('# .in').collapse('hide');
// 		}
    </script>
</html>
