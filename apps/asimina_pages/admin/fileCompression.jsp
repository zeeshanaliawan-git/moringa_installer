<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.ArrayList "%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>

<!DOCTYPE html>
<html>
    <head></head>
    <body>
        <div id="drop-zone1" class="drop-zone">
            <span>Upload File</span>
            <input type="file" name="myFile" class="drop-zone__input">
        </div>
    </body>
</html>


<script>
    let size = 1024;
    let MIME_TYPE = "image/jpeg";
    let QUALITY = 0.7;
    document.querySelectorAll(".drop-zone__input").forEach((inputElement) => {
        let dropZoneElement = inputElement.closest(".drop-zone");

        dropZoneElement.addEventListener("click", (e) => {
            inputElement.click();
        });

        inputElement.addEventListener("change", (e) => {
            if (inputElement.files.length) {
                if (inputElement.files[0].size  >= 2000000) {
                    const blobURL = window.URL.createObjectURL(inputElement.files[0]);
                    const img = new Image();
                    img.src = blobURL;
                    img.onload = function () {
                        window.URL.revokeObjectURL(blobURL); // release memory
                        const canvas = document.createElement('canvas');
                        let newWidth=img.width;
                        let newHeight=img.height;
                        canvas.width = newWidth;
                        canvas.height = newHeight;
                        // if (img.height > img.width) {
                        //
                        //     [newWidth, newHeight] = calculateSize(img, size);
                        //     canvas.width = newWidth;
                        //     canvas.height = newHeight;
                        // }
                        // else {
                        //     [newWidth, newHeight] = calculateSize(img, size);
                        //     canvas.width = newWidth;
                        //     canvas.height = newHeight;
                        // }
                        const ctx = canvas.getContext('2d');
                        ctx.drawImage(img, 0, 0, newWidth, newHeight);
                        canvas.toBlob(
                            (blob) => {
                                
                                saveBlobAsFile(blob, inputElement.files[0].name)
                                // var file = new File([blob], inputElement.files[0].name);
                                // console.log("file:",file)
                            },
                            MIME_TYPE,
                            QUALITY
                        );
                        document.getElementById("drop-zone1").append(canvas);


                    };
                }
            }
        });

    });

    function saveBlobAsFile(blob, fileName) {
        let reader = new FileReader();

        reader.onloadend = function () {
            let base64 = reader.result ;
            let link = document.createElement("a");

            document.body.appendChild(link); // for Firefox
            // document.getElementById('#drop-zone1').append(link)
            link.setAttribute("href", base64);
            link.setAttribute("download", fileName);
            link.click();
        };

        reader.readAsDataURL(blob);
    }

    // function calculateSize(img, maxWidth, maxHeight) {
    //     let width = img.width;
    //     let height = img.height;
    //
    //     console.log("oldWidth:",width)
    //     console.log("oldHeight:",height)
    //     // calculate the width and height, constraining the proportions
    //     if (width > height) {
    //         if (width > maxWidth) {
    //             height = Math.round((height * maxWidth) / width);
    //             width = maxWidth;
    //         }
    //     } else {
    //         if (height > maxHeight) {
    //             width = Math.round((width * maxHeight) / height);
    //             height = maxHeight;
    //         }
    //     }
    //     return [width, height];
    // }
    function calculateSize(img, size) {
        let width = img.width;
        let height = img.height;
        let percentageDifference;
        if (width > height) {
            percentageDifference=Math.round(((width-height)*100)/width);
            width=size;
            height=size-Math.round((percentageDifference/100)*size);
        } else {
            percentageDifference=Math.round(((height-width)*100)/height);
            height=size;
            width=Math.round((percentageDifference/100)*size);
        }
        return [width, height];
    }
</script>