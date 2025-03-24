<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.ArrayList, java.util.HashMap , com.etn.pages.PagesUtil"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%
    String templateId = parseNull(request.getParameter("id"));
    String siteId  = getSiteId(session);
    String backUrl = "stores.jsp?";
	if(templateId.length() == 0)
	{
		response.sendRedirect(backUrl);
		return;
	}
       
	Set rs = Etn.execute("select * from bloc_templates where id = "+escape.cote(templateId));
	if(!rs.next()){
		response.sendRedirect(backUrl);
		return;
	}

	String storeIds = parseNull(request.getParameter("sids"));
	if(storeIds.length() == 0)
	{
		response.sendRedirect(backUrl);
		return;		
	}
	String[] arrStoreIds = storeIds.split(",");
	if(arrStoreIds == null || arrStoreIds.length == 0)
	{
		response.sendRedirect(backUrl);
		return;		
	}

    String templateName = rs.value("name");
    boolean active = true;
    List<Language> langsList = getLangs(Etn,siteId);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="../WEB-INF/include/head2.jsp"%>
    <title>Bulk Modification | <%=templateName%></title>


    <script src="<%=request.getContextPath()%>/ckeditor/ckeditor.js"></script>
    <script src="<%=request.getContextPath()%>/ckeditor/adapters/jquery.js"></script>
    <script>
        CKEDITOR.timestamp = "" + parseInt(Math.random()*100000000);
    </script>

    <style type="text/css">

        .publish-status-circle{
            border-radius: 50%;
            height: 25px;
            width: 25px;
            border-radius: 50%;
            border: 1px solid rgb(221, 221, 221);
            display: inline-block;
            vertical-align: middle;
            margin-left: 15px;
        }

        .ui-datepicker.ui-widget{
            z-index: 2000 !important;
        }

        #publishedPreviewBtn.unpublished{
            display: none;
        }

    </style>
</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
     <%
        breadcrumbs.add(new String[]{"Content", ""});
        breadcrumbs.add(new String[]{"Stores", "stores.jsp"});
        breadcrumbs.add(new String[]{"Bulk Modification", ""});
        breadcrumbs.add(new String[]{templateName, ""});
    %>
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
            <!-- beginning of container -->

			<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-2 border-bottom">
				<div>
					<h1 id="contentHeading" class="h2 float-left mr-3">
						<%=escapeCoteValue("Edit : " +arrStoreIds.length+" store(s) | "+templateName)%>
					</h1>
				</div>
				<div class="btn-toolbar mb-2 mb-md-0 flex-wrap flex-md-nowrap">
				   <div class="btn-group mr-2">
						<button type="button" class="btn btn-primary"
							onclick="goBack('<%=backUrl%>')">Back</button>
						<button class="btn btn-primary" type="button"
							onclick="onSaveStructuredContent()">save</button>
					</div>
				</div>
			</div>
			<div style=" user-select: auto;">
				<div class="invalid-feedback" style="display:block;" id="errorMsgDiv" ></div>
				<ul class="nav nav-tabs " id="langNavTabs" role="tablist">
				<%
					for (Language lang:langsList) {
				%>
					<li class="nav-item" data-lang-id="<%=lang.getLanguageId()%>">
					  <a class='nav-link <%=(active)?"active":""%>' data-lang-id="<%=lang.getLanguageId()%>"
						id="langTab_<%=lang.getLanguageId()%>" data-toggle="tab" href="#langTabContent_<%=lang.getLanguageId()%>"
						role="tab" aria-controls="<%=lang.getLanguage()%>" aria-selected="true"><%=lang.getLanguage()%></a>
					</li>
				<%
                        active = false;
					}
				%>
				</ul>
				<div class="tab-content p-3" id="flangTabContent">
					<form id="mainForm" action="" method="POST" onsubmit="return false;" noValidate>
						<input type="hidden" name="templateId" id="templateId" value='<%=templateId%>'>
						<input type="hidden" name="sids" id="sids" value='<%=storeIds%>'>
					</form>
					<%
                        active = true;
						for (Language lang:langsList) {
					%>
						<div class='tab-pane langTabContent <%=(active)?"show active":""%>'
								id="langTabContent_<%=lang.getLanguageId()%>"
								role="tabpanel" aria-labelledby="<%=lang.getLanguage()%>-tab">
							<!-- templateSections -->
							<form name="templateSectionsForm_<%=lang.getLanguageId()%>" class="langTemplateForm"
								action="" method="POST" onsubmit="return false;">
								<div class="langContent template_container bloc_section"
									id="langContent_<%=lang.getLanguageId()%>" data-lang-id="<%=lang.getLanguageId()%>" >

								</div>
							</form>
							<!-- /templateSections -->
						</div>
						<!-- tabContent -->
					<%
                            active = false;
						}//for lang tab content
					%>
				</div>
			</div><!-- row -->
            <!-- container -->
            <!-- /end of container -->
        </main>
        <%@ include file="/WEB-INF/include/footer.jsp" %>
		<%@ include file="templateFunctions.jsp" %>
    </div>

