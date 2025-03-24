<%@ page import="java.util.regex.Pattern, java.util.regex.Matcher, java.io.FileOutputStream, javax.xml.bind.DatatypeConverter, java.nio.file.Files, java.nio.file.Paths, java.nio.file.Path, java.nio.file.Files  "%>


<%!

    public void saveBase64(String base64Image, String dir, String fileName){
        try{
		int pos = base64Image.indexOf(";base64,");
		if(pos > -1) base64Image = base64Image.substring(pos + 8);
		//System.out.println(base64Image );
              byte [] content = DatatypeConverter.parseBase64Binary(base64Image);
              Path path = Paths.get(dir + fileName);
              Files.write(path , content);
        }catch(Exception ex){
            ex.printStackTrace();
        }
    }

    private String getExtension(String fileName){
        String extension = "";
        int i = fileName.lastIndexOf('.');
        if (i > 0) {
            extension = fileName.substring(i+1);
        }
        return extension;
    }

    private String getContentType(String fileName){
	String ext = getExtension(fileName);
	if("svg".equalsIgnoreCase(ext)) return "image/svg+xml";
       return "image/" + getExtension(fileName);
    }

    public String getBase64Image(String dir, String fileName){
        try{
                Path path = Paths.get(dir + fileName);
                if(Files.exists(path) && Files.isRegularFile(path)){
                    byte[] fileContent = Files.readAllBytes(path);
                    String content = DatatypeConverter.printBase64Binary(fileContent);
                    return "data:" + getContentType(fileName) + ";base64," + content;
                }else{
                    return "";
                }
        }catch(Exception ex){
            ex.printStackTrace();
            return "";
        }
    }

%>