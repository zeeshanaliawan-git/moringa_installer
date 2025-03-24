<%@ page import="java.awt.image.BufferedImage"%>
<%@ page import="javax.imageio.ImageIO, java.io.*"%>


<%!
boolean createForFacebook(String frompath, String fromfile, String topath, String tofile)
{	
	try
	{
		File f = new File(topath);
		if(!f.exists()) f.mkdir();
                
		BufferedImage source = ImageIO.read(new File(frompath+fromfile));
		int w = (int) (source.getWidth());
		int h = (int) (source.getHeight());
		String[] cmdArray = null;	

		int bestWidth = 1200;
		int standardWidth = 600;
		int bestHeight = 630;
		int standardHeight = 315;
		String finalsize = "";
		//creating medium thumbnail			
		if(w >= h) 
		{			
			if(w >= bestWidth)
			{
				finalsize = bestWidth+"x"+bestHeight;

				cmdArray = new String[5];
				cmdArray[0] = "convert";
				cmdArray[1] = "-resize";
				cmdArray[2] = finalsize;
				cmdArray[3] = frompath + fromfile;
				cmdArray[4] = topath + tofile;

				//command = "convert -resize "+finalsize + " " + frompath + fromfile + " " + topath + tofile + "";		
			}
			else if(w >= standardWidth)
			{
				finalsize = standardWidth+"x"+standardHeight;

				cmdArray = new String[5];
				cmdArray[0] = "convert";
				cmdArray[1] = "-resize";
				cmdArray[2] = finalsize;
				cmdArray[3] = frompath + fromfile;
				cmdArray[4] = topath + tofile;

				//command = "convert -resize "+finalsize + " " + frompath + fromfile + " " + topath + tofile + "";		
			}
			else 
			{
				finalsize = standardWidth+"x"+standardHeight;
			}

		}
		else if(h > w)
		{
			if(h >= bestHeight)
			{
				finalsize = standardWidth+"x"+standardHeight;

				cmdArray = new String[5];
				cmdArray[0] = "convert";
				cmdArray[1] = "-resize";
				cmdArray[2] = finalsize;
				cmdArray[3] = frompath + fromfile;
				cmdArray[4] = topath + tofile;

//				command = "convert -resize "+finalsize + " " + frompath + fromfile + " " + topath + tofile + "";		
			}
			else if(h >= standardHeight)
			{
				finalsize = standardWidth+"x"+standardHeight;

				cmdArray = new String[5];
				cmdArray[0] = "convert";
				cmdArray[1] = "-resize";
				cmdArray[2] = finalsize;
				cmdArray[3] = frompath + fromfile;
				cmdArray[4] = topath + tofile;

//				command = "convert -resize "+finalsize + " " + frompath + fromfile + " " + topath + tofile  + "";		
			}
			else
			{
				//this command will not resize but will copy from source to target directory
				finalsize = standardWidth+"x"+standardHeight;
			}
		}

		if(cmdArray != null && cmdArray.length > 0)
		{
	             	Process process = Runtime.getRuntime().exec(cmdArray, null);
			int retVal = 0;
			retVal = process.waitFor();
			if (retVal != 0) {
				System.out.println(retVal);
			}
			frompath = topath;
			fromfile = tofile;
		}

		cmdArray = new String[9];
		cmdArray[0] = "convert";
		cmdArray[1] = "-size";
		cmdArray[2] = finalsize ;
		cmdArray[3] = "xc:White";
		cmdArray[4] = frompath + fromfile;
		cmdArray[5] = "-gravity";
		cmdArray[6] = "center";
		cmdArray[7] = "-composite";
		cmdArray[8] = topath + tofile;

//		command = " convert -size "+finalsize + " xc:White " + frompath + fromfile + " -gravity center -composite " + topath + tofile + "";

		Process process = Runtime.getRuntime().exec(cmdArray, null);
		int retVal = 0;
		retVal = process.waitFor();

		if (retVal != 0) {
			com.etn.util.Logger.error("include/imager.jsp", "fail to create shar bar image");
		}

		return true;
	}
	catch(Exception e)
	{
		e.printStackTrace();
		return false;
	}
}

String getOgImageName(String fromimgname)
{
	String toimgname = "";
	if(fromimgname.indexOf(".") > -1)
	{
		String ext = fromimgname.substring(fromimgname.lastIndexOf("."));
		String fname = fromimgname.substring(0, fromimgname.lastIndexOf("."));
		toimgname = fname + "_og" + ext;
	}
	else toimgname = fromimgname + "_og";

	return toimgname;
}

