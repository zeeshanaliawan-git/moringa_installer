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
public class ReactPageHtml extends BaseClass {

    public ReactPageHtml(Etn Etn, Properties env, boolean debug) {
        super(Etn, env, debug);
    }

    public ReactPageHtml(Etn Etn) {
        super(Etn);
    }

    public void run() {
        try {
            String q = "select id from pages where get_html_status in ('queued')";
            Set rs = Etn.execute(q);
            if (rs != null) {
                System.out.println("****** Generating html for " + rs.rs.Rows + " react pages");

                while (rs.next()) {

                    String pageId = rs.value("id");
                    try {
                        q = "UPDATE pages SET get_html_status = 'processing' "
                            + " WHERE id = " + escape.cote(pageId);
                        Etn.executeCmd(q);
                        String cmd = getParm("NODE_PATH") + " "
                                     + getParm("ENGINE_BASE_DIR") + "compiler/get_page_html.js " + pageId;
                        Command command = Command.exec(cmd);

                        if (command.exitValue == 0) {
                            q = " UPDATE pages SET get_html_status = 'published' "
                                + ", get_html_log = " + escape.cote(command.getOutput())
                                + " WHERE id = " + escape.cote(pageId);
                            Etn.executeCmd(q);
                        }
                        else {
                            q = " UPDATE pages SET get_html_status = 'error' "
                                + ", get_html_log = " + escape.cote(command.getOutput())
                                + " WHERE id = " + escape.cote(pageId);
                            Etn.executeCmd(q);
                        }

                    }
                    catch (Exception ex) {
                        System.out.println("Error in generating html for page : " + pageId);
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