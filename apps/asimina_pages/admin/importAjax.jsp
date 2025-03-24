<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.pages.EntityImport, com.etn.sql.escape, java.util.Arrays, java.util.List, com.etn.util.FormRequest, com.etn.util.FormDataFilter"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="pagesUtil.jsp"%>
<%
    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    int status = STATUS_ERROR;
    String message = "";
    JSONObject data = new JSONObject();

    LinkedHashMap<String, String> colValueHM = new LinkedHashMap<>();

    String q = "";
    Set rs = null;
    int count = 0;

    HashMap<String ,String> requestFields = new HashMap<>();

	try{
		FormRequest formRequest = new FormRequest(this);
		FormDataFilter formData = new FormDataFilter(request.getInputStream());
		String[] fieldData = new String[3];
		while((fieldData = formData.getField()) != null){
			requestFields.put(fieldData[0], parseNull(fieldData[1]));
		}

		String batchId = requestFields.get("batchId");
		
		rs=Etn.execute("select * from batch_imports where id ="+escape.cote(batchId)+" and status='loaded'");
		if(rs.rs.Rows==1){

			rs.next();
			String itemsJson = requestFields.get("itemsJson");
			String jsonInfo = requestFields.get("jsonInfo");

			Etn.executeCmd("update batch_imports set status='importing',info="+escape.cote(jsonInfo)+" where status='loaded' and id="+escape.cote(batchId));

			String[] strArray = null;  
			strArray = itemsJson.split(",");  
			for (int i = 0; i< strArray.length; i++){  
				Etn.executeCmd("update batch_imports_items set process='import' where id="+escape.cote(strArray[i])+" and batch_table_id="+escape.cote(rs.value("id")));
			}  
			status = STATUS_SUCCESS;
			message = "Files are importing.";
		}else{
			status = STATUS_ERROR;
			rs=Etn.execute("select * from batch_imports where id ="+escape.cote(batchId));
			rs.next();
			message = "Error: This batch can not be used. It is in "+rs.value("STATUS")+" state."+"<div>If you want to import again verify batch first.</div>";
		}
		q = "SELECT semfree(" + escape.cote(parseNull(GlobalParm.getParm("IMPORT_SEMAPHORE"))) + ");";
		Etn.execute(q);
	}//try
	catch(Exception ex){
		status = STATUS_ERROR;
		message = "Error: "+ex.getMessage();
	}

	
    JSONObject jsonResponse = new JSONObject();
    jsonResponse.put("status",status);
    jsonResponse.put("message",message);
    jsonResponse.put("data",data);
   	out.write(jsonResponse.toString());
%>
