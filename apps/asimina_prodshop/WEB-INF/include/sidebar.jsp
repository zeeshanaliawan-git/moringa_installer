<style style="user-select: auto;">

	.c-sidebar .c-sidebar-nav-link:hover, .c-sidebar .c-sidebar-nav-dropdown-toggle:hover {
		color: #fff;
		background: #28a745 !important;
	}
	.c-sidebar.c-sidebar-minimized .c-sidebar-nav-item:hover > .c-sidebar-nav-link, .c-sidebar.c-sidebar-minimized .c-sidebar-nav-item:hover > .c-sidebar-nav-dropdown-toggle {
		background: #28a745 !important;
	}
	.c-sidebar-nav-icon{fill:none !important}
	.c-sidebar-minimized .c-sidebar-nav-item-alert svg{color: #f9b115  !important;}
	.c-show .badge-show{display:none}

    .dropdown-menu{min-width: 13rem;}
    
	.bg-published { background-color: #dff0d8;}
    .bg-published:hover { background-color: #d0e9c6 !important;}
    .bg-unpublished { background-color: #f2dede;}
    .bg-unpublished:hover { background-color: #ebcccc !important;}
    .bg-changed { background-color: #fcf8e3;}
    .bg-changed:hover { background-color: #faf2cc !important;}

</style>
<%
	String ____version = com.etn.beans.app.GlobalParm.getParm("APP_VERSION");
	if(____version == null) ____version = "";
	else ____version = "v" + ____version;

	Set ___rsper = Etn.execute("select pr.assign_site from profil pr, profilperson p where p.profil_id = pr.profil_id and p.person_id = " + escape.cote(""+ Etn.getId()));
	boolean useAssignedSites = false;
	if(___rsper.next())
	{
		if("1".equals(___rsper.value("assign_site"))) useAssignedSites = true;
	}

	Set __rssite = Etn.execute("select * from " + com.etn.beans.app.GlobalParm.getParm("PORTAL_DB") + ".sites where enable_ecommerce = 1 order by name " );
	if(useAssignedSites)
	{
		__rssite = Etn.execute("select s.* from " + com.etn.beans.app.GlobalParm.getParm("PORTAL_DB") + ".sites s, person_sites ps where s.enable_ecommerce = 1 and ps.site_id = s.id and ps.person_id = "+escape.cote(""+Etn.getId())+" order by name " );
	}

	String __selectedsite = "";
	String __selectedsitename = "Select Site";

	__selectedsite = (String)session.getAttribute("SELECTED_SITE_ID");
	if(__selectedsite.length() > 0)
	{
		while(__rssite.next())
		{
			if(__selectedsite.equals(__rssite.value("id"))) __selectedsitename = __rssite.value("name");
		}
		__rssite.moveFirst();
	}

	Set ____rsp = Etn.execute("select case coalesce(parent,'') when '' then name else parent end as _parent, case coalesce(icon,'') when '' then icon else parent_icon end as _icon, " +
			" case coalesce(parent,'') when '' then 0 else 1 end as _isparent, min(rang) as rang " +
			" from page where 1=1 group by _parent order by rang, _parent");


	//used to output breadcrumbs in sidebar.jsp
	// each page can add breadcrumbs using example:
	//   breadcrumbs.add(new String[]{"<label>","<url>"});  // url can be empty
	java.util.List<String[]> breadcrumbs = new java.util.ArrayList<>();
	breadcrumbs.add(new String[]{"Home", request.getContextPath() + "/admin/gestion.jsp"});

%>
        <div id="sidebar" class="c-sidebar c-sidebar-dark c-sidebar-fixed c-sidebar-lg-show">
			<div class="c-sidebar-brand d-lg-down-none" style="user-select: auto;">
				<div class="c-sidebar-brand-full" style="user-select: auto;">
					<img src="<%=request.getContextPath()%>/img/logo.png" alt="" style="height: 25px; width: auto; vertical-align: bottom; user-select: auto;">
					<span class="text-success" style="margin-left: 10px; font-size: 1.3rem; color: rgb(241, 110, 0); font-weight: 600; user-select: auto;"> Moringa</span>
				</div>
			</div>
            <ul class="c-sidebar-nav">

				<%-- -------------------------------Added by Ahsan Sites Drop down------------------------------------- --%>
				<li class="c-sidebar-nav-item c-sidebar-nav-dropdown" style="user-select: auto;">
					<a class="c-sidebar-nav-link c-sidebar-nav-dropdown-toggle bg-danger" href="#" style="user-select: auto;">
						<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-share-2 c-sidebar-nav-icon" style="user-select: auto;"><circle cx="18" cy="5" r="3" style="user-select: auto;"></circle><circle cx="6" cy="12" r="3" style="user-select: auto;"></circle><circle cx="18" cy="19" r="3" style="user-select: auto;"></circle><line x1="8.59" y1="13.51" x2="15.42" y2="17.49" style="user-select: auto;"></line><line x1="15.41" y1="6.51" x2="8.59" y2="10.49" style="user-select: auto;"></line></svg><strong style="user-select: auto;"><%=__selectedsitename%></strong>
					</a>
					<ul class="c-sidebar-nav-dropdown-items" style="user-select: auto;">
						<%
							if(useAssignedSites && __rssite.rs.Rows == 0) { 
								out.write("<li class='c-sidebar-nav-item' style='background-color: black; user-select: auto;'><a class='c-sidebar-nav-link' href='#'>No Site is assigned to you</a></li>");
							}else{
								while(__rssite.next()) { 
						%>
									<li class="c-sidebar-nav-item" style="background-color: black; user-select: auto;">
										<a class="c-sidebar-nav-link <%=__rssite.value("name").equals(__selectedsitename)? "c-active":""%>" href="#"
										onclick="$.ajax({ url : '<%=request.getContextPath()%>/admin/updatesiteselection.jsp', type: 'POST', data: { id: $(this).prop('id')}, dataType : 'json', success : function(json) { if(json.resp == 'error') { alert('Error updating site selection'); window.location = '<%=request.getContextPath()%>/admin/gestion.jsp'; } if(json.resp =='success'){ window.location = '<%=request.getContextPath()%>/admin/gestion.jsp'; } }, error : function() { window.location = '<%=request.getContextPath()%>/admin/gestion.jsp'; } });"
										id="<%=__rssite.value("id")%>"> <%=__rssite.value("name")%></a>
									</li>
						<% 		
								}
							}
						%> 
					</ul>
				</li>
				<%-- ---------------------------------------Till Here------------------------------- --%>

                <% 
					while(____rsp.next()){
						if("0".equals(____rsp.value("_isparent")))
						{
							String ____q = "select * from page p where p.name = "+com.etn.sql.escape.cote(____rsp.value("_parent"))+" and coalesce(p.parent,'') = '' ";
							if(!"admin".equalsIgnoreCase((String)session.getAttribute("PROFIL")) && !"super_admin".equalsIgnoreCase((String)session.getAttribute("PROFIL")))
							{
								____q = "select * from page p, page_profil pr where p.name = "+com.etn.sql.escape.cote(____rsp.value("_parent"))+" and coalesce(p.parent,'') = '' ";
								____q += " and pr.url = p.url " ;
								____q += " and pr.profil_id = " + com.etn.sql.escape.cote((String)session.getAttribute("PROFIL_ID"));
							}
							Set ____rs1 = Etn.execute(____q);
							if(____rs1.next())
							{
								String ____u = parseNull(____rs1.value("url"));
								if(!____u.startsWith("/") && !____u.toLowerCase().startsWith("http:") && !____u.toLowerCase().startsWith("https:")) ____u = request.getContextPath() + "/" + ____u;

								String ____target = "";
								if("1".equals(____rs1.value("new_tab"))) ____target = " target='_blank' ";
				%>
								<li class="c-sidebar-nav-item">
									<a class="c-sidebar-nav-link" href="<%=____u%>" <%=____target%>>
										<i class="c-sidebar-nav-icon <%=____rs1.value("icon")%>"></i> <%=____rs1.value("name")%>
										<%if(____rs1.value("menu_badge").length() > 0){%>
										<span class="badge badge-success"><%=____rs1.value("menu_badge")%></span>
										<%}%>
									</a>
								</li>
				<%
							}
						}
						else
						{
							String ____q = "select * from page p where p.parent = "+com.etn.sql.escape.cote(____rsp.value("_parent"))+" ";
							if(!"admin".equalsIgnoreCase((String)session.getAttribute("PROFIL")) && !"super_admin".equalsIgnoreCase((String)session.getAttribute("PROFIL")))
							{
								____q = "select * from page p, page_profil pr where p.parent = "+com.etn.sql.escape.cote(____rsp.value("_parent"))+" ";
								____q += " and pr.url = p.url " ;
								____q += " and pr.profil_id = " + com.etn.sql.escape.cote((String)session.getAttribute("PROFIL_ID"));
							}
							____q += " order by rang, name ";
							Set ____rs1 = Etn.execute(____q);
							if(____rs1.rs.Rows == 0) continue;

				%>
							<li class="c-sidebar-nav-item c-sidebar-nav-dropdown">
								<a class="c-sidebar-nav-link c-sidebar-nav-dropdown-toggle" href="#">
									<i class="c-sidebar-nav-icon <%=____rsp.value("_icon")%>"></i> 
									<%=____rsp.value("_parent")%>
								</a>
								<ul class="c-sidebar-nav-dropdown-items">
								<% 
									while(____rs1.next()) 
									{
										String ____u = parseNull(____rs1.value("url"));
										if(!____u.startsWith("/") && !____u.toLowerCase().startsWith("http:") && !____u.toLowerCase().startsWith("https:")) ____u = request.getContextPath() + "/" + ____u;


										String ____target = "";
										if("1".equals(____rs1.value("new_tab"))) ____target = " target='_blank' ";
								%>
										<li class="c-sidebar-nav-item"><a class="c-sidebar-nav-link" href="<%=____u%>" <%=____target%>>
											<i class="c-sidebar-nav-icon <%=____rs1.value("icon")%>"></i>
											<%=____rs1.value("name")%>
											
											<%
												if(____rs1.value("menu_badge").length() > 0){
											%>
												<span class="badge badge-success"><%=____rs1.value("menu_badge")%></span>
											<%
												}
											%>
											</a>
										</li>
								<%
									} 
								%>
								</ul>
							</li>
				<%	  	
						}
					} 
				%>

				<li class="c-sidebar-nav-item c-sidebar-nav-dropdown c-sidebar-nav-item-alert mt-auto c-sidebar-user-item" style="user-select: auto;">
					<a class="c-sidebar-nav-link c-sidebar-nav-dropdown-toggle" href="#" style="background-color: black; user-select: auto;">
						<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-user c-sidebar-nav-icon" style="user-select: auto;"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" style="user-select: auto;"></path><circle cx="12" cy="7" r="4" style="user-select: auto;"></circle></svg>
						<%=(String)session.getAttribute("LOGIN")%>
					</a>
					<ul class="c-sidebar-nav-dropdown-items" style="user-select: auto;">
						<li class="c-sidebar-nav-item" style="user-select: auto;">
							<a class="c-sidebar-nav-link nav-level2" href="<%=request.getContextPath()+"/changePassword.jsp"%>" style="user-select: auto;">
							<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-chevron-right c-sidebar-nav-icon" style="user-select: auto;"><polyline points="9 18 15 12 9 6" style="user-select: auto;"></polyline></svg>
							Change password</a>
						</li>
						<li class="c-sidebar-nav-item" style="user-select: auto;">
							<a class="c-sidebar-nav-link nav-level2" href="<%=request.getContextPath()+"/logout.jsp"%>" style="user-select: auto;"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-chevron-right c-sidebar-nav-icon" style="user-select: auto;"><polyline points="9 18 15 12 9 6" style="user-select: auto;"></polyline></svg>Logout</a>
						</li>
					
					</ul>
				</li>
			</ul>
			<script>
					jQuery('.c-sidebar-user-item').on('click',function(e){
						jQuery(this).find('ul')[0].scrollIntoView({ 
							behavior: "smooth", // or "auto" or "instant" 
							block: "start" // or "end" 
						});
					})
				</script>
            <button class="c-sidebar-minimizer c-class-toggler" type="button" data-target="_parent" data-class="c-sidebar-minimized" style="user-select: auto;"></button>
        </div>

<script src="<%=request.getContextPath()%>/js/bootbox.min.js"></script>
<script type="text/javascript">
            // $('#global_search_text').keyup(function(event) {
            //     if(event.which === 13){
            //         $('body').append('<form method="post" id="frm_global_search" action="/admin/search.jsp" ><input type="hidden" name="global_search" value="'+$('#global_search_text ').val().trim()+'"/><input type="hidden" name="status" value="All"/></form>');
            //         $('#frm_global_search').submit();
            //     }
            // });
	
	jQuery(document).ready(function($) {

		feather.replace();

		
		$('[data-toggle="tooltip"]').tooltip();
		jQuery(".c-sidebar-minimizer").click(function() {
			jQuery(".c-sidebar").toggleClass( "c-sidebar-minimized" );
		});
		
		jQuery(".c-header-toggler").click(function() {
			jQuery(".c-sidebar").toggleClass( "c-sidebar-show" );
		});
		
		const $menu = $('#sidebar');

		$(document).mouseup(e => {
		   
			if( jQuery('#sidebar').hasClass('c-sidebar-show')) {
		   
			   if (!$menu.is(e.target) // if the target of the click isn't the container...
			   && $menu.has(e.target).length === 0) // ... nor a descendant of the container
			   {
				jQuery(".c-sidebar").toggleClass( 'c-sidebar-show' );
			  }
			}
		 });
			
		jQuery(".c-sidebar-nav-dropdown-toggle").click(function(e) {
			e.preventDefault()
		  jQuery(this).parent().toggleClass( "c-show" );
		});
		

	});
	
	var ___sessionTimeout = <%=com.etn.beans.app.GlobalParm.getParm("SESSION_TIMEOUT_MINS")%>;
	var ___timeout;
	var ___remaining=60; // Number of seconds
	let modalDialogue;
	let id=setTimeout(keepSessionAliveMsg, (___sessionTimeout-1)*60000);

	window.addEventListener('load', function() {
		let id;
		let ___remaining;
		let modalDialogue;
		function onAjaxComplete(event, xhr, options) {
			if (!document.getElementById("_timeoutRemaining_span")) {
				if (id) {
					clearTimeout(id);
				}
				___remaining = 60;
				id = setTimeout(keepSessionAliveMsg, (___sessionTimeout - 1) * 60000);
				} else {
				if (modalDialogue) {
					modalDialogue.modal('hide');
				}
			}
		}

  	document.addEventListener('ajaxComplete', onAjaxComplete);
	});


	function keepSessionAliveMsg(){
		modalDialogue=bootbox.confirm({
			size: 'medium',
			animate: false,
			message: "<span id='_timeoutRemaining_span'>Your session will be expired in next <span style='color:red;font-weight:bold' id='_timeoutRemaining'>60</span> seconds. Click <strong>OK</strong> to keep your session alive.</span>",
			callback: function (result) {
				if(___timeout) window.clearInterval(___timeout);
				if (result) {
					$.ajax({
						url: '<%=request.getContextPath()%>/admin/keepSessionAlive.jsp', 
						type: 'POST', 
						dataType: 'json',
					})
					.always(function (jqXHR) {
						console.log(jqXHR.status);
						if(jqXHR.status == 401)
						{
							window.location.href = "<%=request.getContextPath()%>/ibo.jsp";
						}
					});
				}
			}
		});
		
		___timeout = window.setInterval(function(){
			___remaining--;
			document.getElementById("_timeoutRemaining").innerHTML = ___remaining;
			if(___remaining<=0) {
				document.getElementById("_timeoutRemaining_span").innerHTML = "<div id='_timeoutRemaining'>You have been inactive for few minutes. You have been disconnected.</div>";
				window.clearInterval(___timeout);
				return;
			}
		}, 1000);
	}
	</script>