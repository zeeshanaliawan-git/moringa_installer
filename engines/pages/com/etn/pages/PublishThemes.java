package com.etn.pages;

import com.etn.beans.Etn;
import com.etn.beans.app.GlobalParm;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import org.json.JSONObject;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Properties;

import static com.etn.pages.PagesUtil.getInsertQuery;
import static com.etn.pages.PagesUtil.parseInt;

public class PublishThemes extends BaseClass {

    public PublishThemes(Etn Etn, Properties env, boolean debug) {
        super(Etn, env, debug);
    }

    public PublishThemes(Etn Etn) {
        super(Etn);
    }

    private final String[] themeContents = {
        Constant.THEME_CONTENT_FILES,
        Constant.THEME_CONTENT_MEDIA,
        Constant.THEME_CONTENT_LIBRARIES,
        Constant.THEME_CONTENT_TEMPLATES,
        Constant.THEME_CONTENT_PAGE_TEMPALTES,
        Constant.THEME_CONTENT_SYSTEM_TEMPLATES
    };

    LinkedHashMap<String, String> colValueHM;
    String q = "";
    Set rs;

    private void publishFiles(String themeId, Path contentFolder, String[] fileTypes, String pid, String siteId) throws IOException {
         String uploadFolderPath = GlobalParm.getParm("BASE_DIR") + GlobalParm.getParm("UPLOADS_FOLDER") + siteId;
         LinkedHashMap<String, String> colValueHM;

        if (env != null) {
            Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Pages',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
        }
         List<Path> files = ThemesUtil.getContentFiles(fileTypes, contentFolder);
         for(Path file :  files){
            String ext = ThemesUtil.getFileExtension(file);
            String fileType = ThemesUtil.getFileTypeFromExtension(fileTypes, ext);

            // create upload directories if not exists
            Path uploadFolder = Paths.get(uploadFolderPath + File.separator + fileType);
            try {
                if(!Files.exists(uploadFolder)){
                    Files.createDirectories(uploadFolder);
                }
            } catch (IOException e) {
                System.err.println("Failed to create directory!" + e.getMessage());
            }

            Path targetedFile = uploadFolder.resolve(file.getFileName().toString());
            Files.copy(file, targetedFile, StandardCopyOption.REPLACE_EXISTING);

            colValueHM = new LinkedHashMap<>();
            colValueHM.put("file_name" , escape.cote(file.getFileName().toString()));
            colValueHM.put("type" , escape.cote(fileType));
            colValueHM.put("file_size" , escape.cote(String.valueOf(Files.size(file)/ 1024)));
            colValueHM.put("images_generated" ,"0");
            colValueHM.put("created_ts" ,"NOW()");
            colValueHM.put("updated_ts" ,"NOW()");
            colValueHM.put("created_by" , escape.cote(pid));
            colValueHM.put("updated_by" , escape.cote(pid));
            colValueHM.put("site_id" , escape.cote(siteId));
            colValueHM.put("theme_id" , escape.cote(themeId));
            colValueHM.put("theme_version", "0");
            String  q = getInsertQuery("files", colValueHM);
            q += " ON DUPLICATE KEY UPDATE theme_id=VALUES(theme_id), updated_ts=VALUES(updated_ts), updated_by=VALUES(updated_by)";
            int res = Etn.executeCmd(q);
            
        }
    }

    private void publishTempaltes(String themeId, Path contentFolder, String itemType, String siteId, String pid) throws Exception{
         EntityImport entityImport = new EntityImport(Etn, siteId, parseInt(pid));
         entityImport.setThemeId(themeId);
         
         List<JSONObject> items = ThemesUtil.getAllContentItems(Etn, siteId, contentFolder, itemType);

         for(JSONObject jsonObject :items){
            if (env != null) {
                Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Pages',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
            }
            
             if(jsonObject.getString("status").equals("error") && jsonObject.getString("error").length() > 0){
                 continue; // if there is error then we will ignore it
             }
             JSONObject item =  jsonObject.getJSONObject("item");
             entityImport.importItem(item, EntityImport.IMPORT_TYPE_REPLACE_ALL);
         }
    }

