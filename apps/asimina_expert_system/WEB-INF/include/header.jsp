 <header class="c-header c-header-light c-header-fixed c-header-with-subheader" >
			
			<div class="c-subheader justify-content-between px-3" style="user-select: auto;">

				<!-- Mobile menu-->
				<div class="c-header-brand d-lg-none " style="user-select: auto;">
					<img src="img/logo.png" alt="" style="height: 25px; width: auto; vertical-align: bottom; user-select: auto;">
					<span class="text-success" style="margin-left: 10px; font-size: 1.3rem; color: rgb(241, 110, 0); font-weight: 600; user-select: auto;"> Moringa</span>
				</div>
				
				<button class="c-header-toggler c-class-toggler d-lg-none " type="button" data-target="#sidebar" data-class="c-sidebar-show" style="user-select: auto;">
					<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-menu" style="user-select: auto;"><line x1="3" y1="12" x2="21" y2="12" style="user-select: auto;"></line><line x1="3" y1="6" x2="21" y2="6" style="user-select: auto;"></line><line x1="3" y1="18" x2="21" y2="18" style="user-select: auto;"></line></svg>
				</button>
				<!-- !Mobile menu -->
				
				<!-- Breadcrumb-->
				<ol class="breadcrumb border-0 m-0" style="user-select: auto;">
					<li class="breadcrumb-item breadcrumb-site" style="user-select: auto;"><strong style="user-select: auto;">
					<%=__selectedsitename%>
					:</strong></li>
					<%
						for (int crumbIndex = 0; crumbIndex < breadcrumbs.size(); crumbIndex++) {
							String[] crumb = breadcrumbs.get(crumbIndex);
							if(crumb.length <2) continue;
							String extraClass = (crumbIndex == breadcrumbs.size() - 1) ? "active" : "";

							String crumbLi = "<li class='breadcrumb-item " + extraClass + "' style='user-select: auto;'>";
							if (crumb[1].length() > 0) {
								crumbLi += "<a style='user-select: auto;' href='" + crumb[1] + "' >"
										   + crumb[0] + "</a></li>";
							}
							else {
								crumbLi += crumb[0] + "</li>";
							}
							out.write(crumbLi);
						}
					%>
				</ol>
				<!-- ! Breadcrumb-->
				
				<!-- Favourite-->
				<ul class="c-header-nav ml-auto d-lg-down-none d-none" style="user-select: auto;">
					<li class="c-header-nav-item d-md-down-none" style="user-select: auto;">
						<a class="c-header-nav-link" href="#" style="user-select: auto;">
							<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-star" style="user-select: auto;"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" style="user-select: auto;"></polygon></svg>	
						</a>
					</li>
					<li class="c-header-nav-item d-md-down-none mr-2" style="user-select: auto;">
						<a class="c-header-nav-link" data-toggle="modal" data-target="#modal-add-ticket" style="user-select: auto;">
							<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-alert-triangle" style="user-select: auto;"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z" style="user-select: auto;"></path><line x1="12" y1="9" x2="12" y2="13" style="user-select: auto;"></line><line x1="12" y1="17" x2="12.01" y2="17" style="user-select: auto;"></line></svg>	
						</a>
					</li>
				</ul>
				<!-- ! Favourite -->
				
			</div>
			
    </header>