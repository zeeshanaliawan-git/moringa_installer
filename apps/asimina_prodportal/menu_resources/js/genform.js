function genformisvalidemail(email) 
{
	var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
	return regex.test(email);
}

function genformisnumbersonly(val)
{
	var isnum = /^\d+$/.test(val);
	return isnum;
}

function genformshowerror(frmid, msg)
{
	if(___portaljquery('#'+frmid+'_error_msg') && ___portaljquery('#'+frmid+'_error_msg').length > 0)
	{
		___portaljquery('#'+frmid+'_error_msg').html(msg);
		___portaljquery('#'+frmid+'_error_msg').show();
	}
	else alert(msg);
}

function genformclearerror(frmid)
{
	if(___portaljquery('#'+frmid+'_error_msg') && ___portaljquery('#'+frmid+'_error_msg').length > 0)
	{
		___portaljquery('#'+frmid+'_error_msg').html('');
		___portaljquery('#'+frmid+'_error_msg').hide();
	}
}

function ___checkPasswords(frmid)
{
	var _passwd = "";
	var passfound = false;
	var _confirmpasswd = "";
	var confirmpassfound = false;

	___portaljquery('#'+frmid+' :input').each(function() {
		if(___portaljquery(this).attr('etn_portal_password') == '1') 
		{
			_passwd = ___portaljquery(this).val();
			passfound = true;
		}
		if(___portaljquery(this).attr('etn_portal_confirm_password') == '1') 
		{
			_confirmpasswd = ___portaljquery(this).val();
			confirmpassfound = true;
		}
	});

	if(passfound && confirmpassfound) 
	{
		if(_passwd != _confirmpasswd) return 0;
		return 1;
	}
	else return 2;
}