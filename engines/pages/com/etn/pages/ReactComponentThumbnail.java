package com.etn.pages;

import com.etn.beans.Etn;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;

import java.util.Properties;

/**
 * Generate, publish, un-publish and updates pages that are marked for
 *
 * @author Ali Bin Jamil
 * @since 2019-10-07
 */
public class ReactComponentThumbnail extends BaseClass {

    public ReactComponentThumbnail(Etn Etn, Properties env, boolean debug) {
        super(Etn, env, debug);
    }

    public ReactComponentThumbnail(Etn Etn) {
        super(Etn);
    }

    public void run() {
        try {
            String q = "select id from components where thumbnail_status in ('queued')";
            Set rs = Etn.execute(q);
            if (rs != null) {
                System.out.println("****** Generating thumbnails for " + rs.rs.Rows + " react components");

                while (rs.next()) {

                    String componentId = rs.value("id");
                    try {
                        q = "UPDATE components SET thumbnail_status = 'processing' "
                            + " WHERE id = " + escape.cote(componentId);
                        Etn.executeCmd(q);
                        String cmd = getParm("NODE_PATH") + " "
                                     + getParm("ENGINE_BASE_DIR") + "compiler/capture_image.js " + componentId;
                        Command command = Command.exec(cmd);

                        if (command.exitValue == 0) {
                            q = " UPDATE components SET thumbnail_status = 'published' "
                                + ", thumbnail_file_name = " + escape.cote(componentId + ".png")
                                + ", thumbnail_log = " + escape.cote(command.getOutput())
                                + " WHERE id = " + escape.cote(componentId);
                            Etn.executeCmd(q);
                        }
                        else {
                            q = " UPDATE components SET thumbnail_status = 'error' "
                                + ", thumbnail_log = " + escape.cote(command.getOutput())
                                + " WHERE id = " + escape.cote(componentId);
                            Etn.executeCmd(q);
                        }

                    }
                    catch (Exception ex) {
                        System.out.println("Error in generating thumbnail for component : " + componentId);
                        ex.printStackTrace();
                    }

                }
            }
        }
        catch (Exception ex) {
            ex.printStackTrace();
        }
    }

}