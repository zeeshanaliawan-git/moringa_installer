package com.etn.pages;

import com.etn.beans.Etn;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import org.im4java.core.ConvertCmd;
import org.im4java.core.IMOperation;
import org.im4java.core.Info;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.Properties;

/**
 * For processing and generating required resized images
 * e.g. thumbnail, 4x3 images , og/meta (facebook) images
 *
 * @author Ali Adnan
 * @since 2020-10-01
 */
public class ImagesGenerator extends BaseClass {

    public ImagesGenerator(Etn Etn, Properties env, boolean debug) {
        super(Etn, env, debug);
    }

    public ImagesGenerator(Etn Etn) {
        super(Etn);
    }

    public void generateImages() throws Exception {
        generateImages(null);
    }
    public void generateImages(String id) throws Exception {
        generateImages(id,null);
    }

    public void generateImages(String id,String croppedImages) throws Exception {
        getParm("BASE_DIR"); //testing env
        getParm("UPLOADS_FOLDER"); //testing env

        String q;
        Set rs;

        try {
            String UPLOADS_DIR_PATH = getParm("BASE_DIR") + getParm("UPLOADS_FOLDER");
            File uploadsDir = new File(UPLOADS_DIR_PATH);

            if (!uploadsDir.exists() || !uploadsDir.isDirectory()) {
                System.out.println("generateImages => Error: Uploads folder does not exist.");
                return;
            }

            q = "SELECT id, file_name, site_id, images_generated FROM files "
                + " WHERE type = 'img' AND  images_generated <=";

            if(croppedImages==null){
                q += " 0 ";
            }else{
                q += " 1 ";
            }

            if (id != null) {
                q += " AND id = " + escape.cote(id);
            }

            //guestimate limit so it does not take too long. it took around 4 minutes for 300 images
            q += " LIMIT 300 ";

            rs = Etn.execute(q);

            String IMG_DIR_PATH = "";
            String THUMB_DIR_PATH = "";
            String FOUR_THREE_DIR_PATH = "";
            String OG_DIR_PATH = "";

            String FOUR_THREE_CROP_DIR_PATH = "";
            String SIXTEEN_NINE_CROP_DIR_PATH = "";
            String TWO_THREE_CROP_DIR_PATH = "";
            String ONE_ONE_CROP_DIR_PATH = "";
            
            String siteId = "";
            int i = 0;

            while (rs.next())   {
				
				//some tasks take time in pages module so we must set the engine status at such points
				if (env != null) //this means its running from engine 
				{
					Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Pages',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
				}
				
                if (i++ == 0) {

                    siteId = rs.value("site_id");

                    IMG_DIR_PATH = UPLOADS_DIR_PATH + siteId + "/img/";

                    THUMB_DIR_PATH = IMG_DIR_PATH + "/thumb/";
                    File thumbDir = new File(THUMB_DIR_PATH);
                    if (!thumbDir.exists()) {
                        thumbDir.mkdirs();
                    }

                    FOUR_THREE_DIR_PATH = IMG_DIR_PATH + "/4x3/";
                    File fourThreeDir = new File(FOUR_THREE_DIR_PATH);
                    if (!fourThreeDir.exists()) {
                        fourThreeDir.mkdirs();
                    }
                    
                    OG_DIR_PATH = IMG_DIR_PATH + "/og/";
                    File ogDir = new File(OG_DIR_PATH);
                    if (!ogDir.exists()) {
                        ogDir.mkdirs();
                    }
                    
                    FOUR_THREE_CROP_DIR_PATH = IMG_DIR_PATH + "/cropped/4x3/";
                    File fourThreeCropedDir = new File(FOUR_THREE_CROP_DIR_PATH);
                    if (!fourThreeCropedDir.exists()) {
                        fourThreeCropedDir.mkdirs();
                    }

                    SIXTEEN_NINE_CROP_DIR_PATH = IMG_DIR_PATH + "/cropped/16x9/";
                    File sixteenNineCropedDir = new File(SIXTEEN_NINE_CROP_DIR_PATH);
                    if (!sixteenNineCropedDir.exists()) {
                        sixteenNineCropedDir.mkdirs();
                    }

                    TWO_THREE_CROP_DIR_PATH = IMG_DIR_PATH + "/cropped/2x3/";
                    File twoThreeCropedDir = new File(TWO_THREE_CROP_DIR_PATH);
                    if (!twoThreeCropedDir.exists()) {
                        twoThreeCropedDir.mkdirs();
                    }

                    ONE_ONE_CROP_DIR_PATH = IMG_DIR_PATH + "/cropped/1x1/";
                    File oneOneCropedDir = new File(ONE_ONE_CROP_DIR_PATH);
                    if (!oneOneCropedDir.exists()) {
                        oneOneCropedDir.mkdirs();
                    }
                }

                String imageName = rs.value("file_name");
                try {
                    
                    boolean allGenerated = true;
                    
                    String imgGen = "1";
                    if(croppedImages==null){
                        log("Processing For Genrate Images: " + imageName + " count : " + rs.value("images_generated"));
                        allGenerated &= generateThumbnail(imageName, IMG_DIR_PATH, THUMB_DIR_PATH);
                        allGenerated &= generate4x3Image(imageName, IMG_DIR_PATH, FOUR_THREE_DIR_PATH);
                        allGenerated &= generateOGFacebookImage(imageName, IMG_DIR_PATH, OG_DIR_PATH);
                    }else{
                        log("Processing For Cropped Images: " + imageName + " count : " + rs.value("images_generated"));
                        allGenerated &= croppImages(imageName, IMG_DIR_PATH, SIXTEEN_NINE_CROP_DIR_PATH,16.0,9.0);
                        allGenerated &= croppImages(imageName, IMG_DIR_PATH, FOUR_THREE_CROP_DIR_PATH,4.0,3.0);
                        allGenerated &= croppImages(imageName, IMG_DIR_PATH, ONE_ONE_CROP_DIR_PATH,1.0,1.0);
                        allGenerated &= croppImages(imageName, IMG_DIR_PATH, TWO_THREE_CROP_DIR_PATH,2.0,3.0);
                        imgGen = "2";
                    }
                    
                    log((" ==> " + allGenerated));

                    if (allGenerated) {
                        q = "UPDATE files SET images_generated = "+escape.cote(imgGen)+" WHERE id = " + escape.cote(rs.value("id"));
                        Etn.executeCmd(q);
                    }
                }
                catch(FileNotFoundException ex){
                    System.out.println(ex.getMessage());
                    int imageGeneratedCount = PagesUtil.parseInt(rs.value("images_generated"));
                    if(imageGeneratedCount <= -5){
                        //after 3 tries where src file not found, delete the invalid entry from table
                        System.out.println("Removing invalid file entry after 3 tries");
                        q = "DELETE FROM files WHERE id = " + escape.cote(rs.value("id"));
                        Etn.executeCmd(q);
                    }
                    else{
                        imageGeneratedCount--;
                        q = "UPDATE files SET images_generated = " + escape.cote(""+imageGeneratedCount)
                            + " WHERE id = " + escape.cote(rs.value("id"));
                        Etn.executeCmd(q);
                    }
                }
                catch (Exception ex) {
                    System.out.println("Error in generating images for : " + imageName);
                    ex.printStackTrace();

                }
            }

        }
        finally {

        }

    }

