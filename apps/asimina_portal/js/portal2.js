function encodeBase64(s)
{
	$.base64.utf8encode = true;
	return $.base64.btoa(s);
}