String getRawImageName(String fromimgname)
{
	String toimgname = "";
	if(fromimgname.indexOf(".") > -1)
	{
		String ext = fromimgname.substring(fromimgname.lastIndexOf("."));
		String fname = fromimgname.substring(0, fromimgname.lastIndexOf("."));
		toimgname = fname + "_raw" + ext;
	}
	else toimgname = fromimgname + "_raw";

	return toimgname;
}

boolean createForProductsRawImage(String frompath, String fromfile, String topath, String tofile)
{
	try
	{
		String[] cmdArray = new String[3]; 
		cmdArray[0] = "cp";
		cmdArray[1] = frompath + fromfile;
		cmdArray[2] = topath + tofile;

//		String command = "cp '" + frompath + fromfile + "' '" + topath + tofile + "' ";	
//		com.etn.util.Logger.debug("include/imager.jsp", command);

             	Process process = Runtime.getRuntime().exec(cmdArray, null);
		int retVal = 0;
		retVal = process.waitFor();
		if (retVal != 0) {
			com.etn.util.Logger.error("include/imager.jsp", "fail to create raw image");
			return false;
		}
	}
	catch(Exception e)
	{
		e.printStackTrace();
		return false;
	}
	return true;
}
boolean createForProducts(String frompath, String fromfile, String topath, String tofile)
{	
	try
	{
		String[] cmdArray = null;	

		File f = new File(topath);
		if(!f.exists()) f.mkdir();

		BufferedImage source = ImageIO.read(new File(frompath+fromfile));
		int w = (int) (source.getWidth());
		int h = (int) (source.getHeight());
//		String command = "";	

		int aspectratiowidth = 4;
		int aspectratioheight = 3;

		String finalsize = "";
		//creating medium thumbnail			
		if(w >= h) 
		{				
			int origw = w;
			int origh = h;
			System.out.println("============== orig " + origw + " " + origh );

			int newh = (int)(((double)w/aspectratiowidth)*aspectratioheight);

			int neww = (int)(((double)origw/(double)origh)*newh);

			cmdArray = new String[5];
			cmdArray[0] = "convert";
			cmdArray[1] = "-resize";
			cmdArray[2] = neww+"x"+newh;
			cmdArray[3] = frompath + fromfile;
			cmdArray[4] = topath + tofile;

//			command = "convert -resize "+neww+"x"+newh+" " + frompath + fromfile + " " + topath + tofile + "";		

			int finalw = 0;
			if(origw >= neww) finalw = origw;
			else finalw = neww;
			int finalh = (finalw/aspectratiowidth)*aspectratioheight;
			finalsize = finalw+"x"+finalh;
		}
		else if(h > w)
		{
			int origw = w;
			int origh = h;

			int neww = (int)(((double)h/aspectratiowidth)*aspectratioheight);

			int newh = (int)(((double)origh/(double)origw)*neww);

			cmdArray = new String[5];
			cmdArray[0] = "convert";
			cmdArray[1] = "-resize";
			cmdArray[2] = neww+"x"+newh;
			cmdArray[3] = frompath + fromfile;
			cmdArray[4] = topath + tofile;

//			command = "convert -resize "+neww+"x"+newh+" " + frompath + fromfile + " " + topath + tofile +"";		

			int finalh = 0;
			if(origh >= newh) finalh = origh;
			else finalh = newh;
			int finalw = (finalh/aspectratiowidth)*aspectratioheight;
			finalsize = finalw+"x"+finalh;
		}

		if(cmdArray != null && cmdArray.length > 0)
		{
	             	Process process = Runtime.getRuntime().exec(cmdArray, null);
			int retVal = 0;
			retVal = process.waitFor();
			if (retVal != 0) {
				com.etn.util.Logger.error("include/imager.jsp", "fail to create listing image");
			}
			frompath = topath;
			fromfile = tofile;
		}

		cmdArray = new String[9];
		cmdArray[0] = "convert";
		cmdArray[1] = "-size";
		cmdArray[2] = finalsize ;
		cmdArray[3] = "xc:White";
		cmdArray[4] = frompath + fromfile;
		cmdArray[5] = "-gravity";
		cmdArray[6] = "west";
		cmdArray[7] = "-composite";
		cmdArray[8] = topath + tofile;

//		command = " convert -size "+finalsize + " xc:White " + frompath + fromfile + " -gravity west -composite " + topath + tofile + "";
		Process process = Runtime.getRuntime().exec(cmdArray, null);
		int retVal = 0;
		retVal = process.waitFor();

		if (retVal != 0) {
			com.etn.util.Logger.error("include/imager.jsp", "fail to create listing image");
			return false;
		}
	}
	catch(Exception e)
	{
		e.printStackTrace();
		return false;
	}
	return true;
}

