<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.Contexte,java.nio.charset.StandardCharsets, com.etn.beans.app.GlobalParm,org.apache.commons.codec.digest.DigestUtils,java.time.*,java.time.format.DateTimeFormatter,java.text.SimpleDateFormat"%>
<%@ page import="org.json.*, java.util.*,java.io.*,org.apache.commons.io.comparator.LastModifiedFileComparator" %>


<%!
    String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

    String convertDateToUTC(LocalDateTime datetime){
        LocalDateTime utcNow = datetime.atOffset(ZoneOffset.UTC).toLocalDateTime();
        DateTimeFormatter formatter = DateTimeFormatter.ISO_LOCAL_DATE_TIME;
        String formattedDate = utcNow.format(formatter);
        return formattedDate.split("T")[0];
    }

    Process executeCommand(String cmd){
        ProcessBuilder processBuilder = new ProcessBuilder("bash", "-c", cmd) ;
        processBuilder.redirectErrorStream(true);
        Process process=null;
        try{
            process = processBuilder.start();
        }catch(Exception e){
            e.printStackTrace();
        }
        return process;
    }

    String readStream(InputStream inputStream){
        StringBuilder result = new StringBuilder();
        BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
        String line;
        try{
            while ((line = reader.readLine()) != null) {
                result.append(line).append("\n");
            }
        }
        catch(Exception e)
        {
            e.printStackTrace();
        }

        return result.toString();
    }

    JSONArray getAllLogs() throws JSONException 
    {
        String logsDirectory = GlobalParm.getParm("LOGS_DIRECTORY");
        JSONArray logFiles = new JSONArray();

        File folder = new File(logsDirectory);
        File[] files = folder.listFiles();
        
        Arrays.sort(files,LastModifiedFileComparator.LASTMODIFIED_REVERSE);

        SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MMM-yyyy");
        dateFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
        
        for(File file : files){
            JSONObject json = new JSONObject();
            Date lastModified = new Date(file.lastModified());
            String utcLastModified = dateFormat.format(lastModified);
            System.out.println(utcLastModified);
            json.put("date",utcLastModified);
            json.put("file_name",file.getName());
            logFiles.put(json);
        }
        return logFiles;
    }

    String findBy(String key,String value){
        String cmd = "grep -ril "+GlobalParm.getParm("LOGS_DIRECTORY")+" -e "+escape.cote(key.toLowerCase()+"="+value+">");
        Process process = executeCommand(cmd);
        try{
            System.out.println("err code : "+process.waitFor());

        }catch(InterruptedException e)
        {
            e.printStackTrace();
        }
        return readStream(process.getInputStream());
    }
%>
<%
    int status = 0;
    String message = "";
    String err_code = "";
    JSONObject json = new JSONObject();
    JSONObject data = new JSONObject();
    final String method = parseNull(request.getMethod());
    
    if(method.length()> 0 && method.equalsIgnoreCase("GET")){
        final String action = parseNull(request.getParameter("action"));
        final String orderRef = parseNull(request.getParameter("order-ref"));
        final SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MMM-yyyy");
        dateFormat.setTimeZone(TimeZone.getTimeZone("UTC"));    
        if(action.length() > 0)
        {
            if(action.equalsIgnoreCase("findby"))
            {
                JSONArray files = new JSONArray();
                String []filespaths = findBy("orderRef",orderRef).split("\n");
                boolean found = false;
                for(String path:filespaths)
                {
                    File file = new File(path);
                    Date lastModified = new Date(file.lastModified());
                    String utcLastModified = dateFormat.format(lastModified);
                    
                    if(file.isFile()){
                        JSONObject fileJson = new JSONObject();
                        fileJson.put("date",utcLastModified);
                        fileJson.put("file_name",file.getName());
                        files.put(fileJson);
                        found = true;
                    }
                }
                
                if(!found)
                {
                    status = 99;
                    err_code = "RECORD_NOT_FOUND";
                    message = "No Records found";
                }else{
                    status = 0;
                    data.put("files",files);
                }
            }else if(action.equalsIgnoreCase("getAll")){
                try{
                    data.put("files",getAllLogs());
                    status = 0;
                }catch(JSONException e){
                    status=50;
                    err_code = "SYSTEM_ERROR";
                    message = "Something went wrong";
                }
            }
            else{
                status = 20;
                err_code="INVALID_ACTIONS";
                message="Provided action is invalid";
            }
        }
        else{
            status = 10;
            err_code="ACTION_IS_MISSING";
            message="action is missing";
        }

    }else{
        status = 100;
        err_code = "NOT_SUPPORTED";
        message="fetch.jsp doesnot supports "+method+" method";
    }

    json.put("status",status);

    if(err_code.length() > 0 && status > 0)
    {
        JSONObject jobj = new JSONObject();
        jobj.put("files",new JSONArray());
        json.put("err_code",err_code);
        json.put("err_msg",message);
        json.put("data",jobj);
    }else{
        json.put("data",data);
    }

    out.write(json.toString());
%>