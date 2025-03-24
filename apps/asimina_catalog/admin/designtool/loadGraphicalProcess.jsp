 <jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.lang.Math"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.LinkedHashMap"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>

<%@ include file="common.jsp" %>

<%!
	int GetNumberOfOpenOrders(com.etn.beans.Contexte etn, String process, String phase, String customerIdsList)
	{
		String qry = " select count(client_key) as count from post_work where proces = "+escape.cote(process)+" and phase = "+escape.cote(phase)+" and status in (0,1) "; 
		if(!customerIdsList.equals(""))
			qry += " and client_key in ("+customerIdsList+") ";
		qry += " order by id desc  ";
		Set rs = etn.execute(qry);
		rs.next();
		return Integer.parseInt(rs.value("count"));
	}

	int GetOpenOrdersForErrorCode(com.etn.beans.Contexte etn, String process, String currentPhase, String errCode, String customerIdsList)
	{
		String query = "select count(client_key) as count from post_work where proces = "+escape.cote(process)+" and phase="+escape.cote(currentPhase)+" " +
				" and errCode = '"+errCode+"' and status in (0,1) ";
		if(!customerIdsList.equals(""))
			query += " and client_key in ("+customerIdsList+") ";
		Set rs = etn.execute(query);
		rs.next();
		return Integer.parseInt(rs.value("count"));
	}

	String ChangeMilisecondsForDisplay(float miliseconds)
	{
		if (miliseconds <= 0) return "";
		return ((int)(miliseconds / (1000*60*60))/24 + "Day(s) " + (int)((miliseconds / (1000*60*60)) % 24) + "hrs " + (int)(miliseconds % (1000*60*60)) / (1000*60) + "mins " + (int)((miliseconds % (1000*60*60)) % (1000*60)) / 1000 + "sec");	
	}

	float GetAvgProcessingTimeInPhase(com.etn.beans.Contexte etn, String process, String phase, String customerIdsList) throws Exception
	{
		String qry = " select end, ifnull(start, insertion_date) start from post_work where proces = "+escape.cote(process)+" and phase = "+escape.cote(phase)+" and status not in (0,1) ";
		if(!customerIdsList.equals(""))
			qry += " and client_key in ("+customerIdsList+") ";		
		qry += " order by id desc limit 50 ";	
		
		Set rs = etn.execute(qry);
		int count = 0;
		float diff = 0;
        	DateFormat df = new SimpleDateFormat("dd/MM/yyyy hh:mm:ss");	
		while(rs.next())
		{
			if(rs.value("end") != null && !rs.value("end").equals(""))
			{
				Date finishDate = df.parse(rs.value("end"));
				Date startDate = df.parse(rs.value("start"));
				diff = diff + (finishDate.getTime() - startDate.getTime());
				count ++;
			}
		}
		if(count > 0)
		{
			return diff / count;	
		}
		return 0;		
	}

	float GetVarianceOfProcessingTimeInPhase(com.etn.beans.Contexte etn, String process, String phase, float mean, String customerIdsList) throws Exception
	{
		String qry = " select end, ifnull(start, insertion_date) start from post_work where proces = "+escape.cote(process)+" and phase = "+escape.cote(phase)+" and status not in (0,1) "; 
		if(!customerIdsList.equals(""))
			qry += " and client_key in ("+customerIdsList+") ";		
		qry += " order by id desc limit 50 ";	
		
		Set rs = etn.execute(qry);
		int count = 0;
		float total = 0;
        	DateFormat df = new SimpleDateFormat("dd/MM/yyyy hh:mm:ss");	
		while(rs.next())
		{
			if(rs.value("end") != null && !rs.value("end").equals(""))
			{
				Date finishDate = df.parse(rs.value("end"));
				Date startDate = df.parse(rs.value("start"));
				float diffFromMean = ((finishDate.getTime() - startDate.getTime()) - mean);
				diffFromMean = diffFromMean * diffFromMean;
				total = total + diffFromMean;
				count ++;
			}
		}
		if(count > 0)
		{
			return total/count;	
		}
		return 0;		
	}

	float GetAvgProcessingTimeUptoPhase(com.etn.beans.Contexte etn, String process, String phase, String customerIdsList) throws Exception
	{
		String qry = " select end, ifnull(start, insertion_date) start from post_work where proces = "+escape.cote(process)+" and phase = "+escape.cote(phase)+" and status not in (0,1) ";
		if(!customerIdsList.equals(""))
			qry += " and client_key in ("+customerIdsList+") ";		
		qry += " order by id desc limit 50 ";	
		
		Set rs = etn.execute(qry);
		int count = 0;
		float diff = 0;
		Date startDateFirstPhase = GetStartDateOfProcess(etn, process, customerIdsList);
		if(startDateFirstPhase == null) return 0;

        	DateFormat df = new SimpleDateFormat("dd/MM/yyyy hh:mm:ss");	
		while(rs.next())
		{
			if(rs.value("end") != null && !rs.value("end").equals(""))
			{
				Date finishDate = df.parse(rs.value("end"));
				diff = diff + (finishDate.getTime() - startDateFirstPhase.getTime());
				count ++;
			}
		}
		if(count > 0)
		{
			return diff / count;
		}
		return 0;		
	}

	float GetVarianceOfProcessingTimeUptoPhase(com.etn.beans.Contexte etn, String process, String phase, float mean, String customerIdsList) throws Exception
	{
		String qry = " select end, ifnull(start, insertion_date) start from post_work where proces = "+escape.cote(process)+" and phase = "+escape.cote(phase)+" and status not in (0,1) ";
		if(!customerIdsList.equals(""))
			qry += " and client_key in ("+customerIdsList+") ";		
		qry += " order by id desc limit 50 ";	
		
		Set rs = etn.execute(qry);
		int count = 0;
		float total = 0;
		Date startDateFirstPhase = GetStartDateOfProcess(etn, process, customerIdsList);
		if(startDateFirstPhase == null) return 0;

        	DateFormat df = new SimpleDateFormat("dd/MM/yyyy hh:mm:ss");	
		while(rs.next())
		{
			if(rs.value("end") != null && !rs.value("end").equals(""))
			{
				Date finishDate = df.parse(rs.value("end"));
				float diffFromMean = ((finishDate.getTime() - startDateFirstPhase.getTime()) - mean);
				diffFromMean = diffFromMean * diffFromMean;
				total = total + diffFromMean;
				count ++;
			}
		}
		if(count > 0)
		{
			return total/count;	
		}
		return 0;		
	}

	Date GetStartDateOfProcess(com.etn.beans.Contexte etn, String process, String customerIdsList) throws Exception
	{
		String qry = " select distinct start_phase from rules where start_phase not in (select next_phase from rules where next_proc = " + escape.cote(process) + ") and start_proc = " + escape.cote(process) + " ";
		Set rs = etn.execute(qry);
		rs.next();
		String minStartDateQry = "select min(ifnull(start, insertion_date)) as start from post_work where phase = "+escape.cote(rs.value("start_phase"))+" and proces = " + escape.cote(process )+ " and status not in (0,1) ";
		if(!customerIdsList.equals(""))
			minStartDateQry += " and client_key in ("+customerIdsList+") ";		
		minStartDateQry += " order by id desc limit 50";
		
		rs = etn.execute(minStartDateQry);
		if(rs.next())
		{
			try{
				DateFormat df = new SimpleDateFormat("dd/MM/yyyy hh:mm:ss");	
				return df.parse(rs.value("start"));	
			}catch(Exception ex){
				return null;
			}
		}
		else
		{
			return null;
		}
	}
	boolean IsStartPhase(com.etn.beans.Contexte etn, String process, String phase) throws Exception
	{
		String qry = " select count(0) as count from rules where start_proc = " + escape.cote(process )+ " and start_phase = "+escape.cote(phase)+" ";
		Set rs = etn.execute(qry);
		rs.next();
		int startPhaseCount = Integer.parseInt(rs.value("count"));
		if(startPhaseCount > 0)
		{
			qry = " select count(0) as count from rules where next_proc = " + escape.cote(process) + " and next_phase = "+escape.cote(phase)+" ";
			rs = etn.execute(qry);
			rs.next();
			int nextPhaseCount = Integer.parseInt(rs.value("count"));
			if(nextPhaseCount == 0) //means its the starting phase
				return true;
			else
				return false;
		}
		else
			return false;
	}

	boolean IsEndPhase(com.etn.beans.Contexte etn, String process, String phase) throws Exception
	{
		String qry = " select count(0) as count from rules where start_proc = " + escape.cote(process )+ " and start_phase = "+escape.cote(phase)+" ";
		Set rs = etn.execute(qry);
		rs.next();
		int startPhaseCount = Integer.parseInt(rs.value("count"));
		if(startPhaseCount == 0)
		{
			qry = " select count(0) as count from rules where next_proc = " + escape.cote(process )+ " and next_phase = "+escape.cote(phase)+" ";
			rs = etn.execute(qry);
			rs.next();
			int nextPhaseCount = Integer.parseInt(rs.value("count"));
			if(nextPhaseCount > 0) //means its the starting phase
				return true;
			else
				return false;
		}
		else
			return false;
	}

