
                
                function showHideLoggedProfil(path){
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
                                $(".logged").removeClass("active");
                                $(".logged_"+json.profil).addClass("active");
                                $(".not_logged").removeClass("active");
                                $(".not_logged_promotion").removeClass("active");
                                $(".logged_promotion").addClass("active");
                                
				
                            }
                            else{                                
//                                $(".logged").hide();
//                                $(".not_logged").show();
                                $(".not_logged").addClass("active");
                                $(".logged").removeClass("active");
                                $(".not_logged_promotion").addClass("active");
                                $(".logged_promotion").removeClass("active");
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
                                $(".logged").addClass("active");
                                $(".not_logged").removeClass("active");
                                $(".not_logged_promotion").removeClass("active");
                                $(".logged_promotion").addClass("active");
                                
				
                            }
                            else{                                
//                                $(".logged").hide();
//                                $(".not_logged").show();
                                $(".not_logged").addClass("active");
                                $(".logged").removeClass("active");
                                $(".not_logged_promotion").addClass("active");
                                $(".logged_promotion").removeClass("active");
                            }
                        },
                        error : function()
                        {
                                alert("Error while communicating with the server");
                        }
                    });
                }
                
                function onFilter(path, checkbox){
                    if ($(window).width() < 768 && checkbox) {
                        return;
                    }
                    $("#filter").removeClass('active');
                    var postData = $("#filter").serialize()+"&___pt="+encodeURIComponent(______pt)+"&___mc="+encodeURIComponent(______mc)+"&___mid="+encodeURIComponent(______mid);
                    $.ajax({
                        url : path+'cart/filter.jsp',
                        type: 'post',
			data: postData,
                        dataType: 'json',
                        success : function(data)
                        {
                            $("#gridviewdivs").html(getGridHtml(data.products));
                            $("#listviewdivs").html(getHtml(data.products));
                            
                        },
                        error : function()
                        {
                                alert("Error while communicating with the server");
                        }
                    });
                }
                
                function resetFilter(){
                    $("input[name=attribute_filter]").each( function () {
                        $(this).removeAttr('checked');
                    });
                }