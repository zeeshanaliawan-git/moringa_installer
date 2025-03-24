
package com.etn.eshop;

import com.etn.eshop.mail.*;

import java.io.*;
import java.net.URL;

import javax.mail.*;
import javax.mail.internet.*;

import java.security.*;
import java.security.cert.*;

import javax.net.ssl.*;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Arrays;
import java.util.Properties;
import java.util.Enumeration;
import java.util.StringTokenizer;
import java.util.Date;
import com.etn.util.ItsDate;
import com.etn.sql.escape;
import com.etn.net.MailFromModel;


import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;

public class SendMail extends MailFromModel {

    public final int NO_MAILID = 1;
    public final int NO_ROW = 2;
    public final int NO_CONTACT = 3;
    public final int NO_CONNECTION = -1;
    ClientSql etn;
    String repository;
    Properties env;
    InternetAddress FROM;
    InternetAddress REPLY[];
    boolean withContrat = false;
    String uploadFiles;

    public void addSousPart(MimeMultipart cur, BodyPart lastmodel, int niveau, int souspart) {
        //System.out.println( "niveau:"+niveau+" souspart:"+souspart);
    }

    public SendMail(ClientSql etn, Properties conf) throws Exception {
        super(conf);
        this.etn = etn;
        this.env = conf;

        repository = env.getProperty("MAIL_REPOSITORY");
        uploadFiles = env.getProperty("UPLOADED_FILES_REPOSITORY");

    }

    String getFieldValue(Set rs, String dollar) {
        if (dollar == null || dollar.length() < 2 || dollar.charAt(0) != '$') {
            return (dollar);
        }

        int i = rs.indexOf(dollar.substring(1));

        return (i == -1 ? dollar : rs.value(i));
    }

    boolean isIdentifier(char c) {
        return (Character.isLetterOrDigit(c) || c == '_');
    }

    /**
     * getMailId.
     *
     * @return mailid > 0
     */
    int getMailId(int wkid, String where, Set rs) {
        StringBuilder sb = new StringBuilder(where.length() * 2);
        int i, j;

        i = 0;
        while ((j = where.indexOf('$', i)) != -1) {
            sb.append(where.substring(i, j));
            for (i = ++j; isIdentifier(where.charAt(i)); i++);
            int n = rs.indexOf(where.substring(j, i));
            if (n < 0) {
                sb.append("$" + where.substring(j, i));
            } else {
                sb.append(escape.cote(rs.value(n)));
            }
        }

        sb.append(where.substring(i, where.length()));

        Set rs2 = etn.execute(sb.toString());
        if (!rs2.next()) {
            return (0);
        }
        try {
            return (Integer.parseInt(rs2.value(0)));
        } catch (Exception e) {
            System.err.println("getMailId return non Integer : " + rs2.value(0));
            return (-1);
        }

    }

    InternetAddress setAdr(String adr) {
        try {
            return (new InternetAddress(adr));
        } catch (Exception e) {
            return (null);
        }
    }

    String parseNull(Object o)
    {
      if( o == null )
        return("");
      String s = o.toString();
      if("null".equals(s.trim().toLowerCase()))
        return("");
      else
        return(s.trim());
    }

