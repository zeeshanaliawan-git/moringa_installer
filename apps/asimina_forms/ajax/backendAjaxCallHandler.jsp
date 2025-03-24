<%
  response.setCharacterEncoding("utf-8");
  request.setCharacterEncoding("utf-8");
%>
<%@page import="com.etn.lang.Xml.Rs2Xml"%>
<%@page import="com.etn.sql.escape"%>
<%@page contentType="text/html; charset=UTF-8" %>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="java.util.*"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.Map.Entry"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.LinkedHashMap"%>
<%@ page import="java.util.Arrays"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.LinkedList"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Enumeration"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.Calendar"%>
<%@ page import="javax.servlet.http.Cookie"%>
<%@ page import="com.etn.datatables.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.util.FormDataFilter"%>
<%@ page import="java.io.FileOutputStream"%>
<%@ page import="java.io.File"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm, Logjava.util.*,org.apache.commons.fileupload.*, org.apache.commons.fileupload.servlet.*, org.apache.commons.fileupload.disk.*, com.etn.util.ItsDate, org.apache.tika.*"%>
<%@ page import="java.util.regex.Pattern"%>
<%@ page import="java.util.regex.Matcher"%>
<%@ page import="com.etn.asimina.data.LanguageFactory, com.etn.asimina.beans.Language" %>
<%@ page import="com.etn.util.XSSHandler, org.json.*" %>

<%@ include file="../common2.jsp" %>

