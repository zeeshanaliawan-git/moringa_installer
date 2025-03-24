<%@ page trimDirectiveWhitespaces="true" %>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, org.apache.commons.compress.compressors.gzip.GzipCompressorOutputStream, org.apache.commons.compress.archivers.tar.TarArchiveOutputStream, java.nio.file.*, org.apache.commons.compress.archivers.tar.TarArchiveEntry, org.apache.commons.io.IOUtils,java.io.FileInputStream,com.etn.asimina.util.FileUtil" %>
<%@ include file="../WEB-INF/include/commonMethod.jsp" %>
<%@ include file="pagesUtil.jsp" %>
<%

    	String siteId = getSiteId(session);
        String id = request.getParameter("id");
        String q = "SELECT * FROM themes WHERE id = "+escape.cote(id);
        Set rs =  Etn.execute(q);
        String message = "";

        try {
            if (rs.next()) {
                response.setContentType("application/gzip");
                response.setHeader("Content-Disposition", "attachment; filename=\"" + rs.value("name") +".tar.gz"+ "\"");

                String TEMP_DIR = GlobalParm.getParm("BASE_DIR") + GlobalParm.getParm("UPLOADS_FOLDER") + "temp";
                String THEMES_DIR = GlobalParm.getParm("BASE_DIR") + GlobalParm.getParm("THEMES_FOLDER") + siteId + File.separator + rs.value("uuid");

                JSONObject themeObject = new JSONObject();
                themeObject.put("name", rs.value("name"));
                themeObject.put("version", rs.value("version"));
                themeObject.put("description", rs.value("description"));
                themeObject.put("status", rs.value("status"));
                themeObject.put("asimina_version", rs.value("asimina_version"));
                Path themeFile = Paths.get(THEMES_DIR + File.separator + "theme.json");
                if(!Files.exists(themeFile)){
                   Files.createFile(themeFile);
                }

                Files.write(themeFile, themeObject.toString().getBytes());

                // Compressed output file name
                Path tempFolder = Paths.get(TEMP_DIR + File.separator);
                Path targetFile = tempFolder.resolve(FileUtil.sanitizePath(rs.value("name")) + ".tar.gz");
                Path source = Paths.get(THEMES_DIR);
                //OutputStream Output stream 、BufferedOutputStream Buffering the output stream
                //GzipCompressorOutputStream yes gzip Compress the output stream
                //TarArchiveOutputStream hit tar Packet output stream （ contain gzip Compress the output stream ）
                try (OutputStream fOut = Files.newOutputStream(targetFile);
                     BufferedOutputStream buffOut = new BufferedOutputStream(fOut);
                     GzipCompressorOutputStream gzOut = new GzipCompressorOutputStream(buffOut);
                     TarArchiveOutputStream tOut = new TarArchiveOutputStream(gzOut)) {
                    // Traverse the file directory tree
                    Stream<Path> walk = Files.walk(source);
                    walk.forEach(file -> {
                        if(file.getFileName().toString().length() > 0  && !file.getFileName().toString().equals(source.getFileName().toString())) {
                            // Get the current traversal file name
                            Path target = source.relativize(file);
                            // Pack and compress the file
                            TarArchiveEntry tarEntry = new TarArchiveEntry(
                                    file.toFile(), target.toString());
                            try {
                                tOut.putArchiveEntry(tarEntry);
                                Files.copy(file, tOut);
                                tOut.closeArchiveEntry();
                            }
                            catch (IOException e) {
                                e.printStackTrace();
                            }
                        }
                    });
                    tOut.finish();
                }
                catch (Exception ex) {
                    ex.printStackTrace();
                }
                // download the file
                FileInputStream fileInputStream = FileUtil.getFileInputStream(targetFile.normalize().toString());//change
                // java.io.FileInputStream fileInputStream = new java.io.FileInputStream(targetFile.normalize().toString());
                IOUtils.copyLarge(fileInputStream, response.getOutputStream());
                fileInputStream.close();
            } else {
                message = "Invalid theme id";
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }

    out.write(message);
%>