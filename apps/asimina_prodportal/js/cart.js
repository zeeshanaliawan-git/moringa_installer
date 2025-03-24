		var ___selectedduration = "";	
		var ___selectedprice = "";
		
		function selectCartItem(duration, price)
		{
			___selectedduration = duration;
			___selectedprice = price;
		}

		function addToCart(url, msg)
		{
			if(document.getElementsByClassName('selectforcart'))
			{
				var anychecked = false;
				var val = "";
				for(var i=0; i<document.getElementsByClassName('selectforcart').length; i++)
				{
					if(document.getElementsByClassName('selectforcart')[i].checked) 
					{
						anychecked = true;
						val = document.getElementsByClassName('selectforcart')[i].value;
					}
				}
				if(anychecked)
				{
					url = url.replace("<_selected_item_duration>", ___selectedduration);
					url = url.replace("<_selected_item_price>", ___selectedprice);
					var win = window.open(url, '_blank');
					win.focus();
//					alert(url);
				}
				else
				{
					alert(msg);
				}
			}			
		}

		function addToCart2(url, price)
		{
			url = url.replace("<_selected_item_duration>", "");
			url = url.replace("<_selected_item_price>", price);
			var win = window.open(url, '_blank');
			win.focus();
		}
                
                
function checkLogin(muid){
    $.ajax({
            url : ______portalurl + '/pages/checklogin.jsp',
            type: 'post',
			data : { muid : muid },
            dataType: 'json',
            async : false,
            success : function(json)
            {
                if(json.loggedin == '1') 
                {
                    $('#cartForm').submit();
                }
                else{
                    $('#login-popup').modal('toggle');
                }
            },
            error : function()
            {
                    alert("Error while communicating with the server");
            }
    });
}

function signup(){
                    $('#login-popup').removeClass('active');
                    $('#signup-popup').toggleClass('active');
}

function doLogin(){
    $.ajax({
        url : ______portalurl + 'dologin.jsp',
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
    
var mapShortToLong = {
    "name": "product_name",
    "brand": "product_brand",
    "id": "product_id",
    "price": "product_price",
    "category": "product_category",
    "variant": "product_variant",
    "position": "product_position",
    "quantity":"product_quantity",
    "stock": "product_stock",
    "stock_number": "product_stock_number"
};

function refitKeysArray(a){
    var build = [];
    for(var i = 0; i<a.length; i++) build.push(refitKeys(a[i]));
    return build;
}

function objectFromArray(a){
    var build = {};
    for(var i = 0; i<a.length; i++){
        for(var key in a[i]){
            if(build[key]===undefined) build[key] = a[i][key];
            else build[key] = build[key] + " | " + a[i][key];
        }
    }
    return build;
}
    
function refitKeys(o){
    var build, key, destKey, value;

    build = {};
    for (key in o) {
        // Get the destination key
        destKey = mapShortToLong[key] || key;

        // Get the value
        value = o[key];

        // If this is an object, recurse
        if (typeof value === "object") {
            value = refitKeys(value);
        }

        // Set it on the result using the destination key
        build[destKey] = value;
    }
    return build;
}

function cloneObject(sourceObj){
    return JSON.parse(JSON.stringify(sourceObj));
}