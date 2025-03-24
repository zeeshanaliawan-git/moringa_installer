<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="org.json.JSONArray,org.json.JSONObject,org.json.JSONException, com.google.gson.*, com.google.gson.reflect.TypeToken, java.lang.reflect.Type, org.apache.commons.fileupload.*, org.apache.commons.fileupload.FileItem, org.apache.commons.fileupload.disk.DiskFileItemFactory, org.apache.commons.fileupload.servlet.ServletFileUpload, java.util.*,java.io.*,com.etn.asimina.util.FileUtil"%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ include file="/common2.jsp" %>
<%

    UUID uuid = UUID.randomUUID();
    String pdfName = uuid. toString();
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
    try
    {
        
        String field= "";
        String value= "";

        while (itr.hasNext())
        {
            FileItem item = (FileItem)(itr.next());

            if (item.isFormField())
            {
                field = item.getFieldName();
                value = item.getString("UTF-8");
                incomingfields.put(field,value);
            }
            else
            {
                System.out.println("File");
            }
        }

        String base64_pdf =  incomingfields.get("pdf");
        File fileDirectory = FileUtil.getFile(com.etn.beans.app.GlobalParm.getParm("DASHBOARD_PDF_PATH"));//change
        FileUtil.mkDirs(fileDirectory);//change

        try ( FileOutputStream fos = FileUtil.getFileOutputStream(com.etn.beans.app.GlobalParm.getParm("DASHBOARD_PDF_PATH")+pdfName+".pdf"); ) { //change
            byte[] decoded_pdf = Base64.getDecoder().decode(base64_pdf.substring(28));
            fos.write(decoded_pdf);

            String is_sent ="0";
            int i = Etn.executeCmd("INSERT INTO dashboard_emails(email, subject, message,dashboard_pdf,email_sent) VALUES("+
            escape.cote(incomingfields.get("email"))+","+
            escape.cote(incomingfields.get("subject"))+","+
            escape.cote(incomingfields.get("message"))+","+
            escape.cote(pdfName+".pdf")+","+
            escape.cote(is_sent)
            +");");
            if(i>0){
                Etn.execute("select semfree('"+SEMAPHORE+"')");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    catch(Exception e)
    {
        System.out.println("error");
    }
%>
