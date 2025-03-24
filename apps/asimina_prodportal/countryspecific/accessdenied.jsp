<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm"%>

<% response.setHeader("X-Frame-Options","deny"); %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <meta charset="UTF-8">

    <meta content="width=device-width, initial-scale=1, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no" name="viewport">
    <title>accès refusé</title>
</head>

<body>
    <div class="etn-orange-portal--">
        <div class="o-container o-404">
            <div class="o-row" style="margin-bottom: 30px;">
                <div class="o-col-md-8">
                    <h1 style="margin-bottom: 30px;">accès refusé</h1>
                    <p class="o-fwb o-f16">Nous vous invitons à vérifier l'utilisation des caractères majuscules et minuscules utilisés pour votre requête, ainsi que l'orthographe des mots.</p>
                </div>
                <div class="o-col-md-4">
                    <h3 class="o-color-orange o-fwb" style="font-size: 130px;">accès refusé</h3>
                </div>
            </div>
            <div class="o-row">
                <div class="o-col-md-12">
                    <h2 style="margin-bottom: 20px;margin-top: 30px;">Essayez un des liens suivants</h2>
                </div>
            </div>
        </div>
    </div>

</body>

</html>