<div class="modal fade" tabindex="-1" id="errMsgModal" role="dialog">
    <div class="modal-dialog modal-xl" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Skiped Items</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body" id="errMsgModalPara">
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeErrMsgModal()" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>
<script type="text/javascript">

    $ch.contextPath = '<%=request.getContextPath()%>/';

    window.IMAGE_URL_PREPEND = '<%=getImageURLPrepend(getSiteId(session))%>';
    window.allTagsList = <%=getAllTagsJSON(Etn, getSiteId(session), GlobalParm.getParm("CATALOG_DB") )%>;

    // ready function
    $(function () {
        bulkModificationScreen = true;
        $ch.langContentDivs = $('.langContent');
		$ch.bulkModificationMode = true;
		loadFields();
    });
    
    function closeErrMsgModal(){
        $('#errMsgModal').modal('hide');
    }

    function loadFields(){
        var templateId = $('#templateId').val();

        if(templateId.length === 0) return false;

        showLoader();
        $.ajax({
            url : 'structuredContentsAjax.jsp', type : 'POST', dataType : 'json',
            data : {
                requestType : 'getTemplateFieldsForBulkModification',
                templateId : templateId,
            },
        })
        .done(function (resp) {
            if (resp.status == 1) {
                generateForm(resp.data.sections);
            }
            else {
                bootNotifyError("Error in loading template fields. Please try again.");
            }
        })
        .fail(function () {
            bootNotifyError("Error in contacting server.Please try again.");
        })
        .always(function () {
            hideLoader();
        });
    }

	function onSaveStructuredContent() {
        var form = $("#mainForm");
        form.removeClass('was-validated');
        var errorMsgDiv = $("#errorMsgDiv");
        errorMsgDiv.html("");

        var data = {
            requestType : "saveBulkModifications",
            sids : $("#sids").val(),
            templateId : $('#templateId').val(),
        };

        var langContentDivs = $(".langContent");
        langContentDivs.each(function (index, langContent) {
            langContent = $(langContent);
            var langId = langContent.attr("data-lang-id");

            var templateData = generateTemplateData(langContent);
            data["contentDetailData_" + langId] = JSON.stringify(templateData);
            data["bulkModifyCheckData_" + langId]  = JSON.stringify(getSectionAndField(langId));
        });
        
        showLoader();
        $.ajax({
            url : 'structuredContentsAjax.jsp', type : 'POST', dataType : 'json',
            data : data,
        })
        .done(function (resp) {
            if (resp.status == 1) {
                if(Object.keys(resp.data).length>0){
                    $('#errMsgModalPara').html('<span style="font-weight: bold; font-size: 16px;">Following items have been skipped due to limit reached:</span></br>'+JSON.stringify(resp.data));
                    $('#errMsgModal').modal('show');
                }
                bootNotify(resp.message);
            }
            else {
                $("#errorMsgDiv").html(resp.message);
            }
        })
        .fail(function () {
            bootNotifyError("Error in contacting server.Please try again.");
        })
        .always(function () {
            hideLoader();
        });
    }

    function getSectionAndField(langId){
        let returnItems=[];
        let tmpSections=[];

        let fieldName = "append_to_section_"+langId;
        
        let elements = document.querySelectorAll('select[name="'+fieldName+'"]');
        elements.forEach(element => {
            let itemId = element.getAttribute("data-value");
            let grandparent = element.parentElement.parentElement.parentElement.parentElement;
            if(grandparent.classList.contains("fieldContainerDiv")){
                grandparent = grandparent.parentElement;
                itemId = getSectionCleanName(grandparent.getAttribute("id")) +"."+itemId.split(".")[1];
            }

            let index = tmpSections.indexOf(itemId);
            if(index !=- 1){
                returnItems[index][itemId].push(element.value);
            }else{
                tmpSections.push(itemId);
                let elementsCheckArray = [];
                elementsCheckArray.push(element.value);

                let sectionObject = {
                    [itemId]: elementsCheckArray
                };
                returnItems.push(sectionObject);
            }

        });
        return returnItems;
    }

    function generateForm(sections) {
        var langContentDivs = $ch.langContentDivs;

        langContentDivs.html('');

        if (!sections || sections.length == 0) {
            langContentDivs.append("<span class='text-danger'>No template fields defined</span>");
            return false;
        }

        $ch.loadingBlocData = true;

        langContentDivs.each(function (index, langContent) {
            langContent = $(langContent);
            var curLangId = langContent.attr("data-lang-id");
            $.each(sections, function (index, secCode) {

                var sectionDiv = generateSectionContainer(secCode, langContent, curLangId);
            });

            langContent.find('.collapse:first').addClass('show');

        });
		
		$(".bulkEditChkbox").removeClass("d-none");

        showLoader();
        $(langContentDivs).find(".ckeditorField").ckeditor({
            filebrowserImageBrowseUrl : "imageBrowser.jsp?popup=1",
            extraPlugins: ['colorbutton', 'font', 'colordialog', 'justify', 'basicstyles'],
            colorButton_enableMore : true,
            colorButton_enableAutomatic : false,
            allowedContent: true,
            colorButton_colors : '000000,FFFFFF,FF7900,F16E00,4BB4E6,50BE87,FFB4E6,A885D8,FFD200,085EBD,0A6E31,FF8AD4,492191,FFB400,B5E8F7,B8EBD6,FFE8F7,D9C2F0,FFF6B6,595959,527EDB,32C832,FFCC00,CD3C14',
        }, onFieldCkeditorReady);

        $ch.loadingBlocData = false;
    }
</script>
</body>
</html>