%>
<%

	String process 	  = parseNull(request.getParameter("process"));
	String screenMode = parseNull(request.getParameter("screenMode"));
	String partialUpdate = parseNull(request.getParameter("partialUpdate"));
	if(partialUpdate.equals("")) partialUpdate = "false";
	
	int defaultXCoord = 210;
	int defaultYCoord = 10;
	int defaultWidth  = 120;
	int defaultHeight = 80;
	boolean showLabelsByDefault = Boolean.parseBoolean(parseNull(request.getParameter("showLabels")));

	String customerIdsList = parseNull(request.getParameter("customerIdsList"));

	Set rsProfiles = Etn.execute("select * from profil where profil not like 'SUPER_ADMIN%' order by description");	
	
%>

<script type="text/javascript">

var selectedProcess;
var selectedPhase;

var allProfiles = [];
<% while(rsProfiles.next()) { %>
	var curProfile = {name:'<%=rsProfiles.value("profil")%>',displayName:'<%=rsProfiles.value("description")%>'};
	allProfiles.push(curProfile);
<% } %>
function onClickDetails(process, phase)
{	
	selectedProcess = process;
	selectedPhase = phase;

	var data =  "process="+process+"&phase="+phase+"&customerIdsList=<%=com.etn.asimina.util.UIHelper.escapeCoteValue(customerIdsList)%>";
	jQuery.ajax({
		url: 'processOpenOrders.jsp',
		type: 'POST',
		data: data,
		success: function(resp) {
			resp = jQuery.trim(resp);
			jQuery("#modalWindow").dialog("option","title","Details");
			jQuery("#modalWindow").dialog("option","width",1050);
			jQuery("#modalWindow").dialog("option","height",450);
			jQuery('#modalWindow').unbind("dialogclose");	   
			jQuery("#modalWindow").html(resp);
			jQuery("#modalWindow").dialog('open');
		}
	});				
}

function viewOrderFlow(process, phase, idPanier)
{
	jQuery.ajax({
		url: 'orderFlow.jsp',
		type: 'POST',
		data: {customerId : idPanier, fromDialog: true},
		success: function(resp) {
			resp = jQuery.trim(resp);			
			jQuery("#modalWindow").html(resp);
			jQuery('#modalWindow').bind("dialogclose", function(event, ui) 
			{  
				onClickDetails(selectedProcess, selectedPhase);			
			});								
		}
	});				
}

function onChangePhase(process, phase, orderId)
{
	jQuery.ajax({
		url: 'cli.jsp',
		type: 'POST',
		data: {id_pedido : orderId, fromDialog: true, isAdmin : true},
		success: function(resp) {
			resp = jQuery.trim(resp);			
			jQuery("#modalWindow").html(resp);
			jQuery('#modalWindow').bind("dialogclose", function(event, ui) 
			{  
				onClickDetails(selectedProcess, selectedPhase);			
			});								
		}
	});				
}

