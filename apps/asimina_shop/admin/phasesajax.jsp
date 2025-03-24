<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, java.util.List, com.etn.beans.app.GlobalParm"%>
<%@ page import="java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken" %>
<%@ include file="../common2.jsp" %>

<%!
	public class Field
	{
		public String id;
		public String section;
		public String fieldName;
		public String displayName;
		public boolean isLabel;
		public int order;
	}
%>
<%

	String type = parseNull(request.getParameter("type"));

	if(type.equalsIgnoreCase("getPhases"))
	{
		response.setContentType("application/json");
		String id = parseNull(request.getParameter("id"));

		Set allPhases = Etn.execute("select * from phases where process = "+escape.cote(id)+" order by displayName ");

		if(allPhases != null && allPhases.rs.Rows > 0)
		{
			String phases = "[";
			int i=0;
			while(allPhases.next())
			{
				if(i > 0) phases += ",";
				phases += "{\"id\":\""+allPhases.value("phase")+"\",\"name\":\""+parseNull(allPhases.value("displayName"))+"\"}";
				i++;
			}
			phases += "]";
			out.write("{\"response\":\"success\", \"phases\":"+phases+"}");
		}
		else out.write("{\"response\":\"error\"}");

	} else if (type.equalsIgnoreCase("field_settings")){

		String process = parseNull(request.getParameter("process"));
		String phase = parseNull(request.getParameter("phase"));

		String screenName = "CUSTOMER_EDIT";

	
			//improvement: We should have a table with screen name and all available fieldnames
			List<Field> fieldNames = new ArrayList<Field>();

			Set rsFieldNames = Etn.execute("select * from field_names where screenName = "+escape.cote(screenName)+" order by tabDisplaySeq, sectionDisplaySeq, fieldDisplaySeq");
			while(rsFieldNames.next())
			{
					Field f = new Field();
					f.id = parseNull(rsFieldNames.value("id"));
					f.section = parseNull(rsFieldNames.value("section"));
					f.fieldName = parseNull(rsFieldNames.value("fieldName"));
					f.displayName = parseNull(rsFieldNames.value("displayName"));
					f.isLabel = rsFieldNames.value("isLabel").equals("1") ? true : false;
					f.order = parseNullInt(rsFieldNames.value("fieldDisplaySeq"));
					fieldNames.add(f);
			}

			Set phases = Etn.execute("select distinct phase, displayName from phases order by displayName");

			Set rs = Etn.execute("select * from field_settings where process = " + escape.cote(process) + " and phase = "+escape.cote(phase)+" and screenName = "+escape.cote(screenName));

			List<String> hiddenFields = new ArrayList<String>();
			List<String> editableFields = new ArrayList<String>();
			List<String> mandatoryFields = new ArrayList<String>();
			while(rs.next())
			{
					if(Integer.parseInt(rs.value("isHidden")) > 0) hiddenFields.add(rs.value("fieldName"));
					if(Integer.parseInt(rs.value("isEditable")) > 0) editableFields.add(rs.value("fieldName"));
					if(Integer.parseInt(rs.value("isMandatory")) > 0) mandatoryFields.add(rs.value("fieldName"));
			}

			String previousSection = "";
			for(Field f : fieldNames) { 
				String sec = "";
				if(!previousSection.equals(f.section)){
										sec = f.section;
										if(!previousSection.equals("")) out.write("</tbody>");
							%>
							<tbody class='section'>
								<tr class="disabled">
									<th colspan="5"><%=sec%></th>
								</tr>
							<%
									} 
			%>
			<tr>
								<td>&nbsp;<input type="hidden" value="<%=f.order%>" name="fieldDisplaySeq" class="order_seq" /><input type="hidden" value="<%=f.id%>" name="fieldId" /></td>
				<td nowrap>&nbsp;<%=f.displayName%></td>
				<td><input class="isHidden" type='checkbox' id='hidden_<%=f.fieldName%>' <%if(hiddenFields.contains(f.fieldName)){%>checked<%}%> value='<%=f.fieldName%>' onclick="updateHiddenInfo(this)"/></td>
				<td>
				<%
					if(!f.isLabel){
				%>
						<input type='checkbox' id='edit_<%=f.fieldName%>' <%if(editableFields.contains(f.fieldName)){%>checked<%}%> value='<%=f.fieldName%>' <%if(hiddenFields.contains(f.fieldName)){%>disabled<%}%> onclick="updateInfo(this)"/>
				<%
					}
				%>
				</td>
				<td>
				<%
					if(!f.isLabel){
				%>
						<input type='checkbox' id='mandatory_<%=f.fieldName%>' value='<%=f.fieldName%>' <%if(mandatoryFields.contains(f.fieldName)){%>checked<%}%> <%if(!editableFields.contains(f.fieldName)){%>disabled<%}%> onclick="updateMandatoryInfo(this)"/>
				<%
					}
				%>
				</td>
			</tr>
		<% 
				previousSection = f.section;						
			}
			out.write("</tbody>");
	} else if(type.equalsIgnoreCase("deleteMappedPhase")){

		String formName = parseNull(request.getParameter("form_name"));

		String deleteProcessMappingQuery = "DELETE FROM generic_forms_process_mapping WHERE form_name = " + escape.cote(formName);

		int row = Etn.executeCmd(deleteProcessMappingQuery);;
		if(row > 0){

			Set mappingFormResultSet = Etn.execute("SELECT * FROM generic_forms_process_mapping order by form_name;");
		%>
                    <div class="card-body">
			<table class="table table-responsive-sm resultat table-hover table-striped">
                            <thead>
                                <tr>
                                        <th>Delete(X)</th>
                                        <th>Generic Form</th>		
                                        <th>Process</th>		
                                        <th>Phase</th>

                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (mappingFormResultSet == null || mappingFormResultSet.rs.Rows == 0) {
                                %>
                                <tr>
                                        <td colspan="16" align="center">No Mapping found</td>
                                </tr>
                                <%
                                    } else {
                                                while (mappingFormResultSet.next()) {
                                %>
                                <tr>
                                        <td><input onclick="deleteMappedPhase(this);" type="checkbox" value="<%=mappingFormResultSet.value("form_name")%>"></td>
                                        <td><%=mappingFormResultSet.value("form_name")%></td>
                                        <td><%=mappingFormResultSet.value("process")%></td>
                                        <td><%=mappingFormResultSet.value("phase")%></td>
                                </tr>
                                <%
                                    }
                                }
                                %>
                            </tbody>
		</table>
                    </div>

		<%
		}


	}

%>