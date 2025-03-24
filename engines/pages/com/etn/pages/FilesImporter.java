package com.etn.pages;

import com.etn.beans.Etn;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;

import java.io.File;
import java.io.FileFilter;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Properties;
import java.util.function.Function;

/**
 * Detect and import new files in upload folder
 * of pages web app, which are not in DB records
 *
 * @author Ali Adnan
 * @since 2019-04-01
 */
public class FilesImporter extends BaseClass {

    public FilesImporter(Etn Etn, Properties env, boolean debug) {
        super(Etn, env, debug);
    }

    public FilesImporter(Etn Etn) {
        super(Etn);
    }

    public void importFiles() throws Exception {
        getParm("BASE_DIR"); //testing env
        getParm("UPLOADS_FOLDER"); //testing env

        String q;
        Set rs;

        try {
            String UPLOADS_FOLDER_PATH = getParm("BASE_DIR") + getParm("UPLOADS_FOLDER");
            File uploadsFolder = new File(UPLOADS_FOLDER_PATH);

            if (!uploadsFolder.exists() || !uploadsFolder.isDirectory()) {
                log("Error: Uploads folder does not exist.");
                return;
            }
            //images

            Function<String[], String[]> prefixDot = stringArr -> {
				String[] extensions = new String[stringArr.length];
                for (int i = 0; i < stringArr.length; i++) {
                    extensions[i] = "." +stringArr[i];
                }
                return extensions;
            };
            HashSet<String> allowedExtensions = new HashSet<>();

            String[] imageExtensions = prefixDot.apply(PagesUtil.getAllowedFileTypes("img"));
            allowedExtensions.addAll(Arrays.asList(imageExtensions));
            importFilesGeneric(uploadsFolder, "img", allowedExtensions);

            //js files
            allowedExtensions.clear();
            allowedExtensions.add(".js");
            importFilesGeneric(uploadsFolder, "js", allowedExtensions);

            //css files
            allowedExtensions.clear();
            allowedExtensions.add(".css");
            importFilesGeneric(uploadsFolder, "css", allowedExtensions);

            //fonts files
            String[] fontExtensions = prefixDot.apply(PagesUtil.getAllowedFileTypes("fonts"));
            allowedExtensions.clear();
            allowedExtensions.addAll(Arrays.asList(fontExtensions));
            importFilesGeneric(uploadsFolder, "fonts", allowedExtensions);

            //other files
            String[] otherExtensions = prefixDot.apply(PagesUtil.getAllowedFileTypes("other"));
            allowedExtensions.clear();
            allowedExtensions.addAll(Arrays.asList(otherExtensions));
            importFilesGeneric(uploadsFolder, "other", allowedExtensions);

            String[] videoExtensions = prefixDot.apply(PagesUtil.getAllowedFileTypes("video"));
            allowedExtensions.clear();
            allowedExtensions.addAll(Arrays.asList(videoExtensions));
            importFilesGeneric(uploadsFolder, "video", allowedExtensions);

        }
        finally {

        }

    }

    private void importFilesGeneric(File uploadsFolder, String type, HashSet<String> allowedExtensions) throws Exception {

        Set sitesRs = Etn.execute("SELECT id FROM " + getParm("PORTAL_DB") + ".sites;");

        while (sitesRs.next()) {
            String siteId = sitesRs.value("id");
            try {

                String q;
                Set rs;
                boolean isImg = "img".equals(type);

                String label = isImg ? "image" : type;
                // log(uploadsFolder.getAbsolutePath() + "/" + siteId + "/" + type + "/");
                File targetFolder = new File(uploadsFolder.getAbsolutePath() + "/" + siteId + "/" + type + "/");

                if (!targetFolder.exists() || !targetFolder.isDirectory()) {
                    // log("Error: '" + type + "' does not exist in uploads folder for site : " + siteId);
                    //log("Skipping " + label + " files import");
                    continue; // return;
                }

                HashSet<String> existingFiles = null;

                q = "SELECT file_name FROM files "
                    + " WHERE type = " + escape.cote(type) + " AND site_id = " + escape.cote(siteId);

                rs = Etn.execute(q);
                if (rs.rs.Rows > 0) {
                    existingFiles = new HashSet<>(rs.rs.Rows);
                    while (rs.next()) {
                        existingFiles.add(rs.value("file_name").trim());
                    }
                }
                else {
                    existingFiles = new HashSet<>();
                }

                CustomFileFilter customFileFilter = new CustomFileFilter(existingFiles, allowedExtensions);
                File[] filesList = targetFolder.listFiles(customFileFilter);

                if (filesList == null || filesList.length == 0) {
                    continue; // return;
                }

                int importCount = 0;
                for (File curFile : filesList) {
                    try {
                        String fileName = curFile.getName();
                        String fileLabel = removeExtension(fileName, allowedExtensions);

                        String fileSize = FilesUtil.getFileSize(curFile);

                        q = "INSERT IGNORE INTO files "
                            + " (file_name, label, type, file_size,  "
                            + " created_ts, updated_ts, created_by, updated_by, site_id) "
                            + " VALUES (" + escape.cote(fileName)
                            + " , " + escape.cote(fileLabel)
                            + " , " + escape.cote(type)
                            + " , " + escape.cote(fileSize)
                            + " , NOW(), NOW(), '1', '1', " + escape.cote(siteId) + ") ";
                        int count = Etn.executeCmd(q);
                        if (count > 0) {
                            importCount++;
                        }
                    }
                    catch (Exception fileEx) {
                        //do nothing
                    }
                }

                if (importCount > 0) {
                    log(importCount + " " + label.toUpperCase() + " files imported");
                }
            }
            catch (Exception ex) {
                log("Exception in type = " + type + " , site id = " + siteId);
                ex.printStackTrace();

            }
        }//while
    }

    private static class CustomFileFilter implements FileFilter {

        private final HashSet<String> existingFiles;
        private final HashSet<String> allowedExtensions;

        public CustomFileFilter(HashSet<String> existingFiles, HashSet<String> allowedExtensions) {
            this.existingFiles = existingFiles;
            this.allowedExtensions = allowedExtensions;
        }

        @Override
        public boolean accept(File file) {
            if (!file.isFile() || existingFiles.contains(file.getName())) {
                return false;
            }

            String ext = "";
            if (file.getName().lastIndexOf(".") >= 0) {
                ext = file.getName().substring(file.getName().lastIndexOf(".")).toLowerCase();
            }

            return allowedExtensions.contains(ext);

        }
    }

    private String removeExtension(String fileName, HashSet<String> allowedExtensions) {

        String fileNameWithouExt = fileName;
        for (String curExt : allowedExtensions) {
            if (fileName.endsWith(curExt)) {
                fileNameWithouExt = fileName.substring(0, fileName.lastIndexOf("."));
                break;
            }
        }

        return fileNameWithouExt;
    }

}
