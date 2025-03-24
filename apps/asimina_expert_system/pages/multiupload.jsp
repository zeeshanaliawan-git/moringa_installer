<html>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Alerts</title>

<link href="css/abcde.css" rel="stylesheet" type="text/css" />

<link rel="stylesheet" type="text/css" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" />


<SCRIPT LANGUAGE="JavaScript" SRC="js/jquery.min.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="js/jquery-ui-1.8.18.custom.min.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="json.js"></script>

</head>

<body>
	<input type='file' name='filename' value='' id='f1' />
	<input type='file' name='filename' value='' id='f2' />
	<input type='button' value='upload' id='u1' />
</body>
    <script type="text/javascript">
		jQuery(document).ready(function() {
			var files1 ;
			var files2 ;
			var counter = 0;
			// Grab the files and set them to our variable
			prepareUpload=function(event)
			{
				var id = $(this).attr('id');
				if(id == 'f1') files1 = event.target.files;
				else if(id == 'f2') files2 = event.target.files;
			};

			// Add events
			$('input[type=file]').on('change', prepareUpload);

			$("#u1").click(function(){
				var data = new FormData();
				$.each(files1, function(key, value) {
					data.append(key, value);
				});
				$.each(files2, function(key, value) {
					data.append(key, value);
				});


				var url = "tryupload.jsp";
				
				$.ajax({
					url: url,
					type: 'POST',
					data: data,
					cache: false,
					dataType: 'json',
					processData: false, // Don't process the files
					contentType: false, // Set content type to false as jQuery will tell the server its a query string request
					async: false,
					beforeSend: function()
					{
						//$("#loader").dialog('open');
					},
					success: function(data, textStatus, jqXHR)
					{
						//$("#loader").dialog('close');
						if(data.response == 'success')
						{
							// Success so call function to process the form
							alert('Uploaded successfully!!!');
							$("#downloadScrFile").show();
							$("#updatescrbtnspan").show();
						}
						else
						{
							// Handle errors here
							alert(data.msg);
						}
						//$("#filename").val('');
					},
					error: function(jqXHR, textStatus, errorThrown)
					{
//						/$("#loader").dialog('close');
						// Handle errors here
						console.log('ERRORS: ' + textStatus);
						// STOP LOADING SPINNER
					}
				});

			});

		});
	</script>
</html>


