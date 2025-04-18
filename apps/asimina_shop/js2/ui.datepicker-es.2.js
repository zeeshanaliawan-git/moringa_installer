// Code adapted from JavaScript downloaded from jQuery official site, which stated Sunday as first day
// of the week, instead of Monday


oldjquery(function($){
	$.datepicker.regional['es'] = {
		clearText: 'Limpiar', clearStatus: '',
		closeText: 'Cerrar', closeStatus: '',
		prevText: '&#x3c;Ant', prevStatus: '',
		prevBigText: '&#x3c;&#x3c;', prevBigStatus: '',
		nextText: 'Sig&#x3e;', nextStatus: '',
		nextBigText: '&#x3e;&#x3e;', nextBigStatus: '',
		currentText: 'Hoy', currentStatus: '',
		monthNames: ['Enero','Febrero','Marzo','Abril','Mayo','Junio',
		'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'],
		monthNamesShort: ['Ene','Feb','Mar','Abr','May','Jun',
		'Jul','Ago','Sep','Oct','Nov','Dic'],
		monthStatus: '', yearStatus: '',
		weekHeader: 'Sm', weekStatus: '',
		dayNames: ['Domingo','Lunes','Martes','Mi&eacute;rcoles','Jueves','Viernes','S&aacute;bado'],
		dayNamesShort: ['Dom','Lun','Mar','Mi&eacute;','Juv','Vie','S&aacute;b'],
		dayNamesMin: ['Do','Lu','Ma','Mi','Ju','Vi','S&aacute;'],
		dayStatus: 'DD', dateStatus: 'D, M d',
		dateFormat: 'dd/mm/yy', firstDay: 1, 
		initStatus: '', isRTL: false};
	$.datepicker.setDefaults($.datepicker.regional['es']);
});
