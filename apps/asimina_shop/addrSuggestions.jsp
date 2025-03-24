<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>

<%
	String suggestionHTML = request.getParameter("html");       
	String firstSuggestion = request.getParameter("firstSuggestion");
     
	if(suggestionHTML!=null && !suggestionHTML.equals(""))
	{
		suggestionHTML = suggestionHTML.replaceAll("\"", "'");//this is just to make sure there is no double quote (") in string which will conflict with double quotes in unescape function below
%>
<div>
    <div id="suggestHTML" style="float:left; padding-top: 5px; width: 350px; font-size: 8pt;"></div>
    <div id='suggestionMap' style="float: right; position:relative; width:350px; height:400px;"></div>
    <div style="clear:both;"></div>
</div>
	&nbsp;
	<script id="suggestionMapScript" type="text/javascript">

	GetMap('suggestionMap');	
	<%if (firstSuggestion != null && !firstSuggestion.equals("")) { %>
		FindSuggestedLoc("<%=firstSuggestion%>");
	<% } %>
        document.getElementById("suggestHTML").innerHTML = unescape("<%=suggestionHTML%>");
	</script>
<% } else { %>
	No address provided
<% } %>