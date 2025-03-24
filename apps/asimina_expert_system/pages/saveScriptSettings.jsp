<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="com.etn.sql.escape"%>

<%@ include file="common.jsp" %>
<%
	String jsonid = parseNull(request.getParameter("jsonid"));

	String[] jsontags = request.getParameterValues("jsontags");
	String[] parentjsontags = request.getParameterValues("parentjsontags");
	String[] selectedoutputtags = request.getParameterValues("selectedoutputtags");
	String[] showmaxrows = request.getParameterValues("showmaxrows");
	String[] showcols = request.getParameterValues("showcols");
	String[] colheaders = request.getParameterValues("colheaders");
	String[] colnums = request.getParameterValues("colnums");
	String[] functions = request.getParameterValues("functions");
	String[] fieldtypes = request.getParameterValues("fieldtypes");
	String[] fieldnames = request.getParameterValues("fieldnames");
	String[] fillfroms = request.getParameterValues("fillfroms");
	String[] addpaginations = request.getParameterValues("addpaginations");
	String[] d3charts = request.getParameterValues("d3charts");
	String[] c3charts = request.getParameterValues("c3charts");


	String[] colHeaderCss = request.getParameterValues("colHeaderCss");
	String[] colcss = request.getParameterValues("colcss");

	//for debugging
