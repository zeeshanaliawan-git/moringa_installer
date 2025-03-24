<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape, com.etn.beans.app.GlobalParm, com.etn.asimina.util.*"%>

<%@ include file="common.jsp" %>

<%
	String fromjsonid = parseNull(request.getParameter("fromjsonid"));
	String screenname = parseNull(request.getParameter("screenname"));

	String resp = "SUCCESS";
	String msg = "";
	if(fromjsonid.length() == 0 || screenname.length() == 0)
	{
		resp = "ERROR";
		msg = "Required information to copy screen settings is missing";
	}
	else
	{
		Set rs = Etn.execute("select screen_name from expert_system_json where screen_name = "+escape.cote(screenname));
		if(rs.rs.Rows > 0)
		{
			resp = "ERROR";
			msg = "Screen with the given name already exists";
		}
		else
		{
			rs = Etn.execute("select * from expert_system_json where id = " + escape.cote(fromjsonid));
			rs.next();
			boolean copyJsonUrl = true;
			boolean copyHtmlPage = true;
			if(parseNull(rs.value("url")).startsWith(GlobalParm.getParm("EXPERT_SYSTEM_GENERATE_JSP_URL") + "fetchdata_" + CommonHelper.escapeCoteValue(fromjsonid) + ".jsp")) copyJsonUrl = false;
			if(parseNull(rs.value("destination_page")).startsWith(GlobalParm.getParm("EXPERT_SYSTEM_GENERATED_JSP_RELATIVE_PATH") + "html_" + CommonHelper.escapeCoteValue(fromjsonid) + ".jsp")) copyHtmlPage = false;

			String q = "insert into expert_system_json (screen_name,json ";
			if(copyJsonUrl) q += ", url";
			if(copyHtmlPage) q += ", destination_page";
			q += ") select "+escape.cote(screenname)+", json ";
			if(copyJsonUrl) q += ", url";
			if(copyHtmlPage) q += ", destination_page";
			q += " from expert_system_json where id = " + escape.cote(fromjsonid);

			int newjsonid = Etn.executeCmd(q);
			if(newjsonid > 0)
			{
				Etn.executeCmd("insert into expert_system_html (json_id, tag_type, tag_id, tag_name) select "+newjsonid+", tag_type, tag_id, tag_name from expert_system_html where json_id = " + escape.cote(fromjsonid) + " order by id ");
				Etn.executeCmd("insert into expert_system_script (json_id, json_tag, parent_json_tag, html_tag, max_rows, show_col, col_header, col_seq_num, created_by, created_date, script_file, functions, field_type, field_name, fill_from, add_pagination, col_header_css, col_value_css, d3chart, c3chart, xaxis, xcols, ycols) select "+newjsonid+", json_tag, parent_json_tag, html_tag, max_rows, show_col, col_header, col_seq_num, "+Etn.getId()+", now(), script_file, functions, field_type, field_name, fill_from, add_pagination, col_header_css, col_value_css, d3chart, c3chart, xaxis, xcols, ycols from expert_system_script where json_id = " + escape.cote(fromjsonid) + " order by id ");
	
				Set rules = Etn.execute("select * from expert_system_rules where json_id = " + escape.cote(fromjsonid) + " order by id ");
				while(rules.next())
				{
					int newruleid = Etn.executeCmd("insert into expert_system_rules (json_id, output_type, output_tag, output_val, created_by, created_date, html_tag_id, exec_order) select "+newjsonid+", output_type, output_tag, output_val, "+Etn.getId()+", now(), html_tag_id, exec_order from expert_system_rules where id = "+escape.cote(rules.value("id")) );	
					Etn.executeCmd("insert into expert_system_conditions (rule_id, json_tag, operator, value, intra_condition_operator, value_type, target_func, source_func, source_params, target_params) select "+newruleid+", json_tag, operator, value, intra_condition_operator, value_type, target_func, source_func, source_params, target_params from expert_system_conditions where rule_id = " + escape.cote(rules.value("id")) + " order by id ");
				}

//				Set _rsq = Etn.executeCmd("insert into expert_system_queries (json_id, query, created_by, created_date, query_type, description) select "+newjsonid+", query, "+Etn.getId()+", now(), query_type, description from expert_system_queries where json_id = " + escape.cote(fromjsonid) + " order by id ");
				Set _rsq = Etn.execute("select * from expert_system_queries where json_id = " + escape.cote(fromjsonid) + " order by id ");
				while(_rsq.next())
				{
					int _i = Etn.executeCmd("insert into expert_system_queries (json_id, query, query_type, description, created_by, created_date) values ('"+newjsonid+"', "+escape.cote(parseNull(_rsq.value("query")))+","+escape.cote(parseNull(_rsq.value("query_type")))+","+escape.cote(parseNull(_rsq.value("description")))+","+escape.cote(""+Etn.getId())+", now()) ");
					Etn.executeCmd("insert into expert_system_query_params (json_id, param, default_value, query_id) select "+newjsonid+", param, default_value, "+_i+" from expert_system_query_params where json_id = " + escape.cote(fromjsonid) + " and query_id = "+_rsq.value("id")+" order by id ");
				}

				msg = "Screen settings copied to json id : " + newjsonid;
			}
			else
			{
				resp = "ERROR";
				msg = "Some error occurred while copying";
			}
		}
	}
%>
{"RESPONSE":"<%=resp%>","MSG":"<%=msg%>"}