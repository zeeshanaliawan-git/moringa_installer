<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <%@ include file="../WEB-INF/include/head2.jsp"%>
        <script src="<%=request.getContextPath()%>/js/jquery.lazy.min.js"></script>
        
        <title>Global Information</title>
    </head>
    <body class="" style="background-color:#efefef">

        <%@ include file="/WEB-INF/include/sidebar.jsp" %>
        <div class="c-wrapper c-fixed-components">
            <%
                breadcrumbs.add(new String[]{"Global Information", ""});
            %>
            <%@ include file="/WEB-INF/include/header.jsp" %>
            <div class="c-body">
                <main class="c-main"  style="padding:0px 30px">
                    <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                        <h1 class="h2">Global Information</h1>
                        <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Global Information');" title="Add to shortcuts">
                            <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
                        </button>
                    </div>
                    
                    <div class="border-bottom pb-3">
                        <div style="display: flex;justify-content: space-between;">
                            <div class="custom-control mt-2">
                                <label class="rounded-right">Upload your custom html file to display in case of errors from 500 to 505:</label>
                            </div>
                            <div class="row mr-5">
                                <div class="custom-control">
                                    <div class="custom-file">
                                        <input type="file" id="uploadFile" name="file" accept=".html" class="custom-file-input" onchange="onFileInputChange(this)">
                                        <label id="inputLabel" class="custom-file-label rounded-right fileLabel" for="importFile" 
                                            style="justify-content: left;">Choose file</label>
                                    </div>
                                </div>
                                <button class="btn btn-success ml-2" onclick="uploadGenericErrorPage()">Upload</button>
                            </div>
                        </div>
                        <div class="renameMsg mt-2 mr-5" style="text-align: right;" hidden>This uploaded file will be renamed to "maintenance.html"</div>
                    </div>
                </main>
            </div>
            <%@ include file="/WEB-INF/include/footer.jsp" %>

            
        </div>

        <script type="text/javascript">
            function onFileInputChange(input){
                document.getElementById("inputLabel").textContent = input.files[0].name;
                document.getElementsByClassName("renameMsg")[0].hidden=false;
            }

            function uploadGenericErrorPage(){
                let fileInput = document.getElementById("uploadFile");
                let customFileName = "maintenance";

                if (fileInput.files.length > 0) {
                    let uploadedFile = fileInput.files[0];
                    let renamedFile = new File([uploadedFile], customFileName + uploadedFile.name.substr(uploadedFile.name.lastIndexOf('.')), {
                        type: uploadedFile.type
                    });

                    let formData = new FormData();
                    formData.append('file', renamedFile);
                    $.ajax({
                        url: "<%=request.getContextPath()%>/admin/globalDataAjax.jsp",
                        type: "POST",
                        data: formData,
                        contentType: false,
                        processData: false,
                        success: function (response) {
                            let rsp = JSON.parse(response)
                            if(rsp.status===0){
                                bootNotify(rsp.msg);
                                document.getElementById("uploadFile").value = "";
                                document.getElementById("inputLabel").textContent = "Choose file";
                                document.getElementsByClassName("renameMsg")[0].hidden=true;
                            }else{
                                bootNotifyError("Error: " + rsp.msg);
                            }
                        },
                        error: function (xhr, status, error) {
                            bootNotifyError("Error uploading file: " + error);
                        }
                    });
                } else {
                    bootNotifyError("No file selected");
                }
            }
        </script>

    </body>
</html>