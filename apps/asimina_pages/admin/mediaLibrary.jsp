<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.ArrayList "%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%
    String selectedSiteId = getSiteId(session);
    if(parseNull(request.getParameter("site_id")).length()>0)
        selectedSiteId = parseNull(request.getParameter("site_id"));
    String FILE_URL_PREPEND = parseNull(getFileURLPrepend()) + selectedSiteId + "/";
    
    String q = null;
    Set rs = null;

    boolean isPopup = "1".equals(parseNull(request.getParameter("popup")));
    String pFileTypes = parseNull(request.getParameter("fileTypes"));

    String fileTypes = "img,other,video";
    String mediaTypes = "used,unused";
    if(isPopup){
        if(pFileTypes.length() > 0){
            fileTypes = pFileTypes;
        }
        else{
            //in case of as popup, default is images only
            fileTypes = "img";
        }
    }

    boolean isSuperAdmin = isSuperAdmin(Etn);
    String ckeditorName = parseNull(request.getParameter("CKEditor"));
    String ckeditorFuncNum = parseNull(request.getParameter("CKEditorFuncNum"));

    String pagePathToAddShortcut2 = request.getRequestURI();
	boolean isMarkedForShortcut2 = false;
    Set rsCheckShortcut2 = Etn.execute("select * from shortcuts where site_id="+escape.cote((String)session.getAttribute("SELECTED_SITE_ID"))+" and created_by="+escape.cote(""+ Etn.getId())+
        " and url="+escape.cote(pagePathToAddShortcut2));
    if(rsCheckShortcut2.rs.Rows>0){
        isMarkedForShortcut2=true;
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <%@ include file="../WEB-INF/include/head2.jsp"%>

        <script src="<%=request.getContextPath()%>/js/jquery.lazy.min.js"></script>
        <link rel="stylesheet" href="<%=request.getContextPath()%>/css/cropper.min.css">
        <link rel="stylesheet" href="<%=request.getContextPath()%>/css/flatpickr.min.css">

        <title>Pages : Media Library</title>

        <style type="text/css">

            tr > td.imageClick{
                cursor : pointer;
            }
            #imagesCarousel {
                width:800px;
                height:400px;
                margin: auto;
                overflow: hidden;
            }

            .carousel-inner{
                width: 100%;
                height: 100%;
            }

            .carouselImage{
                /* max-height: 100%; */
                /* max-width: 100%; */
                /* margin: auto; */
                /* cursor: pointer; */
                width: 100%;
                height: 100%;
                object-fit:cover;

            }

            .carouselCaption{
                top:50px;
                bottom : 0px;
                padding: 0px;
                background-color: rgba(0,0,0,0.2);
            }

            .carouselCaption :hover {
                background-color: rgba(0,0,0,0.5);
            }

            .carouselCaption > p{
                margin-bottom : 2px;
            }

            .carousel-control-prev,.carousel-control-next{
                background-color: rgba(0,0,0,0.2);
            }

            .hideInPopup{
                <%=isPopup?"display: none;":""%>
            }

            .carouselImageParent{
                display: flex;
                justify-content: center;
                justify-item: center;
            }
            #dragDropMain{
                align-self: center;
                align-items: center;
                justify-content: center;
                max-width: 100%;
            }
            .drop-zone {
                align-self: center;
                max-width: 100%;
                height: 200px;
                padding: 25px;
                display: flex;
                align-items: center;
                justify-content: center;
                text-align: center;
                font-family: "Quicksand", sans-serif;
                font-weight: 500;
                font-size: 20px;
                cursor: pointer;
                color: #cccccc;
                border: 4px dashed #009578;
                border-radius: 10px;
            }

            .drop-zone--over {
                border-style: solid;
            }

            .drop-zone__input {
                display: none;
            }

            .drop-zone__thumb {
                width: 100%;
                height: 100%;
                border-radius: 10px;
                overflow: hidden;
                background-color: #cccccc;
                background-size: cover;
                position: relative;
            }

            .drop-zone__thumb::after {
                content: attr(data-label);
                position: absolute;
                bottom: 0;
                left: 0;
                width: 100%;
                padding: 5px 0;
                color: #ffffff;
                background: rgba(0, 0, 0, 0.75);
                font-size: 14px;
                text-align: center;
            }

            .media-card:hover .actionsCellTemplate{
                display:flex !important;
            }

            /* New Added */
            .checkbox-wrapper {
                padding-top: 15px; 
            }

        </style>
    </head>
    <body class="" style="background-color:#efefef">

<% if(!isPopup){ %>
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%
        breadcrumbs.add(new String[]{"Content", ""});
        breadcrumbs.add(new String[]{"Media Library", ""});
    %>
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
<% } %>

                <!-- beginning of container -->

                    <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                        <h1 class="h2">List of resources</h1>
                        <%
                            if(!isPopup){
                        %>
                                <div class="btn-toolbar mb-2 mb-md-0">
                                    <button type="button" class="btn btn-primary mr-1 hideInPopup"
                                        onclick="goBack('pages.jsp')">Back</button>

                                    <button class="btn btn-danger mr-2"
                                        onclick="deleteMultipleFiles()">Delete</button>
                        <%
                            }
                        %>

                                    <button class="btn btn-success mr-2"
                                        onclick="openAddMediaModal()">Add media</button>
                        <%
                            if(!isPopup){
                        %>

                                    <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Media Library');" title="Add to shortcuts">
                                        <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut2)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
                                    </button>
                                </div>
                        <%
                            }
                        %>
                    </div>

                    <div class="input-group">
                        <div class="input-group-prepend">
                            <select class="form-control" id="mediaLength">
                                <option value="24" selected>24</option>
                                <option value="48">48</option>
                                <option value="96">96</option>
                            </select>
                        </div>
                        <input type="text" class="form-control" placeholder="Search for name, alternate name, label" id="mediaSearch">
                        <div class="input-group-append">
                            <button class="btn btn-outline-secondary dropdown-toggle" type="button" data-toggle="dropdown" aria-expanded="false" style="color:black">Filters</button>
                            <div class="dropdown-menu custom-menu">
                                <label class="dropdown-item" > <input type="checkbox" class="mr-2 filterType" value="img" checked <%=isPopup?"disabled":""%>/> Image </label>
                                <div class="ml-4">
                                    <label class="dropdown-item">
                                        <input type="checkbox" class="mr-2 imgfilter" value="all" checked/> ALL
                                    </label>
                                    <label class="dropdown-item">
                                        <input type="checkbox" class="mr-2 imgfilter" value="png"/> PNG
                                    </label>
                                    <label class="dropdown-item">
                                        <input type="checkbox" class="mr-2 imgfilter" value="svg"/> SVG
                                    </label>
                                    <label class="dropdown-item">
                                        <input type="checkbox" class="mr-2 imgfilter" value="jpg"/> JPG
                                    </label>
                                </div>
                                <%
                                    if(!isPopup){
                                %>
                                        <label class="dropdown-item" > <input type="checkbox" class="mr-2 filterType" value="video" checked/> Video</label>
                                        <label class="dropdown-item" > <input type="checkbox" class="mr-2 filterType " value="other" checked/> Files</label>
                                <%
                                    }
                                %>
                                <div role="separator" class="dropdown-divider"></div>
                                <label class="dropdown-item" ><input type="checkbox" class="mr-2 filterType" value="unused"/> Not used </label>
                                <label class="dropdown-item" ><input type="checkbox" class="mr-2 filterType" value="removed"/> Removed </label>
                            </div>
                        </div>
                        <div class="input-group-append">
                            <button class="btn btn-outline-secondary dropdown-toggle" type="button" data-toggle="dropdown" aria-expanded="false" style="color:black">
                                Sort (<span id="sortReference">Date - recent</span>)
                            </button>
                            <div class="dropdown-menu custom-menu">
                                <button class="dropdown-item" onclick="sortMedia('f.label asc',this)">A to Z</button>
                                <button class="dropdown-item" onclick="sortMedia('f.label desc',this)">Z to A</button>
                                <button class="dropdown-item" onclick="sortMedia('f.updated_ts asc',this)">Date - older</button>
                                <button class="dropdown-item" onclick="sortMedia('f.updated_ts desc',this)">Date - recent</button>
                                <button class="dropdown-item" onclick="sortMedia('f.times_used asc',this)">Nb of use - ascending</button>
                                <button class="dropdown-item" onclick="sortMedia('f.times_used desc',this)">Nb of use - descending</button>
                                <button class="dropdown-item" onclick="sortMedia('f.file_size asc',this)">Weight - increase</button>
                                <button class="dropdown-item" onclick="sortMedia('f.file_size desc',this)">Weight - decrease</button>
                            </div>
                        </div>
                    </div>

                    <script>
                        document.querySelector('.custom-menu').addEventListener('click', function(event) {
                            event.stopPropagation();
                        });
                    </script>

                     <div class="checkbox-wrapper">
                      <input type="checkbox" name="select-all" id="select-all">
                      <label for="select-all">Select All</label>

                    </div>

                    <div class="mt-3 row" id="imageContainerParentDiv">
                    </div>

                    <div style="display: flex; justify-content: space-between; align-items: center;" class="mb-2" id="pageNavigation">
                        <span id="pageNavigationSpan"></span>
                        <nav aria-label="Page navigation example">
                            <ul class="pagination" id="pagination">
                            </ul>
                        </nav>
                    </div>
                    
