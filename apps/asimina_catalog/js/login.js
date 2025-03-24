function checkLogin(application){
    $.ajax({
            url : application+'/pages/checklogin.jsp',
            type: 'post',
            dataType: 'json',
            async : false,
            success : function(json)
            {
                if(json.loggedin == '1') 
                {
                    $('#cartForm').submit();
                }
                else{
                    $('#login-popup').toggleClass('active');
                }
            },
            error : function()
            {
                    alert("Error while communicating with the server");
            }
    });
}

function doLogin(application){
    $.ajax({
        url : application+'dologin.jsp',
        data : $("#loginForm").serialize(),
        type: 'post',
        dataType: 'json',
        success : function(json)
        {
                if(json.response == 'error') alert(json.message);
                else if(json.refresh && json.refresh == '1') {
                    $('#login-popup').removeClass('active');
                    $('#cartForm').submit();
                }
                //else if(json.goto && json.goto != '') window.location = json.goto;
        },
        error : function()
        {
                window.status = "Error while communicating with the server";
        }
    });
}