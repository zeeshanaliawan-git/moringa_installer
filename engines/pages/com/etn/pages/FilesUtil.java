package com.etn.pages;

import java.io.*;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;

/**
 * @author Ali Adnan
 */
public class FilesUtil {

    /*
     Read / write file code snippet taken from :
     http://www.javapractices.com/topic/TopicAction.do?Id=42
     */
    public static String readFile(File aFile) throws Exception {
        //...checks on aFile are elided
        java.lang.StringBuilder contents = new java.lang.StringBuilder();
        try {
            //use buffering, reading one line at a time
            //FileReader always assumes default encoding is OK!
            BufferedReader input = new BufferedReader(new InputStreamReader(new FileInputStream(aFile), "UTF8"));
            try {
                String line = null; //not declared within while loop
                /*
                 * readLine is a bit quirky :
                 * it returns the content of a line MINUS the newline.
                 * it returns null only for the END of the stream.
                 * it returns an empty String if two newlines appear in a row.
                 */
                while ((line = input.readLine()) != null) {
                    contents.append(line);
                    contents.append(System.getProperty("line.separator"));
                }
            }
            finally {
                if(input != null) input.close();
            }
        }
        finally {

        }

        return contents.toString();
    }

    public static void writeFile(File aFile, String aContents) throws Exception {
        if (aFile == null) {
            throw new IllegalArgumentException("File should not be null.");
        }
        if (!aFile.exists()) {
            throw new FileNotFoundException("File does not exist: " + aFile);
        }
        if (!aFile.isFile()) {
            throw new IllegalArgumentException("Should not be a directory: " + aFile);
        }
        if (!aFile.canWrite()) {
            throw new IllegalArgumentException("File cannot be written: " + aFile);
        }

        //use buffering
        Writer output = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(aFile), "UTF8"));
        try {
            //FileWriter always assumes default encoding is OK!
            output.write(aContents);
        }
        finally {
            if(output != null) output.close();
        }
    }

    public static void copyFile(File source, File dest) throws IOException {

        if (!dest.exists()) {
            dest.createNewFile();
        }

        InputStream is = null;
        OutputStream os = null;
        try {
            is = new FileInputStream(source);
            os = new FileOutputStream(dest);
            byte[] buffer = new byte[1024];
            int length;
            while ((length = is.read(buffer)) > 0) {
                os.write(buffer, 0, length);
            }
        }
        finally {
            if(is != null) is.close();
            if(os != null) os.close();
        }
    }

    public static String getFileSize(File file) {

        String sizeInKB = "0.00";
        if (file.exists() && file.isFile()) {
            DecimalFormatSymbols symbols = new DecimalFormatSymbols();
            symbols.setDecimalSeparator('.');
            DecimalFormat nf = new DecimalFormat("#.00", symbols);
            long sizeInBytes = file.length();
            sizeInKB = nf.format((double) sizeInBytes / (double) 1024.0);
        }
        return sizeInKB;
    }

    /**
     * To delete a directory/ folder along with all its contents
     * simply calling directory.delete() does not delete directory if it has any content
     * we have to first delete all its contents recursively
     *
     * @param directoryToBeDeleted
     */
    public static boolean deleteDirectory(File directoryToBeDeleted) {
        File[] allContents = directoryToBeDeleted.listFiles();
        if (allContents != null) {
            for (File file : allContents) {
                deleteDirectory(file);
            }
        }
        return directoryToBeDeleted.delete();
    }
}