<% if(!isPopup){ %>
            </main>
        </div>
        <%@ include file="/WEB-INF/include/footer.jsp" %>
<% } %>

        <div class="d-none" id="mediaUsesDiv">
            <div class="float-right pl-1 m-0">
                <label>Media:&nbsp;
                    <select name="mediaUsages" style="width: auto;"
                        class="custom-select custom-select-sm ml-1"
                        onchange="applyMediaTypeFilter(this)"
                        onclick="event.stopPropagation();return false;">

                    </select>
                </label>
            </div>
        </div>

        <div class="d-none" id="typeFilterDiv">
            <div class="float-right pl-1 m-0">
                <label>Type:&nbsp;
                    <select name="typeFilter" style="width: auto;"
                        class="custom-select custom-select-sm ml-1"
                        onchange="applyFileTypeFilter(this)"
                        onclick="event.stopPropagation();return false;">

                    </select>
                </label>
            </div>
        </div>
        
        <!-- Modals -->
        <div class="modal fade" id="modalAddEditFile" tabindex="-1" role="dialog" data-backdrop="static" >
            <div class="modal-dialog modal-dialog-slideout modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title"></h5>
                        <button type="button" class="close closeBtn" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <form id="formAddEditFile" action="" onsubmit="return false;" novalidate>
                            <input type="hidden" name="id" value="">
                            <div class="invalid-feedback safeFileErrorMsg pb-1" style="display: block;"></div>
                            <div class="invalid-feedback fileErrorMsg pb-1" style="display: block;"></div>
                            
                            <div calss="d-flex flex-column" id="cropperParentDiv" style="height: 400px;" hidden>
                                <div id="customRatioBar" class="btn-group w-100 mb-1 " role="group">
                                    <button type="button" class="btn btn-primary" onclick="cropper.setAspectRatio(16/9)">16:9</button>
                                    <button type="button" class="btn btn-primary" onclick="cropper.setAspectRatio(4/3)">4:3</button>
                                    <button type="button" class="btn btn-primary" onclick="cropper.setAspectRatio(1)">1:1</button>
                                    <button type="button" class="btn btn-primary" onclick="cropper.setAspectRatio(2/3)">2:3</button>
                                    <button type="button" class="btn btn-primary" onclick="cropper.setAspectRatio(NaN)">Free</button>
                                </div>

                                <div id="cropperImageContainer" class="w-100" style="height: 80%;overflow: hidden;">
                                </div>
                                
                                <div id="customToolBar" class="btn-group w-100 mt-1" role="group">
                                    <button type="button" class="btn btn-success" onclick="callToolBarFunc('move')" title="move"><span class="fa fa-arrows-alt"></span></button>
                                    <button id="cropBtn" type="button" class="btn btn-success" onclick="crop()" title="crop"><span class="fa fa-crop-alt"></span></button>
                                    <button type="button" class="btn btn-success" onclick="callToolBarFunc('in')" title="zoom in"><span class="fa fa-search-plus"></span></button>
                                    <button type="button" class="btn btn-success" onclick="callToolBarFunc('out')" title="zoom out"><span class="fa fa-search-minus"></span></button>
                                    <button type="button" class="btn btn-success" onclick="callToolBarFunc('left')" title="move left"><span class="fa fa-arrow-left"></span></button>
                                    <button type="button" class="btn btn-success" onclick="callToolBarFunc('right')" title="move right"><span class="fa fa-arrow-right"></span></button>
                                    <button type="button" class="btn btn-success" onclick="callToolBarFunc('up')" title="move up"><span class="fa fa-arrow-up"></span></button>
                                    <button type="button" class="btn btn-success" onclick="callToolBarFunc('down')" title="move down"><span class="fa fa-arrow-down"></span></button>
                                    <button type="button" class="btn btn-success" onclick="callToolBarFunc('undo')" title="rotate left"><span class="fa fa-undo-alt"></span></button>
                                    <button type="button" class="btn btn-success" onclick="callToolBarFunc('redo')" title="rotate right"><span class="fa fa-redo-alt"></span></button>
                                    <button type="button" class="btn btn-success" onclick="callToolBarFunc('sync')" title="reset"><span class="fa fa-sync-alt"></span></button>
                                    <button type="button" class="btn btn-success" onclick="callToolBarFunc('download')" title="download"><span class="fa fa-download"></span></button>
                                </div>
                            </div>
                            
                            <div calss="d-flex flex-column" id="otherParentDiv" style="height: 400px;" hidden>
                                <div id="otherFileContainer" class="w-100" style="height: 100%;overflow: hidden;">
                                </div>
                            </div>


                            <div class="card mt-2">
                                <div class="card-header bg-secondary" data-toggle="collapse" href="#mediaInformation" role="button">
                                    <strong >
                                        Media Information
                                    </strong>
                                </div>
                                <div class="collapse show pt-3" id="mediaInformation">
                                    <div class="card-body">
                                        <div class="mb-3">
                                            <div class="custom-file">
                                                <input type="file"  id="file" name="file"
                                                class="custom-file-input" aria-describedby="file"
                                                onchange="onFileInputChange(this)">
                                                <label class="custom-file-label rounded-right fileLabel" for="file">Upgrade this file</label>
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label class="col col-form-label">Label</label>
                                            <div class="col-sm-9">
                                                <input type="text" class="form-control"
                                                    name="label" id="label" value="" maxlength="300" required="required" >
                                                <div class="invalid-feedback">
                                                    Cannot be empty.
                                                </div>
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label class="col col-form-label">File name</label>
                                            <div class="col-sm-9">
                                                <input type="text" class="form-control"
                                                    name="name" maxlength="300" required
                                                    readonly="readonly" />
                                                <div class="invalid-feedback">
                                                    Cannot be empty.
                                                </div>
                                            </div>
                                        </div>
                                         <div class="form-group row">
                                            <label class="col col-form-label">File URL</label>
                                            <div class="col-sm-9">
                                                <input type="text" class="form-control"
                                                    name="file_url" maxlength="300" required
                                                    readonly="readonly" />
                                                <div class="invalid-feedback">
                                                    Cannot be empty.
                                                </div>
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label class="col col-form-label">Alt name</label>
                                            <div class="col-sm-9">
                                                <input type="text" class="form-control"
                                                    name="altName" value="" maxlength="300" required="required">
                                                <div class="invalid-feedback">
                                                    Cannot be empty.
                                                </div>
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label class="col col-form-label">Description</label>
                                            <div class="col-sm-9">
                                                <textarea type="text" class="form-control" style="height: auto;" name="description" rows="4"></textarea>
                                            </div>
                                        </div>
                                        <div class="form-group row" id="thumbnailParent">
                                            <label class="col col-form-label">Upload thumbnail</label>
                                            <div class="col-sm-9">
                                                <div id="thumbnailContainer" class="border d-inline-block p-2 rounded position-relative" onclick="openThumbnailImageInput()">
                                                    <button id="thumbnailBtn" class="btn btn-sm btn-danger position-absolute" style="right:10px;top:10px">x</button>
                                                    <img id="thumbnailImg" src="../img/camera.svg" alt="test" style="
                                                        height: 100px;width: auto;" class="rounded">
                                                </div>
                                                <input type="file" id="thumbnailImageInput" accept="image/*" style="display: none;">
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label class="col col-form-label">Type</label>
                                            <div class="col-sm-9" >
                                                <select class="custom-select" name="fileTypeSelect" disabled>
                                                    <option value="img">Image</option>
                                                    <option value="other">Other</option>
                                                    <option value="video">Video</option>
                                                </select>
                                            </div>
                                            <input type="hidden" name="fileType" value="">
                                        </div>

                                        <div class="form-group row">
                                            <label class="col col-form-label">Tags</label>
                                            <div class="col-sm-9">
                                                <input type="text" name="tagsInput" class="form-control tagInputField" value=""
                                                    placeholder="search and add (by clicking return)">
                                            </div>
                                            <div class="tagsDiv col-sm-12 form-group mt-3 mediaTagsDiv"></div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="card">
                                <div class="card-header bg-secondary" data-toggle="collapse" href="#advancedInfo" role="button">
                                    <strong >
                                        Advanced
                                    </strong>
                                </div>
                                <div class="collapse show pt-3" id="advancedInfo">
                                    <div class="card-body">
                                        <div class="form-group row">
                                            <label class="col col-form-label">Width</label>
                                            <div class="col-sm-9">
                                                <input type="text" class="form-control" name="width">
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label class="col col-form-label">Height</label>
                                            <div class="col-sm-9">
                                                <input type="text" class="form-control" name="height">
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label class="col col-form-label">Compress</label>
                                            <div class="col-sm-9" >
                                                <select class="custom-select" name="compressed">
                                                    <option value="0">No</option>
                                                    <option value="1">Yes</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label class="col col-form-label">Removal Date</label>
                                            <div class="col-sm-9">
                                                <input type="text" class="form-control" name="removalDate" id="removalDate">
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary closeBtn" data-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-primary uploadBtn"
                            onclick="uploadFile()">Update</button>
                    </div>
                </div><!-- /.modal-content -->
            </div><!-- /.modal-dialog -->
        </div><!-- /.modal -->

        <!-- ------------------------------------Modal created by Ahsan for multiple files uploading------------------------------------- -->

        <div class="modal fade" id="modalAddFile" tabindex="-1" role="dialog" data-backdrop="static" >
            <div class="modal-dialog modal-dialog-slideout modal-xl" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close closeBtn" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <form id="formAddFile" action="" onsubmit="return false;" novalidate>
                            <div class="col">
                                <div class="drop-zone">
                                    <span class="drop-zone__prompt">Drop file(s) here or click to upload</span>
                                    <input type="file" multiple name="myFile" class="drop-zone__input">
                                </div>
                                <div id="dragDropMain" class="row mt-4 ml-3">

                                </div>
                            </div>
                        </form>
                    </div>
                    <div id="multipleFilespload" class="modal-footer">
                        <button type="button" class="btn btn-secondary closeBtn" data-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-primary uploadBtn"
                                onclick="uploadAllFiles()">Upload</button>
                    </div>
                </div><!-- /.modal-content -->
            </div><!-- /.modal-dialog -->
        </div><!-- /.modal -->

        <%--top down modal--%>
        <div class="modal fade" tabindex="-1" id="mediaUsesModal" role="dialog">
            <div class="modal-dialog modal-xl" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Media Usages</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body" id="mediaUsesModalPara">
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" onclick="closeMediaUsesModal()" data-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- ----------------------------------------------till here ahsan code---------------------------------------------------------- -->

        <div class="modal fade" id="modalCopyFile" tabindex="-1" role="dialog" data-backdrop="static" >
            <div class="modal-dialog modal-dialog-slideout" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Copy File</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <form id="formCopyFile" action="" onsubmit="return false;" novalidate>
                            <input type="hidden" name="id" value="">
                            <div class="invalid-feedback safeFileErrorMsg pb-1" style="display: block;"></div>
                            <div class="invalid-feedback fileErrorMsg pb-1" style="display: block;"></div>
                            <div class="form-group row">
                                <label class="col col-form-label">File name</label>
                                <div class="col-sm-9">
                                    <input type="text" class="form-control"
                                        name="name" required="required"
                                        readonly="readonly" />
                                    <div class="invalid-feedback">
                                        Cannot be empty.
                                    </div>
                                </div>
                            </div>

                            <div class="form-group row">
                                <label class="col col-form-label">New name</label>
                                <div class="col-sm-9">
                                    <div class="input-group">
                                        <input type="text" class="form-control"
                                            name="newName" maxlength="300" required="required"
                                            onchange="onChangeCopyFileNewName(this)"
                                            />
                                        <div class="input-group-append">
                                            <span class="input-group-text rounded-right fileExt"></span>
                                        </div>
                                        <div class="invalid-feedback">
                                            Cannot be empty.
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label class="col col-form-label">New label</label>
                                <div class="col-sm-9">
                                     <input type="text" class="form-control"
                                        name="newLabel" id="label" value="" maxlength="300" required="required" >
                                    <div class="invalid-feedback">
                                        Cannot be empty.
                                    </div>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label class="col col-form-label">Type</label>
                                <div class="col-sm-9" >
                                    <select class="custom-select" name="fileTypeSelect" disabled>
                                        <option value="img">Image</option>
                                        <option value="other">Other</option>
                                        <option value="video">Video</option>
                                    </select>
                                </div>
                                <input type="hidden" name="fileType" value="">
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-primary"
                            onclick="copyFile()">Upload</button>
                    </div>
                </div><!-- /.modal-content -->
            </div><!-- /.modal-dialog -->
        </div><!-- /.modal -->
               <%-- added by hamza --%>
        <div class="modal fade" id="modalImageSlideshow" tabindex="-1" role="dialog" data-backdrop="static">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-body p-1">
                        <div id="imagesCarousel" class="carousel slide" style="width: 800px; height: 400px;"> <!-- Set your fixed width and height -->
                            <div class="carousel-inner" id="carouselContents">
                                <!-- dynamically loaded -->
                            </div>
                            <a class="carousel-control-prev" href="#imagesCarousel" role="button" data-slide="prev">
                                <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                                <span class="sr-only">Previous</span>
                            </a>
                            <a class="carousel-control-next" href="#imagesCarousel" role="button" data-slide="next">
                                <span class="carousel-control-next-icon" aria-hidden="true"></span>
                                <span class="sr-only">Next</span>
                            </a>
                        </div>

                        <div id="carouselItemTemplate" class="d-none">
                            <div class="carousel-item mediaRow" style="max-height: 100%; max-width: 100%;">
                                <div class="carouselImageParent" style="max-height: 100%; max-width: 100%;">

                                    <img class="carouselImage d-block lazy"
                                        src="../img/spinner.gif" data-src="#SRC#"
                                        file-src="#FILESRC#"
                                        <%-- alt="#LABEL#" onload="onImageLoad(this,true)" --%>
                                        onclick="onCarouselImageClick(this)">
                                </div>
                                <div class="carousel-caption small carouselCaption">
                                    <p>#NAME#</p>
                                    <p></p>
                                    <p>label: #LABEL# , <span class="imageDimensions">#DIMENSIONS#</span> , #FILE_SIZE#</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer p-1">
                        <div class="w-100">
                            <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>

                            <%-- <button class='btn btn-primary float-right <%=!isPopup?"d-none":""%>'
                                onclick="selectImageModal()" >Select</button> --%>
                        </div>
                    </div>
                </div><!-- /.modal-content -->
            </div><!-- /.modal-dialog -->
        </div><!-- /.modal -->
        <%-- till here --%>

