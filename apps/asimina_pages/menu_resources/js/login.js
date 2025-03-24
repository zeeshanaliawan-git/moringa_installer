___portaljquery(document).ready(function() {

	__checkLogin=function()
	{
		//making a post request as post requests are never cached by portal
		___portaljquery.ajax({
		      	url : ______portalurl + 'checklogin.jsp',				
	       	type: 'post',
			data : {mid : ______menuid},
       	       success : function(resp)
	       	{
				___portaljquery("#___portal_login_div").html(resp);
			},
			error : function()
			{
				window.status = "Error while communicating with the server";
			}
		});
	};

	__checkLogin();

	__doPortalLogin=function()
	{		
		___portaljquery.ajax({
		      	url : ______portalurl + 'dologin.jsp',
//			data : {mid : ______menuid, username : ___portaljquery("#___portal_username").val(), password : ___portaljquery("#___portal_password").val()},
			data : ___portaljquery("#___portal_login_frm").serialize(),
	       	type: 'post',
	       	dataType: 'json',
       	       success : function(json)
	       	{
				if(json.response == 'error') alert(json.message);
				else if(json.refresh && json.refresh == '1') __refreshscreen();
				else if(json.goto && json.goto != '') window.location = json.goto;
			},
			error : function()
			{
				window.status = "Error while communicating with the server";
			}
		});
	};			

	__doPortalLogout=function()
	{		
		___portaljquery.ajax({
		      	url : ______portalurl + 'dologout.jsp',
	       	type: 'post',
	       	dataType: 'json',
       	       success : function(json)
	       	{
				__gotoPortalHome();
			},
			error : function()
			{
				window.status = "Error while communicating with the server";
			}
		});
	};			

	__dologin2=function(prevselectedline)
	{
		//alert(prevselectedline + " :: " + ___portaljquery("#___portal_lines_slct").val() );
		
		if(prevselectedline != ___portaljquery("#___portal_lines_slct").val())
		{
			___portaljquery.ajax({
			      	url : ______portalurl + 'doorangelogin.jsp',
		       	type: 'post',
				data : {line_number : ___portaljquery("#___portal_lines_slct").val(), ___pt : ______pt, ___mc : ______mc, ___mid : ______mid},
		       	dataType: 'json',
	       	       success : function(json)
		       	{
					if(json.status == 'success') __refreshscreen();
				},
				error : function()
				{
					window.status = "Error while communicating with the server";
				}
			});
		}
	};

	__showMenus=function(profil)
	{
		//for same profil of user we have classes add to menu items so we will show them
		___portaljquery("."+profil).each(function(){
//			alert(___portaljquery(this));
			___portaljquery(this).removeClass('o-hidden');
		});
	};

	__refreshscreen=function()
	{
		window.location = ______portalurl + 'process.jsp?___pt='+______pt+'&___mc='+______mc+'&___mid='+______mid+'&___mu='+______durl;
	};
});

