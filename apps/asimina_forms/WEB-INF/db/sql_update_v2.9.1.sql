
ALTER TABLE supported_files ADD icon varchar(50);
update supported_files set icon = 'Camera.png' where extension IN ('jpg','jpeg','png');
update supported_files set icon = 'PDF.png' where extension IN ('pdf');
update supported_files set icon = 'Word.png' where extension IN ('doc','docx');
update supported_files set icon = 'Powerpoint.png' where extension IN ('ppt','pptx');
update supported_files set icon = 'Video.png' where extension IN ('mov','avi','mp4','3gp');