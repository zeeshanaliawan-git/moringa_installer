<%
  response.setCharacterEncoding("utf-8");
  request.setCharacterEncoding("utf-8");
%>
<%@page import="com.etn.lang.Xml.Rs2Xml"%>
<%@page import="com.etn.sql.escape"%>
<%@page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList,java.util.List, java.util.LinkedHashMap, java.util.Map, java.text.SimpleDateFormat, com.etn.beans.app.GlobalParm"%>
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
    List<Language> langsList = getLangs(Etn,selectedsiteid);
	Language firstLanguage = langsList.get(0);

    if(action.equals("order_subsidies")){

        try{

            String subsidiesIds = parseNull(request.getParameter("subsidyIds"));
            String SeqOrder = parseNull(request.getParameter("seq_order"));

            String subsidyIdList[] = subsidiesIds.split(",");
            String SqOrderFlag[] = SeqOrder.split(",");

            if( subsidyIdList.length == 0 ){
                    throw new Exception("");
            }

            String q = "";
            for(int i=0; i<subsidyIdList.length; i++){

                if(SqOrderFlag[i].equals("true"))
                    q = "UPDATE subsidies SET order_seq = " + (i+1) + ", version = version + 1 WHERE id = " + escape.cote(subsidyIdList[i]);
                else
                    q = "UPDATE subsidies SET order_seq = " + (i+1) + " WHERE id = " + escape.cote(subsidyIdList[i]);

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

    }  else if(action.equals("subsidy")){

        LinkedHashMap<String, String> feedbackDDValues = new LinkedHashMap<String, String>();
        feedbackDDValues.put("all","All Users");
        feedbackDDValues.put("logged","Logged-in Users");

        LinkedHashMap<String, String> availableTypeValues = new LinkedHashMap<String, String>();
        availableTypeValues.put("sku","SKU");
        availableTypeValues.put("product","Product");
        availableTypeValues.put("product_type","Product Type");
        availableTypeValues.put("catalog","Catalog");
        availableTypeValues.put("manufacturer","Manufacturer");
        availableTypeValues.put("tag","Tag");

        LinkedHashMap<String, String> discountTypeValues = new LinkedHashMap<String, String>();
        
        discountTypeValues.put("fixed","\"-\" fixed amount of original price");
        discountTypeValues.put("percentage","% (-) of original price");

        String id = parseNull(request.getParameter("id"));

        Set rs = null;
        Set rsSubsidiesRules = null;

        if(id.length() > 0)
        {
            rs = Etn.execute("SELECT * FROM subsidies WHERE id =  " + escape.cote(id));
            rs.next();

            rsSubsidiesRules = Etn.execute("SELECT * FROM subsidies_rules WHERE subsidy_id = " + escape.cote(id));
            rsSubsidiesRules.next();

        }

        String startDate = getRsValue(rs, "start_date");
        String endDate = getRsValue(rs, "end_date");

        if(startDate.length() > 0) startDate = buildDateFr(startDate);
        if(endDate.length() > 0) endDate = buildDateFr(endDate);
      
%>
        <!-- additional fees -->
        <form <% if(id.length() > 0){ %> id='editSubsidyfrm' <% }else{%> id='subsidyfrm' <% } %> name='subsidyfrm' method='post' action='savesubsidies.jsp' >

        <%
            if(id.length() > 0){
        %>
                <input type='hidden' name='id' id="subsidy_id" value='<%=getValue(rs, "id")%>' />
        <%
            }
        %>
            <div class="col-sm-12 multilingual-section">
                <table id="languagetable" cellpadding="0" cellspacing="0" border="0" style="margin-bottom: 10px;">
                    <tr>
                        <%=getLanguageTabs(langsList)%>
            
                       <div style="padding-bottom: 20px; float: right;">
                            <button id="selectionSave" type="button" class="btn btn-primary" style="max-height:44.25px; position: absolute; right: 15px; top: 0px; z-index: 1000;" <% if(id.length() > 0){ %> onclick='onEditSubsidySave()' <% }else{%> onclick='onSubsidySave()' <% } %>>Save</button>               
                       </div>

                        <!-- Tab panes -->
                        <div class="tab-content p-3">
                
                            <div id="tab_lang1show" class="container tab-pane active"><br>
                                
                                <%
                                    ArrayList arr = new ArrayList<String>();
                                %>
                                <!-- Global information -->
                                <div class="card mb-2">
                                    <div class="card-header bg-secondary" data-toggle="collapse" href="#general_info" role="button" aria-expanded="true" 
                                    aria-controls="general_info">
                                        <strong>General information</strong>
                                    </div>
                                    <div class="collapse show p-3" id="general_info" style="border:none;">
                                        <div class="card-body">
                                            <div class="form-group row ">
                                                <label for="name" class='col-md-3 control-label is-required'>Subsidy name:</label>
                                                <div class='col-md-9'>
                                                    <input type="text" id="name" name="name" value="<%=getRsValue(rs, "name")%>" class="form-control" />
                                                    <div class="invalid-feedback">Subsidy name is mandatory.</div>
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
                                      
                                <!-- subsidies rules -->
                                <div class="card mb-2">
                                    <div class="card-header bg-secondary" data-toggle="collapse" href="#subsidies_rules" role="button" aria-expanded="true" 
                                    aria-controls="subsidies_rules">
                                        <strong>Rule</strong>
                                    </div>
                                    <div class="collapse show p-3" id="subsidies_rules" style="border:none;">
                                        <div class="card-body">
                                            <div id="appliedToContainer">
                                                <div id="AdditionalPricesTemplate">                        
                                                    <div class="appliedToTemplate" >
                                                        <div class="form-group row ">
                                                            <label for="applied_to_type" class='col-md-3 control-label is-required'>Subsidy on : </label>
                                                            <div class="col-md-9">
                                                                <div class="input-group-append">
                                                                    <%
                                                                        arr = new ArrayList<String>();
                                                                        arr.add(getRsValue(rs, "applied_to_type"));
                                                                    %>
                                                                    <%=addSelectControl("applied_to_type", "applied_to_type", availableTypeValues, arr, "custom-select w-50", "", false)%>


                                                                    <%
                                                                        if(id.length() == 0){ 

                                                                    %>
                                                                            <div class="position-relative w-100">
                                                                                <input id="applied_to_value" type="text" class="form-control applied_to_value_subsidy" />
                                                                            </div>
                                                                            <input id="applied_to_value_key_subsidy" name="applied_to_value" type="hidden" class="form-control" />
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
                                                                                <input type="text" id="applied_to_value" class="form-control applied_to_value_subsidy" value='<%=escapeCoteValue(value)%>' />
                                                                            </div>
                                                                            <input type="hidden" name="applied_to_type" value='<%=escapeCoteValue(type)%>' /> 
                                                                            <input type="hidden" id="applied_to_value_key_subsidy" name="applied_to_value" value='<%=escapeCoteValue(value)%>' /> 

                                                                    <%
                                                                        }
                                                                    }
                                                                %>
                                                                </div>
                                                            </div>
                                                            <div class="invalid-feedback">Subsidy on and value are mandatory.</div>
                                                        </div>

                                                        <div class="form-group row">
                                                            <label for="discount_type" class="col-sm-3 col-form-label is-required">Price diff applied : </label>
                                                            <div class="col-sm-9">
                                                                <div class="input-group">
                                                                    <%
                                                                        arr = new ArrayList<String>();
                                                                        arr.add(getRsValue(rs, "discount_type"));
                                                                    %>
                                                                    <%=addSelectControl("discount_type", "discount_type", discountTypeValues, arr, "custom-select", "", false)%>
                                                                    <input type="text" id="discount_value" name="discount_value" value="<%=getRsValue(rs, "discount_value")%>" class="form-control" />
                                                                    <div class="invalid-feedback">Price diff and value are mandatory.</div>
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <div class="form-group row">
                                                            <label for="redirect_url" class="col-sm-3 col-form-label">Url : </label>
                                                            <div class="col-sm-9">
                                                                <div class="input-group">
                                                                    <input type="text" id="redirect_url" name="redirect_url" class="form-control" value='<%=getRsValue(rs, "redirect_url")%>' />
                                                                    <input type="hidden" id="open_as" name="open_as" class="form-control" value='<%=getRsValue(rs, "open_as")%>' />
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <div class="form-group row ">
                                                            <label for="associated_to_type" class='col-md-3 control-label is-required'>if associated to : </label>
                                                            <div class="col-md-9">
                                                                <div class="input-group-append">
                                                                    <%
                                                                        arr = new ArrayList<String>();
                                                                        arr.add(getRsValue(rsSubsidiesRules, "associated_to_type"));
                                                                    %>

                                                                    <%=addSelectControl("associated_to_type", "associated_to_type", availableTypeValues, arr, "custom-select w-50 associated_to_type", "", false)%>
                                                                    <div class="position-relative w-100">
                                                                        <input type="text" class="form-control associated_to_value_subsidy" id="associated_to_value_subsidy" />
                                                                    </div>
                                                                    <input type="hidden" id="associated_to_type_key_subsidy" class="form-control" />
                                                                    <button type="button" class="btn btn-primary" onclick="add_selected_prod()">Add</button>               

                                                                </div>
                                                                <div class="invalid-feedback">Associated and value are mandatory.</div>
                                                            </div>
                                                        </div>

                                                    </div>
                                                </div>

                                                <div class="form-group row ">
                                                    <div class="col-sm-3"> </div>
                                                    <div id="selected_prod_hvng" class="col-sm-9 row">
                                                    <%

                                                        if(null != rsSubsidiesRules){

                                                            String type = "";
                                                            String value = "";
                                                            String label = "";

                                                            rsSubsidiesRules.moveFirst();
                                                            while(rsSubsidiesRules.next()){

                                                                type = getRsValue(rsSubsidiesRules, "associated_to_type");
                                                                value = getRsValue(rsSubsidiesRules, "associated_to_value");

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
                                                                    <input type="hidden" name="associated_to_type_subsidy" value='<%= escapeCoteValue(rsSubsidiesRules.value("associated_to_type"))%>' />
                                                                    <input type="hidden" name="associated_to_value_subsidy" value='<%= escapeCoteValue(rsSubsidiesRules.value("associated_to_value"))%>' /> 

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
                                <!-- /Subsidies rules -->

                            </div>                   
                        </div>

                    </tr>
                </table>
            </div>
        </form>
        <!-- /Subsidies -->

        <script>
            jQuery(document).ready(function() {
            <%

            if(null == rsSubsidiesRules || rsSubsidiesRules.rs.Rows == 0){
            %>
                addAssociatedTo();
            <%
            }

            if(null == rs || rs.rs.Rows == 0){
            %>
                addAppliedTo();
            <%
            }

            if(rsSubsidiesRules != null) rsSubsidiesRules.moveFirst();

            while(rsSubsidiesRules!=null && rsSubsidiesRules.next()){

                String label = getRsValue(rsSubsidiesRules, "associated_to_value");
                String type = getRsValue(rsSubsidiesRules, "associated_to_type");
                String value = getRsValue(rsSubsidiesRules, "associated_to_value");

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

            %>

                addAppliedTo('<%=type%>','<%=label%>','<%=value%>');

            <%
            }
            %>
            });
        </script>

<%

    } else if(action.equals("copySubsidy")){

        String subsidyId = parseNull(request.getParameter("subsidyId"));
        String subsidyNewName = parseNull(request.getParameter("subsidyNewName"));
        String query = "";
        status = STATUS_SUCCESS;

        try{

            query = "INSERT INTO subsidies (site_id, version, created_by, lang_1_description, lang_2_description, lang_3_description, lang_4_description, lang_5_description, visible_to, start_date, end_date, discount_type, discount_value, applied_to_type, applied_to_value) SELECT site_id, version, " + escape.cote("" + Etn.getId()) + ", lang_1_description, lang_2_description, lang_3_description, lang_4_description, lang_5_description, visible_to, start_date, end_date, discount_type, discount_value, applied_to_type, applied_to_value FROM subsidies WHERE id = " + escape.cote(subsidyId);

            int rowId = Etn.executeCmd(query);

            if(rowId > 0){

                query = "UPDATE subsidies SET name = " + escape.cote(subsidyNewName) + " WHERE id = " + escape.cote(rowId + "");
                Etn.executeCmd(query);

            }

            query = "INSERT INTO subsidies_rules (subsidy_id, associated_to_type, associated_to_value) SELECT '" + rowId + "', associated_to_type, associated_to_value FROM subsidies_rules WHERE subsidy_id = " + escape.cote(subsidyId);

            Etn.executeCmd(query);

        } catch(Exception e){

            status = STATUS_ERROR;
            message = e.getMessage();
        }

        out.write("{\"status\":\""+status+"\",\"message\":\""+message+"\"}");

    }
%>
