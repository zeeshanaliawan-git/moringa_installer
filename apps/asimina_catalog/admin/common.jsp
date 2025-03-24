<%-- Reviewed By Awais --%>
<%!
	String getProcess(String ty)
	{
		String process = ty;
		if("tarif".equalsIgnoreCase(ty)) process = "tarifs";
		else if("device".equalsIgnoreCase(ty)) process = "devices";
		else if("translation".equalsIgnoreCase(ty)) process = "translations";
		else if("accessory".equalsIgnoreCase(ty)) process = "accessories";
		else if("faq".equalsIgnoreCase(ty)) process = "faqs";
		else if("catalog".equalsIgnoreCase(ty)) process = "catalogs";
		else if("product".equalsIgnoreCase(ty)) process = "products";
		else if("familie".equalsIgnoreCase(ty)) process = "families";
		else if("shop".equalsIgnoreCase(ty)) process = "shop";
		else if("resources".equalsIgnoreCase(ty)) process = "resources";
		else if("subsidy".equalsIgnoreCase(ty)) process = "subsidies";
		else if("promotion".equalsIgnoreCase(ty)) process = "promotions";
		else if("cartrule".equalsIgnoreCase(ty)) process = "cartrules";
		else if("additionalfee".equalsIgnoreCase(ty)) process = "additionalfees";
		else if("comewith".equalsIgnoreCase(ty)) process = "comewiths";
		else if("deliveryfee".equalsIgnoreCase(ty)) process = "deliveryfees";
		else if("deliverymin".equalsIgnoreCase(ty)) process = "deliverymins";
		else if("quantitylimit".equalsIgnoreCase(ty)) process = "quantitylimits";
		return process;
	}
	
	boolean movephase(com.etn.beans.Contexte Etn, String clid, String process, String phase, String on)
	{
		boolean succ = false;
		String qrys[] = new String[3];
		qrys[0] = "set @curid = 0";
		qrys[1] = "update post_work set status = 1, id = @curid := id where status = 0 and client_key = "+com.etn.sql.escape.cote(clid)+" and proces = " +com.etn.sql.escape.cote(process);
		qrys[2] = "select @curid as lastLineId ";
		Set rs = Etn.execute(qrys);
		int lastLineId = 0;
		if(rs.next() && rs.next() && rs.next()) lastLineId = Integer.parseInt(rs.value(0));

		//check engine already started work
		if(lastLineId <= 0)
		{
			Set rs3 = Etn.execute("select * from post_work where client_key = "+com.etn.sql.escape.cote(clid)+" and proces = " +com.etn.sql.escape.cote(process));
			//there are rows in post_work for this process and client_key so if lastLineId <= 0 means engine already started work
			if(rs3.rs.Rows > 0) return false;
		}

		String q = "insert into post_work (proces, phase, client_key, insertion_date, priority, operador) values (";
		q += com.etn.sql.escape.cote(process);
		q += "," + com.etn.sql.escape.cote(phase);
		q += "," + com.etn.sql.escape.cote(clid);
		q += ", now() ";
		if(on.equals("-1")) q += ", now() ";
		else q += ", " + com.etn.sql.escape.cote(on);
		q += "," + com.etn.sql.escape.cote(Etn.getId()+"");
		q += " ) " ;
		int r = Etn.executeCmd(q);

		if(r > 0)
		{
			succ = true;
			Etn.executeCmd("update post_work set attempt = attempt + 1, status = 2, start = now(), end= now(), nextid = "+r+" where id = " + escape.cote(""+lastLineId));//change
		}
		else
		{
			Etn.executeCmd("update post_work set status = 0 where id = " + escape.cote(""+lastLineId));//change
		}
		return succ;
	}

    /**
    *  returns [ publishStatus, lastpublish_date]
    */
    String[] getCatalogPublishStatus(com.etn.beans.Contexte Etn,
                String catalogId, String preprodVersion) throws java.text.ParseException{
        // "unpublished","published", "changed"

        String pubStatus = "unpublished";//red
        String lastpublish = "";
		String prodVersion = "";
		String userName = "";

        String process = getProcess("catalog");
        String prodDb = com.etn.beans.app.GlobalParm.getParm("PROD_DB") + ".";

        Set rs = Etn.execute("SELECT date_format(p.priority, '%d/%m/%Y %H:%i:%s') AS _dt, c.version , IFNULL(l.name,'') as user_name "
            + " FROM post_work p"
            + " JOIN "+prodDb+"catalogs c ON c.id = p.client_key AND c.id = " + escape.cote(catalogId)
            + " JOIN post_work pw on pw.nextid = p.id"
            + " LEFT JOIN login l on l.pid = pw.operador"
            + " WHERE p.status in (0,2) "
            + " AND p.phase = 'published' "
            //+ " AND p.client_key = " + escape.cote(catalogId)
            + " AND p.proces = "+escape.cote(process)
            + " ORDER by p.id desc limit 1 ");
        if(rs.next()){
            lastpublish = rs.value("_dt").trim();
			prodVersion = rs.value("version");
			userName = rs.value("user_name");
        }

	if(prodVersion.length() == 0)
	{
		pubStatus = "unpublished";
		lastpublish = "";
	}
	else if(prodVersion.equals(preprodVersion)) pubStatus = "published"; //green
	else pubStatus = "changed";

        String retArr[] = new String[3];
        retArr[0] = pubStatus;
        retArr[1] = lastpublish;
        retArr[2] = userName;
        return retArr;
    }
%>