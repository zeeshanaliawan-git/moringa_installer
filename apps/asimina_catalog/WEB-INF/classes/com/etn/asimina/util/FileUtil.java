package com.etn.asimina.util;

import java.io.*;
import java.util.Objects;
import com.etn.util.Logger;
import org.apache.tika.mime.MimeTypes;
import org.apache.tika.*;

public class FileUtil {

    public static File getFile(String directory, String name) {
		if(UIHelper.parseNull(directory).length() == 0) {
			Logger.error("FileUtil.java", "directory is empty");
			return null;
		}
		if(UIHelper.parseNull(name).length() == 0) {
			Logger.error("FileUtil.java", "name is empty");
			return null;
		}

		try {
			String cleanedFileName = name.replace("../", "").replace("/", "");
			return new File(sanitizePath(directory +  cleanedFileName));
		} catch (Exception e) {
			e.printStackTrace();
			Logger.error("FileUtil.java", "Error in getFile :"+e.getMessage());
			return null;
		}
    }

    public static File getFile(String path)  {
		if(UIHelper.parseNull(path).length() == 0) {
			Logger.error("FileUtil.java", "file path is empty");
			return null;
		}

		try {
			return new File(sanitizePath(path));
		} catch (Exception e) {
			e.printStackTrace();
			Logger.error("FileUtil.java", "Error in getFile :"+e.getMessage());
			return null;
		}
	}
    
	public static String getFileExtension(String fileName) {
		if (fileName == null || fileName.lastIndexOf(".") == -1 || fileName.lastIndexOf(".") == fileName.length() - 1) {
			return "";
		}
		return fileName.substring(fileName.lastIndexOf("."));
	}

	public static String getMimeTypeExtension(String fileName)  {
		if(UIHelper.parseNull(fileName).length() == 0) {
			Logger.error("FileUtil.java", "file path is empty");
			return null;
		}

		Tika tika = new Tika();
		File file = FileUtil.getFile(fileName);
		try {
			String mimeType = tika.detect(file);
			MimeTypes allTypes = MimeTypes.getDefaultMimeTypes();
			return allTypes.forName(mimeType).getExtension();
		} catch (Exception e) {
			e.printStackTrace();
			Logger.error("FileUtil.java", "Error in getFileExtension :"+e.getMessage());
			return null;
		}
    }

    public static String getFileMimeType(String fileName)  {
		if(UIHelper.parseNull(fileName).length() == 0) {
			Logger.error("FileUtil.java", "file path is empty");
			return null;
		}

		Tika tika = new Tika();
		File file = FileUtil.getFile(fileName);
		try {
			String mimeType = tika.detect(file);
			return mimeType;
		} catch (Exception e) {
			e.printStackTrace();
			Logger.error("FileUtil.java", "Error in getFileMimeType :"+e.getMessage());
			return null;
		}
    }

    public static File mkDir(String directory)  {
		if(UIHelper.parseNull(directory).length() == 0) {
			Logger.error("FileUtil.java", "directory parameter is empty");
			return null;
		}

		try {                
			File dir = FileUtil.getFile(directory);
			if (dir.exists()) {
				return dir;
			} else {
				dir.mkdir();
				return dir;
			}
		} catch (Exception e) {
			e.printStackTrace();
			Logger.error("FileUtil.java", "Error in mkDir :"+e.getMessage());
			return null;
		}
    }

    public static File mkDir(File dir)  {
		if(dir == null) {
			Logger.error("FileUtil.java", "dir is null");
			return null;
		}

		try {
			if (dir.exists()) {
				return dir;
			} else {
				dir.mkdir();
				return dir;
			}
		} catch (Exception e) {
			e.printStackTrace();
			Logger.error("FileUtil.java", "Error in mkDir :"+e.getMessage());
			return null;
		}
    }

    public static File mkDirs(String directory)  {
		if(UIHelper.parseNull(directory).length() == 0) {
			Logger.error("FileUtil.java", "directory parameter is empty");
			return null;
		}
		
		try {
			File dir = FileUtil.getFile(directory);
			if (dir.exists()) {
				return dir;
			} else {
				dir.mkdirs();
				return dir;
			}
		} catch (Exception e) {
			e.printStackTrace();
			Logger.error("FileUtil.java", "Error in mkDirs :"+e.getMessage());
			return null;
		}
    }

    public static File mkDirs(File dir)  {
		if(dir == null) {
			Logger.error("FileUtil.java", "dir is null");
			return null;
		}

		try {
			if (dir.exists()) {
				return dir;
			} else {
				dir.mkdirs();
				return dir;
			}
		} catch (Exception e) {
			e.printStackTrace();
			Logger.error("FileUtil.java", "Error in mkDirs :"+e.getMessage());
			return null;
		}
    }

    public static FileInputStream getFileInputStream(String filepath)  {
		if(UIHelper.parseNull(filepath).length() == 0) {
			Logger.error("FileUtil.java", "filepath is empty");
			return null;
		}
		
		try {
			File inputFile = FileUtil.getFile(filepath);
			return new FileInputStream(inputFile);
		} catch (Exception e) {
			e.printStackTrace();
			Logger.error("FileUtil.java", "Error in getFileInputStream :"+e.getMessage());
			return null;
		}
	}

    public static FileOutputStream getFileOutputStream(String filepath) {
		if(UIHelper.parseNull(filepath).length() == 0) {
			Logger.error("FileUtil.java", "filepath is empty");
			return null;
		}
		
		try {
			File outputFile = FileUtil.getFile(filepath);
			return  new FileOutputStream(outputFile);
		} catch (Exception e) {
			e.printStackTrace();
			Logger.error("FileUtil.java", "Error in getFileOutputStream :"+e.getMessage());
			return null;
		}
    }

	public static String sanitizePath(String path) {
		return UIHelper.parseNull(path).replaceAll("\\.\\.(/|\\\\)", "").replaceAll("\\\\", "");
    }
}