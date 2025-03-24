function getToken(path, cookiename)
{
	$.ajax({
	       url : path+'countryspecific/gettoken.jsp',
       	type: 'GET',
		dataType : 'json',
		success : function(resp)
       	{
			$("#form_token").val(resp.token);
			document.cookie = cookiename + "="+resp.token+";path="+______portalurl;
		},
		error : function()
		{
			alert("Error while communicating with the server");
		}
	});	
}

function onsubmitmultipart(url, frmid)
{
	var form = new FormData($("#"+frmid)[0]);

	$.ajax({
	       url : url,
 	      	type: 'POST',
       	data: form,
		dataType : 'json',
		processData: false,
		contentType: false,
	       success : function(resp)
              {
			alert(resp.msg);
			if(resp.response == 'success' && clearform) clearform();
		},
		error : function()
		{
			alert("Error while communicating with the server");
		}
	});	
}

function onsubmit(url, frmid)
{
	$.ajax({
	       url : url,
 	      	type: 'POST',
       	data: $("#"+frmid).serialize(),
		dataType : 'json',
	       success : function(resp)
              {
			alert(resp.msg);
			if(resp.response == 'success' && clearform) clearform();
		},
		error : function()
		{
			alert("Error while communicating with the server");
		}
	});	
}

function validatePhoneNumber(n) 
{
	if(n == '') return true;
	n = $.trim(n);
	//we allow first + in phone number
	if(n[0] == '+') n = n.substring(1);
//			alert(n);
	var reg = /^\d+$/;
//			alert(reg.test(n));			
	return reg.test(n);
}

function validateEmail($email) 
{
	var emailReg = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;
	return emailReg.test( $email );
};