    public boolean generateThumbnail(String imageName, String SRC_DIR, String DEST_DIR) throws Exception {
        boolean imageGenerated = false;

        int MAX_THUMB_SIZE = 100; // pixel , max width  or max height depending on orientation

        String THUMB_DIR = DEST_DIR;
        File thumbDir = new File(THUMB_DIR);
        if (!thumbDir.exists()) {
            throw new Exception("Thumbnail Destination Directory does not exist.");
        }
        File srcFile = new File(SRC_DIR + imageName);
        File destFile = new File(THUMB_DIR + imageName);

        if (!srcFile.exists()) {
            throw new FileNotFoundException("Src image file does not exist: " + SRC_DIR + imageName);
        }

        try {
            //if any error/exception occurs in reading or processing the image
            //  then we copy the src file to destination

            //using im4java library
            // which is java process wrapper for calling image magick commands
            Info imgInfo = new Info(srcFile.getAbsolutePath(), true);
            int imgWidth = imgInfo.getImageWidth();
            int imgHeight = imgInfo.getImageHeight();

            //System.out.println("img : " + imgWidth + " x " + imgHeight);
            if (imgWidth <= MAX_THUMB_SIZE && imgHeight <= MAX_THUMB_SIZE) {
                //image already too small
                //just copy the original image file to thumbnail location
                FilesUtil.copyFile(srcFile, destFile);
            }
            else {

                // create command
                ConvertCmd cmd = new ConvertCmd();
                String imPath = PagesUtil.parseNull(getParm("IMAGE_MAGIC_PATH"));
                if (imPath.trim().length() > 0) {
                    cmd.setSearchPath(imPath);
                }

                // create the operation, add images and operators/options
                IMOperation op = new IMOperation();
                op.addImage(srcFile.getAbsolutePath());

                //it will resize image within 100x100 max keeping original aspect ration
                op.resize(100, 100);

                op.addImage(destFile.getAbsolutePath());
                cmd.run(op); // execute the operation

            }

            imageGenerated = true;
        }
        catch (Exception ex) {
            System.out.println("Error in generating thumbnail for: " + imageName);
            ex.printStackTrace();
            FilesUtil.copyFile(srcFile, destFile);
            imageGenerated = true;
        }

        return imageGenerated;
    }