<script src="<%=request.getContextPath()%>/js/cropper.min.js"></script>
<script src="<%=request.getContextPath()%>/js/flatpickr.min.js"></script>

<script type="text/javascript">
    $ch.isSuperAdmin = <%=isSuperAdmin%>;
    $ch.THEME_LOCKED = '<%=Constant.THEME_LOCKED%>';

    $ch.FILE_TYPES = '<%=fileTypes%>'.split(',');
    $ch.MEDIA_TYPES = '<%=mediaTypes%>'.split(',');

    $ch.ckeditorName = '<%=ckeditorName%>';
    $ch.ckeditorFuncNum = '<%=ckeditorFuncNum%>';

    $ch.FILE_URL_PREPEND = '<%=FILE_URL_PREPEND%>';
    window.allTagsList = <%=getAllTagsJSON(Etn, getSiteId(session), GlobalParm.getParm("CATALOG_DB") )%>;

    $ch.CONFIG_MAX_FILE_UPLOAD_SIZE = {
        "default" : '<%=getMaxFileUploadSize("default")%>' ,
        "other"   : '<%=getMaxFileUploadSize("other")%>' ,
        "video"   : '<%=getMaxFileUploadSize("video")%>' ,
    };

    let cropper;
    let actualFileName;
    let mediaLength = "24";
    let pageNumber = 1;
    let totalPages = 0;
    let totalRecords = 0;
    let sortOrder = "f.updated_ts desc";
    let mediaSearch = "";
    let debounceTimeout;
    let fileTypes="<%=fileTypes%>";
    let imgFilterType = "";
    let mediaType="";
    let showRemoved=false;
    let updateThumbnailVar=0;
    let imgSrc;
    let isToggleOn = false;
    let ImgDimensions="";
    let prevWidth = 0;
    let prevHeight = 0;

    // ready function
    $(function() {
        flatpickr("#removalDate", {
            dateFormat: "Y-m-d",
            minDate: "today",
            defaultDate: "today",
        });
        
            const storedMediaLength = localStorage.getItem('selectedMediaLength');
            totalPages = localStorage.getItem('totalPages');

        if (storedMediaLength!=null && (document.referrer.includes("mediaLibrary.jsp") || document.referrer.length==0)) {
            mediaLength = storedMediaLength;
            $("#mediaLength").val(mediaLength);
        }
        const storedPageNumber = localStorage.getItem('currentPageNumber');
        if (storedPageNumber!=null && (document.referrer.includes("mediaLibrary.jsp") || document.referrer.length==0)) {
            if(storedPageNumber > totalPages){
                pageNumber = 1;
            }else{

                pageNumber = parseInt(storedPageNumber);
            }
        }


        initMediaFiles();

        if(typeof window.MAX_FILE_SIZES != 'undefined'){
            $.each($ch.CONFIG_MAX_FILE_UPLOAD_SIZE, function(key, val) {
                if(val.length > 0){
                    window.MAX_FILE_SIZES[key] = parseInt(val);
                }
            });
        }

        $("#modalAddEditFile").on("hide.bs.modal",function(){
            //$(this).find("input[id=useCroppedImageCheckbox]").attr("checked", true);
            destroyCropperAndImg();
            imgSrc="";
            counter = 1;
        });

        $(".imgfilter").on("change",function(){
            imgFilterType = "";
            if($(this).val() == "all" && $(this).is(":checked") == true){
                $(".imgfilter").each(function(idx,e){
                    if($(e).val() !== "all") $(e).prop("checked",false);
                });
                imgFilterType = "";
            }else
            {
                $(".imgfilter[value='all']").prop("checked",false);
                $(".imgfilter").each(function(idx,e){
                    if($(e).is(":checked")) {
                        if(idx>0) imgFilterType += ",";
                        imgFilterType += $(e).val();
                    }
                });
            } 

            if($(".imgfilter:checked").length == 0)
            {
                $(".imgfilter[value='all']").prop("checked",true);
            }
            initMediaFiles();               
        });

        initTagAutocomplete($('#formAddEditFile').find('input[name=tagsInput]'));

        document.getElementById("mediaLength").addEventListener("change", function() {
            pageNumber=1;
            mediaLength = this.value;
            localStorage.setItem('selectedMediaLength', mediaLength);
            initMediaFiles();
        });
        document.getElementById("mediaSearch").addEventListener("input",function() {
            pageNumber=1;
            clearTimeout(debounceTimeout);
            debounceTimeout = setTimeout(function() {
                mediaSearch = document.getElementById("mediaSearch").value;
                initMediaFiles();
            }, 1000);
            
        });

        

        document.querySelectorAll('.filterType').forEach(function (checkbox) {
            checkbox.addEventListener('change', function () {
                pageNumber = 1;
                fileTypes = "";
                mediaType = "";
                showRemoved = false;
                document.querySelectorAll('.filterType').forEach(function (checkbox2) {
                    if (checkbox2.checked) {
                        if(checkbox2.value.substring(0,1)==="u"){
                            mediaType=checkbox2.value;
                        }else if(checkbox2.value.substring(0,1)==="r"){
                            showRemoved=true;
                        }else{
                            if(fileTypes.length>0){
                                fileTypes +=",";
                            }
                            fileTypes+=checkbox2.value;
                        }
                    }
                });
                initMediaFiles();
            });
        });
        
        $('#imageContainerParentDiv').on('click', '.media-card', function (event) {

            var target = event.target;
            imgSrc = $(event.target).parents(".media-card").find("img").attr("src");
            if (!(target.tagName == "DIV" || target.tagName == "IMG")) return;
            if ($(target).hasClass('mediaInputCheck')) return;

            var mediaUrl = $(target).data('media-url');
            var mediaSize = $(target).data('size');
            var filename = $(target).data('media-name');
            var extension = $(target).data('extension');
            var dimension = $(target).data('dimensions');
            var mediaUsage = $(target).data('media-usage');
            var mediaThemeName = $(target).data('media-theme-name');
            var imageContainer = $('<div class="carousel-item active">' + '<a href="' + mediaUrl + '" target="' + mediaUrl + '" onclick="onFileOpenClick(event)">' + '<img class="carouselImage d-block lazy" src="' + mediaUrl + '" alt="Image" orig-src="' + mediaUrl + '" file-src="' + mediaUrl + '" onload="onImageLoad(this, true)" style="">' + '</a>' + '<div class="carousel-caption d-none d-md-block" style="position: sticky; max-height:75%; max-width:75%; background-color: rgba(0, 0, 0, 0.6); color: #fff; padding: 10px; text-align: center;">' + '<p class="mb-1">' + filename + '</p>' + '<small class="p-1 rounded" style="line-height: 100%; background-color: black;">' + mediaSize + '  ' + extension + '  ' + dimension + '  ' + mediaUsage + '  ' + mediaThemeName + '</small>' + '</div>');
            $('#carouselContents').append(imageContainer);
            var targetTagName = event.target.tagName.toLowerCase();
            if (targetTagName != 'a' && targetTagName != 'svg') {
                var tr = $(this).parents("tr:first");
                openImageSlideshow(tr.data('file-id'));
            }
        });

        $(".carousel-control-prev").on("click", function () {
            moveCarouselImage("prev");
        });

        $(".carousel-control-next").on("click", function () {
            moveCarouselImage("next");
        });

        
        $('#modalImageSlideshow').on('hide.bs.modal', function (event)  {
            $('#carouselContents').html("");
        });

        $('#modalImageSlideshow').on('shown.bs.modal', function (event) {
            var modal = $(this);
            modal.find('.carousel-control-next').focus();
            var carouselItems = [];
            var imgEle = modal.find('.carousel-item.active img.carouselImage:first');
            if (imgEle.length > 0) {
                adjustCarouselImage(imgEle);
            }
        });

        // $("#useCroppedImageCheckbox").change(function() {
        //     var cropperParentDiv = $("#cropperParentDiv");
        //     var cropperImageContainer = $("#cropperImageContainer");

        //     if (this.checked) {
        //             cropper.enable();
        //             cropper.setAspectRatio(16/9); 
        //     } else {
        //         if(cropper !== undefined) { 
        //             cropper.setAspectRatio(null); 
        //             cropper.setCropBoxData({
        //                 left: 0,
        //                 top: 0,
        //                 width: cropper.getImageData().width,
        //                 height: cropper.getImageData().height
        //             });
        //             cropper.disable();
        //         }
        //     }
        // });

    });
    function crop(){
        var button = document.getElementById("cropBtn");
        isToggleOn = !isToggleOn;
        if(isToggleOn){
                var aspectRatio = cropper.getImageData().aspectRatio;
                cropper.enable();
                cropper.setAspectRatio(aspectRatio);
        }
        else{
            if(cropper !== undefined) { 
                    cropper.setAspectRatio(null); 
                    cropper.setCropBoxData({
                        left: 0,
                        top: 0,
                        width: cropper.getImageData().width,
                        height: cropper.getImageData().height
                    });
                    cropper.disable();
                }
        }
    }

    function moveCarouselImage(moveType){
        let curSrc = $("#carouselContents").find(".carouselImage").attr("src");

        let nextObj; 
        if(moveType==="next"){
            nextObj= $(".image-container > img[src='" + curSrc + "']").closest(".media-card").parent().next();
        }else{
            nextObj= $(".image-container > img[src='" + curSrc + "']").closest(".media-card").parent().prev();
        }

        if (nextObj.length > 0) {
            let nextSrc = $(nextObj).find(".image-container > img").attr("src");
            let size = $(nextObj).find(".image-container > img").data("size");
            let extension = $(nextObj).find(".image-container > img").data("extension");
            let filename = $(nextObj).find(".image-container > img").data("media-name");
            let dimension = $(nextObj).find(".image-container > img").data("dimensions");
            let mediaUsage = $(nextObj).find(".image-container > img").data("media-usage");
            let mediaThemeName = $(nextObj).find(".image-container > img").data("media-theme-name");
            $("#carouselContents").find(".carousel-item>a").attr("href", nextSrc);
            $("#carouselContents").find(".carouselImage").attr("src", nextSrc);
            $("#carouselContents").find(".carousel-caption>p").html(filename);
            $("#carouselContents").find(".carousel-caption>small").html(size + ' ' + extension + ' ' + dimension + ' ' + mediaUsage + ' ' + mediaThemeName);
        } else return;
    }

    function openImageSlideshow(id){
        var modal = $('#modalImageSlideshow');
        var existingItem = $(document.getElementById('ci_'+id));
        if(existingItem.length > 0){
            var carouselContents = $('#carouselContents');
            carouselContents.find('.active').removeClass('active');
            existingItem.addClass('active');
        }
        modal.modal('show');
    }

    function selectImageModal(){
        var modal = $('#modalImageSlideshow');

        var curImage = modal.find('.carousel-item.active img.carouselImage');
        if(curImage.length > 0){
            selectImage(curImage);
        }
    }

    function adjustCarouselImage(imgEle){
        if(imgEle.data('adjust-type') == 'height'){
            if(imgEle.width() > imgEle.parent().width()){
                $(imgEle).css({
                    height : '',
                    width : '100%'
                });
            }
        }
        else{
            //width adjusted
            if(imgEle.height() > imgEle.parent().height()){
                $(imgEle).css({
                    width : '',
                    height : '100%'
                });
            }

        }
    }

    function onCarouselImageClick(imgEle){
        imgEle = $(imgEle);
        var imgSrc = imgEle.attr('file-src');
        if(typeof imgSrc != 'undefined' && imgSrc.trim().length > 0 ){
            window.open(imgSrc,imgSrc);
        }
    }

    function onImageLoad(imgEle, isCarouselImage){
        var imgWidth = imgEle.naturalWidth ? imgEle.naturalWidth : imgEle.width;
        var imgHeight = imgEle.naturalHeight ? imgEle.naturalHeight : imgEle.height;

        $(imgEle).parents('.mediaRow:first').find('.imageDimensions').text(imgWidth + "px x " + imgHeight + "px");

        if(isCarouselImage === true){
            imgEle = $(imgEle);
            var parent = imgEle.parent().parent();
            var parentOrientation = "landscape";
            if(parent.width() < parent.height()){
                parentOrientation = "portrait";
            }

            if(parentOrientation == "landscape"){
                if(imgWidth)
                imgEle.css({width : '', height : '100%'})
                    .data('adjust-type','height');
            }
            else{
                imgEle.css({width : '100%', height : ''})
                    .data('adjust-type','width');
            }
            if(imgEle.is(":visible")){
                adjustCarouselImage(imgEle);
            }
        }
    }


    function sortMedia(sort,ele){
        pageNumber=1;
        sortOrder = sort;
        document.getElementById("sortReference").innerHTML=ele.innerHTML;
        initMediaFiles();
    }

    function closeMediaUsesModal(){
        $('#mediaUsesModal').modal('hide');
    }

    let files=[];
    let names=[];
    let invalidFileNames='';
    let counter=1;

    document.querySelectorAll(".drop-zone__input").forEach((inputElement) => {
        const dropZoneElement = inputElement.closest(".drop-zone");

        dropZoneElement.addEventListener("click", (e) => {
            inputElement.click();
        });

        inputElement.addEventListener("change", (e) => {
            if (inputElement.files.length) {
                for(let i=0; i<inputElement.files.length;i++) {
                    updateThumbnail(dropZoneElement, inputElement.files[i]);
                }
                if(invalidFileNames!=="") {
                    bootNotifyError("Invalid Files:" + invalidFileNames);
                    invalidFileNames="";
                }
            }
        });
        dropZoneElement.addEventListener("dragover", (e) => {
            e.preventDefault();
            dropZoneElement.classList.add("drop-zone--over");
        });

        ["dragleave", "dragend"].forEach((type) => {
            dropZoneElement.addEventListener(type, (e) => {
                dropZoneElement.classList.remove("drop-zone--over");
            });
        });

        dropZoneElement.addEventListener("drop", (e) => {
            e.preventDefault();

            if (e.dataTransfer.files.length) {
                inputElement.files = e.dataTransfer.files;
                for(let i=0; i<inputElement.files.length;i++) {
                    updateThumbnail(dropZoneElement, e.dataTransfer.files[i]);
                }
                if(invalidFileNames!=="") {
                    bootNotifyError("Invalid Files:" + invalidFileNames);
                    invalidFileNames="";
                }

            }
            dropZoneElement.classList.remove("drop-zone--over");
        });

    });

    function removeFile(thisElement) {
        document.getElementById(thisElement.parentNode.id).remove();
        for(let i=0;i<files.length;i++){
            if(files[i].id===thisElement.parentNode.id){
                files.splice(i,1);
                names.splice(i,1);
            }
        }

    }
    function updateThumbnail(dropZoneElement, file) {
        if(!names.includes(file.name)) {
            let fileSplitted = file.name.split('.')
            let fileType = fileSplitted[fileSplitted.length - 1].toLowerCase();


            let validImages = ["jpeg", "jpg", "png", "gif", "jpe", "bmp", "tif", "tiff", "dib", "svg", "ico","webp"]
            let validVideos = ["avi", "mov", "mp4", "webm", "flv", "wmv"]
            let validFiles = ["pdf", "xls", "xlsx", "doc", "docx", "ppt", "pptx", "json", "csv", "ttf", "eot", "otf", "svg", "woff", "woff2"]
            let fileReader = new FileReader();
            let newDiv = "";
            fileReader.readAsDataURL(file);
            let id = Date.now().toString(36) + Math.random().toString(36).substr(2);
            file["id"] = id;

            if (validImages.includes(fileType)) {
                file["fileType"] = "img";
                fileReader.onload = () => {
                    newDiv = "<form id='" + id + "' class='col-sm-3 mt-4' style='height: 200px;border: 2px solid #c6c6c6;overflow: hidden;border-radius: 6px;'><div id='fileAlreadyExist"+id+"' class='invalid-feedback' style='display: contents;'></div><button class='close' onclick='removeFile(this)'><span class='hide-close'>&times;</span></button><img src='" + URL.createObjectURL(file) + "' style='width: 100%;height: 80%;' ><span style='position: absolute;bottom: 20px;color: white;left: 20px;'>" + file.name + "</span></form>";
                    $('#dragDropMain').append(newDiv);
                };

            }
            else if (validVideos.includes(fileType)) {
                file["fileType"] = "video";
                fileReader.onload = () => {
                    newDiv = "<form id='" + id + "' class='col-sm-3 mt-4' style='height: 200px;border: 2px solid #c6c6c6;overflow: hidden;border-radius: 6px;'><div id='fileAlreadyExist"+id+"' class='invalid-feedback' style='display: contents;'></div><button class='close' onclick='removeFile(this)'><span class='hide-close'>&times;</span></button><video style='width: 100%;height: 80%;' controls><source src='" + URL.createObjectURL(file) + "' type='video/mp4'></video><span style='position: absolute;bottom: 20px;color: white;left: 20px;'>" + file.name + "</span></form>";
                    $('#dragDropMain').append(newDiv);
                };
            }
            else if (validFiles.includes(fileType)) {
                file["fileType"] = "other";
                fileReader.onload = () => {
                    newDiv = "<form id='" + id + "' class='col-sm-3 mt-4' style='border-radius: 6px;border-color: #3b3b1f;border: 2px solid #c6c6c6;padding: 10px;text-align: center;justify-content: center;align-items: center;align-items: center;height: 200px;'><div id='fileAlreadyExist"+id+"' class='invalid-feedback' style='display: contents;'></div><button class='close' style='position: absolute;right: 10px;' onclick='removeFile(this)'><span class='hide-close'>&times;</span></button><i class='fas fa-file' style='font-size: 50px;display: block;margin-top: 50px;'></i><span>" + file.name + "</span></form>";
                    $('#dragDropMain').append(newDiv);
                };

            }
            else {
                invalidFileNames ===''?invalidFileNames=file.name:invalidFileNames=invalidFileNames+","+file.name;
            }
            checkFileExist(file.name,file.fileType,id)
            files.push(file);
            names.push(file.name);
        }
    }

    function openAddMediaModal(fileData){

        let modal = $('#modalAddFile');
        let form = $('#formAddFile');
        form.get(0).reset();
        $('.progress').remove();
        $('#dragDropMain').html('');
        $('#multipleFilespload').show();
        $('.drop-zone').show();
        $('#fileAlreadyExist').html('')
        invalidFileNames="";
        files=[];
        names=[];
        modal.modal('show');

    }
    function uploadAllFiles(){
        
        if(files.length>0){
            let modal = $('#modalAddFile');
            let form = $('#formAddFile');
            $('#multipleFilespload').hide();
            $('.drop-zone').hide();
            let progress=1;

            form.append("<div class='progress mt-3'><div class='progress-bar' role='progressbar' style='width: " + progress + "%' aria-valuenow='" + progress + "' aria-valuemin='0' aria-valuemax='100'></div></div>")
        
            for (let i = 0; i < files.length; i++) {

                let arr = files[i].name.split('.');
                arr.pop();
                let label = arr.join('.');

                let formData = new FormData();
                formData.append('file', files[i])
                formData.append('name', files[i].name)
                formData.append('label', label)
                formData.append('fileType', files[i].fileType)

                
                $.ajax({
                    type : 'POST',
                    url : 'fileUpload.jsp',
                    data : formData,
                    dataType : "json",
                    cache : false,
                    contentType : false,
                    processData : false,
                })
                .done(function (resp) {
                    progress = progress + (100 / files.length)
                    $('.progress-bar').attr('aria-valuenow', progress)
                    $('.progress-bar').attr('style', "width:" + progress + "%")
                    if (progress >= 100)
                        if (resp.status == 1) {
                            modal.modal('hide');
                            initMediaFiles();
                        }
                        else {
                            bootNotifyError("Error in file uploading");
                        }
                })
                .fail(function (resp) {
                    bootNotifyError("Error in contacting server.Please try again.");
                })
            }
        }else{
            bootNotifyError("No file uploaded.");
        }
    }

    function checkFileExist(name,fileType,id){
        $.ajax({
            url : 'filesAjax.jsp',
            type : 'POST',
            dataType : 'json',
            data : {
                requestType : "getSafeFilename",
                fileName : name,
                fileType : fileType,
                site_id : <%=selectedSiteId%>,
            },
        })
        .done(function(resp) {
            if(resp.status != 1){
                let warningMsg = "File exist. Uploading it will override existing file.";
                warningMsg = "<span class=' mt-3 text-warning'>"+warningMsg + "</span>";
                $('#fileAlreadyExist'+id).append(warningMsg);
            }
            else{
                $('#fileAlreadyExist'+id).html('');
            }

        })
        .fail(function () {
            bootNotifyError("Error contacting server. please try again.");
        })
    }

    function changePage(dir,pgNum){
        if(dir==="prev"){
            if(pageNumber>1){
                pageNumber = pageNumber - pgNum;
            }else{
                pageNumber = 1;
            }
        }else if(dir==="next"){
            if(pageNumber<totalPages){
                pageNumber = pageNumber + pgNum;
            }else{
                pageNumber = totalPages;
            }
        }else{
            if(pgNum>totalPages){
                pageNumber = totalPages;
            }else if(pgNum<1){
                pageNumber = 1;
            }else{
                pageNumber = pgNum;
            }
        }

        $("#select-all").prop("checked", false);

        totalPages= document.getElementById("pageNavigationSpan").querySelector("strong").textContent.split("\n")[0].split("of")[1].replace("pages.","").trim();
        
        localStorage.setItem('currentPageNumber',pageNumber);
        localStorage.setItem('totalPages',totalPages);
        initMediaFiles();
    }

    function initMediaFiles(){
        showLoader();
        document.getElementById("imageContainerParentDiv").innerHTML="";
        $.ajax({
            url: '<%=request.getContextPath()%>/admin/filesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getAllFilesList',
                fileTypes : fileTypes,
                mediatype : mediaType,
                caller : 'mediaLibrary',
                mediaLength : mediaLength,
                sortOrder : sortOrder,
                pageNumber : pageNumber,
                mediaSearch: mediaSearch,
                showRemoved : showRemoved,
                fileFilter : imgFilterType
            },
        })
        .done(function(resp) {
            if(resp.status == 1){
                totalPages = Math.ceil(resp.data.total_records/mediaLength);
                totalRecords = resp.data.total_records;
                

                document.getElementById("pagination").innerHTML=`<li class="page-item"><button class="page-link" onclick="changePage('',1)">First</button></li>`;
                document.getElementById("pagination").innerHTML+=`<li class="page-item"><button class="page-link" onclick="changePage('prev',1)">Previous</button></li>`;
                let count=0;
                for(let j=pageNumber;j<=totalPages;j++){
                    if(count<3){
                        document.getElementById("pagination").innerHTML+=`<li class="page-item"><button class="page-link" onclick="changePage('',`+j+`)">`+j+`</button></li>`;
                    }else{
                        document.getElementById("pagination").innerHTML+=`<li class="page-item"><button class="page-link">.</button></li>`;
                        document.getElementById("pagination").innerHTML+=`<li class="page-item"><button class="page-link">.</button></li>`;
                        break;
                    }
                    count++;
                }
                document.getElementById("pagination").innerHTML+=`<li class="page-item"><button class="page-link" onclick="changePage('next',1)">Next</button></li>`;
                document.getElementById("pagination").innerHTML+=`<li class="page-item"><button class="page-link" onclick="changePage('',`+totalPages+`)">Last</button></li>`;


                document.getElementById("pageNavigationSpan").innerHTML="<strong>Showing "+pageNumber+" of "+totalPages+
                    " pages.\nTotal records:"+totalRecords+"</strong>";
                    if(totalPages != 0 && pageNumber > totalPages){
                        
                        pageNumber = 1;
                       const localMediaLength = localStorage.getItem('selectedMediaLength');
                       mediaLength = localMediaLength;
                        $("#mediaLength").val(mediaLength);
                        showLoader();
                        initMediaFiles();
                    }
                addMediaInContainer(resp.data.files)
                .then(() => {
                    setTimeout(actionsAfterMediaLoaded,1000);
                    hideLoader();
                })
                .catch((error) => {
                    bootAlert(error);
                    hideLoader();
                });
                hideLoader();
            }else{
                bootAlert("Error in fetching data.");
                hideLoader();
            }
        })
        .fail(function() {
            bootAlert("Error in fetching data.");
            hideLoader();
        });
    }

    async function addMediaInContainer(resp){
        for (let i = 0; i < resp.length; i++) {
            // await processItemAsync(resp[i]);
            let fileMediaType = "Image";
            if(resp[i].type!=="img"){
                fileMediaType = resp[i].type.charAt(0).toUpperCase() + resp[i].type.slice(1);
            }

            let mediaName = resp[i].label;
            let extension = resp[i].file_name.substring(resp[i].file_name.lastIndexOf('.')+1).toUpperCase();
            let mediaSize = resp[i].file_size+"KB";
            let mediaUsages = resp[i].times_used;
            let mediaThemeName = "Local";
            if(resp[i].theme_name.length>0){
                mediaThemeName = resp[i].theme_name;
            }

            let isDelDisable = "";
            if(resp[i].theme_status.length>0){
                isDelDisable = "disabled";
            }

            let actionButton = '';
            if("<%=isPopup%>"==="true"){
                actionButton = `<div class="flex-column position-absolute actionsCellTemplate" style="right: 0;top: 10px;gap: 5px;display:none;">
                                    &nbsp;<button class='btn btn-sm btn-primary' onclick="selectImage(this)"><i data-feather="check-circle"></i></button>
                                </div>`;
            }else{
                actionButton = `<div class="flex-column position-absolute actionsCellTemplate" style="right: 0;top: 10px;gap: 5px;display:none;">
                                    &nbsp;<button class='btn btn-sm btn-primary' type="button"
                                        onclick='editOrCopyFile(this,"`+resp[i].id+`","edit")'>
                                        <i data-feather="settings"></i></button>
                                    <button class='btn btn-sm btn-primary' type="button"
                                        onclick='editOrCopyFile(this,"`+resp[i].id+`","copy")'>
                                        <i data-feather="copy"></i></button>
                                    <button class='btn btn-sm btn-danger delBtn' type="button"
                                        onclick='deleteSingleFile("`+resp[i].id+`","`+resp[i].times_used+`")' `+isDelDisable+`>
                                        <i data-feather="x"></i></button>
                                </div>`;
            }

            let mediaUrl = $ch.FILE_URL_PREPEND+resp[i].type+"/"+resp[i].file_name;

            if(resp[i].type!=="img"){
                if(resp[i].thumbnail.length>0){
                    mediaUrl = $ch.FILE_URL_PREPEND+'thumbnail/'+resp[i].thumbnail;
                }else{
                    mediaUrl = '../img/fileIcons/icon-'+resp[i].file_name.slice((resp[i].file_name.lastIndexOf(".") - 1 >>> 0) + 2)+'.png';
                }
            }

            let imageRemoval = "border: 4px solid #e55353";
            if(resp[i].is_removed!=="removed"){
                imageRemoval = "";
            }
            appendToMediaContainer(resp[i].id,mediaUrl,fileMediaType,mediaName,extension,mediaSize,mediaUsages,mediaThemeName,"0x0px",actionButton,resp[i],imageRemoval);
        }
    }

    function appendToMediaContainer(mediaId,mediaUrl,fileMediaType,mediaName,extension,mediaSize,mediaUsages,mediaThemeName,dimensions,actionButton,item,imgRemoval){

        let tmpMediaName=mediaName;
        if(mediaName.length>25){
            mediaName=mediaName.substring(0,24)+"...";
        }

        var timestamp = new Date().getTime().toString();
        mediaUrl+= "?"+timestamp;
        
        let mediaDiv = '<div class="col-12 col-lg-3 col-md-4 col-sm-6 mb-3 overflow-hidden position-relative">' +
        '<div class="card media-card" style="' + imgRemoval + '">' +
        '<label class="mb-0" style="cursor: pointer;">' +
        '<div class="image-container">' +
        '<img src="' + mediaUrl + '" alt="Image" style="height: 150px; object-fit: cover;" class="card-img-top" data-media-url="' + mediaUrl + '" data-size="'+mediaSize+'" data-media-name="' + _hEscapeHtml(mediaName) +'"data-extension="' + extension +'"data-dimensions="' + dimensions +'"data-media-usage="' + mediaUsages +'"data-media-theme-name="' + _hEscapeHtml(mediaThemeName) +'">' +
        '<input class="form-check-input mediaInputCheck" type="checkbox" data-use="'+ mediaUsages +'" value="' + mediaId + '" style="position: absolute; left: 30px; top: 10px;">' +
        '</div>';


         mediaDiv +='<input class="item-data" hidden value="'+item.file_name+','+item.alt_name+','+item.label+','+item.type+'" style="left: 30px; top: 10px;">';
                
          //'<input class="form-check-input mediaInputCheck" type="checkbox" data-use="'+ mediaUsages +'" value="'+mediaId+'" style="left: 30px; top: 10px;">'+
        if(fileMediaType!=="Image"){
            mediaDiv +='<input class="item-data-url" hidden value="'+mediaUrl+'" style="left: 30px; top: 10px;">';
        }

        mediaDiv +='<small class="p-2 position-absolute text-white" style="top: 0; right: 0; background-color: rgba(0 0 0/50%);">'+fileMediaType+'</small>'+
                    actionButton+
                '</label>'+
                '<div class="card-body image-details">'+
                    '<div class="font-weight-bolder image-name text-center" title="'+_hEscapeHtml(tmpMediaName)+'">'+_hEscapeHtml(mediaName)+'</div>'+
                '</div>'+
                '<div class="bg-white card-footer d-flex justify-content-center" style="gap: 5px;">'+
                    '<small class="p-1 rounded" style="line-height: 100%; background-color: #ddd;">'+_hEscapeHtml(extension)+'</small>'+
                    '<small class="p-1 rounded" style="line-height: 100%; background-color: #ddd;">'+mediaSize+'</small>';

        if(fileMediaType==="Image"){
            mediaDiv += '<small class="p-1 rounded img-dimension" style="line-height: 100%; background-color: #ddd;">'+dimensions+'</small>';
        }
        mediaDiv += '<small class="p-1 rounded nbUses" style="line-height: 100%; background-color: #ddd;" title="Total uses: '+mediaUsages+'" >'+mediaUsages+'</small>'+
                    '<small class="bg-warning p-1 rounded" style="line-height: 100%;" title="'+_hEscapeHtml(mediaThemeName)+'">';

        mediaDiv+=_hEscapeHtml(mediaThemeName.slice(0,6));
        if(mediaThemeName !=="Local"){
            mediaDiv+="..";
        }
        mediaDiv += '</small></div></div></div>';

        document.getElementById("imageContainerParentDiv").innerHTML += mediaDiv;
    }

    function actionsAfterMediaLoaded(){

        feather.replace();

        $(".nbUses").on("click", function() {
            var value = $(this).text();
            var inputValue = $(this).closest(".card").find("input.form-check-input").val();

            if(value ==='0'){
                $('#mediaUsesModalPara').html("<p>This media is not used anywhere</p>")
                $('#mediaUsesModal').modal('show');
            }else{
                $.ajax({
                    url : 'getMediaUsesAjax.jsp',
                    type : 'GET',
                    dataType : 'json',
                    data:{
                        file_id:inputValue
                    },
                })
                .done(function(resp) {
                    if(resp.status==0) {
                        let table = "<table id='mediaUsesTable' class='table table-hover table-vam' style='width: 100%;'>" +
                            "<thead class='thead-dark'><tr><th>Type</th><th>Used In</th></tr></thead>" +
                            "<tbody></tbody></table>";
                        $('#mediaUsesModalPara').html( "Uses for file: <span style='font-weight: bold; font-size: 16px;'>"+resp.files[0].file_name+"</span>"+table)

                        let tableRows ="";
                        for (let i = 0; i < resp.files.length; i++) {
                            tableRows += "<tr><td style='min-width:150px;'>" + resp.files[i].type + "</td><td style='word-break: break-all;'>" + resp.files[i].used_at + "</td></tr>"
                        }
                        $("#mediaUsesTable tbody").append(tableRows);
                    }else{
                        $('#mediaUsesModalPara').html("<p>Some error occured</p>")
                        $('#mediaUsesModal').modal('show');
                    }
                    $('#mediaUsesModal').modal('show');
                })
            }
        });

        const imgDimensionElements = document.querySelectorAll('.img-dimension');
        imgDimensionElements.forEach(imgDimensionElement => {
            const labelElement = imgDimensionElement.parentElement.previousSibling.previousSibling;

            const image = new Image();
            image.src = labelElement.querySelector('img').src;

            image.onload = function () {
                imgDimensionElement.innerHTML = image.width+"x"+image.height+"px";
                imgDimensionElement.parentElement.parentElement.querySelector("img").dataset.dimensions  = image.width+"x"+image.height+"px";
            };

        });

        const imgHiddenUrl = document.querySelectorAll('.item-data-url');
        imgHiddenUrl.forEach(imgHiddenUrlElement => {
            const mediaUrl = imgHiddenUrlElement.parentElement.querySelector("img").src;
            if(mediaUrl!=undefined && !mediaUrl.includes("thumbnail")){
                checkFileExistence(mediaUrl)
                .then(exists => {
                    if(!exists) {
                        const parts = mediaUrl.split('.');

                        const parts2 = mediaUrl.replace('.' + parts[parts.length - 1], '').split('-');
                        const extractedString = parts2[parts2.length - 1];

                        imgHiddenUrlElement.parentElement.querySelector("img").src = '../img/filetype/'+extractedString+'.svg';
                    }
                });
            }
        });
    }

    // ------------- Start New media settings -------------------

    document.querySelector('.closeBtn').addEventListener('click', function() {
       document.getElementById('otherFileContainer').innerHTML="";
    });

    function openThumbnailImageInput() {
        const imageInput = document.getElementById('thumbnailImageInput');
        imageInput.click();
    }

    document.getElementById('thumbnailImageInput').addEventListener('change', function(event) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = function(e) {
                let imgContainer = document.querySelector("#thumbnailContainer img");
                imgContainer.src=e.target.result;
            };
            updateThumbnailVar=1;
            document.getElementById("thumbnailBtn").hidden=false;
            reader.readAsDataURL(file);
        }
    });

    function openAddEditMediaModal(fileData){
        updateThumbnailVar=0;
        var modal = $('#modalAddEditFile');
        var form = $('#formAddEditFile');
        form.get(0).reset();
        form.find('.fileErrorMsg').html('');
        form.find('.safeFileErrorMsg').html('');
        form.find('.is-invalid').removeClass('is-invalid');
        modal.find(':input:not(.closeBtn)').prop("disabled", false);
        
        // $("#useCroppedImageCheckbox").prop("checked", true);

        if(typeof fileData == 'undefined'){
            //add new file
            modal.find('.modal-title').text('Add new');

            form.find('[name=id]').val('');
            form.find('[name=name]').val('');
            form.find('[name=label]').val('');

            form.find('[name=fileType]').val("");
            form.find('[name=fileTypeSelect]').val("");

            var fileInputAccept = [];
            $.each($ch.FILE_TYPES, function(index, curFileType) {
                fileInputAccept.push( "."+ALLOWED_TYPES[curFileType].join(',.') );
            });

            fileInputAccept = fileInputAccept.join(",");

            form.find('[name=file]').attr('accept',fileInputAccept);
            form.find('.fileLabel').text('Upload new file');
        }
        else{
            
            
            if(fileData.theme_status.length>0 && fileData.theme_status == $ch.THEME_LOCKED && !$ch.isSuperAdmin){
                modal.find(':input:not(.closeBtn)').prop("disabled", true);
            }
            var fileType = fileData.type;
            var fileTypeFound = false;

            $.each($ch.FILE_TYPES, function(index, curFileType) {
                if(curFileType === fileType){
                    fileTypeFound = true;
                    return false;
                 }
            });
            if( !fileTypeFound ){
                bootNotifyError("Invalid file type.");
                return false;
            }

            modal.find('.modal-title').text('Edit ' + fileType.toUpperCase() + " file");

            var fileName = fileData.file_name;
            actualFileName = fileName;

            var fileUrl = $ch.FILE_URL_PREPEND + fileType + "/" + fileName;

            var fileExt = fileName.substring(fileName.lastIndexOf('.')+1);

            form.find('[name=id]').val(fileData.id);
            form.find('[name=name]').val((fileName));
            form.find('[name=file_url]').val((fileUrl));
			console.log("fileData.label:"+fileData.label);
            form.find('[name=label]').val((fileData.label));

            form.find('[name=fileType]').val(fileType);
            form.find('[name=fileTypeSelect]').val(fileType);

            form.find('[name=file]').attr('accept',"."+fileExt);
            form.find('.fileLabel').text('Upgrade this file');

            var firstThreeChildren = $(document.getElementById("advancedInfo").firstElementChild).children().slice(0, 3);
            if(fileType==="img"){            
                firstThreeChildren.show();
                document.getElementById("cropperParentDiv").hidden=false;
                document.getElementById("otherParentDiv").hidden=true;
                document.getElementById("thumbnailParent").hidden=true;

            }else{
                firstThreeChildren.hide();
                document.getElementById("cropperParentDiv").hidden=true;
                document.getElementById("otherParentDiv").hidden=false;
                document.getElementById("thumbnailParent").hidden=false;

                if(fileName.toLowerCase().endsWith(".pdf") || fileType==="video"){
                    var otherFileContainer = document.getElementById("otherFileContainer");
                    var iframe = document.createElement("iframe");
                    iframe.src = fileUrl;
                    iframe.width = "100%";
                    iframe.height = "100%";
                    otherFileContainer.appendChild(iframe);
                }else{
                    let fileIcon = '../img/fileIcons/icon-'+fileName.slice((fileName.lastIndexOf(".") - 1 >>> 0) + 2)+'.png';

                    checkFileExistence(fileIcon)
                    .then(exists => {
                        if (!exists) {
                            fileIcon = '../img/filetype/'+fileName.slice((fileName.lastIndexOf(".") - 1 >>> 0) + 2)+'.svg';
                        }
                        
                        document.getElementById("otherFileContainer").innerHTML = 
                            '<img width="100%" height="100%" src="'+fileIcon+'">';
                    });
                }
            }

            let imgContainer = document.querySelector("#thumbnailContainer img");
            if(fileData.thumbnail && fileData.thumbnail.length>0){
                imgContainer.src="../<%=GlobalParm.getParm("UPLOADS_FOLDER")+getSiteId(session)+"/thumbnail/" %>"+fileData.thumbnail;
            }else{
                document.getElementById("thumbnailBtn").hidden=true;
                imgContainer.src="../img/camera.svg";
            }

            form.find('[name=altName]').val((fileData.alt_name));
            form.find('[name=description]').val((fileData.description));
            form.find('[name=removalDate]').val(fileData.removal_date);
            $(".mediaTagsDiv").empty();

            var mediaTagInput = form.find("input[name=tagsInput]");
            $.each(fileData.tags, function(index, tagObj) {
                addTagGeneric(tagObj, mediaTagInput);
            });
        }
        modal.modal('show');

        let thumbnailBtn = document.getElementById("thumbnailBtn");
        thumbnailBtn.addEventListener("click", function(event) {
            event.stopPropagation();

            thumbnailBtn.nextElementSibling.src="../img/camera.svg";
            document.getElementById("thumbnailBtn").hidden=true;
            updateThumbnailVar = 1;
        });
        newFileUrl = fileUrl;
        newFileName = fileName;
        newForm = form;
        newFileType = fileType;
          
        setTimeout(function() {
            createImgAndInitCropper(fileUrl,fileName,form,fileType)
        }, 200);
    }

    function createImgAndInitCropper(fileUrl,fileName,form,fileType){
        if(fileType==="img"){
            var img = document.createElement("img");
            var timestamp = new Date().getTime().toString();
            img.src = fileUrl+"?"+timestamp;
            img.alt = fileName;

            initCropper(img,form);
        }
    }

    function checkFileExistence(url) {
        return fetch(url, { method: 'HEAD' })
        .then(response => {
            if (response.ok) {
                return true;
            } else {
                return false;
            }
        })
        .catch(error => {
            console.error('Error checking file existence:', error);
            return false;
        });
    }
    
    function destroyCropperAndImg(){
        let cropperImage =  document.getElementById("cropperImageContainer");
        let img = cropperImage.querySelector(".cropper-canvas img");

        if(img){
            img.remove();
        }
        if (cropper) {
            cropper.destroy();
            cropper=null;
            cropperImage.innerHTML = "";
        }

        document.getElementById("otherFileContainer").innerHTML = "";
        
    }

    function initCropper(img,form){
        
        document.getElementById("cropperImageContainer").appendChild(img);
        
        img.onload = function () {

            prevWidth = img.naturalWidth;
            prevHeight = img.naturalHeight;

            let aspectRatio = img.naturalWidth / img.naturalHeight;
            cropper = new Cropper(img, {
                aspectRatio: aspectRatio,
                viewMode: 1,
                responsive: true,
                movable: true,
                cropBoxResizable: true,
                guides: true,
                rotatable:true,
            });
    
            
    
            img.addEventListener('ready', function () {
                getCroppedDimensions(form,img);
                isToggleOn = false;
                cropper.setAspectRatio(null); 
                cropper.setCropBoxData({
                    left: 0,
                    top: 0,
                    width: cropper.getImageData().width,
                    height: cropper.getImageData().height
                });
                cropper.disable();
            });
        };

    }

    function getCroppedDimensions(form,img) {
        if (cropper) {
            var actualImageData = cropper.imageData;
            if(actualImageData.naturalWidth){
                setDimensions(form,actualImageData.naturalWidth,actualImageData.naturalHeight);
                $('[name="width"], [name="height"]').off('input');
                $('[name="width"], [name="height"]').on('input', function () {
                    debounceTimeout = null;
                    clearTimeout(debounceTimeout);
                    debounceTimeout = setTimeout(function() {
                        updateCropper(form,img);
                    }, 1500);
                });
            }
            $('[name="compressed"]').off('change');
            $('[name="compressed"]').on('change', function () {
                if (this.value === '1') {
                    destroyCropperAndImg();
                    showLoader();
                    compressImage(imgSrc)
                    .then(compressedBlob => {
                        
                        var newImage = new Image();
                        newImage.src = URL.createObjectURL(compressedBlob);
                        initCropper(newImage,form);
                        
                    })
                    .catch(error => {
                        bootAlert('Error compressing image:', error);
                    });
                    hideLoader();
                    
                        isToggleOn = false;
                }
            });
            
        }
    }

    function setDimensions(form,width,height){
        form.find('[name=width]').val(width);
        form.find('[name=height]').val(height);
    }

    function updateCropper(form, oldImg) {
        var newWidth = parseInt($('[name="width"]').val()) || 0;
        var newHeight = parseInt($('[name="height"]').val()) || 0;
        var $tooltipWidth = $('[name="width"]');
        var $tooltipHeight = $('[name="height"]');
        
        if (newWidth > 0 && newHeight > 0) {
            var aspectRatio = cropper.imageData.aspectRatio;

            $tooltipWidth.removeClass('is-invalid').tooltip('hide');
            $tooltipHeight.removeClass('is-invalid').tooltip('hide');

            if (newWidth > prevWidth) {
                $tooltipWidth.addClass('is-invalid').tooltip({
                    title: 'The new Width cannot be greater than the previous Width.',
                    placement: 'bottom',
                    trigger: 'manual'
                }).tooltip('show');
            }

            if (newHeight > prevHeight) {
                $tooltipHeight.addClass('is-invalid').tooltip({
                    title: 'The new Height cannot be greater than the previous Height.',
                    placement: 'bottom',
                    trigger: 'manual'
                }).tooltip('show');
            }

            if (newWidth <= prevWidth && newHeight <= prevHeight) {
                $tooltipWidth.removeClass('is-invalid').tooltip('hide');
                $tooltipHeight.removeClass('is-invalid').tooltip('hide');
                if (aspectRatio) {
                    if (newWidth !== parseInt(cropper.imageData.naturalWidth)) {
                        newHeight = newWidth / aspectRatio;
                    } else if (newHeight !== parseInt(cropper.imageData.naturalHeight)) {
                        newWidth = newHeight * aspectRatio;
                    }
                }

                setDimensions(form, newWidth, newHeight);
                updateImageDimensions(oldImg.src, newWidth, newHeight, form);
            }
        }
    }




    function updateImageDimensions(url,width,heigth,form){
        showLoader();

        const canvas = document.createElement('canvas');
        canvas.width = width;
        canvas.height = heigth;

        const image = new Image();
        image.src = url;

        image.onload = function () {
            const ctx = canvas.getContext('2d');
            ctx.drawImage(image, 0, 0, canvas.width, canvas.height);

            var newImage = new Image();
            newImage.src = canvas.toDataURL('image/jpeg');
            initCropper(newImage,form);
        };
        hideLoader();
    }

    function compressImage(url) {
        return new Promise((resolve, reject) => {
            const image = new Image();
            image.src = url;
            
            image.onload = () => {
                const canvas = document.createElement('canvas');
                const context = canvas.getContext('2d');
                const maxSize = Math.pow(0.75,counter);
                

                const width = parseInt(image.width * maxSize);
                const height = parseInt(image.height * maxSize);

                prevWidth = width;
                prevHeight = height;


                canvas.width = width;
                canvas.height = height;
                
                context.drawImage(image, 0, 0, width, height);
                canvas.toBlob(resolve, 'image/jpeg', 0.9);
            };
            image.onerror = reject;
            counter +=1;
        });
    }

    function callToolBarFunc(action) {
        if(action==="move"){
            cropper.setDragMode(action);
        }else if(action==="crop"){
            cropper.setDragMode(action);
        }else if(action==="in"){
            cropper.zoom(0.1);
        }else if(action==="out"){
            cropper.zoom(-0.1);
        }else if(action==="left"){
            cropper.move(-10,0);
        }else if(action==="right"){
            cropper.move(10,0);
        }else if(action==="up"){
            cropper.move(0,-10);
        }else if(action==="down"){
            cropper.move(0,10);
        }else if(action==="undo"){
            cropper.rotate(-45);
        }else if(action==="redo"){
            cropper.rotate(45);
        }else if(action==="sync"){
            cropper.reset();
        }else{
            downloadCroppedImage();
        }
    }

    function downloadCroppedImage(){
        if (cropper) {
            const croppedCanvas = cropper.getCroppedCanvas();
            const dataURL = croppedCanvas.toDataURL('image/jpeg');
            const downloadLink = document.createElement('a');
            downloadLink.href = dataURL;
            downloadLink.download = actualFileName;

            document.body.appendChild(downloadLink);
            downloadLink.click();
            document.body.removeChild(downloadLink);
        }
    }

    // ------------- endCropper -------------------

    function openCopyMediaModal(fileData){

        var modal = $('#modalCopyFile');
        var form = $('#formCopyFile');
        form.get(0).reset();
        form.removeClass('was-validated');

        form.find('.fileErrorMsg').html('');
        form.find('.safeFileErrorMsg').html('');
        form.find('.is-invalid').removeClass('is-invalid');

        var fileType = fileData.type;

        var fileName = fileData.file_name;

        var fileExt = fileName.substring(fileName.lastIndexOf('.')+1);
        var fileNameWithoutExt = fileName.substring(0,fileName.lastIndexOf('.'));

        form.find('[name=id]').val(fileData.id);
        form.find('[name=name]').val(fileName);
        form.find('[name=newName]').val(fileNameWithoutExt + " copy");
        form.find('[name=newLabel]').val(fileData.label);

        form.find(".fileExt").text('.' + fileExt);

        form.find('[name=fileType]').val(fileType);
        form.find('[name=fileTypeSelect]').val(fileType);

        modal.modal('show');

    }

    function editOrCopyFile(ele,fileId, action){
        showLoader();
        $.ajax({
            url: 'filesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getFileInfo',
                id : fileId,
            },
        })
        .done(function(resp) {
            ImgDimensions = $(ele).closest(".media-card").find("img").data("dimensions");
            if(resp.status == 1){
                if(action === 'copy'){
                    openCopyMediaModal(resp.data.file);
                }
                else{
                    resp.data.file.removal_date=convertDateFormat(resp.data.file.removal_date);
                    openAddEditMediaModal(resp.data.file);
                }
            }
        })
        .fail(function() {
            bootNotifyError("Error contacting server.");
        })
        .always(function() {
            hideLoader();
        });
    }

    function convertDateFormat(inputDate) {
        var parts = inputDate.split('/');
        if (parts.length !== 3) {
            return '';
        }
        var day = parts[0];
        var month = parts[1];
        var year = parts[2];
        var date = new Date(year, parseInt(month) - 1, parseInt(day)+1);
        var formattedDate = date.toISOString().substr(0, 10);

        return formattedDate;
    }

    function uploadFile(){
        var modal = $('#modalAddEditFile');
        var form = $('#formAddEditFile');
        var errorMsgEle = form.find('.fileErrorMsg');
        errorMsgEle.html('');

        var errorMsg = "";
        form.find('.is-invalid').removeClass('is-invalid');

        var name = form.find('input[name=name]');
        var label = form.find('input[name=label]');

        if(name.val().trim().length == 0){
            name.addClass('is-invalid');
            errorMsg += " ";
        }

        if(label.val().trim().length == 0){
            label.addClass('is-invalid');
            errorMsg += " ";
        }

        var fileId = form.find('input[name=id]');

        var fileInput = form.find('input[name=file]');
        var fileType = form.find('input[name=fileType]');

        var numFiles = fileInput.get(0).files.length;
        
        
        if(fileId.val() == "" || numFiles > 0){
            errorMsg += validateFileUpload(fileInput,fileType.val());
        }

        if(errorMsg.length > 0){
            errorMsgEle.html(errorMsg);
            return false;
        }

        var formData = new FormData(form.get(0));

        var mediaTags = [];
        form.find('.mediaTagsDiv input.tagValue').each(function (index, el) {
            var tagId = $(el).val().trim();
            if (tagId.length > 0 && mediaTags.indexOf(tagId) < 0) {
                mediaTags.push(tagId);
            }
        });

        formData.append('mediaTags', mediaTags.join(","));
        formData.append('updateThumbnailVar', updateThumbnailVar);

        if(numFiles===0 && cropper){
            formData.delete('file');
            var croppedCanvas = cropper.getCroppedCanvas();
            var croppedImageData = croppedCanvas.toDataURL('image/jpeg');
            var blob = dataURLtoBlob(croppedImageData);
            formData.append('file', blob, name.val());
        }else{
            const thumbnailImage = document.getElementById('thumbnailImageInput');
            const thumbnail = thumbnailImage.files[0];

            if (thumbnail && thumbnail.type.startsWith("image")) {
                formData.append('thumbnail', thumbnail);
                formData.append('thumbnailName', thumbnail.name);
            }
        }
        
        showLoader();
        $.ajax({
            type :  'POST',
            url :   'fileUpload.jsp',
            data :  formData,
            dataType : "json",
            cache : false,
            contentType: false,
            processData: false,
        })
        .done(function(resp) {
            if(resp.status == 1){

                form.get(0).reset();
                window.location.reload();
                // modal.modal('hide');
                // bootNotify("Media saved.");
                // initMediaFiles();
            }
            else{
                errorMsgEle.html(resp["message"]);
            }
        })
        .fail(function(resp) {
             bootNotifyError("Error in contacting server.Please try again.");
        })
        .always(function() {
            hideLoader();
        });

    }
    function dataURLtoBlob(dataURL) {
        var arr = dataURL.split(','), mime = arr[0].match(/:(.*?);/)[1],
            bstr = atob(arr[1]), n = bstr.length, u8arr = new Uint8Array(n);
        
        while(n--) {
            u8arr[n] = bstr.charCodeAt(n);
        }
        
        return new Blob([u8arr], {type:mime});
    }
    function onFileOpenClick(event){
        event.stopPropagation();
    }

    function onFileInputChange(input){
        input = $(input);
        var form = $('#formAddEditFile');
        var errorMsgDiv = form.find('.fileErrorMsg');
        var fileLabelEle = input.parent().find(".fileLabel");

        errorMsgDiv.text('');

        var fileId = form.find('[name=id]').val();
        var numFiles = input.get(0).files.length;
        var errorMsg = "";

        if(numFiles > 0){
            var file = input.get(0).files[0];

            var fileName = file.name;

            fileLabelEle.text(fileName);

            var fileExt = "";
            if(fileName.lastIndexOf('.') > 0){
                fileExt = fileName.substring(fileName.lastIndexOf('.')+1);
                fileExt = fileExt.toLowerCase();
            }

            if(fileId == ""){
                //new file
                var foundFileType = "";
                $.each($ch.FILE_TYPES, function(index, curFileType) {
                    var curAllowedFileTypes = ALLOWED_TYPES[curFileType];
                    if(curAllowedFileTypes.indexOf(fileExt) >= 0){
                        foundFileType = curFileType;
                        return false;//break the each loop
                    }
                });

                if(foundFileType.length > 0){
                    //fileLabelEle.text("File selected");
                    var label = fileName;
                    if(label.lastIndexOf('.') > 0){
                        label = label.substring(0,label.lastIndexOf('.'));
                    }
                    form.find('[name=label]').val(label);
                    getSafeFileName(foundFileType);
                }
                else{
                   errorMsg = "Error: please selected valid filetype.";

                }

                form.find('[name=fileType]').val(foundFileType);
                form.find('[name=fileTypeSelect]').val(foundFileType);
            }
            else{
                //edit existing file, only allow same files with same extension
                var fileNameInput = form.find('[name=name]');
                var existingFileName = fileNameInput.val();

                var existingFileExt = existingFileName.substring(existingFileName.lastIndexOf('.')+1);
                existingFileExt = existingFileExt.toLowerCase();

                if(existingFileExt !== fileExt){
                    errorMsg = "Error: Invalid file type. Please select file of same type as of existing.";
                }
                else{
                    var fileType = form.find('[name=fileType]').val();

                    var label = fileName;
                    if(label.lastIndexOf('.') > 0){
                        label = label.substring(0,label.lastIndexOf('.'));
                    }
                    form.find('[name=label]').val(label);

                }

            }
        }

        if(errorMsg.length > 0){
            errorMsgDiv.text(errorMsg);
            return false;
        }
    }

    function copyFile(){
        var modal = $('#modalCopyFile');
        var form = $('#formCopyFile');
        var errorMsgEle = form.find('.fileErrorMsg');
        errorMsgEle.html('');

        if(!form.get(0).checkValidity()){
            form.addClass('was-validated');
            return false;
        }

        showLoader();
        $.ajax({
            url: 'filesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'copyFile',
                id : form.find('[name=id]').val(),
                newName : form.find('[name=newName]').val(),
                newLabel : form.find('[name=newLabel]').val(),
            },
        })
        .done(function(resp) {
            if(resp.status == 1){

                modal.modal('hide');
                bootNotify("File copied.");
                initMediaFiles();
            }
            else{
                bootAlert(resp.message);
            }
        })
        .fail(function() {
            bootNotifyError("Error contacting server.");
        })
        .always(function() {
            hideLoader();
        });

    }
    function deleteSingleFile(fileId , noOfUses){
        
        if (noOfUses > 0) {
            bootNotifyError("Unable to delete the file as it is currently in use.");
        }else{
            const idToDelete = [fileId];
            
            bootConfirm("Are you sure you want to delet the file?", function(result){
                if(result){
                    deleteFiles(idToDelete);
                }
            });
        }
    }
    function deleteFiles(idToDelete){
        showLoader();
        $.ajax({
            url: 'filesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'deleteFile',
                elements : JSON.stringify(idToDelete),
            },
        })
        .done(function(resp) {
            if(resp.status == 1){
                let notifyMsg = "";
                if (resp.data.countOk > 0) {
                    notifyMsg = resp.data.countOk + " files  deleted successfully. ";
                }

                if (resp.data.countError > 0) {
                    notifyMsg += resp.data.countError + " files faced an error.";
                }    
                bootNotify(notifyMsg);
            }else{
                bootNotifyError(resp.message);
            }
        })
        .fail(function() {
            bootNotifyError("Error contacting server.");
        })
        .always(function() {
            hideLoader();
            setTimeout(function(){
                window.location.reload();
            },1500);
        });
    }

    function getSafeFileName(fileType){
        var form = $('#formAddEditFile');

        var errorMsgDiv = form.find('.safeFileErrorMsg');

        var fileInput = form.find('[name=file]');
        var numFiles = fileInput.get(0).files.length;
        if(numFiles <= 0){
            return false;
        }


        if(typeof fileType == 'undefined'){
            fileType = 'img';
        }

        var file = fileInput.get(0).files[0];
        var fileName = file.name;

        showLoader();
        $.ajax({
            url: 'filesAjax.jsp',
            type: 'POST',
            dataType: 'json',
            data: {
                requestType : "getSafeFilename",
                fileName : fileName,
                fileType : fileType,
            },
        })
        .done(function(resp) {

            if(typeof resp.data !== 'undefined'
                && typeof resp.data.fileName !== 'undefined'){
                form.find("[name=name]").val(resp.data.fileName);
                //fileInput.parent().find(".fileLabel").text(resp.data.fileName);
            }
            if(resp.status != 1){
                var warningMsg = "Warning: file name already exist. Uploading this image will override existing file.";
                warningMsg = "<span class='text-warning'>"+warningMsg + "</span>";
                errorMsgDiv.html(warningMsg);
            }
            else{
                errorMsgDiv.html('');
            }

        })
        .fail(function() {
            bootNotifyError("Error contacting server. please try again.");
        })
        .always(function() {
            hideLoader();
        });
    }

    function onChangeCopyFileNewName(input){
        var form = $(input).parents('form:first');

        var errorMsgDiv = form.find('.safeFileErrorMsg');

        var fileName = $(input).val().trim();
        var fileExt =  form.find('.fileExt').text();
        var fileType = form.find('[name=fileType]').val();

        showLoader();
        $.ajax({
            url: 'filesAjax.jsp',
            type: 'POST',
            dataType: 'json',
            data: {
                requestType : "getSafeFilename",
                fileName : fileName + fileExt,
                fileType : fileType,
            },
        })
        .done(function(resp) {

            if(typeof resp.data !== 'undefined'
                && typeof resp.data.fileName !== 'undefined'){
                var fileName = resp.data.fileName;
                fileName = fileName.substring(0, fileName.lastIndexOf('.'));
                $(input).val(fileName);
            }
            if(resp.status != 1){
                var warningMsg = "Error: File of same name already exists.";
                warningMsg = "<span class='text-danger'>"+warningMsg + "</span>";
                errorMsgDiv.html(warningMsg);
            }
            else{
                errorMsgDiv.html('');
            }

        })
        .fail(function() {
            bootNotifyError("Error contacting server. please try again.");
        })
        .always(function() {
            hideLoader();
        });
    }

    function selectImage(refEle){

        if(!window.opener){
            return false;
        }

        const hiddenInputValue = refEle.closest('label').querySelector('.item-data').value.split(",");

        var fileName = hiddenInputValue[0];
        var fileType = hiddenInputValue[3];
        var fileLabel = hiddenInputValue[2];
        var altName = hiddenInputValue[1];
        
        if($ch.ckeditorFuncNum.length > 0 && window.opener.CKEDITOR){
            //popup from ckeditor image button
            var fileUrl = $ch.FILE_URL_PREPEND + fileType + "/" + fileName;

            window.opener.CKEDITOR.tools.callFunction( $ch.ckeditorFuncNum, fileUrl, function(){
                // Get the reference to a dialog window.
                var dialog = this.getDialog();
                // Check if this is the Image Properties dialog window.
                if ( dialog.getName() == 'image' ) {
                // Get the reference to a text field that stores the "alt" attribute.
                var element = dialog.getContentElement( 'info', 'txtAlt' );
                // Assign the new value.
                if ( element )
                    element.setValue( fileLabel );
                }
                // Return "false" to stop further execution. In such case CKEditor will ignore the second argument ("fileUrl")
                // and the "onSelect" function assigned to the button that called the file manager (if defined).
                // return false;
            });
        }
        else{
            if(!window.opener.selectFieldImage && !window.opener.selectFieldImageTheme && !window.opener.selectFieldImageDynamic && !window.isImageFieldV2){
                return false;
            }
            
            var pObj = {
                name : fileName,
                label : fileLabel,
                type : fileType,
                altName : altName
            };

            if(fileType == 'video' && window.isImageFieldV2){
                window.opener.selectFieldImageV2(pObj,undefined,fileType);
            }
            else {

            if(fileType != 'img'  && typeof window.opener.selectFieldFile !== 'undefined'){
                window.opener.selectFieldFile(pObj);
            }
            else{
                if(window.opener.location.pathname.includes("themeContentData")){
                    window.opener.selectFieldImageTheme(pObj);
                }else if(window.opener.location.pathname.includes("dtnamicPageEditor")){
                    //popup from bloc image field
                    window.opener.selectFieldImageDynamic(pObj);
                }else{
                    //popup from bloc image field
                    if(window.isImageFieldV2)
                        window.opener.selectFieldImageV2(pObj);    
                    else
                        window.opener.selectFieldImage(pObj);
                }
            }
        }
        }
        window.close();
    }

    function cleanupUnusedMedia(confirmed){

        if(typeof confirmed === 'undefined' || confirmed !== true){
            confirmed = false;
        }

        if(confirmed){
            bootNotify("Deleting un-used media. Processing ...");
        }
        else{
            showLoader();
        }

        $.ajax({
            url: 'filesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'cleanupUnusedMedia',
                confirmed : confirmed? "1" : "0"
            },
        })
        .done(function(resp) {
            var data = [];
            if(resp.status == 1){
                if(!confirmed){
                    var count = resp.data.count;

                    if(count > 0){
                        bootConfirm("There are " + count + " un-used media files (images, video, other). Are you sure you want to delete all these files? This action cannot be undo."
                            , function(response){
                                if(response){
                                    cleanupUnusedMedia(true);
                                }
                            });
                    }
                    else{
                        bootNotify("There are no un-used media files.");
                    }
                }
                else{
                    //return from cleaning/deleting unused files
                    bootNotify("Un-used media deleted successfully.");
                }
            }
        })
        .fail(function() {
            bootNotifyError("Error in contacting server. Please try again.");
        })
        .always(function() {
            hideLoader();
        });
    }

    

    function showAutocompleteList(tags,input,event) {
        var autocompleteList = input.nextElementSibling;
        if(autocompleteList==null)
        {
            autocompleteList=document.createElement("ul");
            autocompleteList.classList.add("autocomplete-items");
            autocompleteList.style.listStyleType="none";
        }
        else{
            autocompleteList.innerHTML="";
        }
        tags.forEach(function(tag) {
            const suggestion = document.createElement('li');
        
            const newText = tag.label.replace(
                new RegExp(event.target.value, 'gi'),
                '<span class="ui-state-highlight">$&</span>'
            );

            suggestion.innerHTML = `<a style="cursor:pointer;">${newText}</a>`;

            suggestion.addEventListener('click', function() {
                addTagGeneric(tag, event.target);
                input.value = '';
                autocompleteList.innerHTML = '';
            });
            
            autocompleteList.appendChild(suggestion);
            const parent = input.parentElement;
            const oldAutocompleteList = parent.querySelector('.autocomplete-items');
            if (oldAutocompleteList) {
                parent.removeChild(oldAutocompleteList);
            }
            parent.appendChild(autocompleteList);
        });
    }

    function setupAutocomplete(input) {
        input.addEventListener('input', function(event) {
            const term = event.target.value.toLowerCase();
            if(term.length<1){
                const parent = input.parentElement;
                if(parent.querySelector(".autocomplete-items")){
                    parent.removeChild(parent.querySelector(".autocomplete-items"));
                    return;
                }
            }
            const filteredTags = window.allTagsList.filter(function(tag) {
                return tag.label.toLowerCase().includes(term);
            });
            showAutocompleteList(filteredTags,input,event);
        });
    }
    

    function initTagAutocomplete(input, isRequired) {
        Array.from(input).forEach((e)=>{
            setupAutocomplete(e);
            if (isRequired === true) {
                e.classList.add('requiredInput');
            }    
        });
    }

    function getTagsDivGeneric(input) {
        input = $(input);
        var tagsDiv = input.parent().find(".tagsDiv:first");
        if (tagsDiv.length == 0) {
            tagsDiv = input.parent().parent().find(".tagsDiv:first");
        }
        return tagsDiv;
    }

    function addTagGeneric(tag, input) {

        if (typeof tag == 'string') {
            var tagFound = false;
            $.each(window.allTagsList, function(index, curTag) {
                if (tag === curTag.id) {
                    tag = curTag;
                    tagFound = true;
                    return false;
                }
            });

            if (!tagFound) {
                return false;
            }
        }

        if (!tagExistsGeneric(tag, input)) {
            input = $(input);
            var tagsDiv = getTagsDivGeneric(input.parent().parent());
            var nbItems = input.data("data-nb-items");
            if(nbItems && nbItems != 0){
            if(tagsDiv.children(".tagButton").length >= nbItems){
                    return;
            }
            }

            var _tagpillid = "_tagpill"+tagsDiv.children(".tagButton").length;

            var divMain = $("<div class='tagButton float-left mb-2 pr-2' data-tag_pillid="+_tagpillid+">");
            var button = $("<button type='button' class='btn btn-pill btn-secondary' >");
            var strong = $("<strong class='moringa-orange-color'>X</strong>");
            strong.click(function(e) {
                var _tagbtn = $(this).closest(".tagButton");
                if(_tagbtn.data("tag_pillid") != "") $("."+_tagbtn.data("tag_pillid")).remove();
                $(this).closest(".tagButton").remove();			
                updateTagsRequiredGeneric(input);
            });
            button.append(strong).append("&nbsp;" + tag.label);
            divMain.append(button).append("<input type='hidden' class='tagValue' name='tagValue' value='" + tag.id + "'>");

            var _divMain = $("<div class='tagButton float-left mb-2 pr-2 "+_tagpillid+"'>");
            var _button = $("<button type='button' class='btn btn-pill btn-secondary' >");
            _button.append("&nbsp;" + tag.label);
            _divMain.append(_button);

            tagsDiv.append(divMain);
            $("._secondaryTagsDiv").append(_divMain);
        }

        updateTagsRequiredGeneric(input);
    }

    function tagExistsGeneric(tag, input) {
        input = $(input);
        var tagsDiv = getTagsDivGeneric(input);

        var doesTagExist = false;
        tagsDiv.find("input.tagValue").each(function(i, ele) {
            if ($(ele).val() === tag.id) {
                doesTagExist = true;
                return false;
            }
        });
        return doesTagExist;
    }

    function updateTagsRequiredGeneric(input) {
        input = $(input);
        if (input.hasClass('requiredInput')) {
            var tagsDiv = getTagsDivGeneric(input);
            var tagsCount = tagsDiv.find('input.tagValue').length;
            if (tagsCount > 0) {
                input.get(0).setCustomValidity("");
            }
            else {
                input.get(0).setCustomValidity("required");
            }
        }
    }


    document.addEventListener('DOMContentLoaded', function() {
        document.getElementById('select-all').addEventListener('change', function() {

            var selectAllChecked = this.checked;
            var checkboxes = document.querySelectorAll('.mediaInputCheck');
            checkboxes.forEach(function(checkbox) {
                checkbox.checked = selectAllChecked;
            });
        });
    });
    

    function deleteMultipleFiles() {

        const elements = document.querySelectorAll(".mediaInputCheck:checked");
        if (elements.length === 0) {
            bootNotifyError("No files selected for deletion.");
            return;
        }

        let idsToDelete = [];
        bootConfirm("Files that are in use will be ignored. Are you sure you want to delete these files?", function (result) {
            if (result) {
                showLoader();

                for (let i = 0; i < elements.length; i++) {
                    let fileUsage = elements[i].getAttribute('data-use');
                    if (elements[i].checked && fileUsage == 0) {
                        idsToDelete.push(elements[i].value);
                    }
                }

                if (idsToDelete.length > 0) {
                    deleteFiles(idsToDelete);
                }else{
                    bootNotifyError("Unable to delete the file as it is currently in use.");
                    hideLoader();
                }
            }
        });
    }
</script>

    </body>
</html>