    private  void publishTheme(String themeId) throws Exception {
        String[] fileTypes;

        q = "SELECT * FROM themes WHERE id  = "+escape.cote(themeId);
        rs = Etn.execute(q);

        if(rs.next()){
            String siteId =  rs.value("site_id");
            String themesFolderPath = GlobalParm.getParm("BASE_DIR")+ GlobalParm.getParm("THEMES_FOLDER") + siteId + File.separator + rs.value("uuid");
            String pid = rs.value("published_by");

            // invalidate the previus theme
            unpublishTheme(siteId);
            // publish contents
            for(String content : themeContents){
                 Path contentFolder = Paths.get(themesFolderPath + File.separator + content);
                 switch (content){
                     case Constant.THEME_CONTENT_FILES:
                         fileTypes = new String[]{"js", "css", "fonts"};
                         publishFiles(themeId ,contentFolder, fileTypes, pid, siteId );
                         break;
                     case Constant.THEME_CONTENT_MEDIA:
                         fileTypes = new String[]{"img", "video", "other"};
                         publishFiles(themeId ,contentFolder, fileTypes, pid, siteId );
                         break;
                     case Constant.THEME_CONTENT_TEMPLATES:
                     case Constant.THEME_CONTENT_SYSTEM_TEMPLATES:
                         publishTempaltes(themeId, contentFolder,"bloc_template", siteId, pid);
                         break;
                     case Constant.THEME_CONTENT_PAGE_TEMPALTES:
                         publishTempaltes( themeId, contentFolder,"page_template", siteId, pid);
                         break;
                     case Constant.THEME_CONTENT_LIBRARIES:
                         publishTempaltes( themeId, contentFolder,"library", siteId, pid);
                         break;
                 }
            }
        }
    }

    private void unpublishTheme(String siteId){
        if (env != null) {
            Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Pages',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
        }
        // invalidate all themes
        q = "UPDATE files SET theme_id = 0, theme_version = 0 WHERE site_id = " + escape.cote(siteId);
        Etn.execute(q);
        q = "UPDATE libraries SET theme_id = 0, theme_version = 0 WHERE site_id = " + escape.cote(siteId);
        Etn.execute(q);
        q = "UPDATE page_templates SET theme_id = 0, theme_version = 0 WHERE site_id = " + escape.cote(siteId);
        Etn.execute(q);
        q = "UPDATE bloc_templates SET theme_id = 0, theme_version = 0 WHERE site_id = " + escape.cote(siteId);
        Etn.execute(q);

        Etn.executeCmd("UPDATE themes SET publish_status = 'unpublished', published_ts = NULL WHERE site_id = "+escape.cote(siteId));

    }

    public void publishUnpublishTheme(){
        try{
            q = "SELECT * FROM themes WHERE (to_publish = 1 && to_publish_ts <= NOW()) || (to_unpublish = 1 && to_unpublish_ts <= NOW()) LIMIT 1";
            rs = Etn.execute(q);
            if(rs.next()){
                int rows = 0;

                if(rs.value("to_publish").equals("1")){ // publish
                    System.out.println("Publishing theme "+rs.value("id"));
                    publishTheme(rs.value("id")); // themes published call

                    q = "UPDATE themes "  // set published status
                        + " SET publish_status = 'published',"
                        + " to_publish =  0, "
                        + " to_publish_ts = NULL, "
                        + " to_publish_by = NULL, "
                        + " published_ts = NOW(), "
                        + " published_by = "+escape.cote(rs.value("to_publish_by"))
                        + " WHERE id = "+escape.cote(rs.value("id"));
                    rows =  Etn.executeCmd(q);
                } else{ // unpublish
                    System.out.println("Unpublishing theme "+rs.value("id"));
                    unpublishTheme(rs.value("site_id"));

                    q = "UPDATE themes "  // set unpublished status
                        + " SET publish_status = 'unpublished',"
                        + " to_unpublish =  0, "
                        + " to_unpublish_ts = NULL, "
                        + " to_unpublish_by = NULL, "
                        + " published_ts = NOW(), "
                        + " published_by = "+escape.cote(rs.value("to_unpublish_by"))
                        + " WHERE id = "+escape.cote(rs.value("id"));
                    Etn.executeCmd(q);
                }
            }
        } catch (Exception ex){
            ex.printStackTrace();
        }
    }
}



