    public boolean generate4x3Image(String imageName, String SRC_DIR, String DEST_DIR) throws Exception {
        boolean imageGenerated = false;

        if (!new File(DEST_DIR).exists()) {
            throw new Exception("4x3 destination directory does not exist.");
        }
        File srcFile = new File(SRC_DIR + imageName);
        File destFile = new File(DEST_DIR + imageName);

        if (!srcFile.exists()) {
            throw new FileNotFoundException("Src image file does not exist: " + SRC_DIR + imageName);
        }

        try {
            //if any error/exception occurs in reading or processing the image
            //  then we copy the src file to destination

            //using im4java library
            // which is java process wrapper for calling image magick commands
            Info imgInfo = new Info(srcFile.getAbsolutePath(), true);
            int w = imgInfo.getImageWidth();
            int h = imgInfo.getImageHeight();

            int aspectRationWidth = 4;
            int aspectRatioHeight = 3;

            int newWidth = 0, newHeight = 0;

            if (w >= h) {
                //landscape
                newWidth = w;
                newHeight = (int) (((double) w / aspectRationWidth) * aspectRatioHeight);
            }
            else if (h > w) {
                //portrait , ration output ratio 3:4
                newHeight = h;
                newWidth = (int) (((double) h / aspectRationWidth) * aspectRatioHeight);

            }

            // create command
            ConvertCmd cmd = new ConvertCmd();
            String imPath = PagesUtil.parseNull(getParm("IMAGE_MAGIC_PATH"));
            if (imPath.trim().length() > 0) {
                cmd.setSearchPath(imPath);
            }

            // create the operation, add images and operators/options
            IMOperation op = new IMOperation();
            op.addImage(srcFile.getAbsolutePath());

            //magick input.jpg -resize 800x600 -background black -compose Copy \
            //  -gravity center -extent 800x600 -quality 92 output.jpg
            //it will resize image within 100x100 max keeping original aspect ration
            op.resize(newWidth, newHeight);
            op.background("white");
            op.compose("Copy");
            op.gravity("center");
            op.extent(newWidth, newHeight);
            op.quality(92.0);

            op.addImage(destFile.getAbsolutePath());
            cmd.run(op); // execute the operation
            imageGenerated = true;
        }
        catch (Exception ex) {
            System.out.println("Error in generating 4x3 image for: " + imageName);
            ex.printStackTrace();
            FilesUtil.copyFile(srcFile, destFile);
            imageGenerated = true;
        }

        return imageGenerated;
    }

