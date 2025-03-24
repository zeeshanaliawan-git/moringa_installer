<%@ page trimDirectiveWhitespaces="true" %>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape,com.etn.beans.app.GlobalParm"%>
<%@ page import="org.json.*, java.util.*"%>
<%@ page import="java.io.FileOutputStream"%>
<%@ page import="java.io.FileInputStream"%>
<%@ page import="java.io.BufferedInputStream"%>
<%@ page import="java.io.File"%>
<%@ page import="java.io.FileNotFoundException"%>
<%@ page import="java.io.IOException"%>
<%@ page import="java.util.zip.ZipEntry"%>
<%@ page import="java.util.zip.ZipOutputStream"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, org.apache.commons.compress.compressors.gzip.GzipCompressorOutputStream, org.apache.commons.compress.archivers.tar.TarArchiveOutputStream, java.nio.file.*, org.apache.commons.compress.archivers.tar.TarArchiveEntry, org.apache.commons.io.IOUtils,com.etn.asimina.util.FileUtil" %>

<%!
    public String parseNull(String s)
    {
        if (s == null) return ("");
        if (s.equals("null")) return ("");
        return (s.trim());
    }

    String getFormName(com.etn.beans.Contexte etn,String form_id)
    {
        Set rs = etn.execute("Select * FROM process_forms_unpublished where form_id="+escape.cote(form_id));
        rs.next();
        return rs.value("process_name");
    }

    Boolean zipDir(com.etn.beans.Contexte etn,String zipFileName, String[] dirs) throws Exception {
        boolean flag = false;
        // ZipOutputStream zip = new ZipOutputStream(new FileOutputStream(zipFileName));
        ZipOutputStream zip = new ZipOutputStream(FileUtil.getFileOutputStream(zipFileName));//change
        for(String dir : dirs){
			com.etn.util.Logger.info("admin/ajax/downloadFormFilesInZip.jsp","dir:"+dir);
			dir = dir.replaceAll("/", "").replaceAll("\\\\", "");
			com.etn.util.Logger.info("admin/ajax/downloadFormFilesInZip.jsp","final dir:"+dir);
            File dirObj = FileUtil.getFile(GlobalParm.getParm("UPLOADED_FILES_REPOSITORY")+dir);//change
            if(dirObj.exists()){
                addDir(dirObj, zip,getFormName(etn,dir));
                flag = true;
            }
			else
			{
				com.etn.util.Logger.error("admin/ajax/downloadFormFilesInZip.jsp","invalid dir:"+dir);
			}
        }
        zip.flush();
        zip.close();
        return flag;
    }

    void addDir(File dirObj, ZipOutputStream zip,String directoryName) throws IOException {
        File[] files = dirObj.listFiles();
        byte[] tmpBuf = new byte[4096];
       
        for (int i = 0; i < files.length; i++) {
            if (files[i].isDirectory()) {
                addDir(files[i], zip,directoryName);
                continue;
            }
            String [] pathParams = files[i].getCanonicalPath().split("/");
            String finalPath=directoryName+"/"+pathParams[pathParams.length-2]+"/"+pathParams[pathParams.length-1];

            FileInputStream in = FileUtil.getFileInputStream(files[i].getCanonicalPath());//change
            zip.putNextEntry(new ZipEntry(finalPath));
            int len;
            while ((len = in.read(tmpBuf)) > 0) {
                zip.write(tmpBuf, 0, len);
            }
            zip.closeEntry();
            in.close();
        }
    } 
      
%>

<%
    String filename = "form.zip";
    String ids = parseNull(request.getParameter("ids"));
    
    String [] form_ids = ids.split(",");

    JSONObject resp = new JSONObject();
	try{
        zipDir(Etn,GlobalParm.getParm("UPLOADED_FILES_REPOSITORY")+filename,form_ids);
        response.setContentType("application/zip");
        response.setHeader("Content-Disposition", "attachment; filename=\""+filename+"\"");
        resp.put("status","success");
        resp.put("url","../uploads/"+filename);
    }catch(FileNotFoundException e)
    {
        System.out.println(e);
        resp.put("status",10);
        resp.put("err_code","Form_Directory_does_not_exist");
        resp.put("message","Form Directory does not contains files exist");
    }

    out.write(resp.toString());
%>
