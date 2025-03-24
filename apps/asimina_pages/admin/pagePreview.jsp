<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>
<%!
	private String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}
%>
<%
    String url = "";
	boolean waitingRecache = false;
    if (request.getParameter("url") != null) {
        url = request.getParameter("url");
    }
    else {
		String pageid = request.getParameter("id");
		Set rs = Etn.execute("select * from pages where id = "+escape.cote(pageid));
		if(!rs.next())
		{
			out.write("<html><body><h1 style='color:red'>No preview available at this time</h1></body></html>");
			return;			
		}
		String lang = rs.value("langue_code");
		String siteid = rs.value("site_id");
		String portaldb = GlobalParm.getParm("PORTAL_DB");
		String pagepath = rs.value("html_file_path");
		String parentpageid = rs.value("parent_page_id");
		String pagetype = rs.value("type");
		
		Set rsM = Etn.execute("Select * from "+portaldb+".site_menus where is_active = 1 and site_id = "+com.etn.sql.escape.cote(siteid)+" and lang ="+com.etn.sql.escape.cote(lang));
		if(!rsM.next())
		{			
			out.write("<html><body><h1 style='color:red'>No preview available at this time</h1></body></html>");
			return;
		}
	
		rs = Etn.execute("Select * from "+portaldb+".config where code = 'BASE_DIR'");
		rs.next();	
		String basedir = rs.value("val");
		
		rs = Etn.execute("Select * from "+portaldb+".config where code = 'DOWNLOAD_PAGES_FOLDER'");
		rs.next();	
		basedir += rs.value("val");		
		if(basedir.endsWith("/") == false) basedir += "/";
		System.out.println(basedir);

		rs = Etn.execute("Select * from "+portaldb+".config where code = 'PAGES_WEBAPP_URL'");
		rs.next();
		String pagesWebappUrl = rs.value("val");
		if(pagesWebappUrl.startsWith("/") == false) pagesWebappUrl = "/" + pagesWebappUrl;
		if(pagesWebappUrl.endsWith("/") == false) pagesWebappUrl = pagesWebappUrl + "/";

		String cachedurl = "http://127.0.0.1"+ pagesWebappUrl + "admin/pages/" + pagepath;

		String qry = "select * from "+portaldb+".cache_tasks where content_type = "+escape.cote(pagetype)+" and site_id = "+escape.cote(siteid)+" and task = 'generate' and status = 0 and content_id= "+escape.cote(parentpageid);		
		Set rsTask = Etn.execute(qry);
		if(rsTask != null && rsTask.rs.Rows > 0) waitingRecache = true;
		
		rs = Etn.execute("select cpp.*, c.filename from "+portaldb+".cached_pages c inner join "+portaldb+".cached_pages_path cpp on cpp.id = c.id where c.menu_id = "+escape.cote(rsM.value("id"))+" and c.url = "+escape.cote(cachedurl));
		if(!rs.next())
		{
			out.write("<html><body><h1 style='color:red'>No preview available at this time</h1></body></html>");
			return;			
		}
		
		String publishedUrl = parseNull(rs.value("published_url"));
		if(publishedUrl.length() == 0) publishedUrl = parseNull(rs.value("file_url")) + parseNull(rs.value("filename"));
		
		url = GlobalParm.getParm("page_preview_api_url")+ "?tm="+System.currentTimeMillis()+"&u="+publishedUrl;
		
		String filepath = basedir + rs.value("file_path") + rs.value("filename");
		com.etn.util.Logger.info("pagePreview.jsp", "filepath::"+filepath);
		com.etn.util.Logger.info("pagePreview.jsp", "url::"+url);
		com.etn.util.Logger.info("pagePreview.jsp", java.nio.file.Files.exists(java.nio.file.Paths.get(filepath)) + "");
		if(java.nio.file.Files.exists(java.nio.file.Paths.get(filepath)) == false)
		{
			out.write("<html><body><h1 style='color:red'>No preview available at this time</h1></body></html>");
			return;						
		}		
    }

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="../WEB-INF/include/head2.jsp" %>
    <title>Preview</title>
    <style type="text/css">
        /*body{*/
        /*    min-height: 0px;*/
        /*    padding-top :0px;*/
        /*}*/

        .feather {
            width: 16px;
        }


        .border-bottom-primary {
            border-bottom: 3px solid #c5ccd6;
        }

        .preview-bar {
            height: 63px;
        }

        .iframe-preview {
            position: absolute;
            height: calc(100% - 63px);
            width: 100%;
            border: none;
            margin-top: 63px;
            background-color: #ffffff;
        }

        .iframe-tabletToggle {
            width: 768px;
            max-height: 1024px;
            left: 50%;
            transform: translateX(-50%);
        }

        .iframe-tabletToggleR {
            width: 1024px;
            height: 768px;
            left: 50%;
            transform: translateX(-50%);
        }

        .iframe-mobileToggle {
            width: 375px;
            height: 667px;
            left: 50%;
            transform: translateX(-50%);
        }

        .iframe-mobileToggleR {
            width: 667px;
            height: 375px;
            left: 50%;
            transform: translateX(-50%);
        }

        .btn-preview:focus, .btn.focus, .btn-rotate:focus {
            outline: 0;
            box-shadow: 0 0 0 0.2rem rgb(77, 189, 116);;
        }

        .btn-preview.active {
            outline: 0;
            box-shadow: 0 0 0 0.2rem rgb(77, 189, 116);;
        }

        .btn-rotate {
            display: none;
        }

        .btn-rotate.active {
            display: inline-block;
        }
    </style>