    public boolean generateOGFacebookImage(String imageName, String SRC_DIR, String DEST_DIR) throws Exception {
        boolean imageGenerated = false;

        if (!new File(DEST_DIR).exists()) {
            throw new Exception("OG(facebook) destination directory does not exist.");
        }
        File srcFile = new File(SRC_DIR + imageName);
        File destFile = new File(DEST_DIR + imageName);

        if (!srcFile.exists()) {
            throw new Exception("Src image file does not exist: " + SRC_DIR + imageName);
        }

        try {
            //if any error/exception occurs in reading or processing the image
            //  then we copy the src file to destination

            //using im4java library
            // which is java process wrapper for calling image magick commands
            Info imgInfo = new Info(srcFile.getAbsolutePath(), true);
            int w = imgInfo.getImageWidth();
            int h = imgInfo.getImageHeight();

            int bestWidth = 1200;
            int bestHeight = 630;

            int minWidth = 600;
            int minHeight = 315;

            int newWidth = 0, newHeight = 0;

            if (w >= h) {
                //landscape

                if (w >= bestWidth) {
                    //apply best width and height
                    newWidth = bestWidth;
                    newHeight = bestHeight;
                }
                else {
                    //apply min width and height
                    newWidth = minWidth;
                    newHeight = minHeight;
                }
            }
            else if (h > w) {
                //portrait
                if (h >= bestHeight) {
                    //apply best width and height
                    newWidth = bestWidth;
                    newHeight = bestHeight;
                }
                else {
                    //apply min width and height
                    newWidth = minWidth;
                    newHeight = minHeight;
                }
            }

            // create command
            ConvertCmd cmd = new ConvertCmd();
            String imPath = PagesUtil.parseNull(getParm("IMAGE_MAGIC_PATH"));
            if (imPath.trim().length() > 0) {
                cmd.setSearchPath(imPath);
            }

            // create the operation, add images and operators/options
            IMOperation op = new IMOperation();
            op.addImage(srcFile.getAbsolutePath());

            //magick input.jpg -resize 800x600 -background black -compose Copy \
            //  -gravity center -extent 800x600 -quality 92 output.jpg
            //it will resize image within 100x100 max keeping original aspect ration
            op.resize(newWidth, newHeight);
            op.background("white");
            op.compose("Copy");
            op.gravity("center");
            op.extent(newWidth, newHeight);
            op.quality(92.0);

            op.addImage(destFile.getAbsolutePath());
            cmd.run(op); // execute the operation
            imageGenerated = true;
        }
        catch (Exception ex) {
            System.out.println("Error in generating OG(facebook) image for: " + imageName);
            ex.printStackTrace();
            FilesUtil.copyFile(srcFile, destFile);
            imageGenerated = true;
        }

        return imageGenerated;
    }

    public boolean croppImages(String imageName, String SRC_DIR, String DEST_DIR,double aspectRationWidth,double aspectRatioHeight) throws Exception {
        boolean imageGenerated = false;

        if (!new File(DEST_DIR).exists()) {
            throw new Exception(aspectRationWidth+"x"+aspectRatioHeight+" destination directory does not exist.");
        }

        File srcFile = new File(SRC_DIR + imageName);
        File destFile = new File(DEST_DIR + imageName);

        if (!srcFile.exists()) {
            throw new FileNotFoundException("Src image file does not exist: " + SRC_DIR + imageName);
        }

        try {

            Info imgInfo = new Info(srcFile.getAbsolutePath(), true);
            int w = imgInfo.getImageWidth();
            int h = imgInfo.getImageHeight();

            int newWidth = 0, newHeight = 0;
            double targeAspectRatio = aspectRationWidth/aspectRatioHeight;

            newWidth = w;
            newHeight = (int)(newWidth/targeAspectRatio);
            if(newHeight>h){
                newWidth = (int)(h*targeAspectRatio);
                newHeight = h;
            }

            ConvertCmd cmd = new ConvertCmd();
            String imPath = PagesUtil.parseNull(getParm("IMAGE_MAGIC_PATH"));
            if (imPath.trim().length() > 0) {
                cmd.setSearchPath(imPath);
            }

            IMOperation op = new IMOperation();
            op.addImage(srcFile.getAbsolutePath());

            op.gravity("center");
            op.crop(newWidth, newHeight,0,0);
            op.addImage(destFile.getAbsolutePath());
            cmd.run(op);
            imageGenerated = true;
            System.out.println("======Done cropping========");
        }
        catch (Exception ex) {
            System.out.println("Error in generating "+aspectRationWidth+"x"+aspectRatioHeight+" image for: " + imageName);
            ex.printStackTrace();
            FilesUtil.copyFile(srcFile, destFile);
            imageGenerated = true;
        }

        return imageGenerated;
    }

}
