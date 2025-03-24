<%
  response.setCharacterEncoding("utf-8");
  request.setCharacterEncoding("utf-8");
%>
<%@page import="com.etn.lang.Xml.Rs2Xml"%>
<%@page import="com.etn.sql.escape"%>
<%@page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, java.text.SimpleDateFormat, com.etn.asimina.beans.Language, com.etn.asimina.data.LanguageFactory ,com.etn.beans.app.GlobalParm"%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="java.util.*"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="/WEB-INF/include/constants.jsp"%>

<%@ include file="/admin/common.jsp" %>

<%!

    String buildDateFr(String date){

        if(date.length() > 0){

            String token[] = date.split(" ");
            String innerToken[] = token[0].split("/");
            return innerToken[2] + "/" + innerToken[1] + "/" + innerToken[0] + " " + token[1];
        }

        return "";
    }


%>

<%

    String action = parseNull(request.getParameter("action"));
    String STATUS_SUCCESS = "SUCCESS", STATUS_ERROR = "ERROR";
    String message = "";
    String status = STATUS_ERROR;
    StringBuffer data = new StringBuffer();
    String selectedsiteid = parseNull(getSelectedSiteId(session));
    List<Language> langsList = getLangs(Etn,session);
    Language firstLanguage = langsList.get(0);
    boolean active = true;
    if(action.equals("order_promotion")){

        try{

            String promoIds = parseNull(request.getParameter("promoIds"));
            String SeqOrder = parseNull(request.getParameter("seq_order"));

            String promoIdList[] = promoIds.split(",");
            String SqOrderFlag[] = SeqOrder.split(",");

            if( promoIdList.length == 0 ){
                    throw new Exception("");
            }

            String q = "";
            for(int i=0; i<promoIdList.length; i++){

                if(SqOrderFlag[i].equals("true"))
                    q = "UPDATE promotions SET order_seq = " + (i+1) + ", version = version + 1 WHERE id = " + escape.cote(promoIdList[i]);
                else
                    q = "UPDATE promotions SET order_seq = " + (i+1) + " WHERE id = " + escape.cote(promoIdList[i]);

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

    } else if(action.equals("order_deliveryfee")){

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
                    q = "UPDATE deliveryfees SET order_seq = " + (i+1) + ", version = version + 1 WHERE id = " + escape.cote(idList[i]);
                else
                    q = "UPDATE deliveryfees SET order_seq = " + (i+1) + " WHERE id = " + escape.cote(idList[i]);

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

    } else if(action.equals("order_deliverymin")){

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
                    q = "UPDATE deliverymins SET order_seq = " + (i+1) + ", version = version + 1 WHERE id = " + escape.cote(idList[i]);
                else
                    q = "UPDATE deliverymins SET order_seq = " + (i+1) + " WHERE id = " + escape.cote(idList[i]);

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

    } else if(action.equals("order_additional_fee")){

        try{

            String addFeeIds = parseNull(request.getParameter("addFeeIds"));
            String SeqOrder = parseNull(request.getParameter("seq_order"));

            String addFeeIdList[] = addFeeIds.split(",");
            String SqOrderFlag[] = SeqOrder.split(",");

            if( addFeeIdList.length == 0 ){
                    throw new Exception("");
            }

            String q = "";
            for(int i=0; i<addFeeIdList.length; i++){

                if(SqOrderFlag[i].equals("true"))
                    q = "UPDATE additionalfees SET order_seq = " + (i+1) + ", version = version + 1 WHERE id = " + escape.cote(addFeeIdList[i]);
                else
                    q = "UPDATE additionalfees SET order_seq = " + (i+1) + " WHERE id = " + escape.cote(addFeeIdList[i]);

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

    } else if(action.equals("order_comewith")){

        try{

            String addComeWithIds = parseNull(request.getParameter("addComeWithIds"));
            String SeqOrder = parseNull(request.getParameter("seq_order"));

            String addComeWithIdsList[] = addComeWithIds.split(",");
            String SqOrderFlag[] = SeqOrder.split(",");

            if( addComeWithIdsList.length == 0 ){
                    throw new Exception("");
            }

            String q = "";
            for(int i=0; i<addComeWithIdsList.length; i++){

                if(SqOrderFlag[i].equals("true"))
                    q = "UPDATE comewiths SET order_seq = " + (i+1) + ", version = version + 1 WHERE id = " + escape.cote(addComeWithIdsList[i]);
                else
                    q = "UPDATE comewiths SET order_seq = " + (i+1) + " WHERE id = " + escape.cote(addComeWithIdsList[i]);

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

    } else if(action.equals("comewith")){


        LinkedHashMap<String, String> frequency = new LinkedHashMap<String, String>();
        frequency.put("none","None");
        frequency.put("weekly","Weekly");
        frequency.put("monthly","Monthly");

        LinkedHashMap<String, String> feedbackDDValues = new LinkedHashMap<String, String>();
        feedbackDDValues.put("all","All Users");
        feedbackDDValues.put("logged","Logged-in Users");

        LinkedHashMap<String, String> comeWithOptionValues = new LinkedHashMap<String, String>();
        comeWithOptionValues.put("gift", "Gift");
        comeWithOptionValues.put("label", "Label");
        comeWithOptionValues.put("product","Product");

        LinkedHashMap<String, String> comeWithTypeValues = new LinkedHashMap<String, String>();
        comeWithTypeValues.put("optional","Optional");
        comeWithTypeValues.put("mandatory","Mandatory");

        LinkedHashMap<String, String> selectProductValues = new LinkedHashMap<String, String>();
        selectProductValues.put("sku","SKU");
        selectProductValues.put("product","Product");

        LinkedHashMap<String, String> variantTypes = new LinkedHashMap<String, String>();
        variantTypes.put("default","Default Variant");
        variantTypes.put("select","Selectable Variant");

        LinkedHashMap<String, String> selectProductAsscteValues = new LinkedHashMap<String, String>();
        selectProductAsscteValues.put("sku","SKU");
        selectProductAsscteValues.put("product","Product");
        selectProductAsscteValues.put("product_type","Product Type");
        selectProductAsscteValues.put("catalog","Catalog");
        selectProductAsscteValues.put("manufacturer","Manufacturer");
        selectProductAsscteValues.put("tag","Tag");

        String id = parseNull(request.getParameter("id"));

        Set rs = null;
        Set rsComewithsRules = null;

        if(id.length() > 0)
        {
            rs = Etn.execute("SELECT * FROM comewiths WHERE id =  " + escape.cote(id));
            rs.next();

            rsComewithsRules = Etn.execute("SELECT * FROM comewiths_rules WHERE comewith_id = " + escape.cote(id));
            rsComewithsRules.next();
        }

        String startDate = getRsValue(rs, "start_date");
        String endDate = getRsValue(rs, "end_date");

        if(startDate.length() > 0) startDate = buildDateFr(startDate);
        if(endDate.length() > 0) endDate = buildDateFr(endDate);
        
%>
        <!-- come-with -->
        <form <% if(id.length() > 0){ %> id='editcomewithfrm' <% }else{%> id='comewithfrm' <% } %> name='comewithfrm' method='post' action='savecomewiths.jsp' >

        <%
            if(id.length() > 0){
        %>
                <input type='hidden' name='id' id="come_with_id" value='<%=getValue(rs, "id")%>' />
        <%
            }
        %>
            <div class="col-sm-12 multilingual-section">
                <table id="languagetable" cellpadding="0" cellspacing="0" border="0" style="margin-bottom: 10px;">
                    <tr>
                        <%=getLanguageTabs(langsList)%>

                       <div style="padding-bottom: 20px; float: right;">
                            <button id="selectionSave" type="button" class="btn btn-primary" style="max-height:44.25px; position: absolute; right: 15px; top: 0px; z-index: 1000;" <% if(id.length() > 0){ %> onclick='onEditComeWithSave()' <% }else{%> onclick='onComeWithSave()' <% } %>>Save</button>
                       </div>

                        <!-- Tab panes -->
                        <div class="tab-content p-3">

                            <div id="tab_lang<%=firstLanguage.getLanguageId()%>show" class="container tab-pane active"><br>

                                <!-- Global information -->
                                <div class="card mb-2">
                                    <div class="card-header bg-secondary" data-toggle="collapse" href="#general_info" role="button" aria-expanded="true" 
                                    aria-controls="general_info">
                                        <strong>General information</strong>
                                    </div>
                                    <div class="collapse show p-3" id="general_info" style="border:none;">
                                        <div class="card-body">
                                            <div class="form-group row ">
                                                <label for="name" class='col-md-3 control-label is-required'>Come-with name:</label>
                                                <div class='col-md-9'>
                                                    <input type="text" id="name" name="name" value="<%=getRsValue(rs, "name")%>" class="form-control" />
                                                    <div class="invalid-feedback">Come-with name is mandatory.</div>
                                                </div>
                                            </div>
                                            <div class="form-group row ">
                                                <label for="title" class='col-md-3 control-label is-required'>Come-with title:</label>
                                                <div class='col-md-9'>
                                                    <input type="text" id="title" name="title" value="<%=getRsValue(rs, "title")%>" class="form-control" />
                                                    <div class="invalid-feedback">Come-with title is mandatory.</div>
                                                </div>
                                            </div>
                                            <div class="form-group row ">
                                                <label for="description" class='col-md-3 control-label'>Description: </label>
                                                <div class='col-md-9'>
                                                        <%=getLanguageTextArea(langsList,rs)%>
                                                    <div class="invalid-feedback">Description is mandatory.</div>
                                                </div>
                                            </div>
                                            <div class="form-group row ">
                                                <label for="visible_to" class='col-md-3 control-label'>Applicable to: </label>
                                                <div class='col-md-9'>
                                                    <%
                                                            ArrayList arr = new ArrayList<String>();
                                                            arr.add(getRsValue(rs, "visible_to"));
                                                    %>
                                                    <%=addSelectControl("visible_to", "visible_to", feedbackDDValues, arr, "custom-select", "", false)%>
                                                </div>
                                            </div>
                                            <div class="form-group row ">
                                                <label for="start_date" class='col-md-3 control-label'>Start / End: </label>
                                                <div class='col-md-9 input-group'>
                                                    <input type="text" id="start_date" placeholder="Start date" name="start_date" value="<%=startDate%>" class="form-control" />
                                                    <input type="text" id="end_date" placeholder="End date" name="end_date" value="<%=endDate%>" class="form-control" />
                                                    <div class="input-group-append">
                                                        <button type="button" name="ignore" class="btn btn-warning pull-right" onclick="$('#start_date').val('');$('#end_date').val('');"  style="max-height:35px"><span class="oi oi-delete" aria-hidden="true"></span></button>&nbsp;
                                                    </div>
                                                </div>

                                            </div>
                                            <div class="form-group row">
                                                <label for="duration" class='col-md-3 control-label'>Frequency: </label>
                                                <div class='col-md-9'>
                                                    <%
                                                            arr = new ArrayList<String>();
                                                            arr.add(getRsValue(rs, "frequency"));
                                                    %>
                                                    <%=addSelectControl("", "frequency", frequency, arr, "custom-select", "", false)%>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <!-- /Global information -->

                                <!-- Come-with Rules -->
                                <div class="card mb-2">
                                    <div class="card-header bg-secondary" data-toggle="collapse" href="#come_with_rules_expand" role="button" aria-expanded="true" 
                                    aria-controls="come_with_rules_expand">
                                        <strong>Rule</strong>
                                    </div>
                                    <div class="collapse show p-3" id="come_with_rules_expand" style="border:none;">
                                        <div class="card-body">
                                            <div id="appliedToContainer">
                                                <div id="ComeWithRuleTemplate">
                                                    <div class="appliedToTemplate" >
                                                        <div class="form-group row ">
                                                            <label for="comewith" class='col-md-3 control-label'>Come-with : <span style="color: red;">*</span> </label>
                                                            <div class="col-md-9">
                                                                <div class="input-group-append">
                                                                    <%
                                                                        arr = new ArrayList<String>();
                                                                        arr.add(getRsValue(rs, "comewith"));
                                                                    %>
                                                                    <%=addSelectControl("comewith", "comewith", comeWithOptionValues, arr, "custom-select", "onchange=defineComeWith(this.value)", false)%>
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <div class="form-group row ">
                                                            <label for="type" class='col-md-3 control-label'>Come-with type : <span style="color: red;">*</span> </label>
                                                            <div class="col-sm-9">
                                                                <div class="input-group">
                                                                    <%
                                                                        arr = new ArrayList<String>();
                                                                        arr.add(getRsValue(rs, "type"));
                                                                    %>
                                                                    <%=addSelectControl("type", "type", comeWithTypeValues, arr, "custom-select", "", false)%>
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <div class="form-group row ">
                                                            <label for="applied_to_type" class='col-md-3 control-label'>Define come-with : <span style="color: red;">*</span> </label>
                                                            <div class="col-sm-9">
                                                                <div class="input-group-append">
                                                                    <%
                                                                        arr = new ArrayList<String>();
                                                                        arr.add(getRsValue(rs, "applied_to_type"));
                                                                    %>
                                                                    <%=addSelectControl("applied_to_type", "applied_to_type", selectProductValues, arr, "custom-select applied_to_type_comewith", "", false)%>

                                                                    <%
                                                                        if(id.length() == 0){

                                                                    %>
                                                                            <div class="position-relative w-100">
                                                                                <input id="applied_to_value" type="text" class="form-control applied_to_value_comewith" />
                                                                            </div>
                                                                            <input id="applied_to_type_comewith" name="applied_to_value" type="hidden" />
                                                                    <%
                                                                        }

                                                                        if(null != rs){

                                                                            rs.moveFirst();

                                                                            String type = "";
                                                                            String value = "";
                                                                            String label = "";

                                                                            while(rs.next()){

                                                                                type = getRsValue(rs, "applied_to_type");
                                                                                value = getRsValue(rs, "applied_to_value");
                                                                                Set rsValue = null;

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
                                                                                <div class="position-relative w-100">
                                                                                    <input id="applied_to_value" type="text" class="form-control applied_to_value_comewith" value='<%= escapeCoteValue(label)%>' />
                                                                                </div>
                                                                                <input id="applied_to_type_comewith" name="applied_to_value" type="hidden" class="form-control" value='<%= escapeCoteValue(value)%>' />
                                                                    <%
                                                                            }
                                                                        }

                                                                    %>
                                                                    <%
                                                                        arr = new ArrayList<String>();
                                                                        arr.add(getRsValue(rs, "variant_type"));
                                                                    %>
                                                                    <%=addSelectControl("variant_type", "variant_type", variantTypes, arr, "custom-select variant_type", "", false)%>

                                                                </div>
                                                                <div class="invalid-feedback">Define come-with and value are mandatory.</div>
                                                            </div>
                                                        </div>

                                                        <div class="form-group row ">
                                                            <label for="type" class='col-md-3 control-label'>Price difference : </label>
                                                            <div class="col-sm-9">
                                                                <div class="input-group">
                                                                    <%
                                                                        arr = new ArrayList<String>();
                                                                        arr.add(getRsValue(rs, "type"));
                                                                    %>
																	<div class='input-group-prepend'><span class="input-group-text">-</span></div>
																	<input id="price_difference_comewith" name="price_difference" type="text" class="form-control price_difference_comewith" value='<%=escapeCoteValue(getRsValue(rs, "price_difference"))%>' />
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <div class="form-group row ">
                                                            <label for="associated_to_type" class='col-md-3 control-label'>Associate to : <span style="color: red;">*</span> </label>
                                                            <div class="col-sm-9">
                                                                <div class="input-group-append">
                                                                    <%
                                                                        arr = new ArrayList<String>();
                                                                        arr.add(getRsValue(rs, "associated_to_type"));
                                                                    %>
                                                                    <%=addSelectControl("associated_to_type", "associated_to_type", selectProductAsscteValues, arr, "custom-select w-50 associated_to_type", "", false)%>
                                                                    <div class="position-relative w-100">
                                                                        <input id="associated_to_value_comewith" type="text" class="form-control associated_to_value_comewith" value='' />
                                                                    </div>
                                                                    <input id="associated_to_type_comewith" type="hidden" value='' />
                                                                    <button type="button" class="btn btn-primary" onclick="add_selected_prod()">Add</button>
                                                                </div>
                                                                <div class="invalid-feedback">Product associate and value are mandatory.</div>
                                                            </div>
                                                        </div>

                                                    </div>
                                                </div>

                                                <div class="form-group row ">
                                                    <div class="col-sm-3"> </div>
                                                    <div id="selected_prod_hvng" class="col-sm-9 row">
                                                    <%
                                                        if(null != rsComewithsRules){

                                                            rsComewithsRules.moveFirst();

                                                            String type = "";
                                                            String value = "";
                                                            String label = "";

                                                            while(rsComewithsRules.next()){

                                                                type = getRsValue(rsComewithsRules, "associated_to_type");
                                                                value = getRsValue(rsComewithsRules, "associated_to_value");
                                                                Set rsValue = null;

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
                                                                        <strong onclick="delete_selected_on(this)" style="color:#f16e00; cursor: pointer;">X</strong>
                                                                        <%= escapeCoteValue(label)%>
                                                                    </button>
                                                                    <input type="hidden" name="associated_to_type_comewith" value='<%= escapeCoteValue(rsComewithsRules.value("associated_to_type"))%>' />
                                                                    <input type="hidden" name="associated_to_value_comewith" value='<%= escapeCoteValue(rsComewithsRules.value("associated_to_value"))%>' />

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
                                </div>
                                <!-- Come-with rules -->

                                <script>
                                    jQuery(document).ready(function() {
                                    <%

                                    if(null == rsComewithsRules || rsComewithsRules.rs.Rows == 0){
                                    %>
                                        addAssociatedTo();
                                    <%
                                    }

                                    if(null == rs || rs.rs.Rows == 0){
                                    %>
                                        addAppliedTo();
                                    <%
                                    }

                                    if(rsComewithsRules != null) rsComewithsRules.moveFirst();

                                    while(rsComewithsRules!=null && rsComewithsRules.next()){

                                        String label = getRsValue(rsComewithsRules, "associated_to_value");
                                        String type = getRsValue(rsComewithsRules, "associated_to_type");
                                        String value = getRsValue(rsComewithsRules, "associated_to_value");

                                        Set rsValue = null;

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
                                        addAssociatedTo('<%=type%>','','<%=value%>');
                                    <%
                                    }

                                    if(rs != null) rs.moveFirst();

                                    while(rs!=null && rs.next()){

                                        String label = getRsValue(rs, "applied_to_value");
                                        String type = getRsValue(rs, "applied_to_type");
                                        String value = getRsValue(rs, "applied_to_value");

                                        Set rsValue = null;
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

                                        addAppliedTo('<%=type%>','<%=label%>','<%=value%>');

                                    <%
                                    }
                                    %>
                                    });
                                </script>


                            </div>
                        </div>

                    </tr>
                </table>
            </div>
        </form>
        <!-- Come-with -->

<%

    }  else if(action.equals("additional_fee")){

        LinkedHashMap<String, String> feedbackDDValues = new LinkedHashMap<String, String>();
        feedbackDDValues.put("all","All Users");
        feedbackDDValues.put("logged","Logged-in Users");

        LinkedHashMap<String, String> selectProductValues = new LinkedHashMap<String, String>();
        selectProductValues.put("sku","SKU");
        selectProductValues.put("product","Product");
        selectProductValues.put("product_type","Product Type");
        selectProductValues.put("catalog","Catalog");
        selectProductValues.put("manufacturer","Manufacturer");
        selectProductValues.put("tag","Tag");

        LinkedHashMap<String, String> additionalFeeTypeValues = new LinkedHashMap<String, String>();
        additionalFeeTypeValues.put("deposit", "Deposit");
        additionalFeeTypeValues.put("adv_amt", "Advance (amount)");
        additionalFeeTypeValues.put("adv_mnth","Advance (months)");

        String id = parseNull(request.getParameter("id"));

        Set rs = null;
        Set rsAdditionalFeeRules = null;

        if(id.length() > 0)
        {
            rs = Etn.execute("SELECT * FROM additionalfees WHERE id =  " + escape.cote(id));
            rs.next();

            rsAdditionalFeeRules = Etn.execute("SELECT * FROM additionalfee_rules WHERE add_fee_id = " + escape.cote(id));
            rsAdditionalFeeRules.next();
        }

        String startDate = getRsValue(rs, "start_date");
        String endDate = getRsValue(rs, "end_date");

        if(startDate.length() > 0) startDate = buildDateFr(startDate);
        if(endDate.length() > 0) endDate = buildDateFr(endDate);

%>
        <!-- additional fees -->
        <form <% if(id.length() > 0){ %> id='editadditionfeefrm' <% }else{%> id='additionfeefrm' <% } %> name='additionfeefrm' method='post' action='saveadditionalfees.jsp' >

        <%
            if(id.length() > 0){
        %>
                <input type='hidden' name='id' id="additional_fee_id" value='<%=getValue(rs, "id")%>' />
        <%
            }
        %>
            <div class="col-sm-12 multilingual-section">
                <table id="languagetable" cellpadding="0" cellspacing="0" border="0" style="margin-bottom: 10px;">
                    <tr>
                        <%= getLanguageTabs(langsList)%>

                       <div style="padding-bottom: 20px; float: right;">
                            <button id="selectionSave" type="button" class="btn btn-primary" style="max-height:44.25px; position: absolute; right: 15px; top: 0px; z-index: 1000;" <% if(id.length() > 0){ %> onclick='onEditAdditionalFeeSave()' <% }else{%> onclick='onAdditionalFeeSave()' <% } %>>Save</button>
                       </div>

                        <!-- Tab panes -->
                        <div class="tab-content p-3">

                            <div id="tab_lang<%=firstLanguage.getLanguageId()%>show" class="container tab-pane active"><br>

                                <%
                                    ArrayList arr = new ArrayList<String>();
                                %>
                                <!-- Global information -->
                                <div class="card mb-2">
                                    <div class="card-header bg-secondary" data-toggle="collapse" href="#general_info_coupon" role="button" 
                                    aria-expanded="true" aria-controls="general_info_coupon">
                                        <strong>General information</strong>
                                    </div>
                                    <div class="collapse show p-3" id="general_info_coupon" style="border: none;">
                                        <div class="card-body">
                                            <div class="form-group row ">
                                                <label for="name" class='col-md-3 control-label is-required'>Additional fee name:</label>
                                                <div class='col-md-9'>
                                                    <input type="text" id="name" name="name" value="<%=getRsValue(rs, "additional_fee")%>" class="form-control" />
                                                    <div class="invalid-feedback">Rule name is mandatory.</div>
                                                </div>
                                            </div>
                                            <div class="form-group row ">
                                                <label for="description" class='col-md-3 control-label is-required'>Description: </label>
                                                <div class='col-md-9'>
                                                    <%=getLanguageTextArea(langsList,rs)%>
                                                    <div class="invalid-feedback">Description is mandatory.</div>
                                                </div>
                                            </div>
                                            <div class="form-group row ">
                                                <label for="visible_to" class='col-md-3 control-label'>Applicable to: </label>
                                                <div class='col-md-9'>
                                                    <%
                                                            arr = new ArrayList<String>();
                                                            arr.add(getRsValue(rs, "visible_to"));
                                                    %>
                                                    <%=addSelectControl("visible_to", "visible_to", feedbackDDValues, arr, "custom-select", "", false)%>
                                                </div>
                                            </div>
                                            <div class="form-group row ">
                                                <label for="start_date" class='col-md-3 control-label'>Start / End: </label>
                                                <div class='col-md-9 input-group'>
                                                    <input type="text" id="start_date" placeholder="Start date" name="start_date" value="<%=startDate%>" class="form-control" />
                                                    <input type="text" id="end_date" placeholder="End date" name="end_date" value="<%=endDate%>" class="form-control" />
                                                    <div class="input-group-append">
                                                        <button type="button" name="ignore" class="btn btn-warning pull-right" onclick="$('#start_date').val('');$('#end_date').val('');"  style="max-height:35px"><span class="oi oi-delete" aria-hidden="true"></span></button>&nbsp;
                                                    </div>
                                                </div>

                                            </div>
                                       </div>
                                    </div>
                                </div>
                                <!-- /Global information -->

                                <!-- Additionnal prices -->
                                <div class="card mb-2">
                                    <div class="card-header bg-secondary" data-toggle="collapse" href="#additional_prices_expand" role="button" 
                                    aria-expanded="true" aria-controls="additional_prices_expand">
                                        <strong>Rule</strong>
                                    </div>
                                    <div class="collapse show p-3" id="additional_prices_expand" style="border: none;">
                                        <div class="card-body">
                                            <div id="appliedToContainer">
                                                <div id="AdditionalPricesTemplate">
                                                    <div class="appliedToTemplate" >
                                                        <div class="form-group row ">
                                                            <label for="rule_apply" class='col-md-3 control-label'>Apply : <span style="color: red;">*</span> </label>
                                                            <div class="col-md-9">
                                                                <div class="input-group-append">
                                                                    <%
                                                                        arr = new ArrayList<String>();
                                                                        arr.add(getRsValue(rsAdditionalFeeRules, "rule_apply"));
                                                                    %>
                                                                    <%=addSelectControl("rule_apply", "rule_apply", additionalFeeTypeValues, arr, "custom-select", "onchange='changeTypeAdditionalPrice(this)'", false)%>
                                                                    <input type="text" id="rule_apply_value" name="rule_apply_value" class="form-control" value='<%= getRsValue(rsAdditionalFeeRules, "rule_apply_value")%>' />
                                                                </div>
                                                                <div class="invalid-feedback">Apply rule and value are mandatory.</div>
                                                            </div>
                                                        </div>

                                                        <div class="form-group row ">
                                                            <label for="element_type_prod" class='col-md-3 control-label'>On : <span style="color: red;">*</span> </label>
                                                            <div class="col-sm-9">
                                                                <div class="input-group-append">
                                                                    <%
                                                                        arr = new ArrayList<String>();
                                                                    %>
                                                                    <%=addSelectControl("element_type_prod", "element_type_prod", selectProductValues, arr, "custom-select w-50 element_type", "", false)%>
                                                                    <div class="position-relative w-100">
                                                                        <input type="text" class="form-control product_value_additinal_fee" />
                                                                    </div>
                                                                    <input type="hidden" id="product_key_additinal_fee" class="form-control" />
                                                                    <button type="button" class="btn btn-primary" onclick="add_selected_prod()">Add</button>
                                                                </div>
                                                                <div class="invalid-feedback">Product selection is mandatory.</div>
                                                            </div>
                                                        </div>

                                                    </div>
                                                </div>

                                                <div class="form-group row ">
                                                    <div class="col-sm-3"> </div>
                                                    <div id="selected_prod_hvng" class="col-sm-9 row">
                                                    <%

                                                        if(null != rsAdditionalFeeRules){

                                                            String type = "";
                                                            String value = "";
                                                            String label = "";

                                                            rsAdditionalFeeRules.moveFirst();
                                                            while(rsAdditionalFeeRules.next()){

                                                                type = getRsValue(rsAdditionalFeeRules, "element_type");
                                                                value = getRsValue(rsAdditionalFeeRules, "element_type_value");
                                                                Set rsValue = null;

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
                                                                        <strong onclick="delete_selected_on(this)" style="color:#f16e00; cursor: pointer;">X</strong>
                                                                        <%= escapeCoteValue(label)%>
                                                                    </button>
                                                                    <input type="hidden" name="element_type" value='<%= escapeCoteValue(rsAdditionalFeeRules.value("element_type"))%>' />
                                                                    <input type="hidden" name="element_type_value" value='<%= escapeCoteValue(rsAdditionalFeeRules.value("element_type_value"))%>' />

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
                                </div>
                                <!-- /Additionnal prices -->

                            </div>
                        </div>

                    </tr>
                </table>
            </div>
        </form>
        <!-- /additional fees -->

        <script>
            jQuery(document).ready(function() {
            <%

            if(null == rsAdditionalFeeRules || rsAdditionalFeeRules.rs.Rows == 0){
            %>
                addAppliedTo();
            <%
            }

            if(rsAdditionalFeeRules != null) rsAdditionalFeeRules.moveFirst();

            while(rsAdditionalFeeRules!=null && rsAdditionalFeeRules.next()){

                String label = getRsValue(rsAdditionalFeeRules, "element_type_value");
                String type = getRsValue(rsAdditionalFeeRules, "element_type");
                String value = getRsValue(rsAdditionalFeeRules, "element_type_value");

                Set rsValue = null;
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

            %>

                addAppliedTo('<%=type%>','','<%=value%>');

            <%
            }
            %>
            });
        </script>

<%

    } else if(action.equals("promotions")){

        LinkedHashMap<String, String> discount_types = new LinkedHashMap<String, String>();
        discount_types.put("fixed","\"-\" fixed amount of original price");
        discount_types.put("percentage","% (-) of original price");

    LinkedHashMap<String, String> selection_types = new LinkedHashMap<String, String>();
    selection_types.put("sku","SKU");
    selection_types.put("product","Product");
    selection_types.put("product_type","Product Type");
    selection_types.put("catalog","Catalog");
    selection_types.put("manufacturer","Manufacturer");
    selection_types.put("tag","Tag");

    LinkedHashMap<String, String> feedbackDDValues = new LinkedHashMap<String, String>();
    feedbackDDValues.put("all","All Users");
    feedbackDDValues.put("logged","Logged-in Users");

    LinkedHashMap<String, String> flash_sale_types = new LinkedHashMap<String, String>();
    flash_sale_types.put("no","No flash sale");
    flash_sale_types.put("quantity","Flash sale quantity");
    flash_sale_types.put("time","Flash sale duration");

    LinkedHashMap<String, String> frequency = new LinkedHashMap<String, String>();
    frequency.put("none","None");
    frequency.put("weekly","Weekly");
    frequency.put("monthly","Monthly");

    String id = parseNull(request.getParameter("id"));;

    Set rs = null;
        Set rsRules = null;
    if(id.length() > 0)
    {
        rs = Etn.execute("SELECT * FROM promotions WHERE id =  " + escape.cote(id));
        rs.next();
                rsRules = Etn.execute("SELECT * FROM promotions_rules WHERE promotion_id="+escape.cote(id));
    }

    String lastpublish = "";
    String nextpublish = "";

    if(id.length() > 0)
    {
        String process = getProcess("promotion");
        Set rspw = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s') from post_work where status = 0 and phase = 'publish' and client_key = " + escape.cote(id) + " and proces = "+escape.cote(process)+" ");
        if(rspw.next()) nextpublish = parseNull(rspw.value(0));

        rspw = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s') from post_work where status  in (0, 2) and phase = 'published' and client_key = " + escape.cote(id) + " and proces = "+escape.cote(process)+" order by id desc limit 1 ");
        if(rspw.next()) lastpublish = parseNull(rspw.value(0));
    }

    String startDate = getRsValue(rs, "start_date");
    String endDate = getRsValue(rs, "end_date");

    if(startDate.length() > 0) startDate = buildDateFr(startDate);
    if(endDate.length() > 0) endDate = buildDateFr(endDate);
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

<!-- Promotion -->
<div class="container">
    <style>.rule-list:nth-of-type(2){margin-left:0px !important}</style>
    <form name='promotionForm' id='promotionForm' method='post' action='savepromotion.jsp'  >
        <input type='hidden' name='id' id="promotion_id" value='<%=getValue(rs, "id")%>' />

        <div class="col-sm-12 multilingual-section">
            <table id="languagetable" cellpadding="0" cellspacing="0" border="0" style="margin-bottom: 10px;">
                <tr>
                    <%= getLanguageTabs(langsList)%>

                    <div style="padding-bottom: 20px; float: right;">
                        <button id="selectionSave" type="button" class="btn btn-primary" style="max-height:44.25px; position: absolute; right: 15px; top: 0px; z-index: 1000;" onclick='onPromotionSave()'>Save</button>
                    </div>

                    <!-- Tab panes -->
                    <div class="tab-content p-3">

                        <div id="tab_lang<%=firstLanguage.getLanguageId()%>show" class="container tab-pane active"><br>

                            <!-- Global information -->
                            <div class="card mb-2">
                                <div class="card-header bg-secondary" data-toggle="collapse" href="#collapsePromotionGeneralInformation" 
                                    role="button" aria-expanded="true" aria-controls="collapsePromotionGeneralInformation">
                                    <strong>General information</strong>
                                </div>
                                <div class="collapse show p-3" id="collapsePromotionGeneralInformation" style="border:none;">
                                    <div class="card-body">
                                        <div class="form-group row ">
                                            <label for="name" class='col-md-3 control-label is-required'>Promotion Name: </label>
                                            <div class='col-md-9'>
                                                <input type="text" id="name" name="name" value="<%=getRsValue(rs, "name")%>" class="form-control" />
                                                <div class="invalid-feedback">Promotion name is mandatory.</div>
                                            </div>
                                        </div>
                                        <div class="form-group row ">
                                            <label for="name" class='col-md-3 control-label is-required'>Promotion Title: </label>
                                            <div class='col-md-9'>
                                                <%
                                                    active = true;
                                                    for(Language lang:langsList){
                                                %>
                                                    <textarea id="lang_<%=lang.getLanguageId()%>_title" name="lang_<%=lang.getLanguageId()%>_title" class="form-control lang<%=lang.getLanguageId()%>show infoText" <%= (active)? "style='display: none;'": "" %> ><%=getRsValue(rs, "lang_"+lang.getLanguageId()+"_title")%></textarea>
                                                <%
                                                    active = false;
                                                    }
                                                %>
                                                <div class="invalid-feedback">Promotion Title is mandatory.</div>
                                            </div>
                                        </div>
                                        <div class="form-group row ">
                                            <label for="name" class='col-md-3 control-label is-required'>Description: </label>
                                            <div class='col-md-9'>
                                                <%=getLanguageTextArea(langsList,rs)%>
                                                <div class="invalid-feedback">Description is mandatory.</div>
                                            </div>
                                        </div>
                                        <div class="form-group row ">
                                            <label for="name" class='col-md-3 control-label'>Applicable to: </label>
                                            <div class='col-md-9'>
                                                <%
                                                        ArrayList arr = new ArrayList<String>();
                                                        arr.add(getRsValue(rs, "visible_to"));
                                                %>
                                                <%=addSelectControl("visible_to", "visible_to", feedbackDDValues, arr, "custom-select", "", false)%>
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label for="staticEmail" class="col-sm-3 col-form-label">Start / End: </label>
                                            <div class="col-sm-9">
                                                <div class="input-group">
                                                    <input type="text" id="start_date" name="start_date" value="<%=startDate%>" class="form-control" placeholder="Start date"/>
                                                    <input type="text" id="end_date" name="end_date" value="<%=endDate%>" class="form-control" placeholder="End date"/>
                                                    <div class="input-group-append">
                                                        <button type="button" name="ignore" class="btn btn-warning pull-right" onclick="$('#start_date').val('');$('#end_date').val('');"  style="max-height:35px"><span class="oi oi-delete" aria-hidden="true"></span></button>&nbsp;
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="form-group row ">
                                            <label for="duration" class='col-md-3 control-label'>Frequency: </label>
                                            <div class='col-md-9'>
                                                <%
                                                        arr = new ArrayList<String>();
                                                        arr.add(getRsValue(rs, "frequency"));
                                                %>
                                                <%=addSelectControl("", "frequency", frequency, arr, "custom-select", "", false)%>
                                            </div>
                                        </div>
                                        <div class="form-group row ">
                                            <label for="flash_sale" class="col-sm-3 col-form-label" data-toggle="tooltip" data-placement="top" title="Select the type of flash sale if needed :
                                            - If “Flash sale quantity” is selected, then a message “Only x left” (with x corresponding to the remaining stock of the considered product(s)) will be displayed on front with a flash sale sticker
                                            - If “Flash sale duration” is selected, then a counter will be displayed (depending on values provided in “start date” and “end date”) will be displayed on front with a flash sale sticker">
                                                Flash sale type
                                                <svg class="feather feather-info sc-dnqmqq jxshSx" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" data-reactid="666"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12" y2="8"></line></svg>
                                            </label>



                                            <div class='col-md-9'>
                                                <%
                                                        arr = new ArrayList<String>();
                                                        arr.add(getRsValue(rs, "flash_sale"));
                                                %>
                                                <%=addSelectControl("", "flash_sale", flash_sale_types, arr, "custom-select", "onchange='onChangeFlashSale(this)'", false)%>
                                            </div>
                                        </div>
                                        <div class="form-group row ">
                                            <label for="duration" class='col-md-3 control-label'>Duration If recurring price (months): </label>
                                            <div class='col-md-9'>
                                                <input type="text" id="duration" name="duration" value="<%=getRsValue(rs, "duration")%>" class="form-control" />
                                            </div>
                                        </div>
                                        <div class="form-group row <%=(getRsValue(rs, "flash_sale").equals("quantity")?"":"d-none")%>">
                                            <label for="flash_sale_quantity" class='col-md-3 control-label'>Quantity (Flash Sale): </label>
                                            <div class='col-md-9'>
                                                <input type="text" id="flash_sale_quantity" name="flash_sale_quantity" value="<%=getRsValue(rs, "flash_sale_quantity")%>" class="form-control" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- Global information -->

                            <!-- Rule -->
                            <div class="card mb-2">
                                <div class="card-header bg-secondary" data-toggle="collapse" href="#collapsePromotionRule" 
                                    role="button" aria-expanded="true" aria-controls="collapsePromotionRule">
                                    <strong>Rule</strong>
                                </div>
                                <div class="collapse show p-3" id="collapsePromotionRule" style="border:none;">
                                    <div class="card-body">
                                        <div class="form-group row">
                                            <label for="staticEmail" class="col-sm-3 col-form-label is-required">Price diff applied</label>
                                            <div class="col-sm-9">
                                                <div class="input-group">
                                                    <%
                                                            arr = new ArrayList<String>();
                                                            arr.add(getRsValue(rs, "discount_type"));
                                                    %>
                                                    <%=addSelectControl("discount_type", "discount_type", discount_types, arr, "custom-select", "", false)%>
                                                    <input type="text" id="discount_value" name="discount_value" value="<%=getRsValue(rs, "discount_value")%>" class="form-control" />
                                                    <div class="invalid-feedback">Price diff and value are mandatory.</div>
                                                </div>
                                            </div>
                                        </div>
                                        <div id="appliedToContainer" class="form-group row">
                                            <label for="" class='col-md-3 control-label'>On: </label>


                                            <div id="appliedToTemplate" class="col-md-9">
                                                <div class="rule-list">
                                                    <div class="input-group-append mb-2">
                                                        <%
                                                                arr = new ArrayList<String>();
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
                                                                <%= escapeCoteValue(label)%>
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
<!-- /Promotion -->

<%
    } else if(action.equals("deliveryfees")){

        LinkedHashMap<String, String> dep_types = new LinkedHashMap<String, String>();

        dep_types.put("all","All");
        dep_types.put("city","City");
        dep_types.put("daline2","Address line 2");
        dep_types.put("postal","Postal Code");

        LinkedHashMap<String, String> yesNoValues = new LinkedHashMap<String, String>();
        yesNoValues.put("1","Yes");
        yesNoValues.put("0","No");

		LinkedHashMap<String, String> selection_types = new LinkedHashMap<String, String>();
		selection_types.put("sku","SKU");
		selection_types.put("product","Product");
		selection_types.put("product_type","Product Type");
		selection_types.put("catalog","Catalog");
		selection_types.put("manufacturer","Manufacturer");
		selection_types.put("tag","Tag");
		selection_types.put("all","All");

		LinkedHashMap<String, String> feedbackDDValues = new LinkedHashMap<String, String>();
		feedbackDDValues.put("all","All Users");
		feedbackDDValues.put("logged","Logged-in Users");

		String id = parseNull(request.getParameter("id"));;

		Set rs = null;
        Set rsRules = null;
		String selectedDeliveryType = "";
		if(id.length() > 0)
		{
			rs = Etn.execute("SELECT * FROM deliveryfees WHERE id =  " + escape.cote(id));
			rs.next();
			selectedDeliveryType = parseNull(rs.value("delivery_type"));
			rsRules = Etn.execute("SELECT * FROM deliveryfees_rules WHERE deliveryfee_id="+escape.cote(id));
		}

		String lastpublish = "";
		String nextpublish = "";

		if(id.length() > 0)
		{
			String process = getProcess("deliveryfee");
			Set rspw = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s') from post_work where status = 0 and phase = 'publish' and client_key = " + escape.cote(id) + " and proces = "+escape.cote(process)+" ");
			if(rspw.next()) nextpublish = parseNull(rspw.value(0));

			rspw = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s') from post_work where status  in (0, 2) and phase = 'published' and client_key = " + escape.cote(id) + " and proces = "+escape.cote(process)+" order by id desc limit 1 ");
			if(rspw.next()) lastpublish = parseNull(rspw.value(0));
		}

		Set rsDeliveryType = Etn.execute("select * from delivery_methods where site_id = "+escape.cote(selectedsiteid)+ " and method = 'home_delivery' and coalesce(subType,'') <> '' and enable = 1 order by subType");
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

<!-- Delivery Fee -->
<div class="container">
    <style>.rule-list:nth-of-type(2){margin-left:0px !important}</style>
    <form name='saveForm' id='saveForm' method='post' action='savedeliveryfees.jsp'  >
        <input type='hidden' name='id' value='<%=getValue(rs, "id")%>' />

        <div class="col-sm-12 multilingual-section">
            <table id="languagetable" cellpadding="0" cellspacing="0" border="0" style="margin-bottom: 10px;">
                <tr>
                    <%= getLanguageTabs(langsList)%>

                    <div style="padding-bottom: 20px; float: right;">
                        <button id="selectionSave" type="button" class="btn btn-primary" 
                        style="max-height:44.25px; position: absolute; right: 15px; top: 0px; z-index: 1000;" onclick='onDeliveryFeeSave()'>Save</button>
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
                                            <label for="name" class='col-md-3 control-label is-required'>Description: </label>
                                            <div class='col-md-9'>
                                                <%=getLanguageTextArea(langsList,rs)%>
                                                <div class="invalid-feedback">Description is mandatory.</div>
                                            </div>
                                        </div>
                                        <div class="form-group row ">
                                            <label for="visible_to" class='col-md-3 control-label'>Applicable to: </label>
                                            <div class='col-md-9'>
                                                <%
                                                        ArrayList arr = new ArrayList<String>();
                                                        arr.add(getRsValue(rs, "visible_to"));
                                                %>
                                                <%=addSelectControl("visible_to", "visible_to", feedbackDDValues, arr, "custom-select", "", false)%>
                                            </div>
                                        </div>
                                        <div class="form-group row ">
                                            <label for="applicable_per_item" class='col-md-3 control-label'>Applicable per item: </label>
                                            <div class='col-md-9'>
                                                <%
                                                        arr = new ArrayList<String>();
                                                        arr.add(getRsValue(rs, "applicable_per_item"));
                                                %>
                                                <%=addSelectControl("applicable_per_item", "applicable_per_item", yesNoValues, arr, "custom-select", "", false)%>
                                            </div>
                                        </div>
                                        <div class="form-group row ">
                                            <label for="dep_type" class='col-md-3 control-label'>Zone: </label>
                                            <div class='col-md-9'>
                                                <div class="input-group">
                                                    <%
                                                            arr = new ArrayList<String>();
                                                            arr.add(getRsValue(rs, "dep_type"));
                                                    %>
                                                    <%=addSelectControl("dep_type", "dep_type", dep_types, arr, "custom-select", "onchange=checkDepType(this)", false)%>
                                                    <input type="text" id="dep_value" name="dep_value" value="<%=getRsValue(rs, "dep_value")%>" class="form-control" <%=getRsValue(rs, "dep_type").equals("all")?"readonly":""%> />
                                                    <div class="invalid-feedback">Zone is mandatory.</div>
                                                </div>
                                            </div>
                                        </div>
                                        <% if(rsDeliveryType.rs.Rows > 0){%>
                                        <div class="form-group row ">
                                            <label for="dep_type" class='col-md-3 control-label'>Delivery Type: </label>
                                            <div class='col-md-9'>
                                                <div class="input-group">
                                                    <select class="custom-select" name="delivery_type" id="delivery_type">
                                                        <% while(rsDeliveryType.next()){%>
                                                        <option <%=(selectedDeliveryType.equals(rsDeliveryType.value("subType"))?"selected":"")%> value="<%=escapeCoteValue(rsDeliveryType.value("subType"))%>"><%=escapeCoteValue(rsDeliveryType.value("subType"))%></option>
                                                        <%}%>
                                                    </select>
                                                    <div class="invalid-feedback">Delivery type is mandatory.</div>
                                                </div>
                                            </div>
                                        </div>
                                        <%}%>
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
                                            <label for="fee" class="col-sm-3 col-form-label is-required">Delivery Fee</label>
                                            <div class="col-sm-9">
                                                    <input type="text" id="fee" name="fee" value="<%=getRsValue(rs, "fee")%>" class="form-control" />
                                                    <div class="invalid-feedback">Delivery Fee is mandatory.</div>
                                            </div>
                                        </div>
                                        <div id="appliedToContainer" class="form-group row">
                                            <label for="" class='col-md-3 control-label'>On: </label>


                                            <div id="appliedToTemplate" class="col-md-9">
                                                <div class="rule-list">
                                                    <div class="input-group-append mb-2">
                                                        <%
                                                                arr = new ArrayList<String>();
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
<!-- /Delivery Fee -->

<%
    } else if(action.equals("deliverymins")){

        LinkedHashMap<String, String> dep_types = new LinkedHashMap<String, String>();

        dep_types.put("all","All");
        dep_types.put("city","City");
		dep_types.put("daline2","Address line 2");
        dep_types.put("postal","Postal Code");
		

        LinkedHashMap<String, String> criteria_types = new LinkedHashMap<String, String>();
        criteria_types.put("minimum","Minimum");
        criteria_types.put("maximum","Maximum");

        LinkedHashMap<String, String> minimum_types = new LinkedHashMap<String, String>();
        minimum_types.put("price","Price");
        minimum_types.put("quantity","Quantity");

        LinkedHashMap<String, String> feedbackDDValues = new LinkedHashMap<String, String>();
        feedbackDDValues.put("all","All Users");
        feedbackDDValues.put("logged","Logged-in Users");

        String id = parseNull(request.getParameter("id"));;

        Set rs = null;
        if(id.length() > 0)
        {
            rs = Etn.execute("SELECT * FROM deliverymins WHERE id =  " + escape.cote(id));
            rs.next();
        }

        String lastpublish = "";
        String nextpublish = "";

        if(id.length() > 0)
        {
            String process = getProcess("deliverymin");
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

<!-- Delivery min -->
<div class="container">
    <style>.rule-list:nth-of-type(2){margin-left:0px !important}</style>
    <form name='saveForm' id='saveForm' method='post' action='savedeliverymins.jsp'  >
        <input type='hidden' name='id' value='<%=getValue(rs, "id")%>' />

        <div class="col-sm-12 multilingual-section">
            <table id="languagetable" cellpadding="0" cellspacing="0" border="0" style="margin-bottom: 10px;">
                <tr>
                    <%= getLanguageTabs(langsList)%>

                    <div style="padding-bottom: 20px; float: right;">
                        <button id="selectionSave" type="button" class="btn btn-primary" 
                        style="max-height:44.25px; position: absolute; right: 15px; top: 0px; z-index: 1000;" onclick='onDeliveryMinSave()'>Save</button>
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
                                            <label for="name" class='col-md-3 control-label is-required'>Description: </label>
                                            <div class='col-md-9'>
                                                <%=getLanguageTextArea(langsList,rs)%>
                                                <div class="invalid-feedback">Description is mandatory.</div>
                                            </div>
                                        </div>
                                        <div class="form-group row ">
                                            <label for="visible_to" class='col-md-3 control-label'>Applicable to: </label>
                                            <div class='col-md-9'>
                                                <%
                                                        ArrayList arr = new ArrayList<String>();
                                                        arr.add(getRsValue(rs, "visible_to"));
                                                %>
                                                <%=addSelectControl("visible_to", "visible_to", feedbackDDValues, arr, "custom-select", "", false)%>
                                            </div>
                                        </div>
                                        <div class="form-group row ">
                                            <label for="dep_type" class='col-md-3 control-label'>Zone: </label>
                                            <div class='col-md-9'>
                                                <div class="input-group">
                                                    <%
                                                            arr = new ArrayList<String>();
                                                            arr.add(getRsValue(rs, "dep_type"));
                                                    %>
                                                    <%=addSelectControl("dep_type", "dep_type", dep_types, arr, "custom-select", "onchange=checkDepType(this)", false)%>
                                                    <input type="text" id="dep_value" name="dep_value" value="<%=getRsValue(rs, "dep_value")%>" class="form-control" <%=getRsValue(rs, "dep_type").equals("all")?"readonly":""%> />
                                                    <div class="invalid-feedback">Zone is mandatory.</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- Global information -->

                            <!-- Rule -->
                            <%-- <div class="btn-group col-12" style="padding-left:0px; padding-right:0px" role="group" aria-label="Basic example">
                                <button type="button" class="btn btn-secondary btn-lg btn-block text-left mb-2" data-toggle="collapse" 
                                href="#collapseRule" role="button" aria-expanded="false" aria-controls="collapseRule">Rule</button>
                            </div> --%>
                            <div class="card mb-2">
                                <div class="card-header bg-secondary" data-toggle="collapse" href="#collapseRule" role="button" 
                                aria-expanded="true" aria-controls="collapseRule">
                                    <strong>Rule</strong>
                                </div>
                                <div class="collapse show p-3" id="collapseRule" style="border:none;">
                                    <div class="card-body">
                                        <div class="form-group row">
                                            <label for="minimum_total" class="col-sm-3 col-form-label is-required">Delivery Min</label>
                                            <div class="col-sm-9">
                                                <div class="input-group">
                                                    <%
                                                            arr = new ArrayList<String>();
                                                            arr.add(getRsValue(rs, "criteria_type"));
                                                    %>
                                                    <%=addSelectControl("criteria_type", "criteria_type", criteria_types, arr, "custom-select", "", false)%>
                                                    <%
                                                            arr = new ArrayList<String>();
                                                            arr.add(getRsValue(rs, "minimum_type"));
                                                    %>
                                                    <%=addSelectControl("minimum_type", "minimum_type", minimum_types, arr, "custom-select", "", false)%>
                                                    <input type="text" id="minimum_total" name="minimum_total" value="<%=getRsValue(rs, "minimum_total")%>" class="form-control" />
                                                    <div class="invalid-feedback">Delivery Minimum is mandatory.</div>
                                                </div>
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
<!-- /Delivery Minimum -->

<%
    } else if(action.equals("copyDeliveryMin")){

        String id = parseNull(request.getParameter("id"));
        String name = parseNull(request.getParameter("newName"));
        String query = "";
        status = STATUS_SUCCESS;

        try{

            query = "INSERT INTO deliverymins (created_by, visible_to, dep_type, dep_value, min, lang_1_description, lang_2_description, lang_3_description, lang_4_description, lang_5_description, site_id, version) SELECT "+escape.cote(""+Etn.getId())+", visible_to, dep_type, dep_value, min, lang_1_description, lang_2_description, lang_3_description, lang_4_description, lang_5_description, site_id, version FROM deliverymins WHERE id = " + escape.cote(id);

            int rowId = Etn.executeCmd(query);

            if(rowId > 0){

                query = "UPDATE deliverymins SET name = " + escape.cote(name) + " WHERE id = " + escape.cote(rowId+"");
                Etn.executeCmd(query);

            }

        } catch(Exception e){

            status = STATUS_ERROR;
            message = e.getMessage();
        }

        out.write("{\"status\":\""+status+"\",\"message\":\""+message+"\"}");

    } else if(action.equals("copyDeliveryFee")){

        String id = parseNull(request.getParameter("id"));
        String name = parseNull(request.getParameter("newName"));
        String query = "";
        status = STATUS_SUCCESS;

        try{

            query = "INSERT INTO deliveryfees (created_by, visible_to, dep_type, dep_value, fee, applicable_per_item, lang_1_description, lang_2_description, lang_3_description, lang_4_description, lang_5_description, site_id, version) SELECT "+escape.cote(""+Etn.getId())+", visible_to, dep_type, dep_value, fee, applicable_per_item, lang_1_description, lang_2_description, lang_3_description, lang_4_description, lang_5_description, site_id, version FROM deliveryfees WHERE id = " + escape.cote(id);

            int rowId = Etn.executeCmd(query);

            if(rowId > 0){

                query = "UPDATE deliveryfees SET name = " + escape.cote(name) + " WHERE id = " + escape.cote(rowId+"");
                Etn.executeCmd(query);

            }

            query = "INSERT INTO deliveryfees_rules (deliveryfee_id, applied_to_type, applied_to_value) SELECT '" + rowId + "', applied_to_type, applied_to_value FROM deliveryfees_rules WHERE deliveryfee_id = " + escape.cote(id);

            Etn.executeCmd(query);

        } catch(Exception e){

            status = STATUS_ERROR;
            message = e.getMessage();
        }

        out.write("{\"status\":\""+status+"\",\"message\":\""+message+"\"}");

    } else if(action.equals("copyPromotion")){

        String promotionId = parseNull(request.getParameter("promotionId"));
        String promotionName = parseNull(request.getParameter("promotionNewName"));
        String query = "";
        status = STATUS_SUCCESS;

        try{

            query = "INSERT INTO promotions (created_by, start_date, end_date, flash_sale, flash_sale_quantity, visible_to, discount_type, discount_value, duration, lang_1_description, lang_2_description, lang_3_description, lang_4_description, lang_5_description, site_id, version) SELECT "+escape.cote(""+Etn.getId())+", start_date, end_date, flash_sale, flash_sale_quantity, visible_to, discount_type, discount_value, duration, lang_1_description, lang_2_description, lang_3_description, lang_4_description, lang_5_description, site_id, version FROM promotions WHERE id = " + escape.cote(promotionId);

            int rowId = Etn.executeCmd(query);

            if(rowId > 0){

                query = "UPDATE promotions SET name = " + escape.cote(promotionName) + " WHERE id = " + escape.cote(rowId+"");
                Etn.executeCmd(query);

            }

            query = "INSERT INTO promotions_rules (promotion_id, applied_to_type, applied_to_value) SELECT '" + rowId + "', applied_to_type, applied_to_value FROM promotions_rules WHERE promotion_id = " + escape.cote(promotionId);

            Etn.executeCmd(query);

        } catch(Exception e){

            status = STATUS_ERROR;
            message = e.getMessage();
        }

        out.write("{\"status\":\""+status+"\",\"message\":\""+message+"\"}");

    } else if(action.equals("copyAdditionalFee")){

        String additionalFeeId = parseNull(request.getParameter("additionalFeeId"));
        String additionalFeeNewName = parseNull(request.getParameter("additionalFeeNewName"));
        String query = "";
        status = STATUS_SUCCESS;

        try{

            query = "INSERT INTO additionalfees (site_id, version, created_by, lang_1_description, lang_2_description, lang_3_description, lang_4_description, lang_5_description, visible_to, start_date, end_date) SELECT site_id, version, "+escape.cote(""+Etn.getId())+", lang_1_description, lang_2_description, lang_3_description, lang_4_description, lang_5_description, visible_to, start_date, end_date FROM additionalfees WHERE id = " + escape.cote(additionalFeeId);

            int rowId = Etn.executeCmd(query);

            if(rowId > 0){

                query = "UPDATE additionalfees SET additional_fee = " + escape.cote(additionalFeeNewName) + " WHERE id = " + escape.cote(rowId+"");
                Etn.executeCmd(query);

            }

            query = "INSERT INTO additionalfee_rules (add_fee_id, rule_apply, rule_apply_value, element_type, element_type_value) SELECT '" + rowId + "', rule_apply, rule_apply_value, element_type, element_type_value FROM additionalfee_rules WHERE add_fee_id = " + escape.cote(additionalFeeId);

            Etn.executeCmd(query);

        } catch(Exception e){

            status = STATUS_ERROR;
            message = e.getMessage();
        }

        out.write("{\"status\":\""+status+"\",\"message\":\""+message+"\"}");

    } else if(action.equals("copyComeWith")){

        String comewithId = parseNull(request.getParameter("comeWithId"));
        String comewithNewName = parseNull(request.getParameter("comeWithNewName"));
        String query = "";
        status = STATUS_SUCCESS;

        try{

            query = "INSERT INTO comewiths (site_id, version, created_by, lang_1_description, lang_2_description, lang_3_description, lang_4_description, lang_5_description, visible_to, start_date, end_date, comewith, type, applied_to_type, applied_to_value, title) SELECT site_id, version, "+escape.cote(""+Etn.getId())+", lang_1_description, lang_2_description, lang_3_description, lang_4_description, lang_5_description, visible_to, start_date, end_date, comewith, type, applied_to_type, applied_to_value, title FROM comewiths WHERE id = " + escape.cote(comewithId);

            int rowId = Etn.executeCmd(query);

            if(rowId > 0){

                query = "UPDATE comewiths SET name = " + escape.cote(comewithNewName) + " WHERE id = " + escape.cote(rowId+"");
                Etn.executeCmd(query);

            }

            query = "INSERT INTO comewiths_rules (comewith_id, associated_to_type, associated_to_value) SELECT '" + rowId + "', associated_to_type, associated_to_value FROM comewiths_rules WHERE comewith_id = " + escape.cote(comewithId);

            Etn.executeCmd(query);

        } catch(Exception e){

            status = STATUS_ERROR;
            message = e.getMessage();
        }

        out.write("{\"status\":\""+status+"\",\"message\":\""+message+"\"}");

    }
%>