    /**
     * setRecipients Analyse du champ email_to Alimente destTO , destCC ,
     * destBCC
     *
     * @return le nombre d'adresse trouvée ou 0 si aucun destinataire
     */
    int setRecipients(Set rs) {
        String s;
        int i, j;
        String z[];
        int nadr = 0;
        InternetAddress t[];

        //reseting these
        destTO = destCC = destBCC = null;

	String emails = parseNull(rs.value("email_to"));
    String emailCc = parseNull(rs.value("email_cc"));
    String emailBcc = parseNull(rs.value("email_ci"));

    List<String> list = Arrays.asList(rs.ColName);          

    System.out.println("email_to : " + emails);
	System.out.println("Send emails to : " + emails);
        StringTokenizer st = new StringTokenizer(emails, "\t,;\r\n");
        z = new String[st.countTokens()];

//	System.out.println("z.length = " + z.length);
        

        if (z.length == 0) {
        
            destTO = new InternetAddress[1];

            if(null != list && list.size() > 0){

                if(list.contains("EMAIL"))
                    destTO[0] = setAdr(rs.value("email"));
                else if(list.contains("_ETN_EMAIL"))
                    destTO[0] = setAdr(rs.value("_etn_email"));
                else
                    destTO[0] = setAdr("");
            }

            return (1);
        }


        i = 0;
        while (st.hasMoreTokens()) {
            z[i++] = st.nextToken();
        }

        System.out.println("z0:" + z[0]);



        // TO...
        if (z.length > 0 && z[0].equalsIgnoreCase("nomail")) // to = all : separated email addrs
        {
            if (z.length == 1) {
                return (0);
            }
	     String[] _tos = z[1].split(":");
	     if(_tos != null)
	     {
              destTO = new InternetAddress[_tos.length];
		for(int _k=0; _k < _tos.length; _k++)
		{
		     System.out.println("############# " + getFieldValue(rs, _tos[_k]));
       	     destTO[_k] = setAdr(getFieldValue(rs, _tos[_k].trim()));
		}
	     }
            z[0] = z[1] = null;
        } else
         {
            destTO = new InternetAddress[1];
            //destTO[0] = setAdr(rs.value("email"));

            if(null != list && list.size() > 0){

                if(list.contains("EMAIL"))
                    destTO[0] = setAdr(rs.value("email"));
                else if(list.contains("_ETN_EMAIL"))
                    destTO[0] = setAdr(rs.value("_etn_email"));
                else
                    destTO[0] = setAdr("");
            }
        }

        nadr = (destTO[0] == null ? 0 : 1);
        if (nadr == 0) {
            destTO = null;
        }

        st = new StringTokenizer(emailCc, "\t,;\r\n");
        z = new String[st.countTokens()];

        i = 0;
        while (st.hasMoreTokens()) {
            z[i++] = st.nextToken();
        }

        // Search CC
        j=0;
        if(z.length > 0 && z[0].equalsIgnoreCase("nomail")){
            if(z.length == 1){
                return (0);
            }

            String[] _Ccs = z[1].split(":");

            if(_Ccs != null){

                destCC = new InternetAddress[_Ccs.length];
                for(int _k=0; _k < _Ccs.length; _k++) {

                    System.out.println("############# CCs " + getFieldValue(rs, _Ccs[_k]));
                    InternetAddress it = setAdr(getFieldValue(rs, _Ccs[_k].trim()));

                    if (it != null) {
                        destCC[j++] = it;
                    }

                }
            }

        }

        if (j != 0) {
            nadr += j;
        }

        st = new StringTokenizer(emailBcc, "\t,;\r\n");
        z = new String[st.countTokens()];

        i = 0;
        while (st.hasMoreTokens()) {
            z[i++] = st.nextToken();
        }

        // All non null are  now bcc
        j=0;
        if(z.length > 0 && z[0].equalsIgnoreCase("nomail")){
            if(z.length == 1){
                return (0);
            }

            String[] _Bccs = z[1].split(":");

            if(_Bccs != null){

                destBCC = new InternetAddress[_Bccs.length];
                for(int _k=0; _k < _Bccs.length; _k++) {

                    System.out.println("############# BCCs " + getFieldValue(rs, _Bccs[_k]));
                    InternetAddress it = setAdr(getFieldValue(rs, _Bccs[_k].trim()));

                    if (it != null) {
                        destBCC[j++] = it;
                    }
                }
            }
        }

        if (j != 0) {
            nadr += j;
        }

        return (nadr);
    }

