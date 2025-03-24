<%@ page import="java.io.*, java.util.*, java.util.zip.*, java.text.DecimalFormat, java.text.DecimalFormatSymbols,java.io.FileInputStream,com.etn.asimina.util.FileUtil"%>
<%!

    public class NamePath implements Comparable<NamePath> {
        public String name;
        public String path;
        public double size;

        public NamePath(String name, String path, double size){
            this.name = name;
            this.path = path;
            this.size = size;
        }

        @Override
        public int compareTo(NamePath o) {
            return this.name.compareTo(o.name);
        }

    }

    /*
        Read / write file code snippet taken from :
        http://www.javapractices.com/topic/TopicAction.do?Id=42
    */

    String readFile(File aFile) throws Exception{
         //...checks on aFile are elided
        java.lang.StringBuilder contents = new java.lang.StringBuilder();
        try {
          //use buffering, reading one line at a time
          //FileReader always assumes default encoding is OK!
		  
            //we are safe to do new FileInputStream without using FilesUtil class because we are passing File object here
			//the actual place to be careful is where this readFile function is called and we must make sure we get the File object using com.etn.asimina.util.FilesUtil class		  
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
            input.close();
          }
        }
        finally {

        }

        return contents.toString();
    }

   void writeFile(File aFile, String aContents) throws Exception {
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
          output.close();
        }
    }

    void copyFile(File source, File dest) throws IOException {

        if(!dest.exists()) {
          dest.createNewFile();
        }

        InputStream is = null;
        OutputStream os = null;
        try {
            //we are safe to do new FileInputStream/FileOutputStream without using FilesUtil class because we are passing File object here
			//the actual place to be careful is where this copyFile function is called and we must make sure we get the File object using com.etn.asimina.util.FilesUtil class			
            is = new FileInputStream(source);
            os = new FileOutputStream(dest);
            byte[] buffer = new byte[1024];
            int length;
            while ((length = is.read(buffer)) > 0) {
                os.write(buffer, 0, length);
            }
        } finally {
            is.close();
            os.close();
        }
    }

    String getFileSize(File file){

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
     * This utility compresses a list of files to standard ZIP format file.
     * It is able to compress all sub files and sub directories, recursively.
     * @author www.codejava.net
     * src : https://www.codejava.net/java-se/file-io/zip-directories
     * ***
     * Ali Adnan modified to add filtering capability
     */
    public class ZipUtility {


        /**
         * A constants for buffer size used to read/write data
         */
        private static final int BUFFER_SIZE = 4096;

        private HashSet<String> excludeFiles;
        private HashSet<String> excludeDirectories;

        public ZipUtility(){
            excludeFiles = excludeDirectories = new HashSet<String>();
        }

        public ZipUtility(HashSet<String> excludeFiles, HashSet<String> excludeDirectories){
            this.excludeFiles = excludeFiles;
            this.excludeDirectories = excludeDirectories;
        }

        /**
         * Compresses a list of files to a destination zip file
         * @param listFiles A collection of files and directories
         * @param destZipFile The path of the destination zip file
         * @throws FileNotFoundException
         * @throws IOException
         */
        public void zip(List<File> listFiles, File destZipFile ) throws FileNotFoundException, IOException {

            //we are safe to do new FileOutputStream without using FilesUtil class because we are passing File object here
			//the actual place to be careful is where this zip function is called and we must make sure we get the File object using com.etn.asimina.util.FilesUtil class
			ZipOutputStream zos = new ZipOutputStream(new FileOutputStream(destZipFile));
            for (File file : listFiles) {
                String curName = file.getName();
                if (file.isDirectory()) {
                    zipDirectory(file, file.getName(), zos);
                } else{
                    zipFile(file, zos);
                }
            }
            zos.flush();
            zos.close();
        }
        /**
         * Compresses files represented in an array of paths
         * @param files a String array containing file paths
         * @param destZipFile The path of the destination zip file
         * @throws FileNotFoundException
         * @throws IOException
         */
        public void zip(String[] files, String destZipFile) throws FileNotFoundException, IOException {
            List<File> listFiles = new ArrayList<File>();
            for (int i = 0; i < files.length; i++) {
                listFiles.add(new File(files[i]));
            }
            zip(listFiles, new File(destZipFile));
        }
        /**
         * Adds a directory to the current zip output stream
         * @param folder the directory to be  added
         * @param parentFolder the path of parent directory
         * @param zos the current zip output stream
         * @throws FileNotFoundException
         * @throws IOException
         */
        private void zipDirectory(File folder, String parentFolder, ZipOutputStream zos) throws FileNotFoundException, IOException {

            if(this.excludeDirectories.contains(folder.getName())){
                //skip
                return;
            }

            zos.putNextEntry(new ZipEntry(parentFolder + "/"));
            zos.closeEntry();

            for (File file : folder.listFiles()) {
                if (file.isDirectory()) {
                    zipDirectory(file, parentFolder + "/" + file.getName(), zos);
                    continue;
                }
                else if(this.excludeFiles.contains(file.getName())){
                    continue; //skip
                }
                zos.putNextEntry(new ZipEntry(parentFolder + "/" + file.getName()));
				
				//we are safe to do new FileInputStream without using FilesUtil class because we are passing File object here
				//the actual place to be careful is where this zipDirectory function is called and we must make sure we get the File object using com.etn.asimina.util.FilesUtil class							
                BufferedInputStream bis = new BufferedInputStream(new FileInputStream(file));
                long bytesRead = 0;
                byte[] bytesIn = new byte[BUFFER_SIZE];
                int read = 0;
                while ((read = bis.read(bytesIn)) != -1) {
                    zos.write(bytesIn, 0, read);
                    bytesRead += read;
                }
                zos.closeEntry();
            }
        }
        /**
         * Adds a file to the current zip output stream
         * @param file the file to be added
         * @param zos the current zip output stream
         * @throws FileNotFoundException
         * @throws IOException
         */
        private void zipFile(File file, ZipOutputStream zos)
                throws FileNotFoundException, IOException {

            if(this.excludeFiles.contains(file.getName())){
                return; //skip
            }

            zos.putNextEntry(new ZipEntry(file.getName()));
            //we are safe to do new FileInputStream without using FilesUtil class because we are passing File object here
			//the actual place to be careful is where this zipFile function is called and we must make sure we get the File object using com.etn.asimina.util.FilesUtil class						
            BufferedInputStream bis = new BufferedInputStream(new FileInputStream(file));
			
            long bytesRead = 0;
            byte[] bytesIn = new byte[BUFFER_SIZE];
            int read = 0;
            while ((read = bis.read(bytesIn)) != -1) {
                zos.write(bytesIn, 0, read);
                bytesRead += read;
            }
            zos.closeEntry();
        }
    }
%>