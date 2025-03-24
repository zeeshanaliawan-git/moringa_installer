package com.etn.eshop;


import java.util.List;
import java.util.ArrayList;
import java.util.Properties;
import java.util.Date;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.io.*;
import javax.mail.*;
import javax.mail.internet.*;
import java.text.SimpleDateFormat;
import com.etn.sql.escape;
import com.etn.lang.ResultSet.Set;
import com.etn.Client.Impl.ClientSql;
import com.etn.net.MailFromModel;


public class SendCalendar
{

    public static final String EVENT_TYPE_ASSIGN = "assign";
    public static final String EVENT_TYPE_CANCEL = "cancel";

    public static final String EVENT_EMAIL_CLIENT = "client";
    public static final String EVENT_EMAIL_RESOURCE = "resource";

    private ClientSql Etn;
    private Properties env;

    public boolean debug = false;

    public SendCalendar(ClientSql etn, Properties conf) throws Exception{
        this.Etn = etn;
        this.env = conf;

        if(parseNull(env.getProperty("CALENDAR_DIR")).length() == 0){
            throw new Exception("Error: CALENDAR_DIR not defined in properties.");
        }
    }

    private String parseNull(Object o)
    {
        if( o == null ) return("");
        String s = o.toString();
        if("null".equals(s.trim().toLowerCase())) return("");
        else return(s.trim());
    }

    int parseInt(Object o){
        return parseInt(o, 0);
    }

    int parseInt(Object o, int defaultValue){
        String s = parseNull(o);
        if(s.length() > 0 ){
            try{
                return Integer.parseInt(s);
            }
            catch(Exception e){
                return defaultValue;
            }
        }
        else{
            return defaultValue;
        }
    }

    public File getCalendarFile(int wkid, String type, String emailType) throws Exception{


        if(!SendCalendar.EVENT_TYPE_ASSIGN.equals(type)
            && !SendCalendar.EVENT_TYPE_CANCEL.equals(type)){

            throw new Exception("Error: Invalid type argument for calendar event");
        }


        if(!SendCalendar.EVENT_EMAIL_CLIENT.equals(emailType)
            && !SendCalendar.EVENT_EMAIL_RESOURCE.equals(emailType)){

            throw new Exception("Error: Invalid email recipient type argument for calendar event");
        }

/*        // TODO
        if(type.equals(SendCalendar.EVENT_TYPE_CANCEL) && emailType.equals(SendCalendar.EVENT_EMAIL_RESOURCE)){
            // event cancel  reasource email
            //unassigned resource is not available at this point,
            // so cant generate calendar event correctly
            return null;
        }*/


        BufferedWriter bw = null;
        FileInputStream fmodele = null;

        try
        {

            // String query = " SELECT r.email AS resource_email, oi.id AS clid,  oi.* "
            //                 + " FROM order_items oi "
            //                 + " INNER JOIN post_work pw ON pw.client_key = oi.id "
            //                 + " INNER JOIN "+env.getProperty("CATALOG_DB")+".products p ON p.product_uuid = oi.product_ref "
            //                 + " INNER JOIN "+env.getProperty("CATALOG_DB")+".resources r ON oi.resource = r.name "
            //                 + " WHERE pw.id = " + wkid;

            String recipientEmailColumn = " c.email ";
            if( emailType.equals(SendCalendar.EVENT_EMAIL_RESOURCE)){
                recipientEmailColumn = " r.email ";
            }

            String query = " SELECT c.* , c.customerid AS clid, "+ recipientEmailColumn + " AS calendar_email "
                            + " FROM customer c "
                            + " INNER JOIN post_work pw ON pw.client_key = c.customerid "
                            + " LEFT OUTER JOIN "+env.getProperty("CATALOG_DB")+".resources r ON c.resource = r.name "
                            + " WHERE pw.id = " + wkid;


            System.out.println(query);//debug
            Set rs = Etn.execute(query);

            if(rs.rs.Rows == 0){
                throw new Exception("Error: no order item record found for the wkid");
            }

            rs.next();

            String clid = parseNull(rs.value("clid"));

            String calendarEmail = parseNull(rs.value("calendar_email"));

            String product_name = parseNull(rs.value("product_name"));
            String product_type = parseNull(rs.value("product_type"));

            String service_date     = parseNull(rs.value("service_date"));
            String service_end_date = parseNull(rs.value("service_end_date"));

            int service_start_time  = parseInt(rs.value("service_start_time"));
            int service_duration    = parseInt(rs.value("service_duration"));
            int quantity            = parseInt(rs.value("quantity"));

            if(calendarEmail.trim().length() == 0){
		  //return null so that original email goes out
		  System.out.println("ERROR::No email provided for calendar event. wkid : " + wkid);
                return null;
            }

            if(service_end_date.trim().length() == 0){
                service_end_date = service_date;
            }


            SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy");
            GregorianCalendar gCal = new GregorianCalendar();

            int startTimeHour = service_start_time / 60;
            int startTimeMinutes = service_start_time % 60;

            String UID = clid;

            String summary = "Service Appointment for "+ product_name;
            String description = "Service Appointment for '"+product_name+"'";

            if( emailType.equals(SendCalendar.EVENT_EMAIL_RESOURCE)){
		  summary = product_name + " by " + parseNull(rs.value("resource")) + " for customer " + parseNull(rs.value("name")) + " " + parseNull(rs.value("surnames"));
                description += "\nCustomer name : " + parseNull(rs.value("name")) + " " + parseNull(rs.value("surnames"));
                if(parseNull(rs.value("email")).length() > 0) description += "\nEmail : " + parseNull(rs.value("email"));
                if(parseNull(rs.value("contactPhoneNumber1")).length() > 0) description += "\nPhone : " + parseNull(rs.value("contactPhoneNumber1"));
		  if(parseNull(rs.value("secondary_resource")).length() > 0) description += "\nRoom : " + parseNull(rs.value("secondary_resource"));
            }

            gCal.clear();
            gCal.setTime(dateFormat.parse(service_date));
            gCal.set(Calendar.HOUR_OF_DAY, startTimeHour);
            gCal.set(Calendar.MINUTE, startTimeMinutes);
            gCal.set(Calendar.SECOND, 0);

            Date startDateTime = gCal.getTime();

            int endTimeHour = (service_start_time + (service_duration * quantity)) / 60;
            int endTimeMinutes = (service_start_time + (service_duration * quantity)) % 60;

            gCal.clear();
            gCal.setTime(dateFormat.parse(service_end_date));
            gCal.set(Calendar.HOUR_OF_DAY, endTimeHour);
            gCal.set(Calendar.MINUTE, endTimeMinutes);
            gCal.set(Calendar.SECOND, 0);

            Date endDateTime = gCal.getTime();

            String calFileContent = getCalendarFileContent(UID, type, calendarEmail,
                startDateTime, endDateTime, summary, description );
            //debug
            System.out.println("======Calendar file content: \n" + calFileContent);

            String directoryPath = parseNull(this.env.getProperty("CALENDAR_DIR"));

            if(directoryPath.length() == 0){
                throw new Exception("Calendar file directory not specified in conf.");
            }

            File directory  = new File(directoryPath);
            if(directory.isDirectory() && !directory.exists()){
                directory.mkdirs();
            }

            String filePath = directoryPath + "/"+wkid + ".ics";
            File icsFile = new File(filePath);

            bw = new BufferedWriter(new OutputStreamWriter(
                                    new FileOutputStream(icsFile),"UTF-8"));
            bw.write(calFileContent);
            return icsFile;
        }
        finally{
            if(bw != null){
                try{ bw.close(); }catch(Exception e){}
            }
            if(fmodele != null){
                try{ fmodele.close(); }catch(Exception e){}
            }
        }
    }