//	if(jsontags!= null) System.out.println("#### " + jsontags.length);
//	if(d3charts!= null) System.out.println("#### " + d3charts.length);
//	if(c3charts!= null) System.out.println("#### " + c3charts.length);
/*	if(selectedoutputtags!= null) System.out.println("#### " + selectedoutputtags.length);
	if(showmaxrows != null) System.out.println("#### " + showmaxrows.length);
	if(showcols != null) System.out.println("#### " + showcols.length);
	if(colheaders != null) System.out.println("#### " + colheaders.length);
	if(colnums != null) System.out.println("#### " + colnums.length);
	if(colcss != null) System.out.println("#### " + colcss.length);
	if(colHeaderCss != null) System.out.println("#### " + colHeaderCss.length);*/


	List<String> qrys = new ArrayList<String>();
	for(int i=0;i<jsontags.length;i++)
	{
		String xaxis = "";
		String xcols = "";
		String ycols = "";
		String c3col_graph_type = "";
		String c3col_groups = "";
		String extras = "";

		if(parseNull(parentjsontags[i]).startsWith("c3json_") && parseNull(jsontags[i]).startsWith("data"))
		{
			String _tkey = parseNull(jsontags[i]);
			if(parseNull(parentjsontags[i]).length() > 0) _tkey = parseNull(parentjsontags[i]) + "." + parseNull(jsontags[i]);
			_tkey = _tkey.replace("[*]","").replace(".", "_");

			xaxis = parseNull(request.getParameter(_tkey + "_xaxis"));

			String zoom = parseNull(request.getParameter(_tkey + "_zoom"));
//System.out.println ("--------------- c3 zoom : " + zoom);		
			if(zoom.length() > 0) extras = "<zoom>"+zoom+"</zoom>";
			else extras = "";
//System.out.println ("--------------- c3 extras : " + extras);		

			if("category".equals(xaxis)) xcols = parseNull(request.getParameter(_tkey + "_c3categorycol"));
			if("timeseries".equals(xaxis))
			{
				String[] _xs = request.getParameterValues(_tkey + "_c3timeseriesxcols");
				String[] _ys = request.getParameterValues(_tkey + "_c3timeseriesycols");
				for(int z=0; z<_xs.length; z++)
				{
					if(parseNull(_xs[z]).length() > 0)
					{
						xcols += _xs[z] + ",";
						ycols += parseNull(_ys[z]) + ",";
					}
				}
			}
			if(parseNull(c3charts[i]).equals("combination"))
			{
				String[] _colnames = request.getParameterValues(_tkey + "_c3colgraphtypecolname");
				String[] _colgraph = request.getParameterValues(_tkey + "_c3colgraphtypegraph");
				c3col_groups = parseNull(request.getParameter(_tkey + "_c3colgroups"));

				for(int z=0; z<_colnames.length; z++)
				{
					if(parseNull(_colnames[z]).length() > 0 && parseNull(_colgraph[z]).length() > 0)
					{
						c3col_graph_type += parseNull(_colnames[z]) + ":" + parseNull(_colgraph[z]) + ",";
					}
				}
//				System.out.println("--- " + c3col_graph_type);
			}

		}
		else if(parseNull(parentjsontags[i]).startsWith("d3mapchljson_") && parseNull(jsontags[i]).startsWith("data"))
		{

			String _tkey = parseNull(jsontags[i]);
			if(parseNull(parentjsontags[i]).length() > 0) _tkey = parseNull(parentjsontags[i]) + "." + parseNull(jsontags[i]);
			_tkey = _tkey.replace("[*]","").replace(".", "_");

			String geoType = parseNull(request.getParameter(_tkey + "_geotype"));			
//System.out.println("-------------- : : " + geoType);
			String scale = parseNull(request.getParameter(_tkey + "_scale"));			
//System.out.println("-------------- : : " + scale);
			extras = "<geo_type>"+geoType+"</geo_type><scale>"+scale+"</scale>";
//System.out.println("-------------- : : " + extras);

		}
		else if(parseNull(parentjsontags[i]).startsWith("d3mapjson_") && parseNull(jsontags[i]).startsWith("data"))
		{

			String _tkey = parseNull(jsontags[i]);
			if(parseNull(parentjsontags[i]).length() > 0) _tkey = parseNull(parentjsontags[i]) + "." + parseNull(jsontags[i]);
			_tkey = _tkey.replace("[*]","").replace(".", "_");

			String geoType = parseNull(request.getParameter(_tkey + "_geotype"));			
//System.out.println("-------------- : : " + geoType);
			extras = "<geo_type>"+geoType+"</geo_type>";
//System.out.println("-------------- : : " + extras);

		}
		


		String q = " insert into expert_system_script (json_id, json_tag, parent_json_tag, html_tag, max_rows, show_col, col_header, col_seq_num, functions, field_type, field_name, fill_from, add_pagination, col_header_css, col_value_css, created_by, d3chart, c3chart, xaxis, xcols, ycols, c3col_graph_type, c3_col_groups, extra_fields) " +
		" values ("+escape.cote(parseNull(jsonid))+", "+escape.cote(parseNull(jsontags[i]))+", "+escape.cote(parseNull(parentjsontags[i]))+", "+escape.cote(parseNull(selectedoutputtags[i]))+", " +
			" "+escape.cote(parseNull(showmaxrows[i]))+", "+escape.cote(parseNull(showcols[i]))+", "+escape.cote(parseNull(colheaders[i]))+", "+escape.cote(parseNull(colnums[i]))+", "+escape.cote(parseNull(functions[i]))+", "+escape.cote(parseNull(fieldtypes[i]))+", "+escape.cote(parseNull(fieldnames[i]))+", "+escape.cote(parseNull(fillfroms[i]))+", "+escape.cote(parseNull(addpaginations[i]))+","+escape.cote(parseNull(colHeaderCss[i]))+","+escape.cote(parseNull(colcss[i]))+","+Etn.getId()+", "+escape.cote(parseNull(d3charts[i]))+", "+escape.cote(parseNull(c3charts[i]))+", "+escape.cote(parseNull(xaxis))+", "+escape.cote(parseNull(xcols))+", "+escape.cote(parseNull(ycols))+", "+escape.cote(parseNull(c3col_graph_type))+", "+escape.cote(c3col_groups)+", "+escape.cote(extras)+") ";
		qrys.add(q);
	}
	if(!qrys.isEmpty())
	{
		Etn.executeCmd("delete from expert_system_script where json_id = " + escape.cote(parseNull(jsonid)));
		Etn.execute(qrys.toArray(new String[qrys.size()]));
		Etn.executeCmd("update expert_system_json set status = '1' where id = " +  escape.cote(parseNull(jsonid)));//status = 1 means script settings are changed so we need to generate script files again
	}

	response.sendRedirect("uiScript.jsp?jsonid="+jsonid);
%>