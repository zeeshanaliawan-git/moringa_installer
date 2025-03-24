/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.etn.pages;

import com.etn.beans.Etn;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import org.json.JSONObject;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * To import and update RSS feed and its item entities
 * in the pages module database
 *
 * @author Ali Adnan
 * @since 2019-06-01
 */
public class RssFeedImporter extends BaseClass {

    public RssFeedImporter(Etn Etn, Properties env, boolean debug) {
        super(Etn, env, debug);
    }

    public RssFeedImporter(Etn Etn) {
        super(Etn);
    }

    public void importFeeds() throws Exception {
        getParm("BASE_DIR"); //testing env

        String q;
        Set rs;

        try {
            q = "SELECT id , now() , next_sync_ts "
                + " FROM ("
                + "   SELECT id, last_sync_ts, sync_frequency, sync_frequency_unit,  "
                + "   CASE sync_frequency_unit"
                + "     WHEN 'minute' THEN date_add(last_sync_ts, INTERVAL sync_frequency MINUTE)"
                + "     WHEN 'hour' THEN date_add(last_sync_ts, INTERVAL sync_frequency HOUR)"
                + "     WHEN 'day' THEN date_add(last_sync_ts, INTERVAL sync_frequency DAY)"
                + "   END AS next_sync_ts"
                + "   FROM rss_feeds "
                + "   WHERE sync_frequency > 0 AND is_active = '1' ) AS rf "
                + " WHERE rf.next_sync_ts < NOW() ";

            rs = Etn.execute(q);

            if (debug && rs.rs.Rows > 0) {
                System.out.println("****** Importing " + rs.rs.Rows + " RSS feeds");
            }
            while (rs.next()) {

                String feedId = rs.value("id");
                if (debug && rs.rs.Rows > 0) {
                    System.out.println("Feed ID : " + feedId);
                }

                try {

                    importRssFeed(feedId);
                }
                catch (Exception ex) {
                    System.out.println(ex.getMessage());
                    ex.printStackTrace();
                }
            }
        }
        finally {

        }

    }

    public void importRssFeed(String feedId) throws Exception {
        String q;
        Set rs;
        HashMap<String,String> colValueHM = new HashMap<>();

        q = " SELECT id, url, max_items,activation_type, sync_frequency, sync_type "
            + " FROM rss_feeds "
            + " WHERE id = " + escape.cote(feedId);
        rs = Etn.execute(q);

        if (!rs.next()) {
            throw new Exception("Invalid feed ID.");
        }

        String activationType = rs.value("activation_type");
        String syncType = rs.value("sync_type");
        int maxItems = PagesUtil.parseInt(rs.value("max_items"));

        try {

            String rssUrl = rs.value("url");
            RssReader rss = new RssReader(env);
            rss.parseRssFromUrl(rssUrl);

            HashMap<String,String> channel = rss.getChannelInfo();

            String title = channel.get("title");
            String link = channel.get("link");
            String description = channel.get("description");

            if (title == null || link == null || description == null) {
                throw new Exception("Invalid RSS xml. Required info missing from channel.");
            }

            //process items first
            HashSet<String> itemFieldsHS = new HashSet<>();
            itemFieldsHS.addAll(Arrays.asList(PagesUtil.FEED_ITEM_FIELDS));

            String itemsErrorText = insertUpdateFeedItems(feedId, syncType, activationType,
                                                          maxItems, rss.getItemsList(), itemFieldsHS);

            if (itemsErrorText.length() > 0) {
                throw new Exception("Error in item(s) : \n" + itemsErrorText);
            }

            //no error in items
            //process channel info
            HashSet<String> chFieldsHS = new HashSet<>();

            for (String field : PagesUtil.FEED_CHANNEL_FIELDS) {
                chFieldsHS.add(field);
                colValueHM.put("ch_" + field, escape.cote(PagesUtil.parseNull(channel.get(field))));
            }

            JSONObject extraParams = new JSONObject();
            for (String key : channel.keySet()) {
                if (!chFieldsHS.contains(key)) {
                    extraParams.put(key, channel.get(key));
                }
            }
            colValueHM.put("ch_extra_params",
                           escape.cote(PagesUtil.encodeJSONStringDB(extraParams.toString())));

            colValueHM.put("last_sync_ts", "NOW()");
            colValueHM.put("is_error", escape.cote("0"));
            colValueHM.put("error_text", escape.cote(""));

            q = PagesUtil.getUpdateQuery("rss_feeds", colValueHM, "WHERE id = " + escape.cote(feedId));
            Etn.executeCmd(q);

            //now mark associated pages to generate
            PagesUtil.markFeedAssociatedPagesToGenerate(Etn, feedId);

        }
        catch (Exception ex) {
            String errorText = ex.toString();

            colValueHM.clear();
            colValueHM.put("is_error", "1");
            colValueHM.put("error_text", escape.cote(errorText));

            q = PagesUtil.getUpdateQuery("rss_feeds", colValueHM, " WHERE id = " + escape.cote(feedId));
            Etn.executeCmd(q);

            throw new Exception("Error in importing feed. " + ex.toString(), ex);
        }
    }

