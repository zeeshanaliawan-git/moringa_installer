package com.etn.pages.excel;

import com.etn.pages.FilesUtil;
import com.github.wnameless.json.flattener.FlattenMode;
import com.github.wnameless.json.flattener.JsonFlattener;
import com.github.wnameless.json.unflattener.JsonUnflattener;
import org.apache.poi.openxml4j.exceptions.InvalidFormatException;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.*;

/**
 * this is just a dev testing class
 */
public class ExcelTest {

    public static void main(String[] args) throws Exception {

        // test1();
        // test2();

    }

    public static void log(Object o) {
        System.out.println(o);
    }

    public static void test2() {

        JSONObject json = new JSONObject().put("name", " name field").put("sections", new String[]{});

        // log(json.toString(2));

        // log(JsonFlattener.flattenAsMap(json.toString()));

        Map<String, Object> map = new LinkedHashMap<String, Object>(){{
            put("sessions[0].name","Session 1");
            put("sessions[0].sections","[]");
            put("sessions[0].sections2","[1]");
            put("sessions[0].sections3",new ArrayList<String>());
            put("sessions[0].emptyObject",new HashMap<String, Object>());
        }};

        JsonUnflattener uf = new JsonUnflattener(map);
        log(uf.unflatten());

        log(new JSONObject(uf.unflatten()).toString(2));

    }

    public static void test1() throws Exception {
        String filePath = "D:\\temp\\pages.json";

        String fileContent = FilesUtil.readFile(new File(filePath));

        JSONObject json = new JSONObject(fileContent);

        JSONArray items = json.getJSONArray("items");

        if (items.length() == 0) return;
        JSONObject itemJson = items.getJSONObject(0);

        Map<String, Object> map = JsonFlattener.flattenAsMap(itemJson.toString());

        ArrayList<String> keys = new ArrayList<>(map.keySet());
        keys.sort(String::compareTo);
        for (String key : keys) {
            log(key + " = " + map.get(key));
        }

        String excelFilePath = "D:\\temp\\pages.xlsx";

        outputExcelFile(new File(excelFilePath), map, "page");
    }

    public static void outputExcelFile(File excelFile, Map<String, Object> map, String itemType ) throws IOException, InvalidFormatException {

        try (Workbook workbook = new XSSFWorkbook(); FileOutputStream out = new FileOutputStream(excelFile);) {
            Sheet sheet = workbook.createSheet();
            Row row;

            ArrayList<String> keys = new ArrayList<>(map.keySet());
            keys.sort(String::compareTo);

            int rowIndex = 0;
            Row headerRow = sheet.createRow(rowIndex++);
            Row dataRow = sheet.createRow(rowIndex++);

            int cellIndex = 0;
            for (String key : keys) {
                String headerName = key;
                if (headerName.startsWith("system_info.")) {
                    headerName = headerName.replace("system_info.", "");
                }
                else if (headerName.equals("internal_info.updated_ts")
                         || headerName.equals("internal_info.created_ts")) {
                    headerName = headerName.replace("internal_info.", "");
                }

                if (headerName.startsWith("folder.parent_folder")) {
                        headerName = headerName.replace("folder.parent_folder", "folder.parent");
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

                headerRow.createCell(cellIndex).setCellValue(headerName);
                dataRow.createCell(cellIndex).setCellValue(String.valueOf(map.get(key)));
                cellIndex++;
            }
            workbook.write(out);
        }

    }
}