function printDiv(divId) 
{
    var html = document.getElementById(divId).innerHTML;
    var w = document.getElementById("ifmPrintContents").contentWindow;
	html = '<div style="font-family: arial;">' + html + '</div>';
	w.document.open();	
    w.document.write(html);
	w.document.close();
	w.focus();
	w.print();
}

var process ;
var workflow = null;
var profileObjs = new Array();	
<% if(process != null && !process.equals("#") && !process.equals("")) 
	{ %> 			
		jQuery('#toolBarDiv').show();		
		if(jQuery('#toolBar1')) jQuery('#toolBar1').show();
		if(jQuery('#toolBar2')) jQuery('#toolBar2').show();
				
		document.forms[0].process.value = '<%=com.etn.asimina.util.UIHelper.escapeCoteValue(process)%>';
		process = document.forms[0].process.value;

		<%
			//this is to check if there is any incoming link from external phase for which coordinates are not yet saved in db, then we have to show that on top of screen
			int deltaY = 0;
			Set rs3 = Etn.execute("select * from rules where start_proc != next_proc and next_proc = "+escape.cote(process));
			while(rs3.next())
			{
				Set rs4 = Etn.execute("select * from external_phases where start_proc = "+escape.cote(process)+" and next_proc = "+escape.cote(rs3.value("start_proc"))+" and next_phase = "+escape.cote(rs3.value("start_phase")));
				if(rs4.rs.Rows == 0) 
				{
					deltaY = 100;
					break;
				}
			}			
		
			String Qry = "select distinct process, phase, displayName, rulesVisibleTo, visc, ifnull(topLeftX,"+defaultXCoord+") as topLeftX, ifnull(topLeftY,"+defaultYCoord+") as topLeftY , width, height, actors, priority, execute from phases where process = " + escape.cote(process )+ " ";
			Set result = Etn.execute(Qry);
		%>
		workflow  = new draw2d.GizmoWorkflow(process, "divGraph","modalWindow");
		if(navigator.userAgent.indexOf("MSIE")) workflow.isIE = true;
		workflow.deltaY = '<%=deltaY%>';
		<%
			int defaultProfileXCoord = 10;
			int defaultProfileYCoord = 10;
			int defaultProfileWidth = 300;
			int defaultProfileHeight = 500;
			rsProfiles.moveFirst();
			while(rsProfiles.next())
			{
				int cX = defaultProfileXCoord;
				int cY = defaultProfileYCoord;
				int cW = defaultProfileWidth;
				int cH = defaultProfileHeight;
				Set profCoordinates = Etn.execute("select * from coordinates where process = "+escape.cote(process)+" and profile  = "+escape.cote(rsProfiles.value("profil"))+" and (phase is null or phase = '')");
				if(profCoordinates.rs.Rows > 0)
				{
					profCoordinates.next();
					cX = Integer.parseInt(profCoordinates.value("topLeftX"));
					cY = Integer.parseInt(profCoordinates.value("topLeftY"));
					cW = Integer.parseInt(profCoordinates.value("width"));
					cH = Integer.parseInt(profCoordinates.value("height"));
				}
		%>
				var profObj = new draw2d.GizmoProfileFigure('<%=rsProfiles.value("profil")%>', '<%=rsProfiles.value("description")%>', <%=cW%>, <%=cH%>, '<%=process%>');
				workflow.addFigure(profObj, <%=cX%>,<%=cY+deltaY%>);				
				workflow.addProfileFigure(profObj);
				profObj.html.style.cursor="";
				profileObjs.push(profObj);
				
		<%  
				defaultProfileXCoord += 305;
			} %>

		<%Map<String, Integer> SearchForConnection = new LinkedHashMap<String, Integer>(); //hash map for searching values for connections.
		int i=0;%>
		obj = new Array();
		<%
		
		while(result.next())
		{
			SearchForConnection.put(result.value("phase"), i);
		
		// Old Code Start
		
//			String val = (String)phases.get(result.value("phase"));
			//String[] coordinates = val.split(",");
			int numberOfOpenOrders = GetNumberOfOpenOrders(Etn, process, result.value("phase"), customerIdsList);
			float avgProcessingMiliseconds = GetAvgProcessingTimeInPhase(Etn, process, result.value("phase"), customerIdsList);
			String avgProcessingTime = ChangeMilisecondsForDisplay(avgProcessingMiliseconds);
			float avgProcessingTimeUptoPhase = GetAvgProcessingTimeUptoPhase(Etn, process, result.value("phase"), customerIdsList);

			String avgProcessingTimeUptoPhaseStr = ChangeMilisecondsForDisplay(avgProcessingTimeUptoPhase);

			
			float varianceInPhase = GetVarianceOfProcessingTimeInPhase(Etn, process, result.value("phase"), avgProcessingMiliseconds, customerIdsList);
			varianceInPhase = new Double(Math.sqrt(varianceInPhase)).floatValue();
			String varianceInPhaseStr = ChangeMilisecondsForDisplay(varianceInPhase);
			
			float varianceUptoPhase = GetVarianceOfProcessingTimeUptoPhase(Etn, process, result.value("phase"), avgProcessingTimeUptoPhase, customerIdsList);
			varianceUptoPhase = new Double(Math.sqrt(varianceUptoPhase)).floatValue();
			String varianceUptoPhaseStr = ChangeMilisecondsForDisplay(varianceUptoPhase);

			String rulesQry = "select distinct errCode from post_work where proces = " + escape.cote(process)+ " and phase = " + escape.cote(result.value("phase")) + " order by errCode ";
			Set rulesSet = Etn.execute(rulesQry);
			Map<String, Integer> errCodeOrders = new LinkedHashMap<String, Integer>();
			while(rulesSet.next())
			{
				String errCode = rulesSet.value("errCode");
				int openOrders = GetOpenOrdersForErrorCode(Etn, process, result.value("phase"), rulesSet.value("errCode"), customerIdsList);
				if(errCodeOrders.get(errCode) != null)
				{
					int numOfOrders = errCodeOrders.get(errCode);
					numOfOrders = numOfOrders + openOrders;
					errCodeOrders.put(errCode,numOfOrders);
				}
				else
					errCodeOrders.put(errCode, openOrders);
			}
			String errDivs = "";
			for(String errCode : errCodeOrders.keySet())
			{
				int numOfOrders = errCodeOrders.get(errCode);
				if(numOfOrders > 0)
				{
					errDivs = errDivs + "<div> <span style=\"font-weight:bold\">Open for Error Code " + errCode + " : </span>" + numOfOrders + "</div>";
				}
			}

			String mainDivColor = "";
			if(IsStartPhase(Etn, process, result.value("phase"))) mainDivColor = "background-color: orange;";

			if(IsEndPhase(Etn, process, result.value("phase"))) mainDivColor = "background-color: yellow;";

		
		
		// Old Code End
		%>
		var groupObj = new GizmoFigureGroup('<%=result.value("phase")%>',"<%=result.value("actors")%>",'<%=result.value("priority")%>','<%=result.value("execute")%>','<%=result.value("visc")%>','<%=(result.value("displayName")).replaceAll("'","&#39;")%>','<%=result.value("process")%>', document.forms[0].process.value);
		workflow.addPhaseGroup(groupObj);
		<%
			java.util.StringTokenizer st = new java.util.StringTokenizer(parseNull(result.value("rulesVisibleTo")), "|");
			while(st.hasMoreTokens())
			{
				String curProf = st.nextElement().toString();
				Set phaseCoords = Etn.execute("select * from coordinates where process = "+escape.cote(process)+" and profile = "+escape.cote(curProf)+" and phase = "+escape.cote(result.value("phase"))+" ");
				int pWidth = defaultWidth;
				int pHeight = defaultHeight;
				int pX = defaultXCoord;
				int pY = defaultYCoord;
				if(phaseCoords.rs.Rows > 0)
				{
					phaseCoords.next();
					pWidth = Integer.parseInt(phaseCoords.value("width"));
					pHeight = Integer.parseInt(phaseCoords.value("height"));
					pX = Integer.parseInt(phaseCoords.value("topLeftX"));
					pY = Integer.parseInt(phaseCoords.value("topLeftY"));
				}
		%>								
			//obj[<%=i%>]= new draw2d.GizmoFigure(<%=pWidth%>,<%=pHeight%>,'<%=result.value("phase")%>',"<%=result.value("actors")%>",'<%=result.value("priority")%>','<%=result.value("execute")%>','<%=result.value("visc")%>','<%=result.value("rulesVisibleTo")%>','<%=(result.value("displayName")).replaceAll("'","&#39;")%>','<%=result.value("process")%>', document.forms[0].process.value, '<%=curProf%>');
			obj[<%=i%>]= new draw2d.GizmoFigure(<%=pWidth%>,<%=pHeight%>,'<%=curProf%>');
			obj[<%=i%>].setTitle('<%=(result.value("displayName")).replaceAll("'","&#39;")%>');
			obj[<%=i%>].setContent('<div style="text-align:left;<%=mainDivColor%>" id="node_<%=result.value("phase").replaceAll(" ","_").toUpperCase()%>"><div><span style="font-weight:bold;">Total open orders : </span><%=numberOfOpenOrders%> <%if(numberOfOpenOrders > 0) { %> <a href="javascript:onClickDetails(\''+process+'\',\'<%=result.value("phase")%>\')" style="color:black;">Click to view</a> <%}%> </div> <%=errDivs%> <%if(!avgProcessingTime.equals("")) {%><div><span style="font-weight:bold">Avg Process Time: </span><%=avgProcessingTime%> </div> <%}%> <%if(!varianceInPhaseStr.equals("")) { %><div> <span style="font-weight:bold">Variance in Processing Time: </span><%=varianceInPhaseStr%> </div> <%}%> <%if(!avgProcessingTimeUptoPhaseStr.equals("")) {%> <div> <span style="font-weight:bold">Avg Time getting out of Phase: </span><%=avgProcessingTimeUptoPhaseStr%> </div> <%}%> <% if(!varianceUptoPhaseStr.equals("")){%> <div> <span style="font-weight:bold">Variance in getting out of Phase: </span><%=varianceUptoPhaseStr%> </div> <%}%> </div>');
			obj[<%=i%>].footer.style.backgroundColor="white";
			groupObj.addChild(obj[<%=i%>]);
			workflow.addFigure(obj[<%=i%>], <%=pX%>,<%=pY+deltaY%>);
			for(var k=0; k<profileObjs.length; k++)
			{
				if(profileObjs[k].name == '<%=curProf%>')
				{
					profileObjs[k].addChild(obj[<%=i%>]);
					break;
				}				
			}
			<%
			i++;	
			}
		}
		%>	
		var conns = new Array();		
		<%
			String newQry = "select start_phase, next_phase, r.errCode, errNom, errCouleur as color, errType from rules r left outer join errcode e on e.id = r.errCode where start_proc = " + escape.cote(process) + " and next_proc = start_proc order by start_proc, start_phase, next_proc, next_phase, r.errCode ";
			Set res = Etn.execute(newQry);		
			String missingPhases = "";
			boolean isWarning = false;
				
		while (res.next())
		{
			String sourceTitle = res.value("start_phase"); 			  //get the source phase title from hashmap			
			if(SearchForConnection.get(sourceTitle) == null || SearchForConnection.get(sourceTitle) < 0) 
			{
				System.out.println("### ERROR: Unable to find phase in phases table. Phase name = " + sourceTitle);
				isWarning = true;
				missingPhases = missingPhases + sourceTitle + ",";
				continue;
			}
			int sourceIndex = SearchForConnection.get(sourceTitle);   //get the source phase index from hashmap			
			
			String destTitle = res.value("next_phase"); 			  			
			if(SearchForConnection.get(destTitle) == null || SearchForConnection.get(destTitle) < 0) 
			{
				System.out.println("### ERROR: Unable to find phase in phases table. Phase name = " + destTitle);
				isWarning = true;
				missingPhases = missingPhases + destTitle + ",";
				continue;
			}
			int destIndex = SearchForConnection.get(destTitle);   
			
			String color = parseNull(res.value("color"));
			
			if(color.equals("")) color = "#000000";
		%>	
		
			var found = false;
			var connGroup = null;
			for(var j=0; j<workflow.lines.size; j++)
			{
				if( workflow.lines.get(j) instanceof draw2d.GizmoConnection &&
					workflow.lines.get(j).sourcePort.parentNode.group.figName === obj[<%=sourceIndex%>].group.figName &&
					workflow.lines.get(j).sourcePort.parentNode.group.process === obj[<%=sourceIndex%>].group.process &&
					workflow.lines.get(j).targetPort.parentNode.group.figName === obj[<%=destIndex%>].group.figName &&
					workflow.lines.get(j).targetPort.parentNode.group.process === obj[<%=destIndex%>].group.process )
				{					
					found = true;
					connGroup = workflow.lines.get(j).group;					
					break;
				}
			}
			// connecting source with destination
			if(!found)
			{	
				var sourceGroup = obj[<%=sourceIndex%>].group;
				var targetGroup = obj[<%=destIndex%>].group;
				connGroup = new GizmoConnectionGroup();
				workflow.addConnectionGroup(connGroup);
				for(var j=0;j<sourceGroup.children.size;j++)
				{
					for(var k=0;k<targetGroup.children.size;k++)
					{
						var c1 = new draw2d.GizmoConnection();
						c1.setSource(sourceGroup.children.get(j).getPort("output"));
						c1.setTarget(targetGroup.children.get(k).getPort("input"));				
						conns.push(c1);
						connGroup.addChild(c1);
						connGroup.addErrInfo('<%=res.value("errCode")%>','<%=parseNull(res.value("errNom"))%>','<%=parseNull(res.value("errType"))%>', '<%=color%>');
						workflow.addFigure(c1);
					}
				}
			}
			if(found) connGroup.addErrInfo('<%=res.value("errCode")%>','<%=parseNull(res.value("errNom"))%>','<%=parseNull(res.value("errType"))%>', '<%=color%>');
			//connGroup.refreshErrInfo();
			/*for(var j=0;j<connGroup.children.size;j++)
			{
//				conns[j].addErrInfo('<%=res.value("errCode")%>','<%=parseNull(res.value("errNom"))%>','<%=parseNull(res.value("errType"))%>', '<%=color%>');
				//conns[j].setColor(new draw2d.Color('<%=color%>'));
				
				connGroup.children.get(j).setColor(new draw2d.Color('<%=color%>'));
				if(!found) 
				{
					workflow.addFigure(connGroup.children.get(j));	
				}
			}		*/	
		<%
			}		
		%>	
		//drawing of out-going intra process starts here
		var externalPhaseObj = new Array();
		<%
			Map<String, Integer> externalPhaseObj = new LinkedHashMap<String, Integer>();
			Set rsExternalPhases = Etn.execute("select ep.start_proc, ep.next_proc, ep.next_phase, ep.topLeftX, ep.topLeftY , ep.width, ep.height, ph.displayName from external_phases ep, phases ph where ph.process = next_proc and ph.phase = next_phase and start_proc = "+escape.cote(process)+" order by ep.start_proc, ep.next_proc, ep.next_phase");					
			int index = 0;
			while(rsExternalPhases.next())
			{
				externalPhaseObj.put(rsExternalPhases.value("next_proc").replaceAll(" ","_")+"_"+rsExternalPhases.value("next_phase").replaceAll(" ","_"), index);
		%>
					//each external phase has its own figure group
					var groupObj = new GizmoFigureGroup('<%=rsExternalPhases.value("next_phase")%>','','','','','<%=(rsExternalPhases.value("displayName")).replaceAll("'","&#39;")%>','<%=rsExternalPhases.value("next_proc")%>', document.forms[0].process.value);
					workflow.addPhaseGroup(groupObj);		
					var targetObj = new draw2d.GizmoFigure(<%=rsExternalPhases.value("width")%>,<%=rsExternalPhases.value("height")%>,'');
					targetObj.setTitle('<%=(rsExternalPhases.value("displayName")).replaceAll("'","&#39;")%>');
					targetObj.setContent('<div style="background-color:gray; color:white; font-weight: bold"> Process : <%=rsExternalPhases.value("next_proc")%></div>');
					targetObj.footer.style.backgroundColor="white";
					groupObj.addChild(targetObj);
					//targetObj.isIntraProcess = true;//this flag will be used in double click of GizmoFigure to either open phase info or load the target process if flag is true
					<% int _y = Integer.parseInt(rsExternalPhases.value("topLeftY")); %>
					workflow.addFigure(targetObj, <%=rsExternalPhases.value("topLeftX")%>,<%=_y+deltaY%>);
					externalPhaseObj.push(targetObj);
		<%
				index++;
			}	

			//loading those external phase from which we just have incoming arrow to this process ... those external phases are not part of externalPhases table
			rsExternalPhases = Etn.execute("select distinct start_proc, start_phase, displayName from rules r, phases p where start_proc != next_proc and start_proc = p.process and start_phase = p.phase and next_proc = "+escape.cote(process));
			int startX = 5;
			while(rsExternalPhases.next())
			{
				if(externalPhaseObj.get(rsExternalPhases.value("start_proc").replaceAll(" ","_")+"_"+rsExternalPhases.value("start_phase").replaceAll(" ","_")) == null)
				{
					externalPhaseObj.put(rsExternalPhases.value("start_proc").replaceAll(" ","_")+"_"+rsExternalPhases.value("start_phase").replaceAll(" ","_"), index);
		%>
					//each external phase has its own figure group
					var groupObj = new GizmoFigureGroup('<%=rsExternalPhases.value("start_phase")%>','','','','','<%=(rsExternalPhases.value("displayName")).replaceAll("'","&#39;")%>','<%=rsExternalPhases.value("start_proc")%>', document.forms[0].process.value);
					workflow.addPhaseGroup(groupObj);		
					var targetObj = new draw2d.GizmoFigure(120,80,'');
					targetObj.setTitle('<%=(rsExternalPhases.value("displayName")).replaceAll("'","&#39;")%>');
					targetObj.setContent('<div style="background-color:gray; color:white; font-weight: bold"> Process : <%=rsExternalPhases.value("start_proc")%></div>');
					targetObj.footer.style.backgroundColor="white";
					groupObj.addChild(targetObj);					
					//targetObj.isIntraProcess = true;//this flag will be used in double click of GizmoFigure to either open phase info or load the target process if flag is true
					workflow.addFigure(targetObj, <%=startX%>, 1);
					externalPhaseObj.push(targetObj);
		<%
					index++;
					startX += 150;
				}
			}			

			//out going links to external phases
			String intraProcessQry = "select r.start_proc, r.next_proc, start_phase, next_phase, r.errCode, errNom, ifnull(errCouleur,'#000000') as color, errType from rules r left outer join errcode e on e.id = r.errCode where start_proc = " + escape.cote(process) + " and next_proc != start_proc order by r.next_proc, r.next_phase, r.start_proc, r.start_phase, r.errCode ";
			Set rsIntraProcess = Etn.execute(intraProcessQry);
			while(rsIntraProcess.next())
			{
				int sourceIndex = SearchForConnection.get(rsIntraProcess.value("start_phase"));
				int targetIndex = externalPhaseObj.get(rsIntraProcess.value("next_proc").replaceAll(" ","_")+"_"+rsIntraProcess.value("next_phase").replaceAll(" ","_"));
		%>
				var found = false;
				var c = null;
				var connGroup = null;
				for(var j=0; j<workflow.lines.size; j++)
				{
					if( workflow.lines.get(j) instanceof draw2d.GizmoConnection &&
						workflow.lines.get(j).sourcePort.parentNode.group.figName === obj[<%=sourceIndex%>].group.figName &&
						workflow.lines.get(j).sourcePort.parentNode.group.process === obj[<%=sourceIndex%>].group.process &&
						workflow.lines.get(j).targetPort.parentNode.group.figName === externalPhaseObj[<%=targetIndex%>].group.figName &&
						workflow.lines.get(j).targetPort.parentNode.group.process === externalPhaseObj[<%=targetIndex%>].group.process )
					{					
						found = true;
						c = workflow.lines.get(j);
						connGroup = workflow.lines.get(j).group;
						break;
					}
				}
				// connecting source with destination
				if(!found)
				{
					var sourceGroup = obj[<%=sourceIndex%>].group;
					var targetGroup = externalPhaseObj[<%=targetIndex%>].group;
					connGroup = new GizmoConnectionGroup();
					workflow.addConnectionGroup(connGroup);
					for(var j=0;j<sourceGroup.children.size;j++)
					{
						for(var k=0;k<targetGroup.children.size;k++)
						{
							var c1 = new draw2d.GizmoConnection();
							c1.setSource(sourceGroup.children.get(j).getPort("output"));
							c1.setTarget(targetGroup.children.get(k).getPort("input"));				
							conns.push(c1);
							connGroup.addChild(c1);
							connGroup.addErrInfo('<%=rsIntraProcess.value("errCode")%>','<%=parseNull(rsIntraProcess.value("errNom"))%>','<%=parseNull(rsIntraProcess.value("errType"))%>', '<%=rsIntraProcess.value("color")%>');
							workflow.addFigure(c1);
						}
					}
				}
				if(found) connGroup.addErrInfo('<%=rsIntraProcess.value("errCode")%>','<%=parseNull(rsIntraProcess.value("errNom"))%>','<%=parseNull(rsIntraProcess.value("errType"))%>', '<%=rsIntraProcess.value("color")%>');
				//connGroup.refreshErrInfo();
				
/*				c.addErrInfo('','','', '');
				c.setColor(new draw2d.Color('<%=rsIntraProcess.value("color")%>'));*/
/*				if(!found)
					workflow.addFigure(c);*/					
		<%
			}

			//out going links from external phases
			intraProcessQry = "select r.start_proc, r.next_proc, start_phase, next_phase, r.errCode, errNom, ifnull(errCouleur,'#000000') as color, errType from rules r left outer join errcode e on e.id = r.errCode where next_proc = " + escape.cote(process) + " and next_proc != start_proc order by r.next_proc, r.next_phase, r.start_proc, r.start_phase, r.errCode ";			
			rsIntraProcess = Etn.execute(intraProcessQry);
			while(rsIntraProcess.next())
			{
				if(externalPhaseObj.get(rsIntraProcess.value("start_proc").replaceAll(" ","_")+"_"+rsIntraProcess.value("start_phase").replaceAll(" ","_")) == null) continue;
				int sourceIndex = externalPhaseObj.get(rsIntraProcess.value("start_proc").replaceAll(" ","_")+"_"+rsIntraProcess.value("start_phase").replaceAll(" ","_"));				
				int targetIndex = SearchForConnection.get(rsIntraProcess.value("next_phase"));
		%>
				var found = false;
				var c = null;
				var connGroup = null;
				for(var j=0; j<workflow.lines.size; j++)
				{
					if( workflow.lines.get(j) instanceof draw2d.GizmoConnection &&
						workflow.lines.get(j).sourcePort.parentNode.group.figName === externalPhaseObj[<%=sourceIndex%>].group.figName &&
						workflow.lines.get(j).sourcePort.parentNode.group.process === externalPhaseObj[<%=sourceIndex%>].group.process &&
						workflow.lines.get(j).targetPort.parentNode.group.figName === obj[<%=targetIndex%>].group.figName &&
						workflow.lines.get(j).targetPort.parentNode.group.process === obj[<%=targetIndex%>].group.process )
					{					
						found = true;
						c = workflow.lines.get(j);
						connGroup = workflow.lines.get(j).group;
						break;
					}
				}
				// connecting source with destination
				if(!found)
				{
					var sourceGroup = externalPhaseObj[<%=sourceIndex%>].group;
					var targetGroup = obj[<%=targetIndex%>].group;
					connGroup = new GizmoConnectionGroup();
					workflow.addConnectionGroup(connGroup);
					for(var j=0;j<sourceGroup.children.size;j++)
					{
						for(var k=0;k<targetGroup.children.size;k++)
						{
							var c1 = new draw2d.GizmoConnection();
							c1.setAllowDoubleClick(false);
							c1.setAllowDelete(false);
							c1.setSource(sourceGroup.children.get(j).getPort("output"));
							c1.setTarget(targetGroup.children.get(k).getPort("input"));				
							conns.push(c1);
							connGroup.addChild(c1);
							connGroup.addErrInfo('<%=rsIntraProcess.value("errCode")%>','<%=parseNull(rsIntraProcess.value("errNom"))%>','<%=parseNull(rsIntraProcess.value("errType"))%>', '<%=rsIntraProcess.value("color")%>');
							workflow.addFigure(c1);
						}
					}
				}
				if(found) connGroup.addErrInfo('<%=rsIntraProcess.value("errCode")%>','<%=parseNull(rsIntraProcess.value("errNom"))%>','<%=parseNull(rsIntraProcess.value("errType"))%>', '<%=rsIntraProcess.value("color")%>');
		<%
			}
		%>		
				
		//drawing of intra process ends here
		for(var i=0;i<workflow.connectionGroups.size;i++)
		{
			workflow.connectionGroups.get(i).refreshErrInfo();
		}
		
		<% if(isWarning) { 
			missingPhases = missingPhases.substring(0,missingPhases.length() - 1);	
		%>
			alert("Following phases are not loaded due to which the connections cannot be drawn. <%=missingPhases%>. Please contact administrator to fix the issue or add phases with same name again");
		<% } %>
		
		//this will let workflow know that screen is loaded and now ajax calls should be made or not on add/remove of node/connection
		<%if(screenMode.equals("UPDATE")){%>
			workflow.setCallAjax(true);
		<% } else { %>
			workflow.setCallAjax(false);
		<% } %>
		
		<%if(partialUpdate.equalsIgnoreCase("true")){%>
			workflow.setPartialUpdate(true);
		<%} else {%>
			workflow.setPartialUpdate(false);
		<% } %>
		
		<% if(showLabelsByDefault) { %>
			workflow.showConnectionLabels();
		<% } %>
	<% } %>	

	draw2d.GizmoFigure.prototype.loadNextProcess=function()
	{
		document.forms[0].process.value = this.group.process;
		document.forms[0].submit();
	}
	
	function onClickLoad()
	{
		document.forms[0].submit();
	}
	
	
	jQuery(document).ready(function() {
		jQuery("#modalWindow").dialog({
			bgiframe: true, autoOpen: false, height: 'auto', width:'auto', modal: true, resizable : false
		});
		jQuery("#showLabels").click(function(){
			if(jQuery("#showLabels").is(':checked') && workflow)
			{
				workflow.showConnectionLabels();
			}
			else
			{
				workflow.hideConnectionLabels();
			}
		});	
		if(jQuery("#deleteProcessBtn")) {
			jQuery("#deleteProcessBtn").click(function(){
				if(confirm("Are you sure to delete the selected process?"))
				{
					jQuery.ajax({
						url: 'deleteProcess.jsp',
						type: 'POST',
						data: {process: document.forms[0].process.value},
						success: function(resp) {
							document.forms[0].process.value = '#';
							document.forms[0].submit();
						},
						error : function(resp) {
							alert("Some error while communication with server. Try again or contact administrator");
						}
					});							
				}
			});
		}
		
		if(jQuery("#copyProcessBtn")) {
			jQuery("#copyProcessBtn").click(function(){
				html = "<div id='copyProcessMsgLbl' class='errMessage'>&nbsp;</div>" + 
					   "<div>Save as : <input type='text' value='' name='saveAsProcessName' id='saveAsProcessName' maxlength='16' size='20'/></div>" + 
					   "<div style='text-align:center; margin-top:3px'><input type='button' value='Ok' onclick='onOkCopyProcess()'></div>" ;

				jQuery("#modalWindow").dialog("option","title","Copy Process");
				jQuery("#modalWindow").dialog("option","width","auto");
				jQuery("#modalWindow").dialog("option","height","auto");
				jQuery('#modalWindow').unbind("dialogclose");	   
				jQuery("#modalWindow").html(html);
				jQuery("#modalWindow").dialog('open');
			});
			onOkCopyProcess = function ()
			{
				jQuery("#copyProcessMsgLbl").html("&nbsp;");
				if(jQuery("#saveAsProcessName").val() == '')
				{
					jQuery("#copyProcessMsgLbl").html("Enter phase name");
					return;
				}
				jQuery.ajax({
					url: 'copyProcess.jsp',
					type: 'POST',
					data: {process: document.forms[0].process.value, copyAs: jQuery('#saveAsProcessName').val()},
					dataType: 'json',
					success: function(resp) {
						if(resp.RESPONSE_STATUS == "SUCCESS")
						{					
							alert(resp.MESSAGE);
							document.forms[0].submit();
						}
						else
						{						
							jQuery("#copyProcessMsgLbl").html(resp.MESSAGE);
						}
					},
					error : function(resp) {
						alert("Some error while communication with server. Try again or contact administrator");
					}
				});							
			};
		}
		
		onNewProcess = function ()
		{
			html = "<div id='newProcessMsg' class='errMessage'>&nbsp;</div>" + 
				   "<div>Process name : <input type='text' value='' name='newProcessName' id='newProcessName' maxlength='16' size='20'/></div>" + 
				   "<div style='text-align:center; margin-top:3px'><input type='button' value='Ok' onclick='onOkNewProcess()'></div>" ;

			jQuery("#modalWindow").dialog("option","title","New Process");
			jQuery("#modalWindow").dialog("option","width","auto");
			jQuery("#modalWindow").dialog("option","height","auto");
			jQuery('#modalWindow').unbind("dialogclose");	   
			jQuery("#modalWindow").html(html);
			jQuery("#modalWindow").dialog('open');			
		};
		onOkNewProcess = function ()
		{
			if(jQuery('#newProcessName').val() == '')
			{
				jQuery('#newProcessMsg').html("Enter Process name");
				return;
			}		
			jQuery.ajax({
				url: 'checkProcessExists.jsp',
				type: 'POST',
				data: {process: jQuery('#newProcessName').val()},
				success: function(resp) {
					resp = jQuery.trim(resp);
					if(resp.indexOf('SUCCESS') > -1)
					{	
						var newOpt = new Option(jQuery('#newProcessName').val(), jQuery('#newProcessName').val());
						procLen = document.forms[0].process.length ;
						document.forms[0].process.options[procLen] = newOpt;
						document.forms[0].process.selectedIndex = procLen;

						if(workflow)
						{
							workflow.setCallAjax(false);
							workflow.clear();
						}
						process = document.forms[0].process.value;
						if(!workflow)
						{
							workflow = new draw2d.GizmoWorkflow(process, "divGraph","modalWindow");
							if(navigator.userAgent.indexOf("MSIE")) workflow.isIE = true;
						}
						else workflow.process = process;
						workflow.setCallAjax(true);
						jQuery('#toolBarDiv').show();
						if(jQuery('#toolBar1')) jQuery('#toolBar1').show();
						if(jQuery('#toolBar2')) jQuery('#toolBar2').show();
						jQuery("#modalWindow").dialog('close');
						if(!workflow.isIE) jQuery('#opacity').show();
						var defaultProfileXCoord = 10;
						var defaultProfileYCoord = 10;
						for(var i=0; i<allProfiles.length;i++)
						{
							var profObj = new draw2d.GizmoProfileFigure(allProfiles[i].name, allProfiles[i].displayName, 300, 500, process);
							workflow.addFigure(profObj, defaultProfileXCoord,defaultProfileYCoord);				
							workflow.addProfileFigure(profObj);
							profObj.html.style.cursor="";
							profileObjs.push(profObj);
							defaultProfileXCoord += 305;
						}
						document.getElementById("toolbar").style.display = "block";
						if(document.getElementById("toolbarPhases")) document.getElementById("toolbarPhases").innerHTML="";
					}
					else jQuery('#newProcessMsg').html(resp);
				},
				error : function(resp) {
					alert("Some error while communication with server. Try again or contact administrator");
				}
			});			
		};
		
		loadPhases = function()
		{
			jQuery.ajax({
				url: 'loadExternalPhases.jsp',
				type: 'POST',
				data: {targetProcess : jQuery("#otherProcess").val(), process : jQuery("#process").val()},
				dataType: 'json',
				success: function(resp) {
					var opts1 = document.getElementById('otherProcessPhase').options;
					opts1.length = 1;
					document.getElementById('otherProcessPhase').selectedIndex=0;
					for( var i = 0, j = 1 ; i < resp.PHASES.length ; i++ )
					{
						opts1[j] = new Option(resp.PHASES[i].PHASE.DISPLAYNAME);
						opts1[j].value = resp.PHASES[i].PHASE.NAME;
						j++;
					}
				}
			});						
		};
		
		showHideToolbar = function(parentId, id, otherId, setPosition)
		{
			if(otherId) document.getElementById(otherId).style.display = 'none';
			if(document.getElementById(id).style.display === 'none')
			{
				document.getElementById(id).style.display = 'block';
				if(setPosition)
				{
					var left = document.getElementById(parentId).style.left;
					left = left.substring(0,left.indexOf('px'));
					left = left + 113;
					document.getElementById(id).style.left = left + 'px';
				}		
			}
			else document.getElementById(id).style.display = 'none';
		};	
		
		help = function ()
		{
			html = '<div style="margin-right:10px; width:300px; text-align:left;"> ';
			html += '<b><font color="#FF6600">Add phase:</font></b>  To add a new phase, right click in any of the profile grouping and select Add Phase from menu<br/><br/>';
			html += '<b><font color="#FF6600">Add phase:</font></b>  To delete a phase, right click on the phase and select Delete from menu<br/><br/>';
			html += '<b><font color="#FF6600">Add phase:</font></b>  To add an external phase, right click outside the profile grouping and select Add External Phase from menu<br/><br/>';
			html += '<b><font color="#FF6600">Add phase:</font></b>  To add same phase into another profile, right click the original phase and select Copy from menu and then right click on the target profile group and select Paste</div>';

			jQuery("#modalWindow").dialog("option","title","Help");
			jQuery("#modalWindow").dialog("option","width","auto");
			jQuery("#modalWindow").dialog("option","height","auto");
			jQuery('#modalWindow').unbind("dialogclose");	   
			jQuery("#modalWindow").html(html);
			jQuery("#modalWindow").dialog('open');	
		};
		
		jQuery(".profChkbox").change(function(){
			var eId = this.id;
			eId = eId.substring(eId.indexOf("checkbox")+8);
			var profFig = null;
			for(var i=0; i<workflow.profileFigures.size;i++)
			{
				if(workflow.profileFigures.get(i).name === eId) 
				{	
					profFig = workflow.profileFigures.get(i);
					break;
				}
			}
			if(this.checked) profFig.show(workflow);
			else profFig.hide(workflow);
		});
		
		jQuery(".phaseChkbox").change(function(){
			var eId = this.id;
			eId = eId.substring(eId.indexOf("checkbox")+8);
			var phaseGrpFig = null;
			for(var i=0; i<workflow.phaseGroups.size;i++)
			{
				if(workflow.phaseGroups.get(i).figName === eId) 
				{	
					phaseGrpFig = workflow.phaseGroups.get(i);
					break;
				}
			}

			if(this.checked) phaseGrpFig.show(workflow);
			else phaseGrpFig.hide(workflow);
		});
				
		jQuery("#opacity").change(function(){
			if(workflow)
			{	
				workflow.arrowsOpacity = this.value;
				for(var i=0;i<workflow.connectionGroups.size;i++)
				{
					workflow.connectionGroups.get(i).refreshErrInfo();
				}
			}
		});
		jQuery("#opacity").hide();
		jQuery("#toolBar2").hide();
		if(workflow && !workflow.isIE) 
		{			
			jQuery("#opacity").show();
		}
		if(workflow) jQuery("#toolBar2").show();
				
	});
</script>
