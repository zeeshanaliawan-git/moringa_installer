<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.ArrayList, java.util.HashMap "%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%

    String q = "";
    Set rs = null;
    // String siteId = getSiteId(session);

    String menuId = parseNull(request.getParameter("id"));

    Set menuRs = null;
    if(menuId.length() > 0){

    	q = "SELECT m.id, m.name, m.template_id"
	        + " FROM menus m"
	        + " JOIN bloc_templates bt ON bt.id = m.template_id"
	        + " WHERE m.id = " + escape.cote(menuId)
	        + " AND m.site_id = " + escape.cote(getSiteId(session))
	        + " AND bt.type = " + escape.cote(Constant.SYSTEM_TEMPLATE_MENU);
	    menuRs = Etn.execute(q);

	    if(!menuRs.next()){
	        response.sendRedirect("menus.jsp");
	    }
	}


    String menuName = "";

    String siteFolderName = "";

    if(menuRs != null){
        menuName = menuRs.value("name");
    }
    else{
        Set siteRs = Etn.execute("SELECT name FROM " + GlobalParm.getParm("PORTAL_DB") + ".sites WHERE id = " + escape.cote(getSiteId(session)));
        if(siteRs.next()){
            String siteName = parseNull(siteRs.value("name"));
            siteFolderName = removeSpecialCharacters(removeAccents(siteName)).toLowerCase();
        }
    }

    List<Language> langsList = getLangs(Etn,getSiteId(session));
    String PROD_PORTAL_LINK = getProdPortalLink(Etn);
    String MENU_APP_URL = GlobalParm.getParm("MENU_APP_URL");

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="../WEB-INF/include/head2.jsp"%>
    <title>Menu editor</title>


    <script src="<%=request.getContextPath()%>/ckeditor/ckeditor.js"></script>
    <script src="<%=request.getContextPath()%>/ckeditor/adapters/jquery.js"></script>
    <script>
        CKEDITOR.timestamp = "" + parseInt(Math.random()*100000000);
    </script>

    <style type="text/css">

        .ui-datepicker.ui-widget{
            z-index: 2000 !important;
        }

    </style>