</head>

<body class="sidebar-lg-show" style="background-color:#333">

<div class="preview-container">
    <div class="preview-bar bg-white fixed-top py-2 border-bottom-primary">
        <div class="container-fluid h-100">
            <div class="row align-items-center justify-content-between h-100">
                <div class="col col-auto d-none d-xl-block" style="margin: 0 auto;">
                    <div class="justify-content-center" style="padding:0 auto;">
						<%if(waitingRecache){%>
						<span style="color:red; margin-right:15px; font-weight:bold">Enqueued for caching</span>
						<%}%>
                        <button id="desktopToggle" class="btn btn-icon btn-transparent-dark mx-1 btn-preview active">
                            <i class="nav-icon" data-feather="monitor"></i>
                        </button><!---->
                        <button id="tabletToggle" class="btn btn-icon btn-transparent-dark mx-1 btn-preview">
                            <i class="nav-icon" data-feather="tablet"></i>
                        </button><!---->
                        <button id="mobileToggle" class="btn btn-icon btn-transparent-dark mx-1 btn-preview">
                            <i class="nav-icon" data-feather="smartphone"></i>
                        </button><!---->
                        <button id="rotateToggle" class="btn btn-icon btn-transparent-dark mx-1 btn-rotate ml-4">
                            <i class="nav-icon nave-rotate-90" data-feather="rotate-cw"></i>
                        </button><!---->
                    </div>
                </div>
            </div>
        </div>
    </div><!---->
    <iframe id='previewIframe' class="iframe-preview iframe-desktopToggle"
            src='<%=url%>' width="100%"></iframe>
</div>


<script type="application/javascript">


    //end breadcrumb preview code

    (function ($) {

        $(".btn-preview").click(function () {

            if ($(this).hasClass("active")) return; //if we click on current active preview, nothing to do


            else {

                $(".btn-preview").each(function () { // if not we check what preview is active and we remove the ifrma class associated and the button active class

                    if ($(this).hasClass('active')) {
                        if ($(this).hasClass('rotate')) {
                            $(".iframe-preview").removeClass("iframe-" + $(this).attr("id") + "R");
                            $(this).removeClass("rotate");
                        }
                        else $(".iframe-preview").removeClass("iframe-" + $(this).attr("id"));
                        $(this).removeClass("active");
                    }

                });

                $(this).addClass("active");
                $(".iframe-preview").addClass("iframe-" + $(this).attr("id"));
                if (($(this).attr("id") == "tabletToggle") || ($(this).attr("id") == "mobileToggle")) $("#rotateToggle").addClass("active");
                else $("#rotateToggle").removeClass("active");

            }
        });

        $(".btn-rotate").click(function () {

            $(".btn-preview").each(function () {

                if ($(this).hasClass("active")) {

                    if ($(this).hasClass("desktopToggle")) return; //if previw is for desktop no rotate
                    else {

                        if ($(this).hasClass("rotate")) {

                            $(".iframe-preview")
                                .removeClass("iframe-" + $(this).attr("id") + "R")
                                .addClass("iframe-" + $(this).attr("id"));
                            $(this).removeClass("rotate");

                        }
                        else {

                            $(".iframe-preview")
                                .removeClass("iframe-" + $(this).attr("id"))
                                .addClass("iframe-" + $(this).attr("id") + "R");
                            $(this).addClass("rotate");

                        }
                    }
                }

            });

        });

    })(jQuery);
</script>

</body>
</html>