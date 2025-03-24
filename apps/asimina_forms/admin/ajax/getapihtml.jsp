<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>
<%@ page import="java.lang.StringBuffer" %>
<%@ page import="java.util.*"%>
<%@ page import="org.json.*"%>
<%@ page import="com.etn.asimina.util.UIHelper"%>

<%!
	Map<String, String> getKeyValues(com.etn.beans.Contexte Etn, String query, String strOptionsJson)
	{
		Map<String, String> keyValues = new LinkedHashMap<String, String>();
		if(parseNull(query).length() > 0)
		{
			Set rsQ = Etn.execute(query);
			if(rsQ != null)
			{
				while(rsQ.next())
				{
					String key = parseNull(rsQ.value(0));
					String val = parseNull(rsQ.value(0));
					if(rsQ.ColName.length > 1) val = parseNull(rsQ.value(1));
					keyValues.put(key, val);
				}
			}
		}
		else if(parseNull(strOptionsJson).length() > 0)
		{
			try
			{
				JSONObject optionsJson = new JSONObject(strOptionsJson);
				if(optionsJson != null)
				{
					for(int i=0; i<optionsJson.getJSONArray("val").length();i++)
					{
						String key = parseNull(optionsJson.getJSONArray("val").getString(i));
						String val = parseNull(optionsJson.getJSONArray("txt").getString(i));
						keyValues.put(key, val);
					}
				}
			} catch (Exception e) { e.printStackTrace(); }
		}	
		return keyValues;
	}

    public String parseNull(String s)
    {
        if (s == null) return ("");
        if (s.equals("null")) return ("");
        return (s.trim());
    }

    public int parseNullInt(String s)
    {
        if (s == null) return 0;
        if (s.equals("null")) return 0;
        if (s.equals("")) return 0;
        return Integer.parseInt(s);
    }

    public double parseNullDouble(String s)
    {
        if (s == null) return 0;
        if (s.equals("null")) return 0;
        if (s.equals("")) return 0;
        return Double.parseDouble(s);
    }
	public String escapeCoteValue(String str){

        if(str != null && str.length() > 0 ){
          return str.replace("'","&#39;").replace("\"","&#34;").replace("<","&lt;").replace(">","&gt;");
        }
        else{
          return str;
        }
	}

    String getFormHtml(com.etn.beans.Contexte Etn, String formId, String langId)
	{          
		String formSubmitBtnLbl = "Submit";
		String formCancelBtnLbl = "Cancel";
		String successMsg = "Data saved successfully!!!";
	
		String h = "";

		Set rs = Etn.execute("Select f.*, d.submit_btn_lbl, d.cancel_btn_lbl, d.success_msg from process_forms f join process_form_descriptions_unpublished d on d.form_id = f.form_id and d.langue_id = "+escape.cote(langId)+" where f.form_id = "+escape.cote(formId));
		if(rs.next())
		{
			if(parseNull(rs.value("submit_btn_lbl")).length() > 0) formSubmitBtnLbl = parseNull(rs.value("submit_btn_lbl"));
			if(parseNull(rs.value("cancel_btn_lbl")).length() > 0) formCancelBtnLbl = parseNull(rs.value("cancel_btn_lbl"));
			if(parseNull(rs.value("success_msg")).length() > 0) successMsg = parseNull(rs.value("success_msg"));
				
			h = "<form id='"+rs.value("form_id")+"' >\n";

			Set rsF = Etn.execute("select d.options, d.option_query, d.value, f.file_extension, f.type, f.field_id, f.label_id, f.field_type, f.db_column_name, f.seq_order, f.maxlength, f.required, d.label, d.placeholder "+
				" from process_form_fields f join process_form_field_descriptions d on d.form_id = f.form_id and d.field_id = f.field_id and d.langue_id = "+escape.cote(langId)+
				" join process_form_lines l on l.id = f.line_id and f.form_id = l.form_id where f.form_id ="+escape.cote(formId)+ " order by l.line_seq, f.seq_order");
			System.out.println("select f.file_extension, f.type, f.field_id, f.label_id, f.field_type, f.db_column_name, f.seq_order, f.maxlength, f.required, d.label, d.placeholder "+
				" from process_form_fields f join process_form_field_descriptions d on d.form_id = f.form_id and d.field_id = f.field_id and d.langue_id = "+escape.cote(langId)+
				" join process_form_lines l on l.id = f.line_id and f.form_id = l.form_id where f.form_id ="+escape.cote(formId)+ " order by l.line_seq, f.seq_order");
			
			while(rsF.next())
			{
				String fieldtype = rsF.value("type");				
				
				if(fieldtype.equals("button") || fieldtype.equals("hyperlink") || fieldtype.equals("textrecaptcha") ) continue;
				
				String fieldvalue = parseNull(rsF.value("value"));
				
				System.out.println(fieldtype);
				String maxlength = "";				
				if(parseNull(rsF.value("maxlength")).length() > 0) maxlength = " maxlength='"+parseNull(rsF.value("maxlength"))+"' ";
				String placeholder = "";
				if(parseNull(rsF.value("placeholder")).length() > 0) placeholder = " placeholder='"+parseNull(rsF.value("placeholder"))+"' ";
				String required = "";
				if(parseNull(rsF.value("required")).equals("1")) required = " required ";
				
				if("texttextarea".equals(fieldtype))
				{
					h += rsF.value("label")+ " <textarea "+required+" name='"+rsF.value("db_column_name")+"' data-noe-fname='"+rsF.value("db_column_name")+"'></textarea>\n";
				}
				else if("label".equals(fieldtype))
				{
					h += "<label>"+rsF.value("label")+ "</label>\n";
				}
				else if("email".equals(fieldtype))
				{
					h += rsF.value("label")+ " <input type='email' value='"+escapeCoteValue(fieldvalue)+"' "+placeholder+" "+maxlength+" "+required+" name='"+rsF.value("db_column_name")+"' data-noe-fname='"+rsF.value("db_column_name")+"'>\n";
				}
				else if("dropdown".equals(fieldtype))
				{
					Map<String, String> keyValues = getKeyValues(Etn, parseNull(rsF.value("option_query")), parseNull(rsF.value("options")));
					h += rsF.value("label")+ " <select "+required+" name='"+rsF.value("db_column_name")+"' data-noe-fname='"+rsF.value("db_column_name")+"'>\n";
					for(String k : keyValues.keySet())
					{
						h += "<option value='"+escapeCoteValue(k)+"'>"+escapeCoteValue(keyValues.get(k))+"</option>\n";
					}
					h += "</select>\n";
				}
				else if("checkbox".equals(fieldtype))
				{
					Map<String, String> keyValues = getKeyValues(Etn, parseNull(rsF.value("option_query")), parseNull(rsF.value("options")));
					h += rsF.value("label") + " ";
					for(String k : keyValues.keySet())
					{
						h += "<input "+required+" type='checkbox' value='"+escapeCoteValue(k)+"' name='"+rsF.value("db_column_name")+"' data-noe-fname='"+rsF.value("db_column_name")+"'>"+escapeCoteValue(keyValues.get(k));
					}
					h += "\n";
				}
				else if("radio".equals(fieldtype))
				{
					Map<String, String> keyValues = getKeyValues(Etn, parseNull(rsF.value("option_query")), parseNull(rsF.value("options")));
					h += rsF.value("label") + " ";
					for(String k : keyValues.keySet())
					{
						h += "<input "+required+" type='radio' value='"+escapeCoteValue(k)+"' name='"+rsF.value("db_column_name")+"' data-noe-fname='"+rsF.value("db_column_name")+"'>"+escapeCoteValue(keyValues.get(k));
					}
					h += "\n";
				}
				else if("texthidden".equals(fieldtype))
				{
					h += " <input type='hidden' value='"+escapeCoteValue(fieldvalue)+"' name='"+rsF.value("db_column_name")+"' data-noe-fname='"+rsF.value("db_column_name")+"'>\n";
				}
				else if("fileupload".equals(fieldtype))
				{
					String accept = "";
					if(parseNull(rsF.value("file_extension")).length() > 0)
					{
						String[] exts = parseNull(rsF.value("file_extension")).split(",");
						if(exts != null && exts.length > 0)
						{
							accept = "accept='";
							for(int i=0;i<exts.length;i++)
							{
								if(i>0) accept += ",";
								accept += "."+exts[i];
							}
							accept += "'";
						}
					}
					h += rsF.value("label")+ " <input type='file' "+accept+" value='"+escapeCoteValue(fieldvalue)+"' "+placeholder+" "+required+" name='"+rsF.value("db_column_name")+"' data-noe-fname='"+rsF.value("db_column_name")+"'>\n";
				}
				else
				{
					h += rsF.value("label")+ " <input type='text' value='"+escapeCoteValue(fieldvalue)+"' "+placeholder+" "+maxlength+" "+required+" name='"+rsF.value("db_column_name")+"' data-noe-fname='"+rsF.value("db_column_name")+"'>\n";
				}
			}
			
			h += "<input type='button' value='" + formSubmitBtnLbl + "' data-formid='"+rs.value("form_id")+"' class='asm-cf-form' data-callback=''>\n";
			h += "<input type='reset' value='" + formCancelBtnLbl + "'>\n";
			h += "</form>";
		}

      return h;
    }
%>
<%
	String formid = parseNull(request.getParameter("id"));
	String langid = parseNull(request.getParameter("langid"));
	
	out.write(getFormHtml(Etn, formid, langid));
%>