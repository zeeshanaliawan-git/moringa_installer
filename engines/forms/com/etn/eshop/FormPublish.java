package com.etn.eshop;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import com.etn.beans.Contexte;
import com.etn.sql.escape;
import com.etn.lang.ResultSet.Set;
import java.util.*;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

/**
 * Generate, publish, un-publish and updates pages that are marked for
 *
 * @author Abdul Rehman
 * @since 2021-06-10
 */
public class FormPublish {

    private ClientSql Etn;
    private Properties env = null;
    private Hashtable GlobalParm = null;

    private boolean debug = false;

    public FormPublish(ClientSql Etn, Properties env, boolean debug) {
        this.Etn = Etn;
        this.Etn.setSeparateur(2, '\001', '\002');
        this.env = env;
        this.debug = debug;
    }

    public FormPublish(Contexte Etn, Hashtable GlobalParm) {
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

    private void deleteFormEntries(String formId, String siteId, String type, boolean isGameForm) throws Exception{

		if(type.equalsIgnoreCase("sign_up") || type.equalsIgnoreCase("forgot_password") || isGameForm){

            Etn.execute("DELETE c FROM coordinates c INNER JOIN process_forms pf ON c.process = pf.table_name WHERE site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));            
            Etn.execute("DELETE p FROM phases p INNER JOIN process_forms pf ON p.process = pf.table_name WHERE site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));
            Etn.execute("DELETE r FROM rules r INNER JOIN process_forms pf ON r.start_proc = pf.table_name AND r.next_proc = pf.table_name WHERE site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));
            Etn.execute("DELETE ha FROM has_action ha INNER JOIN process_forms pf ON ha.start_proc = pf.table_name WHERE site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));
        }

        Set rs = Etn.execute("SELECT * FROM process_forms_unpublished WHERE site_id = " + escape.cote(siteId) + " AND form_id = " + escape.cote(formId));

        String cid = "";
        String bkid = "";
        String smsid = "";

        if(rs.next()){

            cid = rs.value("cust_eid");
            bkid = rs.value("bk_ofc_eid");
            smsid = rs.value("cust_sms_id");
        }

        Etn.execute("DELETE FROM sms WHERE sms_id = " + escape.cote(smsid));
		
        Etn.execute("DELETE FROM mails WHERE id IN (" + escape.cote(cid) + "," + escape.cote(bkid) + ")");
        
        Etn.execute("DELETE mc FROM mail_config mc INNER JOIN process_forms pf ON mc.ordertype = pf.table_name WHERE  site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        Etn.execute("DELETE fr FROM freq_rules fr INNER JOIN process_forms pf ON fr.form_id = pf.form_id WHERE site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        Etn.execute("DELETE fsf FROM form_search_fields fsf INNER JOIN process_forms pf ON fsf.form_id = pf.form_id WHERE site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        Etn.execute("DELETE frf FROM form_result_fields frf INNER JOIN process_forms pf ON frf.form_id = pf.form_id WHERE site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        Etn.execute("DELETE pffd FROM process_form_field_descriptions pffd INNER JOIN process_form_fields pff ON pffd.form_id = pff.form_id INNER JOIN process_forms pf ON pf.form_id = pff.form_id WHERE pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));        

        Etn.execute("DELETE pff FROM process_form_fields pff INNER JOIN process_forms pf ON pf.form_id = pff.form_id WHERE pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        Etn.execute("DELETE pfl FROM process_form_lines pfl INNER JOIN process_forms pf ON pf.form_id = pfl.form_id WHERE pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        Etn.execute("DELETE pfd FROM process_form_descriptions pfd INNER JOIN process_forms pf ON pf.form_id = pfd.form_id WHERE pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        Etn.execute("DELETE FROM process_forms WHERE site_id = " + escape.cote(siteId) + " AND form_id = " + escape.cote(formId));
    }

    private String getFieldsColumn(Set rs, boolean ignoreIdColumn){

        return getFieldsColumn(rs, "", ignoreIdColumn);
    }

    private String getFieldsColumn(Set rs, String allias, boolean ignoreIdColumn){

        String columns = "";
		if(allias == null) allias = "";

        for(int i=0; i<rs.ColName.length; i++) {

            if(ignoreIdColumn && rs.ColName[i].equalsIgnoreCase("id")) continue;

            columns += allias+rs.ColName[i].toLowerCase() + ",";
        }

        if(columns.length() > 0) columns = columns.substring(0, columns.length()-1);

        return columns;
    }

    private void insertFormEntries(String formId, String siteId) throws Exception{

        Set rs = Etn.execute("SELECT * FROM process_forms_unpublished WHERE site_id = " + escape.cote(siteId) + " AND form_id = " + escape.cote(formId));
        
        String cid = "";
        String bkid = "";
        String smsid = "";

        if(rs.next()){

            cid = rs.value("cust_eid");
            bkid = rs.value("bk_ofc_eid");
            smsid = rs.value("cust_sms_id");
        }

		rs = Etn.execute("SELECT * FROM process_forms_unpublished WHERE site_id = " + escape.cote(siteId) + " AND form_id = " + escape.cote(formId));
        //System.out.println("INSERT INTO process_forms ("+getFieldsColumn(rs,false)+") SELECT "+getFieldsColumn(rs,"pf.",false)+" FROM process_forms_unpublished pf WHERE site_id = " + escape.cote(siteId) + " AND form_id = " + escape.cote(formId));
        Etn.executeCmd("INSERT INTO process_forms ("+getFieldsColumn(rs,false)+") SELECT "+getFieldsColumn(rs,"pf.",false)+" FROM process_forms_unpublished pf WHERE site_id = " + escape.cote(siteId) + " AND form_id = " + escape.cote(formId));
		
		rs = Etn.execute("SELECT pfd.* FROM process_form_descriptions_unpublished pfd WHERE pfd.form_id = " + escape.cote(formId));
        //System.out.println("INSERT INTO process_form_descriptions ("+getFieldsColumn(rs,false)+") SELECT "+getFieldsColumn(rs,"pfd.",false)+" FROM process_form_descriptions_unpublished pfd, process_forms_unpublished pf WHERE pf.form_id = pfd.form_id AND pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));
        Etn.executeCmd("INSERT INTO process_form_descriptions ("+getFieldsColumn(rs,false)+") SELECT "+getFieldsColumn(rs,"pfd.",false)+" FROM process_form_descriptions_unpublished pfd, process_forms_unpublished pf WHERE pf.form_id = pfd.form_id AND pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

		rs = Etn.execute("SELECT pfl.* FROM process_form_lines_unpublished pfl WHERE pfl.form_id = " + escape.cote(formId));
        //System.out.println("INSERT INTO process_form_lines ("+getFieldsColumn(rs,false)+") SELECT "+getFieldsColumn(rs,"pfl.",false)+" FROM process_form_lines_unpublished pfl, process_forms_unpublished pf WHERE pf.form_id = pfl.form_id AND pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));
        Etn.executeCmd("INSERT INTO process_form_lines ("+getFieldsColumn(rs,false)+") SELECT "+getFieldsColumn(rs,"pfl.",false)+" FROM process_form_lines_unpublished pfl, process_forms_unpublished pf WHERE pf.form_id = pfl.form_id AND pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        rs = Etn.execute("SELECT * FROM process_form_fields_unpublished WHERE form_id = " + escape.cote(formId));
        //System.out.println("INSERT INTO process_form_fields (" + getFieldsColumn(rs, true) + ") SELECT " + getFieldsColumn(rs, "pff.", true) + " FROM process_form_fields_unpublished pff, process_forms_unpublished pf WHERE pf.form_id = pff.form_id AND pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId) + " ORDER BY pff.seq_order, pff.id ");
        Etn.executeCmd("INSERT INTO process_form_fields (" + getFieldsColumn(rs, true) + ") SELECT " + getFieldsColumn(rs, "pff.", true) + " FROM process_form_fields_unpublished pff, process_forms_unpublished pf WHERE pf.form_id = pff.form_id AND pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId) + " ORDER BY pff.seq_order, pff.id ");

		rs = Etn.execute("SELECT pffd.* FROM process_form_field_descriptions_unpublished pffd WHERE pffd.form_id = " + escape.cote(formId));
        //System.out.println("INSERT INTO process_form_field_descriptions ("+getFieldsColumn(rs,false)+") SELECT "+getFieldsColumn(rs,"pffd.",false)+" FROM process_form_field_descriptions_unpublished pffd, process_forms_unpublished pf WHERE pf.form_id = pffd.form_id AND pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));
        Etn.executeCmd("INSERT INTO process_form_field_descriptions ("+getFieldsColumn(rs,false)+") SELECT "+getFieldsColumn(rs,"pffd.",false)+" FROM process_form_field_descriptions_unpublished pffd, process_forms_unpublished pf WHERE pf.form_id = pffd.form_id AND pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

		rs = Etn.execute("SELECT * FROM sms_unpublished m WHERE sms_id = " + escape.cote(smsid));
        Etn.executeCmd("INSERT INTO sms ("+getFieldsColumn(rs,false)+") SELECT "+getFieldsColumn(rs,"m.",false)+" FROM sms_unpublished m WHERE sms_id = " + escape.cote(smsid));

		rs = Etn.execute("SELECT * FROM mails_unpublished m WHERE id IN (" + escape.cote(cid) + "," + escape.cote(bkid) + ")");
        //System.out.println("INSERT INTO mails ("+getFieldsColumn(rs,false)+") SELECT "+getFieldsColumn(rs,"m.",false)+" FROM mails_unpublished m WHERE id IN (" + escape.cote(cid) + "," + escape.cote(bkid) + ")");
        Etn.executeCmd("INSERT INTO mails ("+getFieldsColumn(rs,false)+") SELECT "+getFieldsColumn(rs,"m.",false)+" FROM mails_unpublished m WHERE id IN (" + escape.cote(cid) + "," + escape.cote(bkid) + ")");

		rs = Etn.execute("SELECT mc.* FROM mail_config_unpublished mc, process_forms_unpublished pf WHERE pf.table_name = mc.ordertype AND pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));
        //System.out.println("INSERT INTO mail_config ("+getFieldsColumn(rs,false)+") SELECT "+getFieldsColumn(rs,"mc.",false)+" FROM mail_config_unpublished mc, process_forms_unpublished pf WHERE pf.table_name = mc.ordertype AND pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));
        Etn.executeCmd("INSERT INTO mail_config ("+getFieldsColumn(rs,false)+") SELECT "+getFieldsColumn(rs,"mc.",false)+" FROM mail_config_unpublished mc, process_forms_unpublished pf WHERE pf.table_name = mc.ordertype AND pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        rs = Etn.execute("SELECT * FROM form_search_fields_unpublished WHERE form_id = " + escape.cote(formId));
        //System.out.println("INSERT INTO form_search_fields (" + getFieldsColumn(rs, true) + ") SELECT " + getFieldsColumn(rs, "fsf.", true) + " FROM form_search_fields_unpublished fsf, process_forms_unpublished pf WHERE pf.form_id = fsf.form_id AND pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));
        Etn.executeCmd("INSERT INTO form_search_fields (" + getFieldsColumn(rs, true) + ") SELECT " + getFieldsColumn(rs, "fsf.", true) + " FROM form_search_fields_unpublished fsf, process_forms_unpublished pf WHERE pf.form_id = fsf.form_id AND pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        rs = Etn.execute("SELECT * FROM form_result_fields_unpublished WHERE form_id = " + escape.cote(formId));
        //System.out.println("INSERT INTO form_result_fields (" + getFieldsColumn(rs, true) + ") SELECT " + getFieldsColumn(rs, "frf.", true) + " FROM form_result_fields_unpublished frf, process_forms_unpublished pf WHERE pf.form_id = frf.form_id AND pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));
        Etn.executeCmd("INSERT INTO form_result_fields (" + getFieldsColumn(rs, true) + ") SELECT " + getFieldsColumn(rs, "frf.", true) + " FROM form_result_fields_unpublished frf, process_forms_unpublished pf WHERE pf.form_id = frf.form_id AND pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

		rs = Etn.execute("SELECT fr.* FROM freq_rules_unpublished fr WHERE fr.form_id = " + escape.cote(formId));
        //System.out.println("INSERT INTO freq_rules ("+getFieldsColumn(rs,false)+") SELECT "+getFieldsColumn(rs,"fr.",false)+" FROM freq_rules_unpublished fr, process_forms_unpublished pf WHERE pf.form_id = fr.form_id AND pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));
        Etn.executeCmd("INSERT INTO freq_rules ("+getFieldsColumn(rs,false)+") SELECT "+getFieldsColumn(rs,"fr.",false)+" FROM freq_rules_unpublished fr, process_forms_unpublished pf WHERE pf.form_id = fr.form_id AND pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));
    }

    private void insertSimpleFormPhaseEntries(String tableName, String isCustomerEmail, String isBackOfficeEmail, String customerMailId, String backofficeMailId) throws Exception{

        Set rs = Etn.execute("SELECT * FROM coordinates WHERE process = " + escape.cote(tableName));

        if(rs.rs.Rows == 0){

            Etn.executeCmd("INSERT INTO coordinates(topLeftX, topLeftY, width, height, process, profile, phase) VALUES (" + escape.cote("44") + ", " + escape.cote("102") + ", " + escape.cote("120") + ", " + escape.cote("80") + ", " + escape.cote(tableName) + ", " + escape.cote("ADMIN") + ", " + escape.cote("FormSubmitted") + ");");

            Etn.executeCmd("INSERT INTO coordinates(topLeftX, topLeftY, width, height, process, profile, phase) VALUES (" + escape.cote("157") + ", " + escape.cote("232") + ", " + escape.cote("120") + ", " + escape.cote("80") + ", " + escape.cote(tableName) + ", " + escape.cote("ADMIN") + ", " + escape.cote("EmailSent") + ");");
        }

        rs = Etn.execute("SELECT * FROM rules WHERE start_proc = " + escape.cote(tableName));

        if(rs.rs.Rows == 0){

            Etn.executeCmd("INSERT INTO rules(start_proc, start_phase, errcode, next_proc, next_phase, rdv, type) VALUES (" + escape.cote(tableName) + ", " + escape.cote("FormSubmitted") + "," + escape.cote("0") + ", " + escape.cote(tableName) + ", " + escape.cote("EmailSent") + ", " + escape.cote("And") + ", " + escape.cote("Cancelled") + ");");
        }

        Set errCodeRs = Etn.execute("SELECT * FROM errcode WHERE id = " + escape.cote("0"));
        if(errCodeRs.rs.Rows == 0){

            Etn.executeCmd("INSERT INTO errcode(id, errMessage, errNom, errType, errCouleur) VALUES (" + escape.cote("0") + ", " + escape.cote("") + ", " + escape.cote("OK") + ", " + escape.cote("success") + ", " + escape.cote("#35f500") + ");");
        }

        rs = Etn.execute("SELECT * FROM phases WHERE process = " + escape.cote(tableName));

        if(rs.rs.Rows == 0){

            Etn.executeCmd("INSERT INTO phases(process, phase, topLeftX, topLeftY, visc, isManual, displayName, rulesVisibleTo) VALUES (" + escape.cote(tableName) + ", " + escape.cote("FormSubmitted") + "," + escape.cote("119") + ", " + escape.cote("87") + ", " + escape.cote("1") + ", " + escape.cote("1") + ", " + escape.cote("Form Submitted") + ", " + escape.cote("ADMIN") + ");");

            Etn.executeCmd("INSERT INTO phases(process, phase, topLeftX, topLeftY, visc, isManual, displayName, rulesVisibleTo) VALUES (" + escape.cote(tableName) + ", " + escape.cote("EmailSent") + "," + escape.cote("151") + ", " + escape.cote("222") + ", " + escape.cote("1") + ", " + escape.cote("1") + ", " + escape.cote("Email Sent") + ", " + escape.cote("ADMIN") + ");");
        }

		String startPhase = "FormSubmitted";
		String nextPhase = "EmailSent";
		//If a form process is customized then chances are the error code 0 will return no cle which is a valid case
		/*
		* There are different case for forms process configuration
		* 1. Not for every form we have to send the email. In that case the form entry stays in FormSubmitted phase
		* 2. We have emails configured in which case the form will go to EmailSent phase.
		* 3. We have to do some special processing on form record but no emails to be sent. So in this case we will manually add a phase after FormSubmitted and do whatever we want to do.
		*	 In this case we must not delete the EmailSent phase but remove its arrow from FormSubmitted and add the arrow with 0 error from the new phase we added to EmailSent. 
		*	 In case in future we want to send emails also, system will add the emails action on that new arrow we added manually rather than over writing anything.
		* 4. We have to send emails and also do some processing. This is easy where we can add our new processing phase after the EmailSent phase.
		*/
        Set rulesRs = Etn.execute("SELECT * FROM rules WHERE start_proc = " + escape.cote(tableName) + 
						" AND errCode = 0 AND next_proc = " + escape.cote(tableName) + 
						" AND next_phase = " + escape.cote(nextPhase));
        
        String cleId = "";

        if(rulesRs.next()) 
		{
			cleId = rulesRs.value("cle");
			startPhase = rulesRs.value("start_phase");
		}
		System.out.println("insertSimpleFormPhaseEntries::cleId::"+cleId);
		System.out.println("insertSimpleFormPhaseEntries::startPhase:"+startPhase);
		System.out.println("insertSimpleFormPhaseEntries::nextPhase:"+nextPhase);

        String actionConfig = "";

        if(isCustomerEmail.equals("1")) 
            actionConfig = "mail:" + customerMailId;

        if(isBackOfficeEmail.equals("1")) {

            if(actionConfig.length() > 0)
                actionConfig += ",mail:" + backofficeMailId;
            else
                actionConfig = "mail:" + backofficeMailId;
        }

        if(actionConfig.length() > 0) actionConfig += ",sql:processNow";

        rs = Etn.execute("SELECT * FROM has_action WHERE cle = "+escape.cote(cleId));

        if(rs.rs.Rows == 0){

            Etn.executeCmd("INSERT INTO has_action(start_proc, start_phase, cle, action) VALUES(" + escape.cote(tableName) + "," + escape.cote(startPhase) + "," + escape.cote(cleId) + "," + escape.cote(actionConfig) + ")");
    
        } else {
			//we must check for cle while update has_action as this action must be updated for errCode = 0 cle only
            System.out.println("UPDATE has_action SET action = " + escape.cote(actionConfig) + " WHERE cle = " + escape.cote(cleId) + " and start_proc = " + escape.cote(tableName) + " AND start_phase = " + escape.cote(startPhase));
            Etn.executeCmd("UPDATE has_action SET action = " + escape.cote(actionConfig) + " WHERE cle = " + escape.cote(cleId) + " and start_proc = " + escape.cote(tableName) + " AND start_phase = " + escape.cote(startPhase));
        }

        System.out.println("UPDATE rules SET action = " + escape.cote(actionConfig) + " WHERE start_proc = " + escape.cote(tableName) + " AND start_phase = " + escape.cote(startPhase) + " AND errCode = " + escape.cote("0") + " AND next_proc = " + escape.cote(tableName) + " AND next_phase = " + escape.cote(nextPhase));
        Etn.executeCmd("UPDATE rules SET action = " + escape.cote(actionConfig) + " WHERE start_proc = " + escape.cote(tableName) + " AND start_phase = " + escape.cote(startPhase) + " AND errCode = " + escape.cote("0") + " AND next_proc = " + escape.cote(tableName) + " AND next_phase = " + escape.cote(nextPhase));

    }

    private void insertGameFormPhaseEntries(String processName, ClientSql etn, String isCustomerEmail, String isBackOfficeEmail, String customerMailId, String backofficeMailId, String isCustSms, String custSmsId) throws Exception{
		
		//creating phases
		etn.executeCmd("insert into phases (process, phase, topLeftX, topLeftY, visc, isManual, displayName, rulesVisibleTo) values ("+escape.cote(processName)+", 'Done', 1134, 308,'1','1','Done','ADMIN')");
		etn.executeCmd("insert into phases (process, phase, topLeftX, topLeftY, visc, isManual, displayName, rulesVisibleTo) values ("+escape.cote(processName)+", 'FormSubmitted', 176, 237,'1','1','FormSubmitted','ADMIN')");
		etn.executeCmd("insert into phases (process, phase, topLeftX, topLeftY, visc, isManual, displayName, rulesVisibleTo) values ("+escape.cote(processName)+", 'GameFinished', 510, 156,'1','1','GameFinished','ADMIN')");
		etn.executeCmd("insert into phases (process, phase, topLeftX, topLeftY, visc, isManual, displayName, rulesVisibleTo) values ("+escape.cote(processName)+", 'GameStarted', 115, 315,'1','1','GameStarted','ADMIN')");
		etn.executeCmd("insert into phases (process, phase, topLeftX, topLeftY, visc, isManual, displayName, rulesVisibleTo) values ("+escape.cote(processName)+", 'Lost', 734, 118,'1','1','Lost','ADMIN')");
		etn.executeCmd("insert into phases (process, phase, topLeftX, topLeftY, visc, isManual, displayName, rulesVisibleTo) values ("+escape.cote(processName)+", 'NotifyBackOffice', 997, 317,'1','1','NotifyBackOffice','ADMIN')");
		etn.executeCmd("insert into phases (process, phase, topLeftX, topLeftY, visc, isManual, displayName, rulesVisibleTo) values ("+escape.cote(processName)+", 'NotifyCustomer', 844, 382,'1','1','NotifyCustomer','ADMIN')");
		etn.executeCmd("insert into phases (process, phase, topLeftX, topLeftY, visc, isManual, displayName, rulesVisibleTo) values ("+escape.cote(processName)+", 'Win', 690, 274,'1','1','Win','ADMIN')");
		
        //creating coordinates of all phases
		etn.executeCmd("insert into coordinates (topLeftX, topLeftY, width, height, process, profile, phase) values (9,8,957,554,"+escape.cote(processName)+",'ADMIN','')");
		etn.executeCmd("insert into coordinates (topLeftX, topLeftY, width, height, process, profile, phase) values (42,208,120,80,"+escape.cote(processName)+",'ADMIN','GameStarted')");
		etn.executeCmd("insert into coordinates (topLeftX, topLeftY, width, height, process, profile, phase) values (630,208,120,80,"+escape.cote(processName)+",'ADMIN','Done')");
		etn.executeCmd("insert into coordinates (topLeftX, topLeftY, width, height, process, profile, phase) values (41,41,120,80,"+escape.cote(processName)+",'ADMIN','FormSubmitted')");
		etn.executeCmd("insert into coordinates (topLeftX, topLeftY, width, height, process, profile, phase) values (43,356,120,80,"+escape.cote(processName)+",'ADMIN','GameFinished')");
		etn.executeCmd("insert into coordinates (topLeftX, topLeftY, width, height, process, profile, phase) values (262,440,120,80,"+escape.cote(processName)+",'ADMIN','Win')");
		etn.executeCmd("insert into coordinates (topLeftX, topLeftY, width, height, process, profile, phase) values (263,208,120,80,"+escape.cote(processName)+",'ADMIN','Lost')");
		etn.executeCmd("insert into coordinates (topLeftX, topLeftY, width, height, process, profile, phase) values (630,440,120,80,"+escape.cote(processName)+",'ADMIN','NotifyBackOffice')");
		etn.executeCmd("insert into coordinates (topLeftX, topLeftY, width, height, process, profile, phase) values (450,441,120,80,"+escape.cote(processName)+",'ADMIN','NotifyCustomer')");
		
		//creating rules
		etn.executeCmd("insert into rules (start_proc, start_phase, errcode, next_proc, next_phase, rdv, type, action) values ("+escape.cote(processName)+",'FormSubmitted','0',"+escape.cote(processName)+",'GameStarted','And','Cancelled','')");
		etn.executeCmd("insert into rules (start_proc, start_phase, errcode, next_proc, next_phase, rdv, type, action) values ("+escape.cote(processName)+",'GameFinished','0',"+escape.cote(processName)+",'Win','And','Cancelled','sql:checkGameStatus')");
		etn.executeCmd("insert into rules (start_proc, start_phase, errcode, next_proc, next_phase, rdv, type, action) values ("+escape.cote(processName)+",'GameFinished','19',"+escape.cote(processName)+",'Lost','And','Cancelled','sql:checkGameStatus')");
		etn.executeCmd("insert into rules (start_proc, start_phase, errcode, next_proc, next_phase, rdv, type, action) values ("+escape.cote(processName)+",'GameStarted','0',"+escape.cote(processName)+",'GameFinished','And','Cancelled','')");		
		etn.executeCmd("insert into rules (start_proc, start_phase, errcode, next_proc, next_phase, rdv, type, action) values ("+escape.cote(processName)+",'Lost','0',"+escape.cote(processName)+",'Done','And','Cancelled','sql:processNow')");
		
		String _action = "";
		int p=0;
		if("1".equals(isBackOfficeEmail))
		{
			_action = "mail:"+backofficeMailId;
			p++;
		}
		if(p > 0) _action += ",";
		_action += "sql:processNow";
		etn.executeCmd("insert into rules (start_proc, start_phase, errcode, next_proc, next_phase, rdv, type, action) values ("+escape.cote(processName)+",'NotifyBackOffice','0',"+escape.cote(processName)+",'Done','And','Cancelled',"+escape.cote(_action)+")");
		
		_action = "";
		p=0;
		if("1".equals(isCustomerEmail))
		{
			_action += "mail:"+customerMailId;
			p++;
		}
		if("1".equals(isCustSms))
		{
			if(p > 0) _action += ",";
			_action += "sms:"+custSmsId;
			p++;
		}
		if(p > 0) _action += ",";
		_action += "sql:processNow";		
		etn.executeCmd("insert into rules (start_proc, start_phase, errcode, next_proc, next_phase, rdv, type, action) values ("+escape.cote(processName)+",'NotifyCustomer','0',"+escape.cote(processName)+",'NotifyBackOffice','And','Cancelled',"+escape.cote(_action)+")");
		
		etn.executeCmd("insert into rules (start_proc, start_phase, errcode, next_proc, next_phase, rdv, type, action) values ("+escape.cote(processName)+",'Win','0',"+escape.cote(processName)+",'NotifyCustomer','And','Cancelled','sql:processNow')");

		Set rsRule = etn.execute("select * from rules where start_proc = "+escape.cote(processName)+ " and start_phase = 'GameFinished' order by cle limit 1");
		rsRule.next();
		etn.execute("insert into has_action (start_proc, start_phase, action, cle) values ("+escape.cote(rsRule.value("start_proc"))+","+escape.cote(rsRule.value("start_phase"))+","+escape.cote(rsRule.value("action"))+","+escape.cote(rsRule.value("cle"))+")");
		
		rsRule = etn.execute("select * from rules where start_proc = "+escape.cote(processName)+ " and start_phase = 'Lost' order by cle limit 1");
		rsRule.next();
		etn.execute("insert into has_action (start_proc, start_phase, action, cle) values ("+escape.cote(rsRule.value("start_proc"))+","+escape.cote(rsRule.value("start_phase"))+","+escape.cote(rsRule.value("action"))+","+escape.cote(rsRule.value("cle"))+")");
		
		rsRule = etn.execute("select * from rules where start_proc = "+escape.cote(processName)+ " and start_phase = 'NotifyBackOffice' order by cle limit 1");
		rsRule.next();
		etn.execute("insert into has_action (start_proc, start_phase, action, cle) values ("+escape.cote(rsRule.value("start_proc"))+","+escape.cote(rsRule.value("start_phase"))+","+escape.cote(rsRule.value("action"))+","+escape.cote(rsRule.value("cle"))+")");
		
		rsRule = etn.execute("select * from rules where start_proc = "+escape.cote(processName)+ " and start_phase = 'NotifyCustomer' order by cle limit 1");
		rsRule.next();
		etn.execute("insert into has_action (start_proc, start_phase, action, cle) values ("+escape.cote(rsRule.value("start_proc"))+","+escape.cote(rsRule.value("start_phase"))+","+escape.cote(rsRule.value("action"))+","+escape.cote(rsRule.value("cle"))+")");
		
		rsRule = etn.execute("select * from rules where start_proc = "+escape.cote(processName)+ " and start_phase = 'Win' order by cle limit 1");
		rsRule.next();
		etn.execute("insert into has_action (start_proc, start_phase, action, cle) values ("+escape.cote(rsRule.value("start_proc"))+","+escape.cote(rsRule.value("start_phase"))+","+escape.cote(rsRule.value("action"))+","+escape.cote(rsRule.value("cle"))+")");
		

		//defining errCodes
        Set errCodeRs = etn.execute("SELECT * FROM errcode WHERE id = " + escape.cote("0"));
        if(errCodeRs.rs.Rows == 0){

            etn.executeCmd("INSERT INTO errcode(id, errMessage, errNom, errType, errCouleur) VALUES (" + escape.cote("0") + ", " + escape.cote("") + ", " + escape.cote("OK") + ", " + escape.cote("success") + ", " + escape.cote("#35f500") + ");");
        }

        errCodeRs = etn.execute("SELECT * FROM errcode WHERE id = " + escape.cote("19"));
        if(errCodeRs.rs.Rows == 0){

            etn.executeCmd("INSERT INTO errcode(id, errMessage, errNom, errType, errCouleur) VALUES (" + escape.cote("19") + ", " + escape.cote("") + ", " + escape.cote("Error") + ", " + escape.cote("error") + ", " + escape.cote("#ff0000") + ");");
        }
		
	}
	
    private void insertSignupFormPhaseEntries(String name, ClientSql etn, String isCustomerEmail, String isBackOfficeEmail, String customerMailId, String backofficeMailId) throws Exception{

        //creating coordinates of all phases
        etn.executeCmd("INSERT INTO coordinates(topLeftX, topLeftY, width, height, process, profile, phase) VALUES (" + escape.cote("78") + ", " + escape.cote("76") + ", " + escape.cote("120") + ", " + escape.cote("80") + ", " + escape.cote(name) + ", " + escape.cote("ADMIN") + ", " + escape.cote("FormSubmitted") + ");");

        etn.executeCmd("INSERT INTO coordinates(topLeftX, topLeftY, width, height, process, profile, phase) VALUES (" + escape.cote("379") + ", " + escape.cote("72") + ", " + escape.cote("130") + ", " + escape.cote("90") + ", " + escape.cote(name) + ", " + escape.cote("ADMIN") + ", " + escape.cote("CheckAdminCreated") + ");");

        etn.executeCmd("INSERT INTO coordinates(topLeftX, topLeftY, width, height, process, profile, phase) VALUES (" + escape.cote("730") + ", " + escape.cote("67") + ", " + escape.cote("140") + ", " + escape.cote("100") + ", " + escape.cote(name) + ", " + escape.cote("ADMIN") + ", " + escape.cote("CreateClient") + ");");

        etn.executeCmd("INSERT INTO coordinates(topLeftX, topLeftY, width, height, process, profile, phase) VALUES (" + escape.cote("81") + ", " + escape.cote("232") + ", " + escape.cote("150") + ", " + escape.cote("110") + ", " + escape.cote(name) + ", " + escape.cote("ADMIN") + ", " + escape.cote("BackOfficeEmail") + ");");

        etn.executeCmd("INSERT INTO coordinates(topLeftX, topLeftY, width, height, process, profile, phase) VALUES (" + escape.cote("380") + ", " + escape.cote("226") + ", " + escape.cote("160") + ", " + escape.cote("120") + ", " + escape.cote(name) + ", " + escape.cote("ADMIN") + ", " + escape.cote("CheckAutoAccept") + ");");

        etn.executeCmd("INSERT INTO coordinates(topLeftX, topLeftY, width, height, process, profile, phase) VALUES (" + escape.cote("627") + ", " + escape.cote("334") + ", " + escape.cote("170") + ", " + escape.cote("130") + ", " + escape.cote(name) + ", " + escape.cote("ADMIN") + ", " + escape.cote("WaitForAdmin") + ");");

        etn.executeCmd("INSERT INTO coordinates(topLeftX, topLeftY, width, height, process, profile, phase) VALUES (" + escape.cote("710") + ", " + escape.cote("201") + ", " + escape.cote("180") + ", " + escape.cote("140") + ", " + escape.cote(name) + ", " + escape.cote("ADMIN") + ", " + escape.cote("Accept") + ");");

        etn.executeCmd("INSERT INTO coordinates(topLeftX, topLeftY, width, height, process, profile, phase) VALUES (" + escape.cote("1064") + ", " + escape.cote("324") + ", " + escape.cote("190") + ", " + escape.cote("105") + ", " + escape.cote(name) + ", " + escape.cote("ADMIN") + ", " + escape.cote("Reject") + ");");

        etn.executeCmd("INSERT INTO coordinates(topLeftX, topLeftY, width, height, process, profile, phase) VALUES (" + escape.cote("950") + ", " + escape.cote("224") + ", " + escape.cote("120") + ", " + escape.cote("80") + ", " + escape.cote(name) + ", " + escape.cote("ADMIN") + ", " + escape.cote("CustomerEmail") + ");");

        etn.executeCmd("INSERT INTO coordinates(topLeftX, topLeftY, width, height, process, profile, phase) VALUES (" + escape.cote("1058") + ", " + escape.cote("65") + ", " + escape.cote("200") + ", " + escape.cote("105") + ", " + escape.cote(name) + ", " + escape.cote("ADMIN") + ", " + escape.cote("Done") + ");");

        etn.executeCmd("INSERT INTO coordinates(topLeftX, topLeftY, width, height, process, profile, phase) VALUES (" + escape.cote("10") + ", " + escape.cote("9") + ", " + escape.cote("1316") + ", " + escape.cote("501") + ", " + escape.cote(name) + ", " + escape.cote("ADMIN") + ", NULL);");
        //-------------------------------

        //creating all possible rules for all phases
        etn.executeCmd("INSERT INTO rules(start_proc, start_phase, errcode, next_proc, next_phase, rdv, type, action) VALUES (" + escape.cote(name) + ", " + escape.cote("FormSubmitted") + "," + escape.cote("0") + ", " + escape.cote(name) + ", " + escape.cote("CheckAdminCreated") + ", " + escape.cote("And") + ", " + escape.cote("Cancelled") + "," + escape.cote("sql:processNow") + ");");

        etn.executeCmd("INSERT INTO rules(start_proc, start_phase, errcode, next_proc, next_phase, rdv, type, action) VALUES (" + escape.cote(name) + ", " + escape.cote("CheckAdminCreated") + "," + escape.cote("0") + ", " + escape.cote(name) + ", " + escape.cote("CreateClient") + ", " + escape.cote("And") + ", " + escape.cote("Cancelled") + "," + escape.cote("checkAdmin:adminRequest") + ");");

        etn.executeCmd("INSERT INTO rules(start_proc, start_phase, errcode, next_proc, next_phase, rdv, type, action) VALUES (" + escape.cote(name) + ", " + escape.cote("CheckAdminCreated") + "," + escape.cote("10") + ", " + escape.cote(name) + ", " + escape.cote("BackOfficeEmail") + ", " + escape.cote("And") + ", " + escape.cote("Cancelled") + "," + escape.cote("checkAdmin:adminRequest") + ");");

        etn.executeCmd("INSERT INTO rules(start_proc, start_phase, errcode, next_proc, next_phase, rdv, type, action) VALUES (" + escape.cote(name) + ", " + escape.cote("BackOfficeEmail") + "," + escape.cote("0") + ", " + escape.cote(name) + ", " + escape.cote("CheckAutoAccept") + ", " + escape.cote("And") + ", " + escape.cote("Cancelled") + "," + escape.cote("sql:processNow") + ");");

        etn.executeCmd("INSERT INTO rules(start_proc, start_phase, errcode, next_proc, next_phase, rdv, type, action) VALUES (" + escape.cote(name) + ", " + escape.cote("CheckAutoAccept") + "," + escape.cote("0") + ", " + escape.cote(name) + ", " + escape.cote("CreateClient") + ", " + escape.cote("And") + ", " + escape.cote("Cancelled") + "," + escape.cote("checkAuto:autoAccept") + ");");

        etn.executeCmd("INSERT INTO rules(start_proc, start_phase, errcode, next_proc, next_phase, rdv, type, action) VALUES (" + escape.cote(name) + ", " + escape.cote("CheckAutoAccept") + "," + escape.cote("10") + ", " + escape.cote(name) + ", " + escape.cote("WaitForAdmin") + ", " + escape.cote("And") + ", " + escape.cote("Cancelled") + "," + escape.cote("checkAuto:autoAccept") + ");");

        etn.executeCmd("INSERT INTO rules(start_proc, start_phase, errcode, next_proc, next_phase, rdv, type) VALUES (" + escape.cote(name) + ", " + escape.cote("WaitForAdmin") + "," + escape.cote("0") + ", " + escape.cote(name) + ", " + escape.cote("Accept") + ", " + escape.cote("And") + ", " + escape.cote("Cancelled") + ");");

        etn.executeCmd("INSERT INTO rules(start_proc, start_phase, errcode, next_proc, next_phase, rdv, type) VALUES (" + escape.cote(name) + ", " + escape.cote("WaitForAdmin") + "," + escape.cote("19") + ", " + escape.cote(name) + ", " + escape.cote("Reject") + ", " + escape.cote("And") + ", " + escape.cote("Cancelled") + ");");

        etn.executeCmd("INSERT INTO rules(start_proc, start_phase, errcode, next_proc, next_phase, rdv, type, action) VALUES (" + escape.cote(name) + ", " + escape.cote("Accept") + "," + escape.cote("0") + ", " + escape.cote(name) + ", " + escape.cote("CreateClient") + ", " + escape.cote("And") + ", " + escape.cote("Cancelled") + "," + escape.cote("sql:processNow") + ");");

        etn.executeCmd("INSERT INTO rules(start_proc, start_phase, errcode, next_proc, next_phase, rdv, type, action) VALUES (" + escape.cote(name) + ", " + escape.cote("CreateClient") + "," + escape.cote("10") + ", " + escape.cote(name) + ", " + escape.cote("CustomerEmail") + ", " + escape.cote("And") + ", " + escape.cote("Cancelled") + "," + escape.cote("client:create") + ");");

        etn.executeCmd("INSERT INTO rules(start_proc, start_phase, errcode, next_proc, next_phase, rdv, type, action) VALUES (" + escape.cote(name) + ", " + escape.cote("CustomerEmail") + "," + escape.cote("0") + ", " + escape.cote(name) + ", " + escape.cote("Done") + ", " + escape.cote("And") + ", " + escape.cote("Cancelled") + "," + escape.cote("sql:processNow") + ");");

        etn.executeCmd("INSERT INTO rules(start_proc, start_phase, errcode, next_proc, next_phase, rdv, type, action) VALUES (" + escape.cote(name) + ", " + escape.cote("CreateClient") + "," + escape.cote("0") + ", " + escape.cote(name) + ", " + escape.cote("Done") + ", " + escape.cote("And") + ", " + escape.cote("Cancelled") + "," + escape.cote("client:create") + ");");

        etn.executeCmd("INSERT INTO rules(start_proc, start_phase, errcode, next_proc, next_phase, rdv, type, action) VALUES (" + escape.cote(name) + ", " + escape.cote("Reject") + "," + escape.cote("0") + ", " + escape.cote(name) + ", " + escape.cote("Done") + ", " + escape.cote("And") + ", " + escape.cote("Cancelled") + "," + escape.cote("sql:processNow") + ");");

        etn.executeCmd("INSERT INTO rules(start_proc, start_phase, errcode, next_proc, next_phase, rdv, type, action) VALUES (" + escape.cote(name) + ", " + escape.cote("CreateClient") + "," + escape.cote("20") + ", " + escape.cote(name) + ", " + escape.cote("Done") + ", " + escape.cote("And") + ", " + escape.cote("Cancelled") + "," + escape.cote("client:create") + ");");

        etn.executeCmd("INSERT INTO rules(start_proc, start_phase, errcode, next_proc, next_phase, rdv, type, action) VALUES (" + escape.cote(name) + ", " + escape.cote("CreateClient") + "," + escape.cote("30") + ", " + escape.cote(name) + ", " + escape.cote("Done") + ", " + escape.cote("And") + ", " + escape.cote("Cancelled") + "," + escape.cote("client:create") + ");");
        //----------------------------

        //defining error codes if not.
        Set errCodeRs = etn.execute("SELECT * FROM errcode WHERE id = " + escape.cote("0"));
        if(errCodeRs.rs.Rows == 0){

            etn.executeCmd("INSERT INTO errcode(id, errMessage, errNom, errType, errCouleur) VALUES (" + escape.cote("0") + ", " + escape.cote("") + ", " + escape.cote("OK") + ", " + escape.cote("success") + ", " + escape.cote("#35f500") + ");");
        }

        errCodeRs = etn.execute("SELECT * FROM errcode WHERE id = " + escape.cote("10"));
        if(errCodeRs.rs.Rows == 0){

            etn.executeCmd("INSERT INTO errcode(id, errMessage, errNom, errType, errCouleur) VALUES (" + escape.cote("10") + ", " + escape.cote("") + ", " + escape.cote("Success") + ", " + escape.cote("success") + ", " + escape.cote("#35f500") + ");");
        }

        errCodeRs = etn.execute("SELECT * FROM errcode WHERE id = " + escape.cote("19"));
        if(errCodeRs.rs.Rows == 0){

            etn.executeCmd("INSERT INTO errcode(id, errMessage, errNom, errType, errCouleur) VALUES (" + escape.cote("19") + ", " + escape.cote("") + ", " + escape.cote("Error") + ", " + escape.cote("error") + ", " + escape.cote("#ff0000") + ");");
        }

        errCodeRs = etn.execute("SELECT * FROM errcode WHERE id = " + escape.cote("20"));
        if(errCodeRs.rs.Rows == 0){

            etn.executeCmd("INSERT INTO errcode(id, errMessage, errNom, errType, errCouleur) VALUES (" + escape.cote("20") + ", " + escape.cote("User is already exists") + ", " + escape.cote("Error") + ", " + escape.cote("error") + ", " + escape.cote("#ff0000") + ");");
        }

        errCodeRs = etn.execute("SELECT * FROM errcode WHERE id = " + escape.cote("30"));
        if(errCodeRs.rs.Rows == 0){

            etn.executeCmd("INSERT INTO errcode(id, errMessage, errNom, errType, errCouleur) VALUES (" + escape.cote("30") + ", " + escape.cote("User created from orange authentication") + ", " + escape.cote("Success") + ", " + escape.cote("success") + ", " + escape.cote("#35f500") + ");");
        }
        //----------------------------------

        //creating phases
        etn.executeCmd("INSERT INTO phases(process, phase, topLeftX, topLeftY, visc, isManual, displayName, rulesVisibleTo) VALUES (" + escape.cote(name) + ", " + escape.cote("FormSubmitted") + "," + escape.cote("109") + ", " + escape.cote("57") + ", " + escape.cote("1") + ", " + escape.cote("1") + ", " + escape.cote("Form Submitted") + ", " + escape.cote("ADMIN") + ");");

        etn.executeCmd("INSERT INTO phases(process, phase, topLeftX, topLeftY, visc, isManual, displayName, rulesVisibleTo) VALUES (" + escape.cote(name) + ", " + escape.cote("CheckAdminCreated") + "," + escape.cote("119") + ", " + escape.cote("67") + ", " + escape.cote("1") + ", " + escape.cote("1") + ", " + escape.cote("Check admin created") + ", " + escape.cote("ADMIN") + ");");

        etn.executeCmd("INSERT INTO phases(process, phase, topLeftX, topLeftY, visc, isManual, displayName, rulesVisibleTo) VALUES (" + escape.cote(name) + ", " + escape.cote("CreateClient") + "," + escape.cote("129") + ", " + escape.cote("77") + ", " + escape.cote("1") + ", " + escape.cote("1") + ", " + escape.cote("Create client") + ", " + escape.cote("ADMIN") + ");");

        etn.executeCmd("INSERT INTO phases(process, phase, topLeftX, topLeftY, visc, isManual, displayName, rulesVisibleTo) VALUES (" + escape.cote(name) + ", " + escape.cote("BackOfficeEmail") + "," + escape.cote("139") + ", " + escape.cote("87") + ", " + escape.cote("1") + ", " + escape.cote("1") + ", " + escape.cote("Back office email") + ", " + escape.cote("ADMIN") + ");");

        etn.executeCmd("INSERT INTO phases(process, phase, topLeftX, topLeftY, visc, isManual, displayName, rulesVisibleTo) VALUES (" + escape.cote(name) + ", " + escape.cote("CheckAutoAccept") + "," + escape.cote("149") + ", " + escape.cote("97") + ", " + escape.cote("1") + ", " + escape.cote("1") + ", " + escape.cote("Check auto accept") + ", " + escape.cote("ADMIN") + ");");

        etn.executeCmd("INSERT INTO phases(process, phase, topLeftX, topLeftY, visc, isManual, displayName, rulesVisibleTo) VALUES (" + escape.cote(name) + ", " + escape.cote("WaitForAdmin") + "," + escape.cote("159") + ", " + escape.cote("107") + ", " + escape.cote("1") + ", " + escape.cote("1") + ", " + escape.cote("Wait for admin") + ", " + escape.cote("ADMIN") + ");");

        etn.executeCmd("INSERT INTO phases(process, phase, topLeftX, topLeftY, visc, isManual, displayName, rulesVisibleTo) VALUES (" + escape.cote(name) + ", " + escape.cote("Accept") + "," + escape.cote("169") + ", " + escape.cote("117") + ", " + escape.cote("1") + ", " + escape.cote("1") + ", " + escape.cote("Accept") + ", " + escape.cote("ADMIN") + ");");

        etn.executeCmd("INSERT INTO phases(process, phase, topLeftX, topLeftY, visc, isManual, displayName, rulesVisibleTo) VALUES (" + escape.cote(name) + ", " + escape.cote("Reject") + "," + escape.cote("179") + ", " + escape.cote("127") + ", " + escape.cote("1") + ", " + escape.cote("1") + ", " + escape.cote("Reject") + ", " + escape.cote("ADMIN") + ");");

        etn.executeCmd("INSERT INTO phases(process, phase, topLeftX, topLeftY, visc, isManual, displayName, rulesVisibleTo) VALUES (" + escape.cote(name) + ", " + escape.cote("CustomerEmail") + "," + escape.cote("961") + ", " + escape.cote("229") + ", " + escape.cote("1") + ", " + escape.cote("1") + ", " + escape.cote("Customer email") + ", " + escape.cote("ADMIN") + ");");

        etn.executeCmd("INSERT INTO phases(process, phase, topLeftX, topLeftY, visc, isManual, displayName, rulesVisibleTo) VALUES (" + escape.cote(name) + ", " + escape.cote("Done") + "," + escape.cote("189") + ", " + escape.cote("127") + ", " + escape.cote("1") + ", " + escape.cote("1") + ", " + escape.cote("Done") + ", " + escape.cote("ADMIN") + ");");

        //---------------------------------------

        //defining actions
        etn.executeCmd("INSERT INTO has_action(start_proc, start_phase, cle, action) VALUES (" + escape.cote(name) + ", " + escape.cote("FormSubmitted") + ",( SELECT cle FROM rules WHERE start_proc = " + escape.cote(name) + " AND start_phase = " + escape.cote("FormSubmitted") + " AND next_phase = " + escape.cote("CheckAdminCreated") + " ), " + escape.cote("sql:processNow") + ");");

        etn.executeCmd("INSERT INTO has_action(start_proc, start_phase, cle, action) VALUES (" + escape.cote(name) + ", " + escape.cote("CheckAdminCreated") + ",( SELECT cle FROM rules WHERE start_proc = " + escape.cote(name) + " AND start_phase = " + escape.cote("CheckAdminCreated") + " AND next_phase = " + escape.cote("CreateClient") + " ), " + escape.cote("checkAdmin:adminRequest") + ");");

        etn.executeCmd("INSERT INTO has_action(start_proc, start_phase, cle, action) VALUES (" + escape.cote(name) + ", " + escape.cote("BackOfficeEmail") + ",( SELECT cle FROM rules WHERE start_proc = " + escape.cote(name) + " AND start_phase = " + escape.cote("BackOfficeEmail") + " AND next_phase = " + escape.cote("CheckAutoAccept") + " ), " + escape.cote("sql:processNow") + ");");

        etn.executeCmd("INSERT INTO has_action(start_proc, start_phase, cle, action) VALUES (" + escape.cote(name) + ", " + escape.cote("CheckAutoAccept") + ",( SELECT cle FROM rules WHERE start_proc = " + escape.cote(name) + " AND start_phase = " + escape.cote("CheckAutoAccept") + " AND next_phase = " + escape.cote("CreateClient") + " ), " + escape.cote("checkAuto:autoAccept") + ");");

        etn.executeCmd("INSERT INTO has_action(start_proc, start_phase, cle, action) VALUES (" + escape.cote(name) + ", " + escape.cote("Accept") + ",( SELECT cle FROM rules WHERE start_proc = " + escape.cote(name) + " AND start_phase = " + escape.cote("Accept") + " AND next_phase = " + escape.cote("CreateClient") + " ), " + escape.cote("sql:processNow") + ");");

        etn.executeCmd("INSERT INTO has_action(start_proc, start_phase, cle, action) VALUES (" + escape.cote(name) + ", " + escape.cote("Reject") + ",( SELECT cle FROM rules WHERE start_proc = " + escape.cote(name) + " AND start_phase = " + escape.cote("Reject") + " AND next_phase = " + escape.cote("Done") + " ), " + escape.cote("sql:processNow") + ");");

        etn.executeCmd("INSERT INTO has_action(start_proc, start_phase, cle, action) VALUES (" + escape.cote(name) + ", " + escape.cote("CreateClient") + ",( SELECT cle FROM rules WHERE start_proc = " + escape.cote(name) + " AND start_phase = " + escape.cote("CreateClient") + " AND next_phase = " + escape.cote("Done") + " AND errCode = " + escape.cote("0") + "), " + escape.cote("client:create") + ");");

        etn.executeCmd("INSERT INTO has_action(start_proc, start_phase, cle, action) VALUES (" + escape.cote(name) + ", " + escape.cote("CustomerEmail") + ",( SELECT cle FROM rules WHERE start_proc = " + escape.cote(name) + " AND start_phase = " + escape.cote("CustomerEmail") + " AND next_phase = " + escape.cote("Done") + "), " + escape.cote("sql:processNow") + ");");

        String actionConfigCsOfc = "sql:processNow";
        String actionConfigBkOfc = "sql:processNow";

        if(isCustomerEmail.equals("1")) {

            actionConfigCsOfc = "mail:" + customerMailId + ",sql:processNow";
        }

        if(isBackOfficeEmail.equals("1")) {

            actionConfigBkOfc = "mail:" + backofficeMailId + ",sql:processNow";
        }

        Etn.executeCmd("UPDATE has_action SET action = " + escape.cote(actionConfigBkOfc) + " WHERE start_proc = " + escape.cote(name) + " AND start_phase = " + escape.cote("BackOfficeEmail"));

        Etn.executeCmd("UPDATE rules SET action = " + escape.cote(actionConfigBkOfc) + " WHERE start_proc = " + escape.cote(name) + " AND start_phase = " + escape.cote("BackOfficeEmail") + " AND errCode = " + escape.cote("0") + " AND next_proc = " + escape.cote(name) + " AND next_phase = " + escape.cote("CheckAutoAccept"));

        Etn.executeCmd("UPDATE has_action SET action = " + escape.cote(actionConfigCsOfc) + " WHERE start_proc = " + escape.cote(name) + " AND start_phase = " + escape.cote("CustomerEmail"));

        Etn.executeCmd("UPDATE rules SET action = " + escape.cote(actionConfigCsOfc) + " WHERE start_proc = " + escape.cote(name) + " AND start_phase = " + escape.cote("CustomerEmail") + " AND errCode = " + escape.cote("0") + " AND next_proc = " + escape.cote(name) + " AND next_phase = " + escape.cote("Done"));
    }

    private void insertForgotPasswordFormPhaseEntries(String name, ClientSql etn, String isCustomerEmail, String isBackOfficeEmail, String customerMailId, String backofficeMailId) throws Exception{

        //creating coordinates of all phases
        etn.executeCmd("INSERT INTO coordinates(topLeftX, topLeftY, width, height, process, profile, phase) VALUES (" + escape.cote("78") + ", " + escape.cote("76") + ", " + escape.cote("120") + ", " + escape.cote("80") + ", " + escape.cote(name) + ", " + escape.cote("ADMIN") + ", " + escape.cote("FormSubmitted") + ");");

        etn.executeCmd("INSERT INTO coordinates(topLeftX, topLeftY, width, height, process, profile, phase) VALUES (" + escape.cote("79") + ", " + escape.cote("198") + ", " + escape.cote("120") + ", " + escape.cote("80") + ", " + escape.cote(name) + ", " + escape.cote("ADMIN") + ", " + escape.cote("CustomerEmail") + ");");

        etn.executeCmd("INSERT INTO coordinates(topLeftX, topLeftY, width, height, process, profile, phase) VALUES (" + escape.cote("38") + ", " + escape.cote("378") + ", " + escape.cote("200") + ", " + escape.cote("105") + ", " + escape.cote(name) + ", " + escape.cote("ADMIN") + ", " + escape.cote("Done") + ");");

        etn.executeCmd("INSERT INTO coordinates(topLeftX, topLeftY, width, height, process, profile, phase) VALUES (" + escape.cote("9") + ", " + escape.cote("10") + ", " + escape.cote("275") + ", " + escape.cote("501") + ", " + escape.cote(name) + ", " + escape.cote("ADMIN") + ", NULL);");
        //-------------------------------

        //creating all possible rules for all phases
        etn.executeCmd("INSERT INTO rules(start_proc, start_phase, errcode, next_proc, next_phase, rdv, type, action) VALUES (" + escape.cote(name) + ", " + escape.cote("FormSubmitted") + "," + escape.cote("0") + ", " + escape.cote(name) + ", " + escape.cote("CustomerEmail") + ", " + escape.cote("And") + ", " + escape.cote("Cancelled") + "," + escape.cote("forgotpassword:clientForgotPassword") + ");");

        etn.executeCmd("INSERT INTO rules(start_proc, start_phase, errcode, next_proc, next_phase, rdv, type, action) VALUES (" + escape.cote(name) + ", " + escape.cote("FormSubmitted") + "," + escape.cote("20") + ", " + escape.cote(name) + ", " + escape.cote("Done") + ", " + escape.cote("And") + ", " + escape.cote("Cancelled") + "," + escape.cote("sql:processNow") + ");");

        etn.executeCmd("INSERT INTO rules(start_proc, start_phase, errcode, next_proc, next_phase, rdv, type, action) VALUES (" + escape.cote(name) + ", " + escape.cote("CustomerEmail") + "," + escape.cote("0") + ", " + escape.cote(name) + ", " + escape.cote("Done") + ", " + escape.cote("And") + ", " + escape.cote("Cancelled") + "," + escape.cote("sql:processNow") + ");");

        //----------------------------

        //defining error codes if not.
        Set errCodeRs = etn.execute("SELECT * FROM errcode WHERE id = " + escape.cote("0"));
        if(errCodeRs.rs.Rows == 0){

            etn.executeCmd("INSERT INTO errcode(id, errMessage, errNom, errType, errCouleur) VALUES (" + escape.cote("0") + ", " + escape.cote("") + ", " + escape.cote("OK") + ", " + escape.cote("success") + ", " + escape.cote("#35f500") + ");");
        }

        errCodeRs = etn.execute("SELECT * FROM errcode WHERE id = " + escape.cote("20"));
        if(errCodeRs.rs.Rows == 0){

            etn.executeCmd("INSERT INTO errcode(id, errMessage, errNom, errType, errCouleur) VALUES (" + escape.cote("20") + ", " + escape.cote("User isn't registered in our system") + ", " + escape.cote("Error") + ", " + escape.cote("error") + ", " + escape.cote("#ff0000") + ");");
        }

        //----------------------------------

        //creating phases
        etn.executeCmd("INSERT INTO phases(process, phase, topLeftX, topLeftY, visc, isManual, displayName, rulesVisibleTo) VALUES (" + escape.cote(name) + ", " + escape.cote("FormSubmitted") + "," + escape.cote("109") + ", " + escape.cote("57") + ", " + escape.cote("1") + ", " + escape.cote("1") + ", " + escape.cote("Form Submitted") + ", " + escape.cote("ADMIN") + ");");

        etn.executeCmd("INSERT INTO phases(process, phase, topLeftX, topLeftY, visc, isManual, displayName, rulesVisibleTo) VALUES (" + escape.cote(name) + ", " + escape.cote("CustomerEmail") + "," + escape.cote("961") + ", " + escape.cote("229") + ", " + escape.cote("1") + ", " + escape.cote("1") + ", " + escape.cote("Customer email") + ", " + escape.cote("ADMIN") + ");");

        etn.executeCmd("INSERT INTO phases(process, phase, topLeftX, topLeftY, visc, isManual, displayName, rulesVisibleTo) VALUES (" + escape.cote(name) + ", " + escape.cote("Done") + "," + escape.cote("189") + ", " + escape.cote("127") + ", " + escape.cote("1") + ", " + escape.cote("1") + ", " + escape.cote("Done") + ", " + escape.cote("ADMIN") + ");");

        //---------------------------------------

        //defining actions
        etn.executeCmd("INSERT INTO has_action(start_proc, start_phase, cle, action) VALUES (" + escape.cote(name) + ", " + escape.cote("FormSubmitted") + ",( SELECT cle FROM rules WHERE start_proc = " + escape.cote(name) + " AND start_phase = " + escape.cote("FormSubmitted") + " AND next_phase = " + escape.cote("CustomerEmail") + " ), " + escape.cote("forgotpassword:clientForgotPassword") + ");");

        etn.executeCmd("INSERT INTO has_action(start_proc, start_phase, cle, action) VALUES (" + escape.cote(name) + ", " + escape.cote("CustomerEmail") + ",( SELECT cle FROM rules WHERE start_proc = " + escape.cote(name) + " AND start_phase = " + escape.cote("CustomerEmail") + " AND next_phase = " + escape.cote("Done") + " AND errCode = " + escape.cote("0") + "), " + escape.cote("sql:processNow") + ");");


        Set rulesRs = Etn.execute("SELECT cle FROM rules WHERE start_proc = " + escape.cote(name) + " AND start_phase = " + escape.cote("FormSubmitted") + " AND errCode = " + escape.cote("0") + " AND next_proc = " + escape.cote(name) + " AND next_phase = " + escape.cote("EmailSent"));
        
        String cleId = "";

        if(rulesRs.next()) cleId = rulesRs.value("cle");

        String actionConfig = "";

        if(isCustomerEmail.equals("1")) 
            actionConfig = "mail:" + customerMailId;

        if(isBackOfficeEmail.equals("1")) {

            if(actionConfig.length() > 0)
                actionConfig += ",mail:" + backofficeMailId;
            else
                actionConfig = "mail:" + backofficeMailId;
        }

        if(actionConfig.length() > 0) actionConfig += ",sql:processNow";

        String startPhase = "CustomerEmail";
        String nextPhase = "Done";

        Etn.executeCmd("UPDATE has_action SET action = " + escape.cote(actionConfig) + " WHERE start_proc = " + escape.cote(name) + " AND start_phase = " + escape.cote(startPhase));

        Etn.executeCmd("UPDATE rules SET action = " + escape.cote(actionConfig) + " WHERE start_proc = " + escape.cote(name) + " AND start_phase = " + escape.cote(startPhase) + " AND errCode = " + escape.cote("0") + " AND next_proc = " + escape.cote(name) + " AND next_phase = " + escape.cote(nextPhase));
    }

    private void createFormTable(String tableName, String type) throws Exception{

        String columnQuery = "CREATE TABLE IF NOT EXISTS " + tableName + " (\n";
        columnQuery += "\t" + tableName + "_id int(11) NOT NULL AUTO_INCREMENT,\n";
        columnQuery += "\t" + "rule_id int(11) NOT NULL,\n";
        columnQuery += "\t" + "form_id varchar(50) NOT NULL,\n";
        columnQuery += "\t" + "created_on datetime DEFAULT NULL,\n";
        columnQuery += "\t" + "created_by varchar(20) DEFAULT NULL,\n";
        columnQuery += "\t" + "updated_on datetime DEFAULT NULL,\n";
        columnQuery += "\t" + "updated_by varchar(20) DEFAULT NULL,\n";
        columnQuery += "\t" + "lastid int(10) unsigned DEFAULT 0,\n";
        columnQuery += "\t" + "menu_lang varchar(20) DEFAULT NULL,\n";
        columnQuery += "\t" + "mid varchar(50) DEFAULT NULL,\n";
        columnQuery += "\t" + "portalurl varchar(255) DEFAULT NULL,\n";
        columnQuery += "\t" + "userip varchar(50) DEFAULT NULL,\n";

        if(type.equalsIgnoreCase("sign_up") || type.equalsIgnoreCase("forgot_password")){

            columnQuery += "\t" + "is_admin char(1) DEFAULT '0',\n";
        }

        columnQuery += "PRIMARY KEY (" + tableName + "_id)";

        columnQuery += ")ENGINE=MyISAM DEFAULT CHARSET=utf8;";

        if(columnQuery.length() > 0)
            Etn.execute(columnQuery);
    }

    private void addEmailToForgotPassword(String tableName, String formId) throws Exception{
		Set rs = Etn.execute("SELECT db_column_name, pff.type FROM process_form_fields_unpublished pff  WHERE pff.form_id = " + escape.cote(formId)+ " and db_column_name = '_etn_email'");
		if(rs.rs.Rows == 0)
		{
			System.out.println("Email field not found in the forgot password table so force add it");
			Etn.execute("alter table "+tableName+" add column _etn_email varchar(255) default null");
		}
	}
	
    private void alterCustomTableColumn(String tableName, String siteId, String formId) throws Exception{

        Set rs = Etn.execute("SELECT db_column_name, pff.type FROM process_form_fields_unpublished pff, process_forms_unpublished pf WHERE pf.form_id = pff.form_id AND pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));
      
        while(rs.next()){

            String type = rs.value("type");
            String dbColumnName = rs.value("db_column_name");
            String columnQuery = "";

            Set colRs = Etn.execute("SHOW COLUMNS from " + tableName + " LIKE " + escape.cote(dbColumnName));

            if(colRs.rs.Rows  == 0){

                if(type.equals("textdate"))
                    columnQuery = "ALTER TABLE " + tableName + " ADD COLUMN " + dbColumnName + " date DEFAULT NULL;";
                else if(type.equals("textdatetime"))
                    columnQuery = "ALTER TABLE " + tableName + " ADD COLUMN " + dbColumnName + " datetime DEFAULT NULL;";
                else if(type.equals("email"))
                    columnQuery = "ALTER TABLE " + tableName + " ADD COLUMN " + dbColumnName + " VARCHAR(255) DEFAULT NULL;";
                else if(!(type.equals("hr_line") || type.equals("label") || type.equals("button")))
                    columnQuery = "ALTER TABLE " + tableName + " ADD COLUMN " + dbColumnName + " TEXT DEFAULT NULL;";

                if(columnQuery.length() > 0) Etn.execute(columnQuery);
            }
        }
    }

    private void alterCustomTableUuidColumn(String tableName) throws Exception
	{
		String dbColumnName = "_asm_tbl_uid";

		Set colRs = Etn.execute("SHOW COLUMNS from " + tableName + " LIKE " + escape.cote(dbColumnName));

		if(colRs.rs.Rows  == 0)
		{
			String columnQuery = "ALTER TABLE " + tableName + " ADD COLUMN "+dbColumnName+" varchar(50) not null default uuid()";
			Etn.execute(columnQuery);
        }
    }

    private void copyMailTemplate(String id) throws Exception {


        Set rs = Etn.execute("SELECT * FROM language");

        while(rs.next()){

            String langId = rs.value("langue_id");
            String langCode = rs.value("langue_code");

            if(!langId.equals("1")) langCode = "_"+langCode;
            else langCode = "";

            String filePath = this.getParm("MAIL_UPLOAD_PATH");
            String sourceFilePath = filePath+"unpublished_mail"+id+langCode;
            String destFilePath = filePath+"mail"+id+langCode;

            File source = new File(sourceFilePath);
            File dest = new File(destFilePath);

            if(source.exists()) Files.copy(source.toPath(), dest.toPath(), StandardCopyOption.REPLACE_EXISTING);

            sourceFilePath = filePath+"unpublished_mail"+id+langCode+".ftl";
            destFilePath = filePath+"mail"+id+langCode+".ftl";

            source = new File(sourceFilePath);
            dest = new File(destFilePath);

            if(source.exists()) Files.copy(source.toPath(), dest.toPath(), StandardCopyOption.REPLACE_EXISTING);
        }
    }

    public void run() {
        try {
			//publish games
            String q = "SELECT * "
                + " FROM games_unpublished"
                + " WHERE to_publish = 1 AND to_publish_ts <= NOW()";
            Set rs = Etn.execute(q);
			while(rs.next())
			{
				String formId = rs.value("form_id");
				String gameId = rs.value("id");
				System.out.println("---- Publish Game : "+ gameId + " name : " + rs.value("name"));
				Etn.executeCmd("delete from game_prize where game_uuid = "+escape.cote(gameId));
				Etn.executeCmd("delete from games where id = "+escape.cote(gameId));
				
				Set rsGamePrizesUnp = Etn.execute("select * from game_prize_unpublished where game_uuid = "+escape.cote(gameId));
				Etn.executeCmd("INSERT INTO game_prize ("+getFieldsColumn(rsGamePrizesUnp,false)+") SELECT "+getFieldsColumn(rsGamePrizesUnp,"pf.",false)+" FROM game_prize_unpublished pf WHERE game_uuid = " + escape.cote(gameId));
								
				Etn.executeCmd("INSERT INTO games ("+getFieldsColumn(rs,false)+") SELECT "+getFieldsColumn(rs,"pf.",false)+" FROM games_unpublished pf WHERE id = " + escape.cote(gameId));
				
				//lets mark it for publish and next query will do publishing of the form
				Etn.execute("update process_forms_unpublished set to_publish = 1, to_publish_ts = now() where form_id = "+escape.cote(formId));
				Etn.execute("update games_unpublished set to_publish = 0 where id = "+escape.cote(gameId));
			}

            q = "SELECT form_id "
                + " FROM process_forms_unpublished"
                + " WHERE to_publish = 1 AND to_publish_ts <= NOW()";

            rs = Etn.execute(q);
            if (rs != null && rs.rs.Rows > 0) {

                System.out.println("****** Publishing " + rs.rs.Rows + " form(s)....................");
                List<String> dbColumnNameList = new ArrayList<String>();

                while(rs.next()){

					String formId = rs.value("form_id");
					boolean isGameForm = false;
					Set rsG = Etn.execute("select * from games_unpublished where form_id = "+escape.cote(formId));
					if(rsG != null && rsG.rs.Rows > 0) isGameForm = true;
                    
                    System.out.println("****** Publishing form id >>>> " + formId);

                    String tableName = "";
                    String siteId = "";
                    String type = "";
                    String customerMailId = "";
                    String backofficeMailId = "";
                    String isCustomerMailId = "";
                    String isBackOfficeEmailId = "";
                    String isCustSms = "";
                    String custSmsId = "";

                    Set processFormRs = Etn.execute("SELECT is_sms, cust_sms_id, table_name, process_name, site_id, type, bk_ofc_eid as bkid, cust_eid as cid, is_email_cust as is_customer_mail_id, is_email_bk_ofc as is_backoffice_mail_id FROM process_forms_unpublished WHERE form_id = " + escape.cote(formId));

                    if(processFormRs.next()){

                        tableName = processFormRs.value("table_name");
                        siteId = processFormRs.value("site_id");
                        type = processFormRs.value("type");
                        customerMailId = processFormRs.value("cid");
                        backofficeMailId = processFormRs.value("bkid");
                        isCustomerMailId = processFormRs.value("is_customer_mail_id");
                        isBackOfficeEmailId = processFormRs.value("is_backoffice_mail_id");
                        isCustSms = processFormRs.value("is_sms");
                        custSmsId = processFormRs.value("cust_sms_id");
                    }

                    deleteFormEntries(formId, siteId, type, isGameForm);
                    insertFormEntries(formId, siteId);

                    if(isGameForm){
						insertGameFormPhaseEntries(tableName, Etn, isCustomerMailId, isBackOfficeEmailId, customerMailId, backofficeMailId, isCustSms, custSmsId);
                    } else if(type.equalsIgnoreCase("simple")){

                        insertSimpleFormPhaseEntries(tableName, isCustomerMailId, isBackOfficeEmailId, customerMailId, backofficeMailId);

                    } else if(type.equalsIgnoreCase("sign_up")) {

                        insertSignupFormPhaseEntries(tableName, Etn, isCustomerMailId, isBackOfficeEmailId, customerMailId, backofficeMailId);

                    } else if(type.equalsIgnoreCase("forgot_password")) {

                        insertForgotPasswordFormPhaseEntries(tableName, Etn, isCustomerMailId, isBackOfficeEmailId, customerMailId, backofficeMailId);
    
                    }

                    createFormTable(tableName, type);
                    alterCustomTableColumn(tableName, siteId, formId);
                    alterCustomTableUuidColumn(tableName);
					//this is required as from forgot password the user can delete the email column but we always need it for sending the email to client
					//so we will force created that column
					if(type.equals("forgot_password")) addEmailToForgotPassword(tableName, formId);

                    copyMailTemplate(customerMailId);
                    copyMailTemplate(backofficeMailId);


                    Etn.execute("UPDATE process_forms_unpublished SET to_publish = 0 WHERE form_id = " + escape.cote(formId));
                    
					Etn.executeCmd("update "+env.getProperty("PREPROD_PORTAL_DB")+".cache_tasks set status = 9 where status = 0 and site_id = "+escape.cote(siteId)+" and task in ('publish','unpublish') and content_type = 'form' and content_id ="+escape.cote(formId));
					Etn.executeCmd("insert into "+env.getProperty("PREPROD_PORTAL_DB")+".cache_tasks (site_id, content_type, content_id, task) "+
								" values("+escape.cote(siteId)+", 'form', "+escape.cote(formId)+", 'publish') ");
								
					Etn.execute("select semfree("+escape.cote(env.getProperty("PORTAL_ENG_SEMA"))+")");
					
                    Set rs_type = Etn.execute("SELECT type FROM "+env.getProperty("PAGES_DB")+".parent_pages_forms WHERE form_id = " + escape.cote(formId)+" GROUP BY type");
                    
                    while(rs_type.next()){
                    
                        if(rs_type.value("type").equalsIgnoreCase("freemarker"))
                        {
                            Etn.execute("UPDATE "+env.getProperty("PAGES_DB")+".freemarker_pages fmp INNER JOIN "+env.getProperty("PAGES_DB")+".parent_pages_forms ppf ON ppf.page_id = fmp.id SET fmp.updated_ts =NOW(), fmp.to_generate = 1 WHERE ppf.form_id = "+escape.cote(formId));
                        }
                        if(rs_type.value("type").equalsIgnoreCase("structured"))
                        {
                            Etn.execute("UPDATE "+env.getProperty("PAGES_DB")+".structured_contents sc INNER JOIN "+env.getProperty("PAGES_DB")+".parent_pages_forms ppf ON ppf.page_id = sc.id SET sc.updated_ts =NOW(), fmp.to_generate = 1 WHERE ppf.form_id = "+escape.cote(formId));
                        }					
                    }
                }
            }
        }
        catch (Exception ex) {
            ex.printStackTrace();
        }
    }
}
