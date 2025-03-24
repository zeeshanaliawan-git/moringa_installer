package com.etn.pages.excel;

import com.etn.pages.PagesUtil;
import org.apache.poi.openxml4j.exceptions.InvalidFormatException;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Optional;

public class ExcelImportFile {

    protected LinkedHashMap<String, Integer> colNamesHM = new LinkedHashMap<>();
    protected List<List<String>> rows = new ArrayList<>();
    protected SimpleDateFormat dateFormat = new SimpleDateFormat(PagesUtil.getFormat("date_time"));

    public ExcelImportFile(File file) throws IOException, InvalidFormatException {

        Workbook workbook = new XSSFWorkbook(file);
        Sheet sheet = workbook.getSheetAt(0);

        int rowStart = Math.min(15, sheet.getFirstRowNum());
        int rowEnd = sheet.getLastRowNum();
        int MY_MINIMUM_COLUMN_COUNT = 0;
        FormulaEvaluator evaluator = workbook.getCreationHelper().createFormulaEvaluator();
        int firstRow = 0;
        for (int rowNum = rowStart; rowNum <= rowEnd; rowNum++) {
            Row r = sheet.getRow(rowNum);
            if (r == null) {
                continue;
            }
            if (firstRow == 0) {
                //first row is the column names
                MY_MINIMUM_COLUMN_COUNT = r.getLastCellNum();
                int lastColumn = Math.max(r.getLastCellNum(), MY_MINIMUM_COLUMN_COUNT);
                for (int cn = 0; cn < lastColumn; cn++) {
                    Cell cell = r.getCell(cn, Row.MissingCellPolicy.CREATE_NULL_AS_BLANK);
                    if(cell != null){
                        String cellVal = getCellValue(cell, evaluator);
                        if (cellVal != null && cellVal.length()>0) {
                            colNamesHM.put(cellVal, cell.getColumnIndex());
                        }
                    }
                }
            } else {
                int lastColumn =MY_MINIMUM_COLUMN_COUNT;
                List<String> curRow = new ArrayList<>();
                for (int cn = 0; cn < lastColumn; cn++) {
                    Cell cell = r.getCell(cn, Row.MissingCellPolicy.CREATE_NULL_AS_BLANK);
                    String cellVal = getCellValue(cell, evaluator);
                    curRow.add(cellVal);
                }
                this.rows.add(curRow);
            }
            firstRow ++;
        }
    }

    public int getRowCount() {
        return rows.size();
    }

    public com.etn.pages.excel.ExcelImportFile.ExcelRow getRow(int index) {
        if (index < rows.size()) {
            return new com.etn.pages.excel.ExcelImportFile.ExcelRow(colNamesHM, rows.get(index));
        }
        else {
            throw new IndexOutOfBoundsException("Row index out of bound : " + index);
        }
    }

    public List<String> getColumnNamesList() {
        return new ArrayList<>(colNamesHM.keySet());
    }

    public LinkedHashMap<String, Integer> getColumnIndexMap() {
        return colNamesHM;
    }

    public List<List<String>> getDataRowsList() {
        return rows;
    }

    protected String getCellValue(Cell cell, FormulaEvaluator evaluator) {
        if(cell == null) return "";
        try{
            switch (evaluator.evaluateInCell(cell).getCellType()) {
                case STRING:
                    return cell.getRichStringCellValue().toString();
                case NUMERIC:
                    if (DateUtil.isCellDateFormatted(cell)) {
                        return dateFormat.format(cell.getDateCellValue());
                    }
                    else {
                        return String.valueOf(cell.getNumericCellValue());
                    }
                case BOOLEAN:
                    return String.valueOf(cell.getBooleanCellValue());
                case BLANK:
                    return "";
                default:
                    return null;
            }
        } catch (Exception ex){
            ex.printStackTrace();
            return "";
        }
    }

    public static class ExcelRow {

        protected final LinkedHashMap<String, Integer> colNamesHM;
        protected final List<String> rowData;

        public ExcelRow(LinkedHashMap<String, Integer> colNamesHM, List<String> rowData) {
            this.colNamesHM = colNamesHM;
            this.rowData = rowData;
        }

        public Optional<String> getColumnValue(String columnName) {
            String retVal = null;
            if (colNamesHM.containsKey(columnName)) {
                int index = colNamesHM.get(columnName);
                if (index < rowData.size()) {
                    retVal = rowData.get(index);
                }
            }
            return Optional.ofNullable(retVal);
        }

        public Optional<String> getColumnValue(int index) {
            String retVal = null;
            if (index < rowData.size()) {
                retVal = rowData.get(index);
            }
            return Optional.ofNullable(retVal);
        }

        public LinkedHashMap<String, String> getColumnValueMap() {
            return getColumnValueMap("");
        }

        public LinkedHashMap<String, String> getColumnValueMap(String columnPrefixFilter) {
            LinkedHashMap<String, String> retMap = new LinkedHashMap<>(colNamesHM.size());
            boolean isFilter = columnPrefixFilter.length() > 0;
            for (String colName : colNamesHM.keySet()) {
                if (!isFilter || colName.startsWith(columnPrefixFilter)) {
                    retMap.put(colName, getColumnValue(colNamesHM.get(colName)).orElse(""));
                }
            }

            return retMap;
        }
    }


    // public static void main(String[] args) throws IOException, InvalidFormatException {
    //     String filePath = "D:\\temp\\import_sample.xlsx";
    //
    //     ExcelImportFile excel = new ExcelImportFile(new File(filePath));
    //     System.out.println(excel.getColumnIndexMap().toString().replaceAll("=\\d,", ","));
    //     System.out.println(excel.getColumnNamesList().toString());
    // }

}
