


<%
    String _prof = (String)request.getSession().getAttribute("PROFIL");
    java.util.LinkedHashMap<String, String> __pages = new java.util.LinkedHashMap<String, String>();
    Set __rs = null;
    if(_prof.equalsIgnoreCase("admin"))
    {
        __rs = Etn.execute("select * from page order by rang");
    }
    else
    {
        __rs = Etn.execute("select p.* from page p, page_profil pp where pp.url = p.url and pp.profil_id = " + (String)request.getSession().getAttribute("PROFIL_ID") + " order by p.rang");
    }
    while(__rs.next())
    {
        __pages.put(__rs.value("url"), __rs.value("name"));
    }

%>
<center>




<div id="bandeau_menu_responsive">

<div style="width: 1280px;">
<div id="bandeau_logo_orange">
<div style="float: left;"><img src='./img/1clic2.png' height="" /></div><div style="float: left;color: #FF6600;font-size: 19pt;padding: 5px;padding-left: 10px;">Client 1 Click</div></div>
<div id="bandeau_menu">

<div class="wrap" style="text-align: center;">
        <nav class="menu">
            <ul class="active">

                <!-- <li class="current-item"><a href="#">Home</a></li> -->

    <%
        for(String k : __pages.keySet()) { %>
        <li><a href='<%=request.getContextPath()%><%=k%>'><%=__pages.get(k)%></a></li>
    <%     } %>
        <li><a href='<%=request.getContextPath()%>/changePassword.jsp'>Change Password</a></li>
            </ul>

            <a class="toggle-nav" href="#">&#9776;</a>



        </nav>
    </div>

</div>
    </div>
</div>
</center>

