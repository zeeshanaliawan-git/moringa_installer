		var globalEnable = false;	

                function addToCart(id, cookieName, path){
                    if(globalEnable){
                        $("#errorDiv").hide();
                    }
                    else{
                        $("#errorDiv").show();
                        return;
                    }
                    var productsArray;            
                    if(getDecodedCookie(cookieName) == ""){
                        productsArray = [];			
                    }
                    else {
                        productsArray = JSON.parse(getDecodedCookie(cookieName));
                        //if(products.indexOf(id)==-1) products+=","+id;
                    }
                    
                    var attributes = [];
                    $( ".attributes" ).each(function() {
                        attributes.push($( this ).val());
                    });

                    attributes.sort(function(a, b){
                        a = a.substring(0,a.indexOf("_"));
                        b = b.substring(0,b.indexOf("_"));
                        return parseInt(a)-parseInt(b);
                    });
                    
                    var product = {
                        id: id+"",
                        qty: $("#slots").val(),
                        slot_discount_type: $("#slot_discount_type").val(),
                        slot_discount_value: $("#slot_discount_value").val(),
                        attributes: attributes,
                        start_time: (parseInt($("#hour").val())*60+parseInt($("#minute").val()))+"",
                        date: $("#date").val()
                    };
//                    if (productsArray.some(function(e) e.id == id)) {
//                        productsArray.push(product);
//                    } else {
//                        productsArray.push(product);
//                    }
                    productsArray.push(product);
                    setEncodedCookie(cookieName, JSON.stringify(productsArray),7);
                    var menuCookieName = cookieName.replace("CartItems","")+"MenuUuid";
                    setEncodedCookie(menuCookieName, ______muid,7);
                    //setCookie("cartItems", products,7);
                    cartDialog();
                    
                    //$('<form method="POST" action="'+path+'cart/cart.jsp'+'"><input type="hidden" name="muid" value="'+______muid+'" ></form>').appendTo('body').submit();
                    //window.location=path+"cart/cart.jsp?menuid="+______menuid;
                }
                
                function updateAppointment(id, client_key, path){
                    if(globalEnable){
                        $("#errorDiv").hide();
                    }
                    else{
                        $("#errorDiv").show();
                        return;
                    }
                    var productsArray = [];
                    
                    var attributes = [];
                    
                    var product = {
                        id: id+"",
                        qty: $("#slots").val(),
                        slot_discount_type: $("#slot_discount_type").val(),
                        slot_discount_value: $("#slot_discount_value").val(),
                        attributes: attributes,
                        start_time: (parseInt($("#hour").val())*60+parseInt($("#minute").val()))+"",
                        date: $("#date").val(),
                        client_key: client_key
                    };
                    productsArray.push(product);
                    //setCookie("cartItems", products,7);
                    jQuery.ajax({
			url : path+'cart/updateAppointment.jsp',
			type: 'POST',
			dataType: 'json',
			data: {
                            json: JSON.stringify(productsArray)
                        },
			success : function(data)
			{
                            if(data.status=="OK"){
                                parent.completeAction("Reschedule");
                            }
                            else{
                                alert(data.reason);
                            }
			}
                    });
                    //$('<form method="POST" action="'+path+'cart/updateAppointment.jsp'+'"><input type="hidden" name="json" value=\''+JSON.stringify(productsArray)+'\' ></form>').appendTo('body').submit();
                    //window.location=path+"cart/cart.jsp?menuid="+______menuid;
                }
                
                function updatePriceAjax(path, postData, enable){
                    jQuery.ajax({
			url : path+'cart/serviceattributeprice.jsp',
			type: 'POST',
			dataType: 'json',
			data: postData,
			success : function(data)
			{
                            //alert(data);
                            $("#currency_frequency").html(data.currency_frequency);
                            $("#currency_frequency_logged").html(data.currency_frequency);
                            $("#stock").html(data.stock);
                            
                            $("#price_display").html(data.price);
                            if($("#promo_price_display").length) $("#promo_price_display").html(data.promo_price);
                            $("#price_display").show();
                            $("#price_display_logged").html(data.price);
                            if($("#promo_price_display_logged").length) $("#promo_price_display_logged").html(data.promo_price);
                            $("#price_display_logged").show();
                            
                            globalEnable = enable;
                            $("#addToCart").removeClass("o-disabled");
			}
                    });
                }
                
                function showLoggedSpecs(path){
                    $.ajax({
                        url : path+'pages/checklogin.jsp',
                        type: 'post',
                        dataType: 'json',
                        success : function(json)
                        {
                            $(".specs_all").show();
                            if(json.loggedin == '1') 
                            {
                                $(".specs_logged_customer").show();
                                $("#tabhead_summary").show();
                                $(".o-tab-content").removeClass("show");
                                $("#summarytab").addClass("show");
                                //$(".specs_logged_supplier").show();
                            }
                            else{
                                //$('#login-popup').toggleClass('active');
                            }
                        },
                        error : function()
                        {
                                alert("Error while communicating with the server");
                        }
                    });
                }
                
                function showHideLogged(path){
                    $.ajax({
                        url : path+'pages/checklogin.jsp',
                        type: 'post',
                        dataType: 'json',
                        success : function(json)
                        {
                            if(json.loggedin == '1') 
                            {
//                                $(".logged").show();
//                                $(".not_logged").hide();
                                $("#user").val(json.login);
                                $("#questions_user").val(json.login);
                                $(".not_logged").removeClass("active");
                                $(".logged").addClass("active");
                                if(allow_comments!=0 ){
                                    $("#tabhead_comments").show();
                                    if(!$("#summarytab").hasClass("show")){
                                        $(".o-tab-content").removeClass("show");
                                        $("#commentstab").addClass("show");
                                    }                                    
                                }
                                if(allow_questions!=0 ){
                                    $("#tabhead_questions").show();
                                    if(!$("#summarytab").hasClass("show")&&!$("#commentstab").hasClass("show")){
                                        $(".o-tab-content").removeClass("show");
                                        $("#questionstab").addClass("show");
                                    }                                    
                                }
                                
				
                            }
                            else{                                
//                                $(".logged").hide();
//                                $(".not_logged").show();
                                $(".logged").removeClass("active");
                                $(".not_logged").addClass("active");                                
                                if(allow_comments>1){
                                    $("#tabhead_comments").show();
                                    if(!$("#summarytab").hasClass("show")){
                                        $(".o-tab-content").removeClass("show");
                                        $("#commentstab").addClass("show");
                                    }                                    
                                }                               
                                if(allow_questions>1){
                                    $("#tabhead_questions").show();
                                    if(!$("#summarytab").hasClass("show")&&!$("#commentstab").hasClass("show")){
                                        $(".o-tab-content").removeClass("show");
                                        $("#questionstab").addClass("show");
                                    }                                    
                                }
                            }
                        },
                        error : function()
                        {
                            alert("Error while communicating with the server");
                        }
                    });
                }
                
                function initializeCalendar(path, product_uuid){
                    jQuery('#calendar').fullCalendar({
                        header: {
                            left: '',
                            center: 'title',
                            right: 'prev,next'
                        },
                        buttonText: {
                            prev: 'Prev',
                            next: 'Next'
                        },
                        defaultView: 'agendaWeek',
                        minTime: formatTime(getMinTime()),
                        maxTime: formatTime(getMaxTime()),
                        allDaySlot: false,
                        slotDuration: '01:00'/*+service_duration*/+':00',
                        height: 'auto',
                        selectable: true,
                        select: function(start, end) {
                                //alert(start);
                                if(moment().diff(start, 'days')<=0){
                                    var slots = Math.ceil(moment.duration(end.diff(start)).asMinutes()/service_duration);
                                    if(slots>service_max_slots) slots = service_max_slots;
                                    $("#slots").val(slots);
                                    selectedMoment = start;
                                    $("#date").datepicker( "setDate" , start.toDate() );
                                    $("#date_display").html($("#date").val());
                                    //updatePrice();
                                    $( "#scheduleDialog" ).hide("fast");
                                }
                                
                        },
                        events: { // ajax call to populate the data from db
                            url: path+'cart/getSchedule.jsp',
                            type: 'POST',
                            data: {
                                product_uuid: product_uuid,
                                min_time: getMinTime(),
                                max_time: getMaxTime()
                            },
                            error: function() {
                                alert('there was an error while fetching events!');
                            }
                        },
                        eventClick: function(calEvent, jsEvent, view) {
                            /*calEvent.title = "TEST";
                            $('#calendar').fullCalendar('updateEvent', calEvent);*/

                            // change the border color just for fun
                            //$(this).css('border-color', 'red');
                        }
                    });
                }
                
                function loadComments(id, path, num, next_prev){  
                    if(next_prev&&(num<1||num>totalPages)) return;                          
                    
                    currentCommentsPage = num;
                    var postData = {
                            product_id: id,
                            num: num
                    };                
                    jQuery.ajax({
			url : path+'cart/loadComments.jsp',
			type: 'POST',
			data: postData,
			success : function(data)
			{
                            $("#comments_container").html($.trim(data));
                            loadPagination();
                            
                            if(num==1) $("#prevCommentsPage").addClass("o-disabled");
                            else $("#prevCommentsPage").removeClass("o-disabled");

                            if(num>=totalPages) $("#nextCommentsPage").addClass("o-disabled");
                            else $("#nextCommentsPage").removeClass("o-disabled");  
                            $(".commentsPagination").removeClass("active");
                            $(".commentsPagination").removeClass("o-active");
                            $("#commentsPagination"+num).addClass("active");
                            $("#commentsPagination"+num).addClass("o-active");
			}
                    });
                }
                
                function onSaveComments(id, path, message){
                    if($("#user").val()==""||$("#comments").val()==""){
                        if($("#comments").val()!=""){
                            alert(message);
                        }
                        //alert("Please Enter User Name for Comments!");
                        return;
                    }
                    
                    var postData = {
                        product_id: id,
                        comments: $("#comments").val(),
                        user: $("#user").val()
                    };
                    jQuery.ajax({
			url : path+'cart/saveComments.jsp',
			type: 'POST',
			data: postData,
			success : function(data)
			{
                            //if(currentCommentsPage==0) currentCommentsPage=1;
                            loadComments(id, path, currentCommentsPage, false);
                            $("#comments").val("");
			}
                    });
                }                    
                
                function loadPagination(){
                    totalPages = parseInt($("#total_pages").val());
                    if(totalPages<1) $("#pagination_container").hide();
                    else $("#pagination_container").show();
                    var html="<li id='prevCommentsPage'><a href='javascript:gotoPage(currentCommentsPage-1, true)' aria-label='Previous'><span aria-hidden='true'>&laquo;</span></a></li>";
                    for(var i = 1; i<=totalPages; i++){
                        html+="<li id='commentsPagination"+i+"' class='commentsPagination'><a href='javascript:gotoPage("+i+", false)'>"+i+"</a></li>";
                    }
                    html+="<li id='nextCommentsPage'><a href='javascript:gotoPage(currentCommentsPage+1, true)' aria-label='Next'><span aria-hidden='true'>&raquo;</span></a></li>";
                    $("#pagination_container").html(html);
                }
                
                function loadQuestions(id, path, num, next_prev){  
                    if(next_prev&&(num<1||num>totalQuestionsPages)) return;                          
                    
                    currentQuestionsPage = num;
                    var postData = {
                            product_id: id,
                            num: num
                    };                
                    jQuery.ajax({
			url : path+'cart/loadQuestions.jsp',
			type: 'POST',
			data: postData,
			success : function(data)
			{
                            $("#questions_container").html($.trim(data));
                            loadQuestionsPagination();
                            
                            if(num==1) $("#prevQuestionsPage").addClass("o-disabled");
                            else $("#prevQuestionsPage").removeClass("o-disabled");

                            if(num>=totalQuestionsPages) $("#nextQuestionsPage").addClass("o-disabled");
                            else $("#nextQuestionsPage").removeClass("o-disabled");  
                            $(".questionsPagination").removeClass("active");
                            $(".questionsPagination").removeClass("o-active");
                            $("#questionsPagination"+num).addClass("active");
                            $("#questionsPagination"+num).addClass("o-active");
			}
                    });
                }
                
                function onSaveQuestions(id, path, message){
                    if($("#questions_user").val()==""||$("#questions").val()==""){
                        if($("#questions").val()!=""){
                            alert(message);
                        }
                        return;
                    }
                     
                    var postData = {
                        product_id: id,
                        questions: $("#questions").val(),
                        user: $("#questions_user").val(),
                        muid: ______muid
                    };
                    jQuery.ajax({
			url : path+'cart/saveQuestions.jsp',
			type: 'POST',
			data: postData,
			success : function(data)
			{
                            loadQuestions(id, path, currentQuestionsPage, false);
                            $("#questions").val("");
			}
                    });
                }                    
                
                function loadQuestionsPagination(){
                    totalQuestionsPages = parseInt($("#questions_total_pages").val());
                    if(totalQuestionsPages<1) $("#questions_pagination_container").hide();
                    else $("#questions_pagination_container").show();
                    var html="<li id='prevQuestionsPage'><a href='javascript:gotoPageQuestions(currentQuestionsPage-1, true)' aria-label='Previous'><span aria-hidden='true'>&laquo;</span></a></li>";
                    for(var i = 1; i<=totalQuestionsPages; i++){
                        html+="<li id='questionsPagination"+i+"' class='questionsPagination'><a href='javascript:gotoPageQuestions("+i+", false)'>"+i+"</a></li>";
                    }
                    html+="<li id='nextQuestionsPage'><a href='javascript:gotoPageQuestions(currentQuestionsPage+1, true)' aria-label='Next'><span aria-hidden='true'>&raquo;</span></a></li>";
                    $("#questions_pagination_container").html(html);
                }