    public int send(int wkid, String mailident, boolean flag) 
    {

        int r, mailid = Integer.parseInt(mailident);
        FileInputStream fmodele = null;
        FileOutputStream out = null;
        ArrayList<String> atts = new ArrayList<String>();
        String attachs[] = null;

        try {

            Set rs = null;
//System.out.println("################## in send");
            while (true) {
                Set rsp = etn.execute("select * from post_work where id = " + wkid);
                rsp.next();

		  String tablename = rsp.value("form_table_name");

                String s = "select c.*, m.sujet, m.sujet_lang_2, m.sujet_lang_3, m.sujet_lang_4, m.sujet_lang_5, a.email_to, a.email_cc, a.email_ci, a.where_clause, a.attach, c.menu_lang, pf.process_name, (select langue_id from language where langue_code = c.menu_lang) as lang_id, m.id as mail_id, m.template_type, pff.db_column_name"
				+ " from post_work p inner join "+tablename+" c on c."+tablename+"_id = p.client_key inner join (process_forms pf) on pf.form_id = c.form_id "
                            + " inner join process_form_fields pff on pf.form_id = pff.form_id and pff.form_id = c.form_id inner join mails m on m.id = " + mailid + " left join mail_config a on  a.id = m.id and a.ordertype = pf.table_name where p.id = " + wkid;

                rs = etn.execute(s);

                if (!rs.next()) {
                    return (NO_ROW);
                }

                // Analyse du where_clause
                s = rs.value("where_clause");
                if (s.length() == 0) {
                    break;
                }

                if ((r = getMailId(wkid, s, rs)) == mailid) {
                    break;
                }
                if (r <= 0) {
                    return (0);
                }
                mailid = r;
//System.out.println("################## in send : " + mailid);
            }


 	     String maillang = "";
	     if(rs != null && parseNull(rs.value("menu_lang")).length() > 0) maillang = parseNull(rs.value("menu_lang"));

            // Destinataires
            if (setRecipients(rs) == 0) {
                return (NO_CONTACT); // nothing to do
            }

            setFrom(env.getProperty("MAIL_FROM"), env.getProperty("MAIL_FROM_DISPLAY_NAME"));
            if(parseNull(env.getProperty("MAIL_REPLY")).length() > 0) setReply(env.getProperty("MAIL_REPLY"));

	     Set rslang = etn.execute("select * from language order by langue_id ");
	     int langcount = 1;
            while(rslang.next())
	     {
		if(maillang.length() == 0)//if no lang found in table we just use first language
		{
			maillang = rslang.value("langue_code");
			break;
		}
		else
		{
		     	if(maillang.equals(rslang.value("langue_code"))) break;
		       langcount++;
		}
	     }
	     System.out.println("Subject column : " + "sujet_lang_"+langcount);
	     String sujet = parseNull(rs.value("sujet_lang_"+langcount));
            if(sujet.length() == 0) sujet = rs.value("sujet");

	     System.out.println("Final Subject : " + sujet);

            String toattach = rs.value("attach");

	     String emailtemplate = repository + "/mail" + mailid + "_" + maillang;
	     File ftemplate = new File(emailtemplate);
		System.out.println("Try Template : " + emailtemplate);
	     if(!ftemplate.exists() || ftemplate.length() == 0) emailtemplate = repository + "/mail" + mailid;

         if(rs.value("template_type").equalsIgnoreCase("freemarker"))
            emailtemplate += ".ftl";

		System.out.println("Final Template : " + emailtemplate);
 
            fmodele = new FileInputStream(emailtemplate);

            if (toattach.indexOf("upload_mail") != -1) {

                String path = uploadFiles+parseNull(rs.value("form_id"))+"/"+rs.value(0);
                File folder = new File(path);
                File[] listOfFiles = folder.listFiles();
				if(listOfFiles != null)
				{
					for (int i = 0; i < listOfFiles.length; i++) {
						if (listOfFiles[i].isFile()) {
							atts.add(path+"/"+listOfFiles[i].getName());
						}
					}
				}
            }


            if (atts.size() > 0) {
                attachs = atts.toArray(new String[atts.size()]);
                for (int n = 0; n < attachs.length; n++) {
                    System.out.println("Attachs[" + n + "] = " + attachs[n]);
                }
            }

            return (send(fmodele, rs, sujet, attachs, etn));
        } catch (Exception e) {
            e.printStackTrace();
            if (debug) {
                System.out.println("MAIL: wid:" + wkid);
            }
            return (NO_CONNECTION);
        } finally {
            try {
                if (fmodele != null) {
                    fmodele.close();
                }
                if (out != null) {
                    out.close();
                }

                if (!flag && attachs != null) {
                    for (int n = 0; n < attachs.length; n++) {
                        if (attachs[n] != null) {
                            new File(attachs[n]).delete();
                        }
                    }
                }
            } catch (Exception ze) {
            }
        }


    }

