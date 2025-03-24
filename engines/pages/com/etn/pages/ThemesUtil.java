package com.etn.pages;

import com.etn.beans.Etn;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class ThemesUtil {

    public static String lastModified(Path path){
        long  lastModifiedInMilliSeconds =  path.toFile().lastModified();
        Date date = new Date(lastModifiedInMilliSeconds);
        DateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
        return df.format(date);
    }

    public static List<JSONObject> getAllContentItems(Etn Etn, String siteId, Path folderPath, String itemType) throws IOException{
        int count = 0;
        EntityImport entityImport = new EntityImport(Etn, siteId, 3);
        List<JSONObject> itemsData = new ArrayList<>();

        List<Path> paths =  Files.walk(folderPath, 1)
            .filter(Files::isRegularFile)
            .filter(p -> p.getFileName().toString().endsWith(".json"))
            .collect(Collectors
            .toList());


       for(Path path : paths){
            StringBuilder fileContent = new StringBuilder();
            // read file
            try (Stream<String> stream = Files.lines(path, StandardCharsets.UTF_8))
            {
                stream.forEach(s -> fileContent.append(s).append(System.getProperty("line.separator")));
            } catch (IOException e) {
                e.printStackTrace();
                continue;
            }
            // validate json
            try {
                JSONObject fileData = new JSONObject(fileContent.toString());

                JSONArray items =  fileData.getJSONArray("items");

                for(Object item: items) {
                    JSONObject itemJsonObject = (JSONObject)item;
                    if(itemJsonObject.getString("item_type").equals(itemType)){
                        JSONObject obj = new JSONObject();
                        JSONObject statusObj = new JSONObject();
                        String error = entityImport.verifyImportItem(itemJsonObject, statusObj);
                        JSONObject itemWrapper = new JSONObject();
                        itemWrapper.put("item", itemJsonObject);
                        itemWrapper.put("status", statusObj.getString("status"));
                        itemWrapper.put("error", error);
                        itemsData.add(itemWrapper);
                    }
                }
            } catch (org.json.JSONException ex) {
                ex.printStackTrace();
            }
       }
       return  itemsData;
    }

    public static String getFileExtension(Path path){
        String fileName = path.getFileName().toString();
        int i = fileName.lastIndexOf('.');
        if (i > 0) {
            return fileName.substring(i + 1);
        }
        return "";
    }

    public static String getFileTypeFromExtension(String[] fileTypes,String ext){
       HashSet<String> set ;
       String fileType = "";
       for(String type: fileTypes){
            set = new HashSet<>(Arrays.asList(PagesUtil.ALLOWED_FILETYPES.get(type)));
            if(set.contains(ext)){
                 fileType = type;
                 break;
            }
        }
        return fileType;
    }

    public static Boolean validateFileExtension(String[] fileTypes ,String ext){
       HashSet<String> set ;
       boolean valid = false;
       for(String type: fileTypes){
            set = new HashSet<>(Arrays.asList(PagesUtil.ALLOWED_FILETYPES.get(type)));
            if(set.contains(ext)){
                 valid = true;
                 break;
            }
        }
        return valid;
    }

    public static List<Path> getContentFiles(String[] fileTypes ,Path folderPath) throws IOException {

        List<String[]> allFileTypes = new ArrayList<>();
        int totalSize = 0;

        for(String type: fileTypes){
            totalSize += PagesUtil.ALLOWED_FILETYPES.get(type).length;
        }
        List<String> fileExtensions  = new ArrayList<>(totalSize);

        for(String type: fileTypes){
            Collections.addAll(fileExtensions, PagesUtil.ALLOWED_FILETYPES.get(type));
        }
        java.util.Set<String> fileExtensionsSet = new HashSet<>(fileExtensions);

        return Files.walk(folderPath, 1)
                    .filter(file ->
                         fileExtensionsSet.contains(getFileExtension(file)))
                    .collect(Collectors.toList());
    }
}
