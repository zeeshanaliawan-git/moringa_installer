package com.etn.pages;

import com.etn.beans.app.GlobalParm;
import org.apache.http.HttpEntity;
import org.apache.http.HttpHost;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.CredentialsProvider;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.ssl.SSLContextBuilder;
import org.apache.http.ssl.TrustStrategy;
import org.apache.http.util.EntityUtils;
import org.json.JSONObject;
import org.jsoup.nodes.Attribute;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.parser.Parser;
import org.jsoup.select.Elements;

import java.nio.charset.StandardCharsets;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Properties;

/**
 * Class to read an RSS feed items
 * given its URL or RSS XML
 *
 * @author Ali Adnan
 */
public class RssReader {

    private String errorText = "";

    private Document xmlRoot = null;

    private String xmlString = null;

    private HashMap<String,String> channelInfo = new HashMap<>();

    private ArrayList<HashMap<String,String>> itemsList = new ArrayList<>();

    private Properties env = null;

    public RssReader() {
    }

    public RssReader(Properties env) {
        this.env = env;
    }

    public String getParm(String key) throws Exception {
        if (env != null) {
            return env.getProperty(key);
        }
        else {
            return GlobalParm.getParm(key);
        }

    }

    public boolean parseRssFromUrl(String url) throws Exception {
        boolean isSuccess = false;

        this.xmlString = getResponseAsString(url);

        Parser xmlParser = Parser.xmlParser();

        this.xmlRoot = xmlParser.parseInput(xmlString, "");

        isSuccess = parseRssXml(xmlRoot);

        return isSuccess;
    }

    public boolean parseRssXml(Document xmlRoot) {

        boolean isSuccess = false;

        Elements channels = xmlRoot.select("channel");

        if (channels == null || channels.isEmpty()) {
            this.errorText = "Invalid RSS xml. No channel found.";
            return isSuccess = false;
        }
        Element channel = channels.get(0);

        for (Element curEle : channel.children()) {

            if ("item".equals(curEle.tagName())) {
                processItemElement(curEle);
            }
            else if ("image".equals(curEle.tagName())) {
                if (curEle.selectFirst("url") != null) {
                    this.channelInfo.put("image_url", curEle.selectFirst("url").html());
                }
                if (curEle.selectFirst("title") != null) {
                    this.channelInfo.put("image_title", curEle.selectFirst("title").html());
                }
            }
            else {

                String name = curEle.tagName();
                String value = curEle.html();

                name = name.replaceAll(":", "_");

                this.channelInfo.put(name, value);
            }

        }

        return isSuccess;
    }

    private void processItemElement(Element item) {

        HashMap<String,String> itemMap = new HashMap<>();

        for (Element curEle : item.children()) {
            if ("enclosure".equals(curEle.tagName())) {

                String url = curEle.attr("url");
                String type = curEle.attr("type");
                String length = curEle.attr("length");

                itemMap.put("enclosure_url", url);
                itemMap.put("enclosure_type", type);
                itemMap.put("enclosure_length", length);
            }
            else {
                String name = curEle.tagName();
                String value = curEle.html();

                name = name.replaceAll(":", "_");

                itemMap.put(name, value);

                for (Attribute curAttr : curEle.attributes()) {
                    String key = name + "_" + curAttr.getKey();
                    itemMap.put(key, curAttr.getValue());
                }
            }
        }

        this.itemsList.add(itemMap);
    }