    public int test(int wkid, String mailident) {
        int r, mailid = Integer.parseInt(mailident);
        FileInputStream fmodele = null;
        FileOutputStream out = null;
        ArrayList<String> atts = new ArrayList<String>();
        String attachs[] = null;
        String s;


        try {

            Set rs = null;
//System.out.println("################## in send");
            while (true) {
                rs =
                        etn.execute(s =
                        "select  p.*, c.* "
                        + " from post_work p inner join form_table c "
                        + " on p.client_key = c.form_table_id "
			   + " inner join process_forms pf on pf.form_id = c.form_id "
                        + " inner join mails m on m.id = " + mailid
                        + " left join mail_config a on  a.id = m.id and a.ordertype = pf.process_name "
                        + " where p.id = " + wkid);

                if (!rs.next()) {
                    return (NO_ROW);
                }

                // Analyse du where_clause
                s = rs.value("where_clause");
                if (s.length() == 0) {
                    break;
                }

                if ((r = getMailId(wkid, s, rs)) == mailid) {
                    break;
                }
                if (r <= 0) {
                    return (0);
                }
                mailid = r;
//System.out.println("################## in send : " + mailid);
            }


            // Destinataires
            if (setRecipients(rs) == 0) {
                return (NO_CONTACT); // nothing to do
            }

            // par defaut
            setFrom(env.getProperty("MAIL_FROM"), env.getProperty("MAIL_FROM_DISPLAY_NAME"));
            if(parseNull(env.getProperty("MAIL_REPLY")).length() > 0) setReply(env.getProperty("MAIL_REPLY"));


            String sujet = rs.value("sujet");
            String toattach = rs.value("attach");
//System.out.println("$$$$$$$$$$$$ mail repository " + repository);
            fmodele = new FileInputStream(repository + "/mail" + mailid);

            atts.add(new String(("/tmp/méditel.pdf").getBytes(), "UTF-8"));

            if (atts.size() > 0) {
                attachs = atts.toArray(new String[atts.size()]);
                for (int n = 0; n < attachs.length; n++) {
                    System.out.println("Attachs[" + n + "] = " + attachs[n]);
                }
            }



            return (send(fmodele, rs, sujet, attachs, etn));
        } catch (Exception e) {
            e.printStackTrace();
            if (debug) {
                System.out.println("MAIL: wid:" + wkid);
            }
            return (NO_CONNECTION);
        } finally {
            try {
                if (fmodele != null) {
                    fmodele.close();
                }
                if (out != null) {
                    out.close();
                }
                if (attachs != null) {
                    for (int n = 0; n < attachs.length; n++) {
                        if (attachs[n] != null) {
                            new File(attachs[n]).delete();
                        }
                    }
                }
            } catch (Exception ze) {
            }
        }
    }

    public static void main(String a[])
            throws Exception {

        String mailid;
        int wkid;
        String orderType = null, tosend = null;


        if (a.length == 0) {
            mailid = "20";
            wkid = 14183;
        } else if ("test".equals(a[0])) {
            if (a.length != 4) {
                System.exit(1);
            }
            mailid = a[1];
            tosend = a[2];
            orderType = a[3];
            wkid = 1;
        } else {
            mailid = a[0];
            wkid = Integer.parseInt(a[1]);
        }

        Properties p = new Properties();
        p.load(SendMail.class.getResourceAsStream("Scheduler.conf"));

        com.etn.Client.Impl.ClientDedie etn =
                new com.etn.Client.Impl.ClientDedie("MySql",
                "com.mysql.jdbc.Driver",
                p.getProperty("CONNECT"));

        if (tosend != null && orderType != null) {
            etn.execute("update customer "
                    + " set ordertype =" + escape.cote(orderType)
                    + ", email = " + escape.cote(tosend)
                    + " where customerid = 1 ");
        }

        SendMail sm = new SendMail(etn, p);
System.out.println("####### main send");

        int r = sm.send(wkid, mailid, false);
        System.out.println("" + r);
        System.exit(r);

    }
}