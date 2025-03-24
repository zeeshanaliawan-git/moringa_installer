<%
  response.setCharacterEncoding("utf-8");
  request.setCharacterEncoding("utf-8");
%>
<%@page import="com.etn.lang.Xml.Rs2Xml"%>
<%@page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.util.ItsDate, com.etn.sql.escape, java.text.SimpleDateFormat, com.etn.asimina.data.LanguageFactory ,com.etn.beans.app.GlobalParm"%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="java.util.*"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="/WEB-INF/include/constants.jsp"%>

<%@ include file="/admin/common.jsp" %>

<%

    String action = parseNull(request.getParameter("action"));
    String STATUS_SUCCESS = "SUCCESS", STATUS_ERROR = "ERROR";
    String message = "";
    String status = STATUS_ERROR;
    StringBuffer data = new StringBuffer();
    String selectedsiteid = parseNull(getSelectedSiteId(session)); 

    List<Language> langsList = getLangs(Etn,selectedsiteid);
    Language firstLanguage = langsList.get(0);

    if(action.equals("order_quantitylimits")){

        try{

            String ids = parseNull(request.getParameter("ids"));
            String SeqOrder = parseNull(request.getParameter("seq_order"));

            String idList[] = ids.split(",");
            String SqOrderFlag[] = SeqOrder.split(",");

            if( idList.length == 0 ){
                    throw new Exception("");
            }

            String q = "";
            for(int i=0; i<idList.length; i++){

                if(SqOrderFlag[i].equals("true"))
                    q = "UPDATE quantitylimits SET order_seq = " + (i+1) + ", version = version + 1 WHERE id = " + escape.cote(idList[i]);
                else
                    q = "UPDATE quantitylimits SET order_seq = " + (i+1) + " WHERE id = " + escape.cote(idList[i]);

                Etn.executeCmd(q);
            }

            status = STATUS_SUCCESS;
            message = "";

            if(data.length() == 0){
                data.append("\"\"");
            }

            response.setContentType("application/json");
            out.write("{\"status\":\""+status+"\",\"message\":\""+message+"\",\"data\":"+data+"}");
        }
        catch(Exception ex){
                status = STATUS_ERROR;
        }

    } else if(action.equals("quantitylimits")){

        LinkedHashMap<String, String> selection_types = new LinkedHashMap<String, String>();
        selection_types.put("sku","SKU");
        selection_types.put("product","Product");
        selection_types.put("product_type","Product Type");
        selection_types.put("catalog","Catalog");
        selection_types.put("manufacturer","Manufacturer");
        selection_types.put("tag","Tag");
        selection_types.put("all","All");

        String id = parseNull(request.getParameter("id"));;

        Set rs = null;
            Set rsRules = null;
        if(id.length() > 0)
        {
            rs = Etn.execute("SELECT * FROM quantitylimits WHERE id =  " + escape.cote(id));
            rs.next();
                    rsRules = Etn.execute("SELECT * FROM quantitylimits_rules WHERE quantitylimit_id="+escape.cote(id));
        }

        String lastpublish = "";
        String nextpublish = "";

        if(id.length() > 0)
        {
            String process = getProcess("quantitylimit");
            Set rspw = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s') from post_work where status = 0 and phase = 'publish' and client_key = " + escape.cote(id) + " and proces = "+escape.cote(process)+" ");
            if(rspw.next()) nextpublish = parseNull(rspw.value(0));

            rspw = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s') from post_work where status  in (0, 2) and phase = 'published' and client_key = " + escape.cote(id) + " and proces = "+escape.cote(process)+" order by id desc limit 1 ");
            if(rspw.next()) lastpublish = parseNull(rspw.value(0));
        }
%>


<div class="container">
    <div id='mycontainer'>
        <!-- messages zone  -->
        <div class='m-b-20'>

            <!-- info -->
            <% if(lastpublish.length() > 0) { %>
                <div id='infoBox' class="alert alert-success" role="alert" >
                    <div id=''>Last published on : <%=lastpublish%></div>
                </div>
            <% } %>

            <br/>

            <% if(nextpublish.length() > 0) { %>
                <div id='infoBox' class="alert alert-danger" role="alert" >
                    <div id=''><span class="oi oi-info" aria-hidden="true"></span><span class="m-l-10">Next publish on</span><span style='color:red'><%=nextpublish%></span></div>
                    <div ><span style='color:red'>WARNING!!!</span> If you make any changes now those will be published also</div>
                </div>
            <% } %>
            <!-- /info -->
        </div>
        <!-- messages zone  -->
    </div>
</div>

<div class="container">
    <style>.rule-list:nth-of-type(2){margin-left:0px !important}</style>
    <form name='saveForm' id='saveForm' method='post' action='savequantitylimits.jsp'  >
        <input type='hidden' name='id' value='<%=getValue(rs, "id")%>' />
    
        <div class="col-sm-12 multilingual-section">
            <table id="languagetable" cellpadding="0" cellspacing="0" border="0" style="margin-bottom: 10px;">
                <tr>
                    <%= getLanguageTabs(langsList)%>
                    <div style="padding-bottom: 20px; float: right;">
                        <button id="selectionSave" type="button" class="btn btn-primary" 
                        style="max-height:44.25px; position: absolute; right: 15px; top: 0px; z-index: 1000;" onclick='onQuantityLimitSave()'>Save</button>            
                    </div>        

                    <!-- Tab panes -->
                    <div class="tab-content p-3">
                        
                        <div id="tab_lang<%=firstLanguage.getLanguageId()%>show" class="container tab-pane active"><br>                

                            <!-- Global information -->
                            <div class="card mb-2">
                                <div class="card-header bg-secondary" data-toggle="collapse" href="#collapseGeneralInformation" role="button" 
                                aria-expanded="true" aria-controls="collapseGeneralInformation">
                                    <strong>General information</strong>
                                </div>
                                <div class="collapse show p-3" id="collapseGeneralInformation" style="border:none;">
                                    <div class="card-body">
                                        <div class="form-group row ">
                                            <label for="name" class='col-md-3 control-label is-required'>Name: </label>
                                            <div class='col-md-9'>
                                                <input type="text" id="name" name="name" value="<%=getRsValue(rs, "name")%>" class="form-control" />
                                                <div class="invalid-feedback">Name is mandatory.</div>
                                            </div>
                                        </div>
                                        <div class="form-group row ">   
                                            <label for="lang_<%=firstLanguage.getLanguageId()%>_description" class='col-md-3 control-label'>Description: </label>
                                            <div class='col-md-9'> 
                                                <%=getLanguageTextArea(langsList,rs) %>
                                                <div class="invalid-feedback">Description is mandatory.</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- Global information -->

                            <!-- Rule -->
                            <div class="card mb-2">
                                <div class="card-header bg-secondary" data-toggle="collapse" href="#collapseRule" role="button" 
                                aria-expanded="true" aria-controls="collapseRule">
                                    <strong>Rule</strong>
                                </div>
                                <div class="collapse show p-3" id="collapseRule" style="border:none;">
                                    <div class="card-body">
                                        <div class="form-group row">
                                            <label for="quantity_limit" class="col-sm-3 col-form-label is-required">Quantity Limit</label>
                                            <div class="col-sm-9">
                                                    <input type="text" id="quantity_limit" name="quantity_limit" value="<%=getRsValue(rs, "quantity_limit")%>" class="form-control" />
                                                    <div class="invalid-feedback">Quantity Limit is mandatory.</div>                                        
                                            </div>
                                        </div>
                                        <div id="appliedToContainer" class="form-group row">
                                            <label for="" class='col-md-3 control-label'>On: </label>
                                            
                                            
                                            <div id="appliedToTemplate" class="col-md-9">
                                                <div class="rule-list">
                                                    <div class="input-group-append mb-2">
                                                        <%
                                                                ArrayList arr = new ArrayList<String>();
                                                        %>
                                                        <%=addSelectControl("applied_to_type_sl", "applied_to_type_sl", selection_types, arr, "custom-select w-50 applied_to_type", "", false)%>
                                                        <div class="position-relative w-100">
                                                            <input type="text" name="" value="" class="form-control applied_to_value" placeholder="search item and enter" />
                                                        </div>
                                                        <input type="hidden" id="applied_to_key" class="form-control" />
                                                            <button type="button" class="btn btn-primary" onclick="addProduct()">Add</button>               

                                                    </div>

                                                </div>
                                            </div>
                                        </div>

                                        <div class="form-group row ">
                                            <div class="col-sm-3"> </div>
                                            <div id="selected_prod_hvng" class="col-sm-9 row">
                                            <%

                                                if(null != rsRules){

                                                    rsRules.moveFirst();

                                                    String type = "";
                                                    String value = "";
                                                    String label = "";

                                                    while(rsRules.next()){
                                                        
                                                        type = getRsValue(rsRules, "applied_to_type");
                                                        value = getRsValue(rsRules, "applied_to_value");
                                                        Set rsValue = null;

                                                        //System.out.println("type:"+type+"=value:"+value);
                                                        
                                                        if(type.equals("product")){
                                                            rsValue = Etn.execute("select lang_"+firstLanguage.getLanguageId()+"_name from products where id = "+escape.cote(value));
                                                            if(rsValue.next()){
                                                                label = rsValue.value(0);
                                                            }
                                                        }
                                                        else if(type.equals("catalog")){
                                                            rsValue = Etn.execute("select name from catalogs where id = "+escape.cote(value));
                                                            if(rsValue.next()){
                                                                label = rsValue.value(0);
                                                            }
                                                        }
                                                        else if(type.equals("product_type")){
                                                            rsValue = Etn.execute("select name from catalog_types where value = "+escape.cote(value));
                                                            if(rsValue.next()){
                                                                label = rsValue.value(0);
                                                            }
                                                        }
                                                        else if(type.equals("sku")){
                                                            rsValue = Etn.execute("select sku from product_variants where sku = "+escape.cote(value));
                                                            if(rsValue.next()){
                                                                label = rsValue.value(0);
                                                            }
                                                        }
                                                        else if(type.equals("manufacturer")){
                                                            rsValue = Etn.execute("select brand_name from products where brand_name = "+escape.cote(value));
                                                            if(rsValue.next()){
                                                                label = rsValue.value(0);
                                                            }
                                                        }
                                                        else if(type.equals("tag")){
                                                            rsValue = Etn.execute("select label from tags where site_id = "+escape.cote(selectedsiteid)+" and id = "+escape.cote(value));
                                                            if(rsValue.next()){
                                                                label = rsValue.value(0);
                                                            }
                                                        }
                                            %>
                                                        <div style="margin-left: 20px; margin-top: 10px;">
                                                            <button class="btn btn-pill btn-block btn-secondary" type="button">
                                                                <strong onclick="removeAppliedTo(this)" style="color:#f16e00; cursor: pointer;">X</strong> 
                                                                <%= escapeCoteValue((type.equals("all")?"All":label))%>
                                                            </button> 
                                                            <input type="hidden" name="applied_to_type" value='<%= escapeCoteValue(type)%>' />
                                                            <input type="hidden" name="applied_to_value" value='<%= escapeCoteValue(value)%>' /> 
                                                        </div>
                                            <%
                                                    }
                                                }

                                            %>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- /Rule -->


                        </div>
                    </div>

                </tr>
            </table>
        </div>
    </form>
</div>

<%
    } else if(action.equals("copyQuantityLimits")){

        String id = parseNull(request.getParameter("id"));
        String name = parseNull(request.getParameter("newName"));
        String query = "";
        status = STATUS_SUCCESS;

        try{

            query = "INSERT INTO quantitylimits (created_by, quantity_limit, lang_1_description, lang_2_description, lang_3_description, lang_4_description, lang_5_description, site_id, version) SELECT "+escape.cote(""+Etn.getId())+", quantity_limit, lang_1_description, lang_2_description, lang_3_description, lang_4_description, lang_5_description, site_id, version FROM quantitylimits WHERE id = " + escape.cote(id);

            int rowId = Etn.executeCmd(query);

            if(rowId > 0){

                query = "UPDATE quantitylimits SET name = " + escape.cote(name) + " WHERE id = " + escape.cote(rowId+"");
                Etn.executeCmd(query);

            }

            query = "INSERT INTO quantitylimits_rules (quantitylimit_id, applied_to_type, applied_to_value) SELECT '" + rowId + "', applied_to_type, applied_to_value FROM quantitylimits_rules WHERE quantitylimit_id = " + escape.cote(id);

            Etn.executeCmd(query);

        } catch(Exception e){

            status = STATUS_ERROR;
            message = e.getMessage();
        }

        out.write("{\"status\":\""+status+"\",\"message\":\""+message+"\"}");

    }
%>