    public String getCalendarFileContent(String UID, String type, String email,
                                            Date startDateTime, Date endDateTime,
                                            String summary, String description) throws Exception {

        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd'T'HHmmss");

        SimpleDateFormat dateFormat2 = new SimpleDateFormat("yyyyMMdd");

        Date startDate = dateFormat2.parse(dateFormat2.format(startDateTime));

        Date now = new Date();

        String eventSequence = "0";
        String eventStatus = "CONFIRMED";
        if(SendCalendar.EVENT_TYPE_CANCEL.equals(type)){
            eventSequence = "10";
            eventStatus = "CANCELLED";
        }

        email = email.trim();
        String emails[] = {email};
        if(email.contains(":")){
            emails = email.split(":");
        }

        String attendeeStr = "";
        for(String curEmail : emails){
            attendeeStr += "ATTENDEE;CUTYPE=INDIVIDUAL;ROLE=REQ-PARTICIPANT;PARTSTAT=ACCEPTED;CN="+curEmail+";X-NUM-GUESTS=0:mailto:"+curEmail+"\n";
        }



        String calStr = ""
            +"BEGIN:VCALENDAR\n"
            +"PRODID:-//"+parseNull(env.getProperty("CALENDAR_NAME"))+"\n"
            +"VERSION:2.0\n"
            +"CALSCALE:GREGORIAN\n"
            +"METHOD:PUBLISH\n"
            +"BEGIN:VEVENT\n"
            +"DTSTART:"+dateFormat.format(startDateTime)+"\n"
            +"DTEND:"+dateFormat.format(endDateTime)+"\n"
            +"DTSTAMP:"+dateFormat.format(startDate)+"\n"
            +"UID:"+UID+"@asimina.com\n"
            + attendeeStr
            +"CREATED:"+dateFormat.format(now)+"\n"
            +"DESCRIPTION: "+description.replace("\n","\\n")+"\n"
            +"LAST-MODIFIED:"+dateFormat.format(now)+"\n"
            // +"LOCATION:Lahore Pakistan\n"
            +"SEQUENCE:"+eventSequence+"\n"
            +"STATUS:"+eventStatus+"\n"
            +"SUMMARY:"+summary.replace("\n","")+"\n"
            +"TRANSP:OPAQUE\n"
            +"END:VEVENT\n"
            +"END:VCALENDAR\n";
        return calStr;
    }

    public static void main(String a[]) throws Exception {

        System.out.println("### main start");

        //wkid = post_work id
        int wkid = 0;
        String type = null;
        String emailType = null;


        if (a.length == 0) {
            wkid = 5346;
            type = SendCalendar.EVENT_TYPE_ASSIGN;
            emailType = SendCalendar.EVENT_EMAIL_RESOURCE;
        }
        else if("test".equals(a[0]) ){

            wkid    = Integer.parseInt(a[1]);
            type    = a[2];
            emailType = a[3];
        }

        Properties p = new Properties();
        p.load(SendMail.class.getResourceAsStream("Scheduler.conf"));

        com.etn.Client.Impl.ClientDedie etn =
                new com.etn.Client.Impl.ClientDedie("MySql",
                "com.mysql.jdbc.Driver",
                p.getProperty("CONNECT"));



        SendCalendar  sc = new SendCalendar(etn, p);

        File file = sc.getCalendarFile(wkid, type, emailType);

        if(file != null)
        System.out.println("" + file.getAbsolutePath());

        System.out.println("### main end");
        System.exit(0);

    }

}