<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, com.etn.pages.*, org.json.JSONObject,
com.etn.asimina.util.ActivityLog, org.json.JSONArray, java.util.LinkedHashMap,java.util.HashMap, java.util.HashSet"%>
<%@ include file="pagesUtil.jsp"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%
    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    int status = STATUS_ERROR;
    String message = "";
    JSONObject data = new JSONObject();

    LinkedHashMap<String, String> colValueHM = new LinkedHashMap<String,String>();

    String q = "";
    Set rs = null;
    int count = 0;

    String requestType = parseNull(request.getParameter("requestType"));

	try{

	    if("getRssFeedsList".equalsIgnoreCase(requestType)){
	    	try{

	    		JSONArray feedList = new JSONArray();

				q = " SELECT r.id, r.name, r.last_sync_ts, r.updated_ts , l.name updated_by"
                    + " , IFNULL(ri.nb_items,0) AS nb_items "
	                + " , IF(r.is_active=1,'active','in-active') AS status "
                    + " FROM rss_feeds r "
                    + " LEFT JOIN login l on l.pid =  r.updated_by"
                    + " LEFT JOIN ( SELECT rss_feed_id, COUNT(0) AS nb_items "
                    + "     FROM rss_feeds_items "
                    + "     GROUP BY rss_feed_id "
                    + " ) AS ri ON ri.rss_feed_id = r.id "
	                + " WHERE r.site_id = " + escape.cote(getSiteId(session));
				rs = Etn.execute(q);

                JSONObject curObj = null;
				while(rs.next()){
					curObj = new JSONObject();
					for(String colName : rs.ColName){
						curObj.put(colName.toLowerCase(), rs.value(colName));
					}

					feedList.put(curObj);
				}

				data.put("rssFeeds",feedList);
				status = STATUS_SUCCESS;

	    	}//try
	    	catch(Exception ex){
				throw new SimpleException("Error in getting rss feeds list. Please try again.",ex);
	    	}
	    }
        else if("getRssFeedItemsList".equalsIgnoreCase(requestType)){
            try{
                String feedId = parseNull(request.getParameter("id"));

                q = "SELECT id FROM rss_feeds "
                    + " WHERE id = " + escape.cote(feedId)
                    + " AND site_id = "+ escape.cote(getSiteId(session));

                rs = Etn.execute(q);
                if(!rs.next()){
                    throw new SimpleException("Invalid params");
                }

                JSONArray itemsList = new JSONArray();
                q = "SELECT id, title, link, updated_ts, pubDate_std "
                    + " , IF(is_active=1,'active','in-active') AS status "
                    + " FROM rss_feeds_items "
                    + " WHERE rss_feed_id = " + escape.cote(feedId);
                rs = Etn.execute(q);

                JSONObject curObj = null;
                while(rs.next()){
                    curObj = new JSONObject();
                    for(String colName : rs.ColName){
                        curObj.put(colName.toLowerCase(), rs.value(colName));
                    }

                    itemsList.put(curObj);
                }

                data.put("items",itemsList);
                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting rss feed items list. Please try again.",ex);
            }
        }
        else if("getItemInfo".equalsIgnoreCase(requestType)){
            try{

                String id = parseNull(request.getParameter("id"));

                JSONObject infoObj = new JSONObject();

                q = "SELECT ri.* "
                    + " FROM rss_feeds_items AS ri "
                    + " JOIN rss_feeds AS r ON r.id = ri.rss_feed_id "
                    + " WHERE ri.id = " + escape.cote(id)
                    + " AND r.site_id = "+ escape.cote(getSiteId(session));
                rs = Etn.execute(q);
                if(rs.next()){

                    for(String colName : PagesUtil.FEED_ITEM_FIELDS){
                        infoObj.put(colName, rs.value(colName));
                    }

                    infoObj.put("created_ts",rs.value("created_ts"));
                    infoObj.put("updated_ts",rs.value("updated_ts"));

	                JSONObject extraParams = null;
	                try{
	                    extraParams = new JSONObject(rs.value("extra_params"));
	                }
	                catch(Exception tempEx){ }

                	if(extraParams != null && JSONObject.getNames(extraParams) != null){
	                    for(String name : JSONObject.getNames(extraParams)){
	                        infoObj.put(name, extraParams.get(name));
	                    }
	                }

	                data.put("item",infoObj);
	                status = STATUS_SUCCESS;
                }

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting rss feed info. Please try again.",ex);
            }
        }
        else if("getRssFeedInfo".equalsIgnoreCase(requestType)){
            try{

                String id = parseNull(request.getParameter("id"));

                JSONObject infoObj = new JSONObject();
                JSONObject channelObj = new JSONObject();

                q = "SELECT * FROM rss_feeds "
                    + " WHERE id = " + escape.cote(id);
                rs = Etn.execute(q);
                if(rs.next()){
                    for(String colName : rs.ColName){
                        String colNameLower = colName.toLowerCase();
                        if(colNameLower.startsWith("ch_")){
                        	continue;
                        }
                        else{
                            infoObj.put(colNameLower, rs.value(colName));
                        }
                    }

                    for(String field : PagesUtil.FEED_CHANNEL_FIELDS){
                    	String colName = "ch_"+field;
                        channelObj.put(field, rs.value(colName));

                    }

                    JSONObject extraParams = null;
                    try{
                    	String extraParamsStr = rs.value("ch_extra_params");
                    	extraParamsStr = decodeJSONStringDB(extraParamsStr);

                        extraParams = new JSONObject(extraParamsStr);
                    }
                    catch(Exception tempEx){ }

                    if(extraParams != null && JSONObject.getNames(extraParams) != null){
                        for(String name : JSONObject.getNames(extraParams)){
                            channelObj.put(name, extraParams.getString(name));
                        }
                    }
                }
                infoObj.put("channel",channelObj);
                data = infoObj;
                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting rss feed info. Please try again.",ex);
            }
        }
        else if("saveRssFeed".equalsIgnoreCase(requestType)){
            try{

                String id = parseNull(request.getParameter("id"));
                String name = parseNull(request.getParameter("name"));
                String url = parseNull(request.getParameter("url"));
                String max_items = parseNull(request.getParameter("max_items"));
                String activation_type = parseNull(request.getParameter("activation_type"));
                String sync_frequency = parseNull(request.getParameter("sync_frequency"));
                String sync_frequency_unit = parseNull(request.getParameter("sync_frequency_unit"));
                String sync_type = parseNull(request.getParameter("sync_type"));


                q = "SELECT id FROM rss_feeds "
                    + " WHERE url = " + escape.cote(url)
                    + " AND site_id = " + escape.cote(getSiteId(session));
                if(id.length() > 0){
                    q += " AND id != " + escape.cote(id);
                }

                rs = Etn.execute(q);
                if(rs.next()){
                    throw new SimpleException("Error: Duplicate URL. Feed with this URL already exists.");
                }

                colValueHM.put("name",escape.cote(name));
                colValueHM.put("url",escape.cote(url));
                colValueHM.put("max_items",escape.cote(max_items));
                colValueHM.put("activation_type",escape.cote(activation_type));
                colValueHM.put("sync_frequency",escape.cote(sync_frequency));
                colValueHM.put("sync_frequency_unit",escape.cote(sync_frequency_unit));
                colValueHM.put("sync_type",escape.cote(sync_type));
                colValueHM.put("updated_ts","NOW()");
                colValueHM.put("updated_by",""+Etn.getId());

                if(id.length() == 0){

                    colValueHM.put("site_id",escape.cote(getSiteId(session)));

                    colValueHM.put("last_sync_ts","'2018-01-01'");//fixed past date

                    colValueHM.put("created_ts","NOW()");
                    colValueHM.put("created_by",""+Etn.getId());

                    q = getInsertQuery("rss_feeds",colValueHM);

                    count = Etn.executeCmd(q);
                    if(count <= 0){
                        throw new SimpleException("Error in adding new rss feed record.");
                    }

                    id = ""+count;
                    ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),id,"CREATED","RSS feeds",name,getSiteId(session));

                }
                else{

                    q = getUpdateQuery("rss_feeds", colValueHM,
                            " WHERE id = " + escape.cote(id)
                            + " AND site_id = " + escape.cote(getSiteId(session)) );

                    count = Etn.executeCmd(q);
                    if(count <= 0){
                        throw new SimpleException("Error in updating rss feed record.");
                    }
                    ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),id,"UPDATED","RSS feeds",name,getSiteId(session));

                }

                data.put("id",id);
                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting rss feeds list. Please try again.",ex);
            }
        }
        else if("deleteRssFeed".equalsIgnoreCase(requestType)){
            try{

                String feedIds = parseNull(request.getParameter("id"));
                String names = "";
                int deletedFeedsCount = 0;
                for(String feedId : feedIds.split(",")){
                    q = "SELECT name FROM rss_feeds WHERE id = " + escape.cote(feedId)
                                       + " AND site_id = " + escape.cote(getSiteId(session));
                    rs =  Etn.execute(q);
                    if(!rs.next()){
                        throw new Exception("Invalid feed ID");
                    }

                    names  += rs.value("name");

                    //delete child items
                    q = "DELETE FROM rss_feeds_items "
                        + " WHERE rss_feed_id = " + escape.cote(feedId);
                    Etn.executeCmd(q);

                    q = "DELETE FROM rss_feeds "
                        + " WHERE id = " + escape.cote(feedId)
                        + " AND site_id = " + escape.cote(getSiteId(session));
                    count = Etn.executeCmd(q);
                    deletedFeedsCount++;
                }
                status = STATUS_SUCCESS;
                message = deletedFeedsCount+" RSS feeds deleted";
                ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),feedIds,"DELETED","RSS feeds",names, getSiteId(session));
            }//try
            catch(Exception ex){
                throw new SimpleException("Error in deleting rss feed. Please try again.",ex);
            }
        }
        else if("deleteFeedItem".equalsIgnoreCase(requestType)){
            try{

                String itemId = parseNull(request.getParameter("id"));

                q = "SELECT i.title FROM rss_feeds_items i "
                    + " JOIN rss_feeds f ON f.id = i.rss_feed_id "
                    + " WHERE i.id = " + escape.cote(itemId)
                    + " AND f.site_id = " + escape.cote(getSiteId(session));
                rs =  Etn.execute(q);
                if(!rs.next()){
                    throw new SimpleException("Invalid feed ID.");
                }

                String name = rs.value("title");

                //delete child items
                q = "DELETE i FROM rss_feeds_items i "
                    + " JOIN rss_feeds f ON f.id = i.rss_feed_id "
                    + " WHERE i.id = " + escape.cote(itemId)
                    + " AND f.site_id = " + escape.cote(getSiteId(session));
                count = Etn.executeCmd(q);

                status = STATUS_SUCCESS;
                ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),itemId,"DELETED","RSS feeds Item",name,getSiteId(session));

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in deleting rss feed. Please try again.",ex);
            }
        }
        else if("importRssFeed".equalsIgnoreCase(requestType)){
            try{

                String feedId = parseNull(request.getParameter("id"));

                try{
                	RssFeedImporter rssFeedImporter = new RssFeedImporter(Etn);
                	rssFeedImporter.importRssFeed(feedId);

                	status = STATUS_SUCCESS;
                }
                catch(Exception ex){
                    ex.printStackTrace();
                	message = ex.getMessage();
                }

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in importing rss feed. Please try again.",ex);
            }
        }
        else if("setFeedsStatus".equalsIgnoreCase(requestType)){
            try{

                String isActive = parseNull(request.getParameter("status"));
                String ids = parseNull(request.getParameter("ids"));

                isActive = "1".equals(isActive)?"1":"0";
                String names = "";
                for(String feedId : ids.split(",")){
                    q = "SELECT name FROM rss_feeds WHERE id = " + escape.cote(feedId)
                               + " AND site_id = " + escape.cote(getSiteId(session));
                    rs =  Etn.execute(q);
                    rs.next();
                    names += parseNull(rs.value(0)) + ", ";

                    q = "UPDATE rss_feeds SET is_active = " + escape.cote(isActive)
                    + " WHERE id = " + escape.cote(feedId);
                    Etn.executeCmd(q);
                }

                ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),ids,
                    ("1".equals(isActive)?"ACTIVATED":"DEACTIVATE"), "RSS feeds",names,getSiteId(session));

                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in setting rss feeds status. Please try again.",ex);
            }
        }
        else if("setFeedItemsStatus".equalsIgnoreCase(requestType)){
            try{

                String isActive = parseNull(request.getParameter("status"));
                String feedId = parseNull(request.getParameter("feedId"));
                String ids = parseNull(request.getParameter("ids"));

                isActive = "1".equals(isActive)?"1":"0";

                q = "SELECT name FROM rss_feeds WHERE id = " + escape.cote(feedId)
                           + " AND site_id = " + escape.cote(getSiteId(session));
                rs =  Etn.execute(q);
                rs.next();
                String feedName = parseNull(rs.value(0));

                for(String itemId : ids.split(",")){

                    q = "UPDATE rss_feeds_items SET is_active = " + escape.cote(isActive)
                        + " WHERE id = " + escape.cote(itemId)
                        + " AND rss_feed_id = " + escape.cote(feedId);
                    Etn.executeCmd(q);
                }


                ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),feedId,
                        ("1".equals(isActive)?"ACTIVATED":"DEACTIVATE"),"RSS feeds Items",feedName,getSiteId(session));

                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in setting feed items status. Please try again.",ex);
            }
        }

    }
	catch(SimpleException ex){
		message = ex.getMessage();
		ex.print();
	}

    JSONObject jsonResponse = new JSONObject();
    jsonResponse.put("status",status);
    jsonResponse.put("message",message);
    jsonResponse.put("data",data);
   	out.write(jsonResponse.toString());
%>