String getGridImageName(String fromimgname)
{
	String toimgname = "";
	if(fromimgname.indexOf(".") > -1)
	{
		String ext = fromimgname.substring(fromimgname.lastIndexOf("."));
		String fname = fromimgname.substring(0, fromimgname.lastIndexOf("."));
		toimgname = fname + "_grid" + ext;
	}
	else toimgname = fromimgname + "_grid";

	return toimgname;
}

boolean createForProductsGridView(String frompath, String fromfile, String topath, String tofile)
{	
	try
	{
		String[] cmdArray = null;

		File f = new File(topath);
		if(!f.exists()) f.mkdir();

		BufferedImage source = ImageIO.read(new File(frompath+fromfile));
		int w = (int) (source.getWidth());
		int h = (int) (source.getHeight());
//		String command = "";	

		int aspectratiowidth = 1;
		int aspectratioheight = 2;

		String finalsize = "";
		//creating medium thumbnail			
		if(w >= h) 
		{				
			int origw = w;
			int origh = h;

			int neww = origw;
			int newh = (int)(((double)neww*aspectratioheight)/aspectratiowidth );

			cmdArray = new String[5];
			cmdArray[0] = "convert";
			cmdArray[1] = "-resize";
			cmdArray[2] = neww+"x"+newh ;
			cmdArray[3] = frompath + fromfile;
			cmdArray[4] = topath + tofile;

//			command = "convert -resize "+neww+"x"+newh+" " + frompath + fromfile + " " + topath + tofile + "";		
			int finalw = neww;
			int finalh = newh ;
			finalsize = finalw+"x"+finalh;
		}
		else if(h > w)
		{
			int origw = w;
			int origh = h;

			int newh = origh;
			int neww = (int)(((double)newh*aspectratiowidth)/aspectratioheight);

			cmdArray = new String[5];
			cmdArray[0] = "convert";
			cmdArray[1] = "-resize";
			cmdArray[2] = neww+"x"+newh ;
			cmdArray[3] = frompath + fromfile;
			cmdArray[4] = topath + tofile;

//			command = "convert -resize "+neww+"x"+newh+" " + frompath + fromfile + " " + topath + tofile +"";		
			int finalh = newh;
			int finalw = neww;
			finalsize = finalw+"x"+finalh;
		}

		if(cmdArray != null && cmdArray.length > 0)
		{
//System.out.println(Arrays.toString(cmdArray));
	             	Process process = Runtime.getRuntime().exec(cmdArray, null);
			int retVal = 0;
			retVal = process.waitFor();
			if (retVal != 0) {
				com.etn.util.Logger.error("include/imager.jsp", "fail to create grid image");
			}
			frompath = topath;
			fromfile = tofile;
		}

		cmdArray = new String[9];
		cmdArray[0] = "convert";
		cmdArray[1] = "-size";
		cmdArray[2] = finalsize ;
		cmdArray[3] = "xc:White";
		cmdArray[4] = frompath + fromfile;
		cmdArray[5] = "-gravity";
		cmdArray[6] = "north";
		cmdArray[7] = "-composite";
		cmdArray[8] = topath + tofile;
//System.out.println(Arrays.toString(cmdArray));

//		command = " convert -size "+finalsize + " xc:White " + frompath + fromfile + " -gravity north -composite " + topath + tofile + "";
		Process process = Runtime.getRuntime().exec(cmdArray, null);
		int retVal = 0;
		retVal = process.waitFor();

		if (retVal != 0) {
			com.etn.util.Logger.error("include/imager.jsp", "fail to create grid image");
			return false;
		}

	}
	catch(Exception e)
	{
		e.printStackTrace();
		return false;
	}
	return true;
}

boolean saveAllImages(String imagePath,String fileName){    
    String rawimagename = getRawImageName(fileName);
    String gridimagename = getGridImageName(fileName);
    String ogimagename = getOgImageName(fileName);
    //this will create a raw image copy before any image manipulation && we are creating 4x3 or 3x4 aspect ratio image after the image is created for facebook otherwise facebook image becomes smaller && we are creating 2x1 or 1x2 aspect ratio image 
    return createForProductsRawImage(imagePath, fileName, imagePath, rawimagename) 
        && createForProducts(imagePath, rawimagename, imagePath, fileName)
        && createForProductsGridView(imagePath, rawimagename, imagePath, gridimagename)
        && createForFacebook(imagePath, rawimagename, imagePath, ogimagename);
}

%>
