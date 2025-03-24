 <jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%
	String selectedsiteid = getSelectedSiteId(session);

    String url = "";
	boolean waitingRecache = false;
	
    if(request.getParameter("url") != null){
        url = request.getParameter("url");
    }else{

        String _type = request.getParameter("ty");
        String _id = request.getParameter("id");
        String lang = request.getParameter("lang");
        String langid = request.getParameter("langid");
		if(langid != null && langid.length() > 0)
		{
			Set rsL = Etn.execute("Select * from language where langue_id = "+escape.cote(langid));
			if(rsL.next())
			{
				lang = rsL.value("langue_code");
			}
		}		
		
        String p = request.getParameter("p");
        boolean isProd = "1".equals(p);
		String portaldb = GlobalParm.getParm("PORTAL_DB");
		
		Set rsM = Etn.execute("Select * from "+portaldb+".site_menus where is_active = 1 and site_id = "+com.etn.sql.escape.cote(selectedsiteid)+" and lang ="+com.etn.sql.escape.cote(lang));
		if(!rsM.next())
		{			
			out.write("<html><body><h1 style='color:red'>No preview available at this time</h1></body></html>");
			return;
		}
	
		Set rs = Etn.execute("Select * from "+portaldb+".config where code = 'BASE_DIR'");
		rs.next();	
		String basedir = rs.value("val");
		
		rs = Etn.execute("Select * from "+portaldb+".config where code = 'DOWNLOAD_PAGES_FOLDER'");
		rs.next();	
		basedir += rs.value("val");		
		if(basedir.endsWith("/") == false) basedir += "/";
		System.out.println(basedir);

		rs = Etn.execute("Select * from "+portaldb+".config where code = 'CATALOG_WEBAPP_URL'");
		rs.next();
		String catalogWebappUrl = rs.value("val");
		if(catalogWebappUrl.startsWith("/") == false) catalogWebappUrl = "/" + catalogWebappUrl;
		if(catalogWebappUrl.endsWith("/") == false) catalogWebappUrl = catalogWebappUrl + "/";

		String cachedurl = "http://127.0.0.1"+catalogWebappUrl;
		if("c".equals(_type))
		{
			cachedurl += "listproducts.jsp?cat="+_id;
		}
		else
		{
			cachedurl += "product.jsp?id="+_id;
		}

		String qry = "select * from "+portaldb+".cache_tasks where site_id = "+escape.cote(selectedsiteid)+" and task = 'generate' and status = 0 and content_id= "+escape.cote(_id);
		if("c".equals(_type)) qry += " and content_type = 'catalog' ";
		else qry += " and content_type = 'product' ";
		
		Set rsTask = Etn.execute(qry);
		if(rsTask != null && rsTask.rs.Rows > 0) waitingRecache = true;
		
		rs = Etn.execute("select cpp.*, c.filename from "+portaldb+".cached_pages c inner join "+portaldb+".cached_pages_path cpp on cpp.id = c.id where c.menu_id = "+escape.cote(rsM.value("id"))+" and c.url = "+escape.cote(cachedurl));
		if(!rs.next())
		{
			out.write("<html><body><h1 style='color:red'>No preview available at this time</h1></body></html>");
			return;			
		}
		
		url = GlobalParm.getParm("page_preview_api_url")+ "?tm="+System.currentTimeMillis()+"&u="+rs.value("file_url")+rs.value("filename");
		
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
<html  lang="en">
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
<meta name="description" content="">
<meta name="author" content="">
<title>Preview</title>
<%@ include file="../../WEB-INF/include/head2.jsp"%>
</head>
    <style>
        body{
            min-height: 0px;
            padding-top :0px;
        }
       .btn {
          display: inline-block;
          font-weight: $btn-font-weight;
          text-align: center;
          white-space: nowrap;
          vertical-align: middle;
          user-select: none;
          border: $btn-border-width solid transparent;
          @include button-size($btn-padding-y, $btn-padding-x, $font-size-base, $btn-line-height, $btn-border-radius);
          @include transition($btn-transition);

          // Share hover and focus styles
          @include hover-focus {
            text-decoration: none;
          }

          &:focus,
          &.focus {
            outline: 0;
            box-shadow: $btn-focus-box-shadow;
          }

          // Disabled comes first so active can properly restyle
          &.disabled,
          &:disabled {
            opacity: $btn-disabled-opacity;
            @include box-shadow(none);
          }

          // Opinionated: add "hand" cursor to non-disabled .btn elements
          &:not(:disabled):not(.disabled) {
            cursor: pointer;
          }

          &:not(:disabled):not(.disabled):active,
          &:not(:disabled):not(.disabled).active {
            @include box-shadow($btn-active-box-shadow);

            &:focus {
              @include box-shadow($btn-focus-box-shadow, $btn-active-box-shadow);
            }
          }
        }
        .feather {width: 16px;vertical-align: text-bottom;}

        .h-100 {
            height: 100% !important;
        }
        .align-items-center {
            align-items: center !important;
        }
        .justify-content-between {
            justify-content: space-between !important;
        }

        .d-xl-block {
            display: block !important;
        }
        .preview-container[_ngcontent-serverApp-c86] {
            height: 100vh;
            background-color: #212832;
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
            background-color: white;
        }
        .iframe-tabletToggle {
            width: 768px;
            max-height:1024px;
            left: 50%;
            transform: translateX(-50%);
        }

        .iframe-tabletToggleR {
            width: 1024px;
            height:768px;
            left: 50%;
            transform: translateX(-50%);
        }
        .iframe-mobileToggle {
            width: 375px;
            height:667px;
            left: 50%;
            transform: translateX(-50%);
        }

        .iframe-mobileToggleR {
            width: 667px;
            height:375px;
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
        .btn-rotate{
            display:none;
        }
        .btn-rotate.active{
            display:inline-block;
        }
    </style>
<body class="sidebar-lg-show" style="background-color:#333">

<div class="preview-container">
        <div class="preview-bar bg-white fixed-top py-2 border-bottom-primary">
            <div class="container-fluid h-100">
                <div class="row align-items-center justify-content-between h-100">
                    <div class="col col-auto d-none d-xl-block" style="margin: 0 auto;">
                        <div class="justify-content-center" style="padding:0 auto">
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
        <iframe id='previewIframe' onload="addbreadcrumbpreview()" class="iframe-preview iframe-desktopToggle" src='<%=url%>' width="100%"></iframe>
    </div>


    <script type="application/javascript">

	//code added by umair for preview of breadcrumbs in blocksystem
	//this function will call the breadcrumb call back passing a dummy json
	function addbreadcrumbpreview()
	{
		let brcallback = $(".asm-cf-breadcrumb", document.getElementById("previewIframe").contentWindow.document).data('asm-cf-breadcrumb-callback')
		if(typeof brcallback !== 'undefined')
		{			
			let ifrm = document.getElementById("previewIframe").contentWindow;
			let xc = ifrm.eval( brcallback );;
			if (typeof xc == 'function') 
			{				
				let _brjson = [];
				_brjson[0] = {"name":"Homepage","url":"#"};
				_brjson[1] = {"name":"Page 1","url":"#"};
				_brjson[2] = {"name":"Page 2","url":"#"};
				xc(_brjson);				
			}
		}
	}
	//end breadcrumb preview code

    (function($) {



        feather.replace();

        $( ".btn-preview" ).click(function() {

            if($(this).hasClass("active")) return; //if we click on current active preview, nothing to do


            else {

                $( ".btn-preview" ).each(function() { // if not we check what preview is active and we remove the ifrma class associated and the button active class

                    if($(this).hasClass('active')) {
                        if($(this).hasClass('rotate')) {
                            $(".iframe-preview").removeClass("iframe-"+$(this).attr("id")+"R");
                            $(this).removeClass("rotate");
                        }
                        else $(".iframe-preview").removeClass("iframe-"+$(this).attr("id"));
                        $(this).removeClass("active");
                    }

                });

                $(this).addClass("active");
                $(".iframe-preview").addClass("iframe-"+$(this).attr("id"));
                if( ($(this).attr("id") == "tabletToggle") || ($(this).attr("id") == "mobileToggle") ) $("#rotateToggle").addClass("active");
                else $("#rotateToggle").removeClass("active");

            }
        });

        $( ".btn-rotate" ).click(function() {

            $( ".btn-preview" ).each(function() {

                if($(this).hasClass("active")) {

                    if($(this).hasClass("desktopToggle")) return; //if previw is for desktop no rotate
                    else {

                        if($(this).hasClass("rotate")){

                            $(".iframe-preview").removeClass("iframe-"+$(this).attr("id")+"R");
                            $(".iframe-preview").addClass("iframe-"+$(this).attr("id"));
                            $(this).removeClass("rotate");

                        }
                        else {

                            $(".iframe-preview").removeClass("iframe-"+$(this).attr("id"));
                            $(".iframe-preview").addClass("iframe-"+$(this).attr("id")+"R");
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