<%	
	String action = parseNull(request.getParameter("action"));
	if(action.equals("getJsCode"))
	{
		String formId = parseNull(request.getParameter("form_id"));
		String ruleId = parseNull(request.getParameter("rule_id"));

		out.write("<script>" + getJsTriggersCode(Etn, formId, ruleId) + "</script>");
	} 
	else 
	{		
		response.setContentType("application/json");
		
		JSONObject jResp = new JSONObject();
		FileItemFactory factory = new DiskFileItemFactory();
		ServletFileUpload upload = new ServletFileUpload(factory);

		List items = null;

		try
		{
			upload.setHeaderEncoding("UTF-8");
			items = upload.parseRequest(request);
		}
		catch (FileUploadException e)
		{
			e.printStackTrace();
		}
		Iterator itr = items.iterator();
		List<FileItem> files = new ArrayList<FileItem>();

		Map<String, String> incomingfields = new HashMap<String, String>();
		Map<String, String> filesMap = new HashMap<String, String>();
		try
		{
			String field= "";
			String value= "";
			String multipleFieldValue = "";

			while (itr.hasNext())
			{
				FileItem item = (FileItem)(itr.next());

				if (item.isFormField())
				{
					field=item.getFieldName().toLowerCase();
					value = XSSHandler.clean(item.getString("UTF-8"));
					if(value.length() == 0) continue;
					if(incomingfields.containsKey(field))
					{
						multipleFieldValue = incomingfields.get(field) + "!@##@!" + value;
						incomingfields.put(field, multipleFieldValue);
					}
					else
					{
						incomingfields.put(field, value);
					}
				}
				else
				{
					field = item.getFieldName();
					value = item.getName().replace("<","-").replace(">","-").replace("\\","-").replace("/","-");
					if(value.length() == 0) continue;
					if(filesMap.containsKey(field))
					{
						multipleFieldValue = filesMap.get(field) + "!@##@!" + value;
						filesMap.put(field, multipleFieldValue);
					}
					else
					{
						filesMap.put(field, value);
					}

					files.add(item);
				}
			}//while

			String formId = parseNull(incomingfields.get("form_id"));
			String ruleId = parseNull(incomingfields.get("rule_id"));
			String isUpdate = parseNull(incomingfields.get("update_generic"));
			String tableId = parseNull(incomingfields.get("table_id"));
			String mid = parseNull(incomingfields.get("mid"));
			String menuLang = parseNull(incomingfields.get("menu_lang"));
			String portalurl = parseNull(incomingfields.get("portalurl"));
			String formToken = parseNull(incomingfields.get("form_token"));

			String userIp = parseNull(request.getHeader("X-FORWARDED-FOR"));

			String updateQuery = "";
			String query = "";
			String errorMessage = "";

			String params = "";
			String values = "";
			String tableName = "";
			String processName = "";
			String requestParameterValue = "";
			String insertQuery = "INSERT INTO ";
			int rowId = 0;
			Pattern pattern = Pattern.compile("@@(.*)@@");
			Matcher matcher = null;
			int elementGroupOfFields = 1;
			Map<String, String> fileExtensionMap = new HashMap<String, String>();
			boolean fileUploadFlag = false;

			String[] multipleVal = null;

			if(isUpdate.length() > 0 && isUpdate.equals("update"))
			{
				query = "SELECT pf.form_id, table_name, db_column_name, name, pff.type, pff.group_of_fields FROM process_forms_unpublished pf, process_form_fields_unpublished pff WHERE pf.form_id = pff.form_id AND pf.form_id = " + escape.cote(formId) + " AND pff.rule_field != 1 AND name != ''";

				Set requestParameterRs = Etn.execute(query);

				while(requestParameterRs.next())
				{
					tableName = parseNull(requestParameterRs.value("table_name"));
					requestParameterValue = "";
					elementGroupOfFields = parseNullInt(requestParameterRs.value("group_of_fields"));

					values = "";

					if(null!= incomingfields.get(requestParameterRs.value("db_column_name")) && "multextfield".equalsIgnoreCase(parseNull(requestParameterRs.value("type"))))
					{
						multipleVal = incomingfields.get(requestParameterRs.value("db_column_name")).split("!@##@!");

						for(int i=0; elementGroupOfFields != 0 && i < multipleVal.length;)
						{
							for(int j=0; j < elementGroupOfFields; j++)
							{
								requestParameterValue += parseNull(multipleVal[i++]);
								if( j != elementGroupOfFields-1 ) requestParameterValue += ";";
							}
							requestParameterValue += ",";
						}

						requestParameterValue = requestParameterValue.substring(0, requestParameterValue.length()-1);

					} 
					else if(null != incomingfields.get(requestParameterRs.value("db_column_name")) && "checkbox".equalsIgnoreCase(parseNull(requestParameterRs.value("type")))) 
					{
						multipleVal = incomingfields.get(requestParameterRs.value("db_column_name")).split("!@##@!");

						for(int i=0; i < multipleVal.length; i++){
							requestParameterValue += parseNull(multipleVal[i]);
							if( i != multipleVal.length-1 ) requestParameterValue += ";";
						}

					} 
					else if( null != filesMap.get(requestParameterRs.value("db_column_name")) && files.size() > 0 && "fileupload".equalsIgnoreCase(parseNull(requestParameterRs.value("type"))))
					{
						multipleVal = filesMap.get(requestParameterRs.value("db_column_name")).split("!@##@!");

						for(int i=0; i < multipleVal.length; i++)
						{
							requestParameterValue += parseNull(multipleVal[i]);
							if( i != multipleVal.length-1 ) requestParameterValue += ";";
						}
					} 
					else 
					{
						requestParameterValue = parseNull(incomingfields.get(requestParameterRs.value("db_column_name").replaceAll(" ", "_").toLowerCase()));
					}

					params = parseNull(requestParameterRs.value("db_column_name"));
					if(requestParameterValue.length() > 0)
					{
						values = requestParameterValue;

						if("textdate".equalsIgnoreCase(parseNull(requestParameterRs.value("type"))))//its date
						{
							values = ItsDate.stamp(ItsDate.getDate(values)).substring(0,8);
						}
						else if("textdatetime".equalsIgnoreCase(parseNull(requestParameterRs.value("type"))))//its date
						{
							if(values.length() <= 16) values += ":00";
							values = ItsDate.stamp(ItsDate.getDate(values));
						}
					}

					if(parseNull(requestParameterRs.value("type")).equals("texthidden") && requestParameterValue.contains("@@"))
					{
						matcher = pattern.matcher(requestParameterValue);
						if (matcher.find()) 
						{
							values = requestParameterValue.substring(0, requestParameterValue.indexOf("@@")) + parseNull(request.getParameter(matcher.group(1))) + requestParameterValue.substring(requestParameterValue.lastIndexOf("@@")+2, requestParameterValue.length());
						}
					}

					updateQuery = "UPDATE " + tableName + " SET " + params + "=" + escape.cote(values) + " WHERE " + tableName + "_id = " + escape.cote(tableId);

					rowId = Etn.executeCmd(updateQuery);
				}//while

			} 
			else 
			{
				query = "SELECT pff.field_id, process_name, table_name, db_column_name, name, pff.type, group_of_fields, pf.type as form_type, pff.file_extension FROM process_forms_unpublished pf, process_form_fields_unpublished pff WHERE pf.form_id = pff.form_id AND pf.form_id = " + escape.cote(formId) + " AND name != ''";

				Set requestParameterRs = Etn.execute(query);
				Set freqRulesRs = null;
				String fieldId = "";
				String freq = "";
				String periodValue = "";
				String formType = "";
				boolean freqFlag = true;

				while(requestParameterRs.next())
				{
					requestParameterValue = "";
					fieldId = parseNull(requestParameterRs.value("field_id"));
					elementGroupOfFields = parseNullInt(requestParameterRs.value("group_of_fields"));
					processName = parseNull(requestParameterRs.value("process_name"));
					tableName = parseNull(requestParameterRs.value("table_name"));
					formType = parseNull(requestParameterRs.value("form_type"));

					if(null != incomingfields.get(requestParameterRs.value("db_column_name")) && "multextfield".equalsIgnoreCase(parseNull(requestParameterRs.value("type"))))
					{
						multipleVal = incomingfields.get(requestParameterRs.value("db_column_name")).split("!@##@!");

						for(int i=0; elementGroupOfFields != 0 && i < multipleVal.length;)
						{
							for(int j=0; j < elementGroupOfFields; j++)
							{
								requestParameterValue += parseNull(multipleVal[i++]);
								if( j != elementGroupOfFields-1 ) requestParameterValue += ";";
							}
							requestParameterValue += ",";
						}
						requestParameterValue = requestParameterValue.substring(0, requestParameterValue.length()-1);

					} 
					else if(null != incomingfields.get(requestParameterRs.value("db_column_name")) && "checkbox".equalsIgnoreCase(parseNull(requestParameterRs.value("type")))) 
					{
						multipleVal = incomingfields.get(requestParameterRs.value("db_column_name")).split("!@##@!");

						for(int i=0; i < multipleVal.length; i++)
						{
							requestParameterValue += parseNull(multipleVal[i]);
							if( i != multipleVal.length-1 ) requestParameterValue += ";";
						}
		
					} 
					else if( null != filesMap.get(requestParameterRs.value("db_column_name")) && files.size() > 0 && "fileupload".equalsIgnoreCase(parseNull(requestParameterRs.value("type"))))
					{
						multipleVal = filesMap.get(requestParameterRs.value("db_column_name")).split("!@##@!");

						for(int i=0; i < multipleVal.length; i++)
						{
							requestParameterValue += parseNull(multipleVal[i]);
							if( i != multipleVal.length-1 ) requestParameterValue += ";";
						}

						fileExtensionMap.put(parseNull(requestParameterRs.value("db_column_name")), parseNull(requestParameterRs.value("file_extension")));

					} 
					else 
					{
						requestParameterValue = parseNull(incomingfields.get(requestParameterRs.value("db_column_name").replaceAll(" ", "_").toLowerCase()));
					}

					if(requestParameterValue.length() > 0)
					{
						if("textdate".equalsIgnoreCase(parseNull(requestParameterRs.value("type"))))//its date
						{
							requestParameterValue = ItsDate.stamp(ItsDate.getDate(requestParameterValue)).substring(0,8);
						}
						else if("textdatetime".equalsIgnoreCase(parseNull(requestParameterRs.value("type"))))//its date
						{
							if(requestParameterValue.length() <= 16) requestParameterValue += ":00";
							requestParameterValue = ItsDate.stamp(ItsDate.getDate(requestParameterValue));
						}

						tableName = parseNull(requestParameterRs.value("table_name"));
						params += parseNull(requestParameterRs.value("db_column_name")) + ",";
						values += escape.cote(requestParameterValue) + ",";

						if(parseNull(requestParameterRs.value("db_column_name")).length() > 0)
						{
							freqRulesRs = Etn.execute("SELECT * FROM freq_rules WHERE form_id = " + escape.cote(formId) + " AND field_id = " + escape.cote(fieldId));
							String finalDatetime = "";
							String occurence = "";
							String  langId = LanguageFactory.instance.getLanguage(menuLang).getLanguageId();
							
							while(freqRulesRs.next())
							{
								freq = parseNull(freqRulesRs.value("frequency"));
								periodValue = parseNull(freqRulesRs.value("period"));

								finalDatetime = "";
								occurence = "";

								if(periodValue.equals("daily")) finalDatetime = "CONCAT(CURDATE(), ' 00:00:00')";
								else if(periodValue.equals("weekly")) finalDatetime = "CONCAT(DATE_SUB(CURDATE(), INTERVAL 6 DAY), '00:00:00')";
								else if(periodValue.equals("monthly")) finalDatetime = "CONCAT(DATE_SUB(CURDATE(), INTERVAL 29 DAY), '00:00:00')";

								Set freqCheckRs = Etn.execute("SELECT count(*) as occurence FROM " + tableName + " WHERE form_id = " + escape.cote(formId) + " AND " + parseNull(requestParameterRs.value("db_column_name")) + " = " + escape.cote(requestParameterValue) + " AND created_on >= " + finalDatetime + " AND created_on <= NOW();");

								if(freqCheckRs.next()) occurence = parseNull(freqCheckRs.value("occurence"));

								if(occurence.length() > 0)
								{
									if(Integer.parseInt(freq) > Integer.parseInt(occurence))
									{
										freqFlag = true;
									}
									else
									{
										freqFlag = false;
										Set fieldLabelRs = Etn.execute("SELECT label FROM process_form_field_descriptions WHERE form_id="+escape.cote(formId)+" AND field_id="+escape.cote(fieldId)+" AND langue_id="+escape.cote(parseNull(langId)));
										fieldLabelRs.next();
										jResp.put("response","error");
										jResp.put("msg","Malheureusement! Le formulaire ne peut pas être soumis pour le moment car le '"+parseNull(fieldLabelRs.value("label"))+"' a atteint sa limite maximale.");
										//out.write("{\"response\":\"error\",\"msg\":\"Malheureusement! Le formulaire ne peut pas être soumis pour le moment car le \'"+parseNull(fieldLabelRs.value("label"))+"\' a atteint sa limite maximale.\"}");
										com.etn.util.Logger.info("ajax/backendAjaxCallHandler.jsp", jResp.toString());
										out.write(jResp.toString());
										return;
									}
								}
							}
						}

						if(parseNull(requestParameterRs.value("type")).equals("texthidden") && requestParameterValue.contains("@@"))
						{
							matcher = pattern.matcher(requestParameterValue);
							if (matcher.find()) 
							{
								updateQuery += parseNull(requestParameterRs.value("db_column_name")) + " = " + escape.cote(requestParameterValue.substring(0, requestParameterValue.indexOf("@@")) + parseNull(request.getParameter(matcher.group(1))) + requestParameterValue.substring(requestParameterValue.lastIndexOf("@@")+2, requestParameterValue.length())) + ",";
							}
						}
					}
				}

				if(freqFlag)
				{
					freqRulesRs = Etn.execute("SELECT * FROM freq_rules WHERE form_id = " + escape.cote(formId) + " AND field_id = " + escape.cote("ip"));

					String finalDatetime = "";
					String occurence = "";
					while(freqRulesRs.next() && freqFlag)
					{		
						freq = parseNull(freqRulesRs.value("frequency"));
						periodValue = parseNull(freqRulesRs.value("period"));

						finalDatetime = "";
						occurence = "";

						if(periodValue.equals("daily")) finalDatetime = "CONCAT(CURDATE(), ' 00:00:00')";
						else if(periodValue.equals("weekly")) finalDatetime = "CONCAT(DATE_SUB(CURDATE(), INTERVAL 6 DAY), '00:00:00')";
						else if(periodValue.equals("monthly")) finalDatetime = "CONCAT(DATE_SUB(CURDATE(), INTERVAL 29 DAY), '00:00:00')";

						Set freqCheckRs = Etn.execute("SELECT count(*) as occurence FROM " + tableName + " WHERE form_id = " + escape.cote(formId) + " AND userip = " + escape.cote(userIp) + " AND created_on >= " + finalDatetime + " AND created_on <= NOW();");

						if(freqCheckRs.next()) occurence = parseNull(freqCheckRs.value("occurence"));

						if(occurence.length() > 0)
						{
							if(Integer.parseInt(freq) > Integer.parseInt(occurence))
							{
								freqFlag = true;
							}
							else
							{
								freqFlag = false;
								jResp.put("response","error");
								jResp.put("msg","Malheureusement! Le formulaire ne peut pas être soumis pour le moment car le 'IP' a atteint sa limite maximale.");
								out.write(jResp.toString());
								com.etn.util.Logger.info("ajax/backendAjaxCallHandler.jsp", jResp.toString());
								//out.write("{\"response\":\"error\",\"msg\":\"Malheureusement! Le formulaire ne peut pas être soumis pour le moment car le \'IP\' a atteint sa limite maximale.\"}");
								return;
							}
						}
					}
				}

				fileUploadFlag = false;
				Set supportedFileRs = Etn.execute("SELECT * FROM supported_files;");
				List<String> supportedFiles = new ArrayList<String>();

				while(supportedFileRs.next())
				supportedFiles.add(supportedFileRs.value("type"));

				String fExtension = "";

				for(FileItem fi : files)
				{
					String _type = new Tika().detect(org.apache.commons.io.IOUtils.toByteArray(fi.getInputStream()));
					String f = parseNull(fi.getName()).replace("<","-").replace(">","-").replace("\\","-").replace("/","-");
					System.out.println(">>>>>>>>>>>>>>>> f "+f);

					if(f.length() > 0) fExtension = f.split("\\.")[1];

					boolean fileFlag = false;

					if(f.length() > 0)
					{
						if(fileExtensionMap.get(fi.getFieldName()).length() > 0 && fileExtensionMap.get(fi.getFieldName()).toLowerCase().contains(fExtension.toLowerCase()) && supportedFiles.contains(_type))
						{
							fileFlag = true;
						} 
						else if( fileExtensionMap.get(fi.getFieldName()).length() == 0 && supportedFiles.contains(_type))
						{
							fileFlag = true;
						} 
						else
						{
							fileFlag = false;
						}

						if(!fileFlag)
						{
							jResp.put("response","error");
							jResp.put("msg",f + ": "+libelle_msg(Etn, request, "This file type is not supported. Please select another and try again."));
							out.write(jResp.toString());
							com.etn.util.Logger.info("ajax/backendAjaxCallHandler.jsp", jResp.toString());
							//out.write("{\"response\":\"error\",\"msg\":\""+f+": "+libelle_msg(Etn, request, "This file type is not supported. Please select another and try again.")+"\"}");
							fileUploadFlag = true;
							break;
						}
					}
				}


				if(freqFlag && params.length() > 0 && !fileUploadFlag)
				{
					if(formType.equalsIgnoreCase("sign_up"))
					{
						params += "is_admin,";
						values += escape.cote(incomingfields.get("is_admin"))+",";
					}

					params = params.substring(0, params.length()-1);
					values = values.substring(0, values.length()-1);

					insertQuery += tableName + "(form_id, rule_id, created_on, created_by, updated_by, menu_lang, mid, portalurl, userip," + params + ") VALUES (" + escape.cote(formId) + "," + escape.cote(ruleId) + ", NOW()," + Etn.getId() + "," + Etn.getId() + "," + escape.cote(menuLang) + "," + escape.cote(mid) + "," + escape.cote(portalurl) + "," + escape.cote(userIp) + "," + values + ")";

					rowId = Etn.executeCmd(insertQuery);

					new File(GlobalParm.getParm("FORM_UPLOADS_ROOT_PATH") + (formId.replaceAll("/", "").replaceAll("\\\\", ""))).mkdir();
					new File(GlobalParm.getParm("FORM_UPLOADS_ROOT_PATH") + (formId.replaceAll("/", "").replaceAll("\\\\", "")) + "/" + rowId).mkdir();

					for(FileItem fi : files)
					{
						if(fi.getName().length() > 0)
						{
							String _filename = fi.getName().replace("<","-").replace(">","-").replace("\\","-").replace("/","-");
							System.out.println(">>>>>>>>>>>>>>>> _filename "+ _filename);
							File savedFile = new File(GlobalParm.getParm("FORM_UPLOADS_ROOT_PATH") + (formId.replaceAll("/", "").replaceAll("\\\\", "")) + "/" + rowId + "/"+ _filename);
							fi.write(savedFile);
						}
					}

					if(rowId > 0 && !fileUploadFlag)
					{
						jResp.put("response","success");
						jResp.put("msg", "Success");
						jResp.put("rd", rowId);
						jResp.put("fd", formId);						
						
						//recently added row uuid column which might not be in all tables unless those are published again.
						//so we check if the column is there we also send its value in response and preferably use that to update the record
						Set colRs = Etn.execute("SHOW COLUMNS from " + tableName + " LIKE " + escape.cote("_asm_tbl_uid"));						
						if(colRs.rs.Rows  > 0)
						{
							Set _Rs = Etn.execute("Select _asm_tbl_uid from "+tableName+" where "+tableName+"_id = "+escape.cote(""+rowId));
							_Rs.next();
							jResp.put("uid", _Rs.value("_asm_tbl_uid"));
						}
						com.etn.util.Logger.info("ajax/backendAjaxCallHandler.jsp", jResp.toString());
						out.write(jResp.toString());
						//out.write("{\"response\":\"success\",\"msg\":\"Success\",\"rd\":"+rowId+",\"fd\":\""+formId+"\"}");
					}
					else 
					{
						jResp.put("response","error");
						jResp.put("msg", errorMessage);
						jResp.put("fd", formId);	
						out.write(jResp.toString());
						com.etn.util.Logger.info("ajax/backendAjaxCallHandler.jsp", jResp.toString());
						//out.write("{\"response\":\"error\",\"msg\":\"" + errorMessage + "\",\"fd\":\""+formId+"\"}");
					}


					if(rowId > 0 && !fileUploadFlag)
					{
						if(updateQuery.length() > 0) 
						{
							updateQuery = updateQuery.substring(0, updateQuery.length()-1);
							updateQuery = "UPDATE " + tableName + " SET " + updateQuery + " WHERE " + tableName + "_id = " + escape.cote(rowId+"");

							Etn.execute(updateQuery);
						}

						Etn.executeCmd("INSERT INTO post_work(proces, phase, priority, insertion_date, client_key, form_table_name) VALUES (" + escape.cote(tableName) + "," + escape.cote("FormSubmitted") + ", NOW(), NOW() ," + escape.cote(""+rowId) + "," + escape.cote(tableName) + ")");

						Etn.execute("select semfree('" + GlobalParm.getParm("SEMAPHORE") + "');");
					}
				}
			}

		}
		catch(Exception e)
		{
			e.printStackTrace();
			out.write("{\"response\":\"error\",\"msg\":\"Error\"}");
		}
	}

%>

