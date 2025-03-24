/apiv2/gettoken.jsp

Header : Authorization
case for invalid api key or id
{
	status : 10
	err_code : "invalid_credentials",
	err_msg : "invalid api ID or key"
}

case for success
{
	status : 0,
	data:{ 
           access-token : <acces-token>,
           expires_in : <expires in seconds> 
        }
}


/apiv2/orders/fetch.jsp

filter will check for access token if its valid or expired

Header : access-token

case for invalid access token
{
	status : 10
	err_code : "invalid_access_token",
	err_msg : "access token provided is invalid"
}

case for missing token
{
	status : 20
	err_code : "access_token_missing",
	err_msg : "access token is missing"
}

case for expired token
{
	status : 20
	err_code : "access_token_expired",
	err_msg : "access token provided is already expired"
}

Another filter which will execute after the APIV2auth filter
This filter will be APIV2SiteCheck
Header : site-uid
case for missing site-uid
{
	status : 30
	err_code : "site_id_missing",
	err_msg : "Site ID is missing"
}
case for invalid site-uid
{
	status : 31
	err_code : "invalid_site_id",
	err_msg : "Site ID is not valid"
}


/apiv2/orders/fetch.jsp

case for required fields missing
{
	status : 100
	err_code : "required_fields_missing",
	err_msg : "<provide list of required fields which are missing>"
}

case for success
{
	status : 0
	data : {
		orders : []
	}
}