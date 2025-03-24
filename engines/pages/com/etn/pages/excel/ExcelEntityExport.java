package com.etn.pages.excel;

import com.github.wnameless.json.flattener.JsonFlattener;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.json.JSONArray;
import org.json.JSONObject;
import java.util.*;

public class ExcelEntityExport {

    public Workbook getExportExcel(JSONArray items) {
        try{
            String itemType = "";
            if(items.length()>0){
                itemType = items.getJSONObject(0).optString("item_type");
            }
            Workbook workbook = new XSSFWorkbook();
            Sheet sheet = workbook.createSheet();
            LinkedHashSet<String> keySet = new LinkedHashSet<>();
            ArrayList<LinkedHashMap<String, Object>> itemsMaps = new ArrayList<>();

            // get keys and Json items from flattern Map
            for (Object obj : items) {
                JSONObject item = (JSONObject) obj;
                if(item.optString("item_type").equals(itemType)){ // we will hanlde only first type of items

                    Map<String, Object> map  = JsonFlattener.flattenAsMap(item.toString()); // get key value pair
                    // alter Keys  headers
                    LinkedHashSet<String> keys = new LinkedHashSet<>();
                    LinkedHashMap<String, Object> itemMap = new LinkedHashMap<>();
                    for(String key : map.keySet()){
                        String headerKey = getCustomRowHeader(key, itemType);
                        itemMap.put(headerKey, map.get(key));
                        keys.add(headerKey);
                    }
                    itemsMaps.add(itemMap);
                    keySet.addAll(keys);
                }
            }

            // sorting and merging keys
            ArrayList<String> firstHeadersList = new ArrayList<>();
            ArrayList<String> secondHeadersList = new ArrayList<>();
            ArrayList<String> thirdHeadersList = new ArrayList<>();

            for(String key  : keySet){
                boolean flag = false;
                for(LinkedHashMap<String, Object> itemMap : itemsMaps){
                    String kVal = "";
                    if(itemMap.containsKey(key)){
                        Object obj = itemMap.get(key);
                        if(obj != null) {
                            kVal = obj.toString();
                        }
                    }

                    if(!(!itemMap.containsKey(key) ||
                            kVal.equals("[]") ||
                            kVal.equals("{}"))){
                        flag = true;
                        break;
                    }
                }
                if(flag){
                    int dotIndex = key.indexOf('.');
                    int bracketIndex = key.indexOf('[');
                    String firstIndex = "";

                    if(dotIndex < 0){
                       dotIndex = 999999999;
                    }
                    if(bracketIndex < 0){
                       bracketIndex = 999999999;
                    }

                    if(bracketIndex < dotIndex){
                        thirdHeadersList.add(key);
                    } else if(dotIndex < bracketIndex){
                        secondHeadersList.add(key);
                    } else{
                        firstHeadersList.add(key);
                    }
                }
            }
            //sort
            // Collections.reverse(firstHeadersList);
            // secondHeadersList.sort(String::compareTo);
            // thirdHeadersList.sort(String::compareTo);

            // combine keys
            ArrayList<String> headerKeys = new ArrayList<>();
            headerKeys.addAll(firstHeadersList);
            headerKeys.addAll(secondHeadersList);
            headerKeys.addAll(thirdHeadersList);

            int rowIndex = 0;
            // add header first
            Row row = sheet.createRow(rowIndex++); // create new sheet row
            int cellIndex = 0;
            for (String key : headerKeys) {
                row.createCell(cellIndex).setCellValue(key);
                cellIndex++;
            }

            //  add values row
            for(LinkedHashMap<String, Object> map :itemsMaps) {
                row = sheet.createRow(rowIndex++); // create new sheet row
                cellIndex = 0;
                for (String key : headerKeys) {
                    String value = "";
                    if (map.containsKey(key)) {
                        value = String.valueOf(map.get(key));
                    }
                    row.createCell(cellIndex).setCellValue(value);
                    cellIndex++;
                }
            }
            return workbook;
        }  catch (Exception ex){
            ex.printStackTrace();
        }
        return new XSSFWorkbook();
    }

    private String getCustomRowHeader(String headerName, String itemType ){
        if (headerName.startsWith("system_info.")) {
            headerName = headerName.replace("system_info.", "");
        }
        else if (headerName.equals("internal_info.updated_ts")
                 || headerName.equals("internal_info.created_ts")) {
            headerName = headerName.replace("internal_info.", "");
        }

        if (headerName.contains("parent_folder")) {
                headerName = headerName.replace("parent_folder", "parent");
        }

        for(int i=0; i<3; i++){
            String prefix = "details["+i+"].page_settings.";
            if (headerName.startsWith(prefix+"system_info.")) {
                headerName = headerName.replace("system_info.", "");
            }
            else if (headerName.equals(prefix+"internal_info.updated_ts")
                     || headerName.equals(prefix+"internal_info.created_ts")) {
                headerName = headerName.replace("internal_info.", "");
            }
            else if (headerName.startsWith(prefix+"meta_info")) {
                if(headerName.equals(prefix+"meta_info.title")){
                    headerName = headerName.replace("meta_info.title", "meta_title");
                } else{
                    headerName = headerName.replace("meta_info.", "");
                }
            }
        }

        if(itemType.equals("page")){
            if (headerName.startsWith("meta_info")) {
                if(headerName.equals("meta_info.title")){
                    headerName = headerName.replace("meta_info.title", "meta_title");
                } else{
                    headerName = headerName.replace("meta_info.", "");
                }
            }
        }

        if(itemType.equals("page_template")){
            if (headerName.startsWith("details.")) {
                headerName = headerName.replace("details.", "");
            }
        }
        return headerName;
    }
}