    public String getResponseAsString(String url) throws Exception {

        String responseStr;

        String proxyHost = PagesUtil.parseNull(getParm("HTTP_PROXY_HOST"));
        String proxyPort = PagesUtil.parseNull(getParm("HTTP_PROXY_PORT"));
        final String proxyUser = PagesUtil.parseNull(getParm("HTTP_PROXY_USER"));
        final String proxyPasswd = PagesUtil.parseNull(getParm("HTTP_PROXY_PASSWD"));

        CloseableHttpClient httpClient = null;
        //Builder for SSLContext instances
        SSLContextBuilder builder = new SSLContextBuilder();
        TrustStrategy strategy = new TrustStrategy() {
            @Override
            public boolean isTrusted(final X509Certificate[] chain, String authType)
            throws CertificateException {

                return true;
            }
        };
        builder.loadTrustMaterial(null, strategy);
        //create SSL connection Socket Factory object for trusting self-signed certificates
        SSLConnectionSocketFactory sslcsf = new SSLConnectionSocketFactory(builder.build());

        HttpClientBuilder clientBuilder = HttpClients.custom();
        clientBuilder.setSSLSocketFactory(sslcsf);
        if (proxyHost.length() > 0 && proxyPort.length() > 0) {
            HttpHost proxy = new HttpHost(proxyHost, Integer.parseInt(proxyPort));
            if (proxyUser.length() > 0 & proxyPasswd.length() > 0) {
                CredentialsProvider credentialsPovider = new BasicCredentialsProvider();
                credentialsPovider.setCredentials(new AuthScope(proxyHost, Integer.parseInt(proxyPort)), new UsernamePasswordCredentials(proxyUser, proxyPasswd));
                clientBuilder.setDefaultCredentialsProvider(credentialsPovider);
            }
            clientBuilder.setProxy(proxy);
        }

        httpClient = clientBuilder.build();

        HttpGet httpGet = new HttpGet(url);
        //setting timeout
        int connectionTimeout = PagesUtil.getHttpConnectionTimout();
        RequestConfig requestConfig = RequestConfig.custom()
            .setConnectionRequestTimeout(connectionTimeout)
            .setConnectTimeout(connectionTimeout)
            .setSocketTimeout(connectionTimeout)
            .build();
        httpGet.setConfig(requestConfig);

        try (CloseableHttpResponse response = httpClient.execute(httpGet)) {
            response.getStatusLine();
            HttpEntity entity = response.getEntity();

            // do something useful with the response body
            // and ensure it is fully consumed
            responseStr = EntityUtils.toString(entity, StandardCharsets.UTF_8);

            EntityUtils.consume(entity);

        }

        return responseStr;

//old code
//        URL website = new URL(url);
//        URLConnection connection = website.openConnection();
//        connection.connect();
//        BufferedReader in = new BufferedReader(
//            new InputStreamReader(
//                connection.getInputStream()));
//
//        StringBuilder response = new StringBuilder();
//        String inputLine;
//
//        while ((inputLine = in.readLine()) != null) {
//            response.append(inputLine);
//        }
//
//        in.close();
//        String responseStr;
//        Content content = Request.Get(url)
//            .execute().returnContent();
//        responseStr = content.asString();
    }

    public String getErrorText() {
        return errorText;
    }

    public Document getXmlRoot() {
        return xmlRoot;
    }

    public String getXmlString() {
        return xmlString;
    }

    public HashMap<String,String> getChannelInfo() {
        return channelInfo;
    }

    public ArrayList<HashMap<String,String>> getItemsList() {
        return itemsList;
    }

    public static void main(String[] args) throws Exception {
        String testUrl = "";
        if (args.length > 0) {
            testUrl = args[0];
        }
        RssReader rssReader = new RssReader(new Properties());
//        testUrl = "https://orangefootballclub.com/fr/feed/?cat=3120";
        testUrl = "http://carspiritpk.com/feed/";
        //String testUrl = "https://devmycem.codehoppers.com/networkanalyticsapp/img/sample-rss-2.xml";
//        String testUrl = "https://154.68.34.73:8280/";
        //System.out.println(rssReader.getResponseAsString(testUrl));
        rssReader.parseRssFromUrl(testUrl);

        //System.out.println(rssReader.getXmlRoot().toString());
        System.out.println(new JSONObject(rssReader.getItemsList().get(0)));
        //System.out.println(rssReader.getItemsList().get(0).toString().replaceAll(",", ",\n"));

    }
}