</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
            <!-- beginning of container -->
            <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-2 border-bottom">
                <%
                    String heading = "Add new menu";
                    if(menuRs != null){
                        heading = "<span>Edit: " + menuName;
                    }

                %>
                <div>
                    <h1 class="h2 float-left"><%=heading%></h1>
                </div>



                <div class="btn-toolbar mb-2 mb-md-0 flex-wrap flex-md-nowrap">

                    <div class="btn-group mr-2">
                        <button type="button" class="btn btn-primary"
                            onclick="goBack('menus.jsp')">Back</button>
                        <button class="btn btn-primary" type="button"
                            onclick="onSaveMenu()">save</button>
                    </div>
                </div>
            </div>
            <!-- row -->
            <div class="row">
                <div class="col" id="mainFormDiv">
                    <div class="invalid-feedback pb-2" style="display:block;" id="errorMsgDiv" ></div>
                    <form id="mainForm" action="" method="POST" onsubmit="return false;" noValidate>
                        <input type="hidden" name="requestType" value='saveMenu'>
                        <input type="hidden" name="menuId" id="menuId" value='<%=menuId%>'>
                        <input type="hidden" name="templateData" value=''>

                        <!-- menu info -->
                        <div class="btn-group w-100 mb-1">
                            <button type="button" class="btn btn-secondary btn-lg btn-block text-left"
                                data-toggle="collapse" href="#menuInfoCollapse" role="button" >
                                Menu information
                            </button>
                            <!-- <button type="button" class="btn btn-primary" onclick='onSaveMenu()'>Save</button> -->
                        </div>
                        <div class="collapse show p-3" id="menuInfoCollapse">

                            <!-- hidden on new, shown for saved  -->
                            <div class="form-group row d-none showOnEdit">
                                <label class="col-sm-3 col-form-label">Menu UUID</label>
                                <div class="col-sm-9">
                                    <input type="text" class="form-control " name="uuid" disabled="" value="" >
                                </div>
                            </div>

                            <div class="form-group row">
                                <label class="col-sm-3 col-form-label">Menu name</label>
                                <div class="col-sm-9">
                                    <input type="text" class="form-control" name="name" value=""
                                            maxlength="300" required="" >
                                    <div class="invalid-feedback">
                                        Cannot be empty
                                    </div>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label class="col-sm-3 col-form-label">Menu template</label>
                                <div class="col-sm-9">
                                    <select name="template_id" class="custom-select editDisabled" required=""
                                        onChange="onChangeTemplate(this)" >
                                        <option value=''>-- menu template --</option>
                                        <%
                                            q = "SELECT id, name, custom_id FROM bloc_templates "
                                                + " WHERE site_id = " + escape.cote(getSiteId(session))
                                                + " AND type = 'menu'";
                                            rs = Etn.execute(q);
                                            while(rs.next()){
                                                String label = rs.value("name") + " ("+rs.value("custom_id") + ")";
                                        %>
                                            <option value='<%=rs.value("id")%>'><%=label%></option>
                                        <%
                                            }
                                        %>
                                    </select>
                                    <div class="invalid-feedback">
                                        Select a template.
                                    </div>
                                </div>
                            </div>

                            <div class="form-group row">
                                <label class="col-sm-3 col-form-label">Language</label>
                                <div class="col-sm-9">
                                    <select name="langue_id" id="langue_id" class="custom-select" required=""
                                        onchange="onChangeMenuLang(this)">
                                        <%
                                            for (Language lang:langsList) {
                                        %>
                                            <option value='<%=lang.getLanguageId()%>' data-lang-code='<%=lang.getCode()%>' ><%=lang.getLanguage() +" - "+ lang.getCode()%> </option>
                                        <%
                                            }
                                        %>
                                    </select>
                                    <div class="invalid-feedback">
                                        Select a language.
                                    </div>
                                </div>
                            </div>
                        <%--
                            <div class="form-group row">
                                <label class="col-sm-3 col-form-label">Prod path</label>
                                <div class="col-sm-9">
                                    <div class="input-group">
                                        <div class="input-group-prepend">
                                            <span class="input-group-text"><%=PROD_PORTAL_LINK%></span>
                                        </div>
                                        <% if(menuRs == null){ %>
                                        <input type="text" class="form-control production_path editDisabled"
                                            name="production_path" id="production_path"
                                            value="" maxlength="100"
                                            onkeyup="onProdPathKeyup(this)"
                                            onblur="onPathBlur(this,true)"
                                            required="" >

                                        <div class="input-group-append">
                                            <span class="input-group-text rounded-right">/</span>
                                        </div>
                                        <% } else { %>
                                            <input type="text" class="form-control production_path editDisabled"
                                            name="production_path" id="production_path"
                                            value="" disabled="">
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label class="col-3 col-form-label">Homepage URL</label>
                                <div class="col-9">
                                    <input type="text" class="form-control" name="homepage_url" value=""
                                            maxlength="2000" required="" id="homepage_url" >
                                    <div class="invalid-feedback">
                                        Cannot be empty
                                    </div>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label class="col-3 col-form-label">Page 404 URL</label>
                                <div class="col-9">
                                    <input type="text" class="form-control" name="page_404_url" value=""
                                            maxlength="2000" required="" id="page_404_url" >
                                    <div class="invalid-feedback">
                                        Cannot be empty
                                    </div>
                                </div>
                            </div>

                            <div class="form-group row" >
                                <label class="col col-form-label">Favicon</label>
                                <div class="col-sm-9">
                                    <div class="card image_card">
                                        <div class="card-body text-center image_body">
                                            <input type="hidden" name="favicon"
                                                   value="" class="image_value">
                                            <img class="card-image-top" style="max-width:100px;max-height:100px" >
                                        </div>
                                        <div class="card-footer image_footer">
                                            <div class="form-group row mb-0">
                                                <div class="col-6">
                                                    <button type="button" class="btn btn-link"
                                                            onclick="loadFieldImage(this)">Load Image</button>
                                                </div>
                                                <div class="col-6">
                                                    <button type="button" class="btn btn-link text-danger"
                                                            onclick="clearFieldImage(this)">Delete Image</button>
                                                </div>
                                                <div class="col-12">
                                                    <input type="text" name="favicon_alt" value=""
                                                           class="image_alt form-control" placeholder="alt text" maxlength="50">

                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        --%>

                        </div>
                        <!-- /menu info -->
                    <%--
                        <!-- trust domain -->
                        <div class="btn-group w-100 mb-1">
                            <button type="button" class="btn btn-secondary btn-lg btn-block text-left "
                                    data-toggle="collapse" href="#trustedDomainsCollapse" role="button" >
                                Trusted domains
                            </button>
                            <button type="button" class="btn btn-success" onclick="addTrustedDomain()">+ Add a trusted domain</button>
                            <!-- <button type="button" class="btn btn-primary" onclick='onSaveMenu()'>Save</button> -->
                        </div>
                        <div class="collapse p-3" id="trustedDomainsCollapse">
                            <div class="table-responsive">
                                <table class="table table-bordered table-hover ">
                                  <thead class="thead-dark">
                                    <tr>
                                      <th scope="col">Apply to</th>
                                      <th scope="col">URL/Path</th>
                                      <th scope="col">Prod URL/Path</th>
                                      <th scope="col">GTM</th>
                                      <th scope="col">Replace tags</th>
                                      <th>&nbsp;</th>
                                    </tr>
                                  </thead>
                                  <tbody id="trustedDomainsTableBody">
                                  </tbody>
                                </table>
                            </div>
                        </div>
                        <!-- /trust domain -->

                    --%>

                        <!-- templateSections -->
                        <div class="row">
                            <div class="col">
                                <div id="templateSectionsContainer" class="template_container bloc_section">
                                </div>

                            </div>
                        </div>
                        <!-- /templateSections -->

                    </form>

                </div>
            </div><!-- row -->
            <!-- container -->
            <!-- /end of container -->
        </main>
    <%@ include file="/WEB-INF/include/footer.jsp" %>
    </div>
    <div class="d-none">
        <div >
            <table>
            <tr id="trustedDomainRowTemplate">
                <td class="px-1">
                    <input type="hidden" name="apply_to_id" value="">
                    <select name="apply_type" class="custom-select" onchange="onChangeApplyType(this)">
                      <option value="url">Exact URL</option>
                      <option value="url_starting_with">URL starting with</option>
                    </select>
                </td>
                <td class="px-1">
                    <input type="text" class="form-control applyToInput" name="apply_to" value=""
                                    maxlength="255" required="required" placeholder="URL"
                                    onchange="onApplyToChange(this)"
                                    >
                </td>
                <td class="px-1">
                    <input type="text" class="form-control applyToInput" name="prod_apply_to" value=""
                                    maxlength="255">
                </td>
                <td align="center">
                      <input type="hidden" name="add_gtm_script" value="0">
                      <input class="form-check-input" type="checkbox" name="add_gtm_script_check"
                        value="1" onchange="onChangeGtmCheckbox(this)">
                </td>
                <td class="px-1" style="width: 20%;">
                    <input type="hidden" name="replace_tags" value="">
                    <span class="replaceTagsSpan"></span>
                </td>
                <td class="text-nowrap">
                    <button type="button" class="btn btn-sm btn-success" title="Replace tags"
                                onclick='openReplaceTagsWindow(this)' >
                                <i data-feather="code"></i></button>
                    <button type="button" class="btn btn-sm btn-danger" title="Delete"
                                onclick='deleteTrustedDomain(this)' >
                                <i data-feather="x"></i></button>
                </td>
            </tr>
            </table>
        </div>
    </div>

    <!-- template functions -->
    <%@ include file="templateFunctions.jsp" %>

<script type="text/javascript">

    $ch.contextPath = '<%=request.getContextPath()%>/';
    $ch.siteFolderName = '<%=siteFolderName%>';

    window.IMAGE_URL_PREPEND = '<%=getImageURLPrepend(getSiteId(session))%>';
    window.allTagsList = <%=getAllTagsJSON(Etn, getSiteId(session), GlobalParm.getParm("CATALOG_DB") )%>;
    // ready function
    $(function() {

        $('#langue_id').trigger('change');
        var menuId = $('#menuId').val();

        if(menuId.length > 0){
            loadMenuData();
        }
    });

    function loadMenuData(){
        var menuId = $('#menuId').val();

        if(menuId.length === 0) return false;


        $('.editDisabled').prop('disabled',true);

        showLoader();
        $.ajax({
            url: 'menusAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getMenuDetail',
                menuId : '<%=menuId%>',
            },
        })
        .done(function(resp) {
            var data = [];
            if(resp.status == 1){
                var menuData = resp.data.menu;
                var form = $('#mainForm');
                var fieldNames = ["uuid", "name","template_id","langue_id"];

                fieldNames.forEach(function(fieldName){
                    var formField = form.find('[name='+fieldName+']');
                    if(formField.length > 0){
                        formField.val(menuData[fieldName]).trigger('change');
                    }
                });

                var templateCode = menuData.template_code;
                var templateData = menuData.template_data;
                var templateDataObj = JSON.parse(templateData);
                generateTemplateForm(templateCode, templateDataObj);

                $('.showOnEdit').removeClass('d-none');
            }
            else{
                bootNotifyError("Error in loading menu data. Please try again.");
            }
        })
        .fail(function() {
            bootNotifyError("Error in contacting server.Please try again.");
        })
        .always(function() {
            hideLoader();
        });

    }

    function onSaveMenu(verified){
        var form = $("#mainForm");
        form.removeClass('was-validated');
        var errorMsgDiv = $("#errorMsgDiv");
        errorMsgDiv.html("");

        var isAllValid = true;
        var errorFields = [];
        //custom check for special fields like ckeditor
        form.find('.requiredInput').trigger('checkRequired');
        if(!form.get(0).checkValidity()){
            isAllValid = false;
            var invalidFields = form.find(':invalid');
            // console.log('invalidfield',invalidFields);
            if(invalidFields.length > 0){
                // bootNotifyError("Error: Some required fields are empty.");
                errorMsgDiv.append("Error: Some required fields are empty.");
                errorFields = errorFields.concat(invalidFields.toArray());
            }
        }

        //custom validation fields e.g. URL
        var invalidFields = form.find('.is-invalid');
        if(invalidFields.length > 0){
            var errorMsg = "Error: " + invalidFields.length
                + " field(s) have invalid values";
            // bootNotifyError(errorMsg);
            errorMsgDiv.append(errorMsg);
            errorFields = errorFields.concat(invalidFields.toArray());
        }

        if(errorFields.length > 0){
            form.addClass('was-validated');
            focusOnErrorField(errorFields, $('#mainFormDiv'));
            return false;
        }

        var templateData = generateTemplateData($('#templateSectionsContainer'));
        form.find('[name=templateData]').val(JSON.stringify(templateData));

        showLoader("Saving menu ... ");
        $.ajax({
            url: 'menusAjax.jsp', type: 'POST', dataType: 'json',
            data: form.serialize(),
        })
        .done(function(resp) {
            var data = [];
            if(resp.status == 1){
                //TODO , do not refresh
                bootNotify("Menu saved. Reloading...");
                var url ="menuEditor.jsp?id="+resp.data.id;
                window.location.href = url;
            }
            else{
                $("#errorMsgDiv").html(resp.message);
                bootNotifyError(resp.message);
            }
        })
        .fail(function() {
            bootNotifyError("Error in contacting server.Please try again.");
        })
        .always(function() {
            hideLoader();
        });


    }



    function onChangeTemplate(select){

        if($('#menuId').val().length > 0){
            return;
        }

        var templateId = $(select).val();

        if(templateId.length === 0){
            $('#templateSectionsContainer').html('');
        }

        showLoader();
        $.ajax({
            url: 'blocTemplatesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getTemplateSectionsData',
                template_id : templateId,
            },
        })
        .done(function(resp) {
            var data = [];
            if(resp.status == 1){
                var templateCode = {
                    sections : resp.data.sections
                };
                generateTemplateForm(templateCode);
            }
            else{
                bootNotifyError("Error in loading template sections data. Please try again.");
            }
        })
        .fail(function() {
            bootNotifyError("Error in contacting server.Please try again.");
        })
        .always(function() {
            hideLoader();
        });

    }

    function generateTemplateForm(templateCode, templateDataObj){
        // console.log(templateCode);//debug
        // console.log(templateDataObj);//debug
        $ch.templateCode = templateCode;
        $ch.templateData = templateDataObj;

        var templateSectionsContainer =  $('#templateSectionsContainer');

        templateSectionsContainer.html('');

        var sections = templateCode.sections;

        if(!sections || sections.length == 0){
            templateSectionsContainer.append("<span class='text-warning'>No template fields defined</span>");
            return false;
        }

        $ch.loadingBlocData = true;

        $.each(sections, function(index, secCode) {

            var sectionDiv = generateSectionContainer(secCode, templateSectionsContainer, $("#langue_id").val());

            if(templateDataObj){
                //now filling form with existing bloc data
                fillBlocData(templateDataObj, sectionDiv);
            }

        });

        $(templateSectionsContainer).find(".ckeditorField").ckeditor({
            filebrowserImageBrowseUrl : "<%=GlobalParm.getParm("PAGES_APP_URL")%>admin/imageBrowser.jsp?popup=1",
            extraPlugins: ['colorbutton', 'font', 'colordialog', 'justify', 'basicstyles'],
            colorButton_enableMore : true,
            colorButton_enableAutomatic : false,
            allowedContent: true,
            colorButton_colors : '000000,FFFFFF,FF7900,F16E00,4BB4E6,50BE87,FFB4E6,A885D8,FFD200,085EBD,0A6E31,FF8AD4,492191,FFB400,B5E8F7,B8EBD6,FFE8F7,D9C2F0,FFF6B6,595959,527EDB,32C832,FFCC00,CD3C14',
        }, onFieldCkeditorReady);

        templateSectionsContainer.find('.collapse:first').addClass('show');

        $ch.loadingBlocData = false;

    }

    function onChangeMenuLang(select){
        //if new menu , set prod path
        select = $(select);

        var menuId = $('#menuId').val();

        if(menuId.length == 0){
            var langCode = select.find("option:selected").attr('data-lang-code');

            var prodPath = $ch.siteFolderName + "/" + langCode ;

            $('#production_path').val(prodPath);
            $('#prodPathWarningDiv').html("Warning: Changing path other than '"+prodPath+"' requires nginx/apache configuration changes");
        }

        //change url fields lang
        $('#homepage_url, #page_404_url').each(function(index, el) {
            var urlGen = $(el).data('url-generator');
            urlGen.options.langId = select.val()
            $(el).trigger('blur');
        });

    }

    function addTrustedDomain(dataObj){
        var newRow = $('#trustedDomainRowTemplate').clone();

        newRow.attr('id',null);
        $('#trustedDomainsTableBody').append(newRow);

        if(typeof dataObj === 'undefined'){
            newRow.find("[name=apply_to]").focus();
        }
        else{
            newRow.find('[name=apply_to_id]').val(dataObj.id);
            newRow.find('[name=apply_type]').val(dataObj.apply_type).trigger('change');
            newRow.find('[name=apply_to]').val(dataObj.apply_to);
            newRow.find('[name=prod_apply_to]').val(dataObj.prod_apply_to);

            var addGtmCheck = newRow.find('[name=add_gtm_script_check]');
            if(dataObj.add_gtm_script == '1'){
                addGtmCheck.prop('checked',true).trigger('change');
            }

            newRow.find('[name=replace_tags]').val(dataObj.replace_tags);
            newRow.find('.replaceTagsSpan').html(dataObj.replace_tags);

        }
    }

    function deleteTrustedDomain(btn){
        var msg = "Are you sure you want to delete?";
        bootConfirm(msg,function(result){
                if(result){
                    $(btn).parents("tr:first").remove();
                }
            });
    }

    function onProdPathKeyup(input){
        onPathKeyup(input,true);
        input = $(input);
        //resources is a keyword for path as we have a specific folder created at time of crawling and that is named resources
        //so we avoid using it in menu path to avoid any kind of conflicts later
        if(input.val().indexOf("resources") >= 0){
            input.val(input.val().replace("resources",""));
        }
    }

    function onChangeApplyType(select){
        select = $(select);
        inputs = select.parent().parent().find("input.applyToInput");

        var placeholder = select.val() == "url_starting_with" ? "URL starting with" : "URL";
        inputs.attr('placeholder', placeholder);

    }

    function onChangeGtmCheckbox(checkbox){
        checkbox = $(checkbox);
        var hiddenInput = checkbox.parent().find('[name=add_gtm_script]');

        hiddenInput.val(checkbox.prop('checked')?"1":"0");
    }

    $ch.replaceTagsList = [];
    $ch.replaceTagInput = null;
    function openReplaceTagsWindow(btn){
        btn = $(btn);
        var row = btn.parents("tr:first");
        $ch.replaceTagInput = row.find("[name=replace_tags]");
        $ch.replaceTagsList = [];

        var u = row.find('[name=apply_to]').val().trim();
        if(!u.startsWith("http://") && !u.startsWith("https://")){
            u = "http://"+u;
        }

        var prop = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
        prop += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
            prop += ",width=1000" + ",height=800";  //propriete += ",width=" + screen.availWidth + ",height=" + screen.availHeight;
            win = window.open("<%=MENU_APP_URL%>pages/selector.jsp?url="+u,"Select divs to replace", prop);
            win.focus();
    };

    function addSelectedSection(_id){
        $ch.replaceTagsList.push(_id);
        setReplaceTags();
    };

    function removeSelectedSection(_id){
        for(var i=0; i<$ch.replaceTagsList.length; i++)
        {
            if($ch.replaceTagsList[i] == _id) $ch.replaceTagsList.splice(i, 1);
        }
        setReplaceTags();
    };

    function setReplaceTags(){
        var replaceTagsStr = $ch.replaceTagsList.join(", ");
        $ch.replaceTagInput.val(replaceTagsStr);

        $ch.replaceTagInput.parent().find(".replaceTagsSpan").html(replaceTagsStr);
    };

</script>
    </body>
</html>