    private String insertUpdateFeedItems(String feedId, String syncType, String activationType,
                                         int maxItems, ArrayList<HashMap<String,String>> itemsList, HashSet<String> itemFields) {

        String errorText = "";

        String q = "";
        Set rs = null;

        HashMap<String,String> colValueHM = new HashMap<>();
        ArrayList<String> itemQueries = new ArrayList<>();

        SimpleDateFormat rssDateFormat
            = new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss zzz", Locale.ENGLISH);
        SimpleDateFormat stdDf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

        //NOTE: iterating in reverse
        // so that items are inserted in reverse order in db
        // so the auto increment id can be used a 2nd alternate to
        // sorting by date
        for (int i = itemsList.size() - 1; i >= 0; i--) {

            HashMap<String,String> item = itemsList.get(i);
            try {

                String title = item.get("title");
                String link = item.get("link");
                String description = item.get("description");

                if (title == null || link == null || description == null) {
                    errorText += "Required fields missing in item.\n";
                    continue;
                }

                colValueHM.clear();

                for (String colName : itemFields) {
                    colValueHM.put(colName, escape.cote(PagesUtil.parseNull(item.get(colName))));
                }

                //convert pubDate to standard datetime
                String pubDate_std = "2000-01-01 00:00:00";
                try {
                    String pubDateStr = PagesUtil.parseNull(item.get("pubDate"));
                    Date pubDate = rssDateFormat.parse(pubDateStr);
                    pubDate_std = stdDf.format(pubDate);
                }
                catch (ParseException parseEx) {
                    //parseEx.printStackTrace();
                }
                colValueHM.put("pubDate_std", escape.cote(pubDate_std));

                //extra_params
                JSONObject extraParams = new JSONObject();
                for (String key : item.keySet()) {
                    if (!itemFields.contains(key)) {
                        extraParams.put(key, item.get(key));
                    }
                }
                colValueHM.put("extra_params",
                               escape.cote(PagesUtil.encodeJSONStringDB(extraParams.toString())));

                boolean insertNewRecord = false;

                if ("delete".equals(syncType)) {
                    //delete all existing and add new items
                    insertNewRecord = true;
                }
                else if ("update".equals(syncType)) {
                    //update the existing items
                    //keep old items no longer in field

                    String itemId = "";
                    //search based on guid
                    String guid = PagesUtil.parseNull(item.get("guid"));

                    if (guid.length() > 0) {
                        q = "SELECT id FROM rss_feeds_items "
                            + " WHERE rss_feed_id = " + escape.cote(feedId)
                            + " AND guid = " + escape.cote(guid);

                        rs = Etn.execute(q);

                        if (rs.next()) {
                            itemId = rs.value("id");
                        }
                    }

                    if (itemId.length() == 0) {
                        //search based on title + link
                        q = "SELECT id FROM rss_feeds_items "
                            + " WHERE rss_feed_id = " + escape.cote(feedId)
                            + " AND title = " + escape.cote(title)
                            + " AND link = " + escape.cote(link);

                        rs = Etn.execute(q);

                        if (rs.next()) {
                            itemId = rs.value("id");
                        }
                    }

                    if (itemId.length() > 0) {

                        colValueHM.put("updated_ts", "NOW()");
                        q = PagesUtil.getUpdateQuery("rss_feeds_items", colValueHM,
                                                     "WHERE id = " + escape.cote(itemId));
                        itemQueries.add(q);
                    }
                    else {

                        insertNewRecord = true;
                    }

                }
                else if ("duplicate".equals(syncType)) {
                    //you keep all old item
                    // and  reimport the feed by duplicating existing items
                    insertNewRecord = true;
                }

                if (insertNewRecord) {

                    //insert new item record
                    colValueHM.put("rss_feed_id", escape.cote(feedId));
                    colValueHM.put("created_ts", "NOW()");
                    colValueHM.put("updated_ts", "NOW()");

                    String isActive = "1";
                    if ("never".equals(activationType)) {
                        isActive = "0";
                    }
                    colValueHM.put("is_active", escape.cote(isActive));

                    q = PagesUtil.getInsertQuery("rss_feeds_items", colValueHM);
                    itemQueries.add(q);
                }

            }
            catch (Exception ex) {
                errorText += ex.toString() + "\n";
            }

        }

        if (errorText.length() == 0) {
            //if no error in any item
            //only then import new items

            if ("delete".equals(syncType)) {
                //delete all existing
                q = "DELETE FROM rss_feeds_items "
                    + " WHERE rss_feed_id = " + escape.cote(feedId);
                Etn.executeCmd(q);
            }

            for (String query : itemQueries) {
                Etn.executeCmd(query);
            }

        }

        if (maxItems > 0) {
            //delete extra items
            // delete oldest by updated_ts, id
            q = "SELECT COUNT(0) as total FROM rss_feeds_items "
                + " WHERE rss_feed_id = " + escape.cote(feedId);
            rs = Etn.execute(q);
            int total = 0;
            if (rs.next()) {
                total = PagesUtil.parseInt(rs.value("total"));
            }

            int diff = (total - maxItems);
            if (diff > 0) {
                q = "SELECT id FROM rss_feeds_items "
                    + " WHERE rss_feed_id = " + escape.cote(feedId)
                    + " ORDER BY updated_ts DESC, id DESC "
                    + " LIMIT " + diff;
                rs = Etn.execute(q);
                while (rs.next()) {
                    q = "DELETE FROM rss_feeds_items "
                        + " WHERE id = " + escape.cote(rs.value("id"));
                    Etn.executeCmd(q);

                }
            }
        }

        return errorText;
    }

}
