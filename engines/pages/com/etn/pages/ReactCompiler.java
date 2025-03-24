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
public class ReactCompiler extends BaseClass {

    public ReactCompiler(com.etn.beans.Etn Etn, Properties env, boolean debug) {
        super(Etn, env, debug);
    }

    public ReactCompiler(Etn Etn) {
        super(Etn);
    }

    public void run() {
        try {
            String q = "SELECT id, site_id, langue_code, variant, path,package_name "
                       + " FROM pages"
                       + " WHERE type = " + escape.cote(Scheduler.PAGE_TYPE_REACT)
                       + " AND to_publish = 1 AND to_publish_ts <= NOW()";

            Set rs = Etn.execute(q);
            if (rs != null && rs.rs.Rows > 0) {
                System.out.println("****** Generating " + rs.rs.Rows + " react pages");

                while (rs.next()) {

                    String pageId = rs.value("id");
                    try {
                        q = "UPDATE pages SET publish_status = 'processing' "
                            + " WHERE id = " + escape.cote(pageId);
                        Etn.executeCmd(q);
                        String cmd = getParm("NODE_PATH") + " "
                                     + getParm("ENGINE_BASE_DIR") + "compiler/compiler.js " + pageId;
                        Command command = Command.exec(cmd);
                        String publishStatus = "unpublished";
                        if (command.exitValue == 0) {

                            String siteId = rs.value("site_id");
                            String langueCode = rs.value("langue_code");
                            String variant = rs.value("variant");
                            String path = rs.value("path");

                            String pageHtmlPath = PagesUtil.getDynamicPagePath(siteId, langueCode, variant, path) + "index.html";

                            q = " UPDATE pages SET published_ts = NOW() "
                                + ", published_by = to_publish_by "
                                + ", published_html_file_path = " + escape.cote(pageHtmlPath)
                                + ", to_publish = 0 , to_publish_ts = NULL"
                                + ", publish_status = 'published' "
                                + ", publish_log = " + escape.cote(command.getOutput())
                                + " WHERE id = " + escape.cote(pageId);
                            Etn.executeCmd(q);
                        }
                        else {
                            String output = command.getOutput();
                            q = " UPDATE pages SET published_ts = NULL, published_by = NULL "
                                + ", to_publish = 0 , to_publish_ts = NULL"
                                + ", publish_status = 'error' "
                                + ", publish_log = " + escape.cote(output)
                                + " WHERE id = " + escape.cote(pageId);
                            Etn.executeCmd(q);
                        }

                    }
                    catch (Exception ex) {
                        System.out.println("Error in generating page : " + pageId);
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
