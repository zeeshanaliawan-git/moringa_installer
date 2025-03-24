package com.etn.eshop;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import com.etn.beans.Contexte;
import com.etn.sql.escape;
import com.etn.lang.ResultSet.Set;
import java.util.*;
/**
 * Generate, publish, un-publish and updates pages that are marked for
 *
 * @author Abdul Rehman
 * @since 2021-06-10
 */
public class FormUnpublish {

    private ClientSql Etn;
    private Properties env = null;
    private Hashtable GlobalParm = null;

    private boolean debug = false;

    public FormUnpublish(ClientSql Etn, Properties env, boolean debug) {
        this.Etn = Etn;
        this.Etn.setSeparateur(2, '\001', '\002');
        this.env = env;
        this.debug = debug;
    }

    public FormUnpublish(Contexte Etn, Hashtable GlobalParm) {
        this.Etn = Etn;
        this.GlobalParm = GlobalParm;
    }

    public String getParm(String key) throws Exception {
        if (env != null) {
            return env.getProperty(key);
        }
        else if (GlobalParm != null) {
            return String.valueOf(this.GlobalParm.get(key));
        }
        else {
            throw new Exception("No env or params set.");
        }

    }

    private void deleteFormEntries(String formId, String siteId){

		Set rsF = Etn.execute("select * from process_forms where form_id = "+escape.cote(formId));
		rsF.next();
		String custSmsId = Util.parseNull(rsF.value("cust_sms_id"));
		
		if(custSmsId.length() > 0)
		{
			Etn.executeCmd("delete from sms where sms_id = "+escape.cote(custSmsId));
		}

        Etn.execute("DELETE c FROM coordinates c INNER JOIN process_forms pf ON c.process = pf.table_name WHERE site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));
        
        Etn.execute("DELETE p FROM phases p INNER JOIN process_forms pf ON p.process = pf.table_name WHERE site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));
        
        Etn.execute("DELETE r FROM rules r INNER JOIN process_forms pf ON r.start_proc = pf.table_name AND r.next_proc = pf.table_name WHERE site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));
        
        Etn.execute("DELETE m FROM mails m INNER JOIN mail_config mc ON m.id = mc.id INNER JOIN process_forms pf ON mc.ordertype = pf.table_name WHERE site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));
        
        Etn.execute("DELETE mc FROM mail_config mc INNER JOIN process_forms pf ON mc.ordertype = pf.table_name WHERE  site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        Etn.execute("DELETE fr FROM freq_rules fr INNER JOIN process_forms pf ON fr.form_id = pf.form_id WHERE site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        Etn.execute("DELETE pffd FROM process_form_field_descriptions pffd INNER JOIN process_form_fields pff ON pffd.form_id = pff.form_id INNER JOIN process_forms pf ON pf.form_id = pff.form_id WHERE pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));        

        Etn.execute("DELETE pff FROM process_form_fields pff INNER JOIN process_forms pf ON pf.form_id = pff.form_id WHERE pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        Etn.execute("DELETE pfl FROM process_form_lines pfl INNER JOIN process_forms pf ON pf.form_id = pfl.form_id WHERE pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        Etn.execute("DELETE pfd FROM process_form_descriptions pfd INNER JOIN process_forms pf ON pf.form_id = pfd.form_id WHERE pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));
		
        Etn.execute("DELETE pfd FROM form_search_fields pfd INNER JOIN process_forms pf ON pf.form_id = pfd.form_id WHERE pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));
		
        Etn.execute("DELETE pfd FROM form_result_fields pfd INNER JOIN process_forms pf ON pf.form_id = pfd.form_id WHERE pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        Etn.execute("DELETE FROM process_forms WHERE site_id = " + escape.cote(siteId) + " AND form_id = " + escape.cote(formId));
    }

    public void run() {
        try {

			//publish games
            String q = "SELECT * "
                + " FROM games_unpublished"
                + " WHERE to_unpublish = 1 AND to_unpublish_ts <= NOW()";
            Set rs = Etn.execute(q);
			while(rs.next())
			{
				String formId = rs.value("form_id");
				String gameId = rs.value("id");
				System.out.println("---- UnPublish Game : "+ gameId + " name : " + rs.value("name"));
				Etn.executeCmd("delete from game_prize where game_uuid = "+escape.cote(gameId));
				Etn.executeCmd("delete from games where id = "+escape.cote(gameId));
				
				//lets mark it for publish and next query will do publishing of the form
				Etn.execute("update process_forms_unpublished set to_unpublish = 1, to_unpublish_ts = now() where form_id = "+escape.cote(formId));
				Etn.execute("update games_unpublished set to_unpublish = 0 where id = "+escape.cote(gameId));
			}

            q = "SELECT form_id "
                + " FROM process_forms_unpublished"
                + " WHERE to_unpublish = 1 AND to_unpublish_ts <= NOW()";

            rs = Etn.execute(q);
            if (rs != null && rs.rs.Rows > 0) {

                System.out.println("****** Unpublishing " + rs.rs.Rows + " form(s)....................");

                while(rs.next()){

                    String formId = rs.value("form_id");					
                    System.out.println("****** Unpublishing form id >>>> " + formId);
					
					boolean isGameForm = false;
					Set rsG = Etn.execute("select * from games_unpublished where form_id = "+escape.cote(formId));
					if(rsG != null && rsG.rs.Rows > 0) isGameForm = true;
					

                    String siteId = "";

                    Set processFormRs = Etn.execute("SELECT site_id FROM process_forms_unpublished WHERE form_id = " + escape.cote(formId));

                    if(processFormRs.next()){

                        siteId = processFormRs.value("site_id");
                    }

                    deleteFormEntries(formId, siteId);
					Etn.execute("UPDATE process_forms_unpublished SET to_unpublish = 0 WHERE form_id = " + escape.cote(formId));
					
					Etn.executeCmd("update "+env.getProperty("PREPROD_PORTAL_DB")+".cache_tasks set status = 9 where status = 0 and site_id = "+escape.cote(siteId)+" and task in ('publish','unpublish') and content_type = 'form' and content_id ="+escape.cote(formId));
					Etn.executeCmd("insert into "+env.getProperty("PREPROD_PORTAL_DB")+".cache_tasks (site_id, content_type, content_id, task) "+
								" values("+escape.cote(siteId)+", 'form', "+escape.cote(formId)+", 'unpublish') ");
					
                }
				Etn.execute("select semfree("+escape.cote(env.getProperty("PORTAL_ENG_SEMA"))+")");
                
            }
        }
        catch (Exception ex) {
            ex.printStackTrace();
        }
    }
}
