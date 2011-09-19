//Documento JavaScript
//Esta función cargará las paginas
function llamarasincrono(url, id_contenedor){
	var pagina_requerida = false;
	if (window.XMLHttpRequest) {// Si es Mozilla, Safari etc
		pagina_requerida = new XMLHttpRequest();
	} else if (window.ActiveXObject){ // pero si es IE
		try {
			pagina_requerida = new ActiveXObject("Msxml2.XMLHTTP");
		} 
		catch (e){ // en caso que sea una versión antigua
			try{
				pagina_requerida = new ActiveXObject("Microsoft.XMLHTTP");
			}
			catch (e){}
		}
	}
	else
		return false;
	pagina_requerida.onreadystatechange=function(){ // función de respuesta
		cargarpagina(pagina_requerida, id_contenedor);
	};
	pagina_requerida.open('GET', url, true) ;// asignamos los métodos open y send
	pagina_requerida.send(null);
}
//todo es correcto y ha llegado el momento de poner la información requerida
//en su sitio en la pagina xhtml
function cargarpagina(pagina_requerida, id_contenedor){
	if (pagina_requerida.readyState == 4 && (pagina_requerida.status==200 || window.location.href.indexOf("http")==-1))
		document.getElementById(id_contenedor).innerHTML=pagina_requerida.responseText;
}

function limpiarColegio(form) {
	form.colegiotexto.value = '';
	form.idcolegio.value = '0';
}

function validarNumero(form)
{
	if ((event.keyCode < 48 || event.keyCode > 57) && (event.keyCode != 13)) 
		event.returnValue = false;

}


function validarValores(form){
	if ( (form.iddonatario.value=="" || form.iddonatario.value == null) 
			&&(form.nombre.value=="" || form.nombre.value == null)
			&&(form.representante_ci.value=="" || form.representante_ci.value == null)
			&&(form.representante_nombre.value=="" || form.representante_nombre.value == null)
			&&(form.idestado.value == 0)
			&&(form.idmunicipio.value == 0)
			&&(form.ciudad.value=="" || form.ciudad.value == null)
			&&(form.idcolegio.value=="" || form.idcolegio.value=="0" || form.idcolegio.value == null)
			&&(form.colegio.value=="" || form.colegio.value == null)			
	)
	{
		alert("Introduzca al menos un campo");
		return false;
	} 

}

function validarValoresDocente(form){
	if ( (form.iddocente.value=="" || form.iddocente.value == null) 
			&&(form.nombre.value=="" || form.nombre.value == null)
			&&(form.cedula.value=="" || form.cedula.value == null)
			&&(form.idestado.value == 0)
			&&(form.idmunicipio.value == 0)
			&&(form.idparroquia.value == 0)
			&&(form.ciudad.value=="" || form.ciudad.value == null)
			&&(form.idcolegio.value=="" || form.idcolegio.value=="0" || form.idcolegio.value == null)
	)
	{
		alert("Introduzca al menos un campo");
		return false;
	} 

}

function validarValoresColegio(form){
	if ( (form.idestado.value == 0) &&(form.idmunicipio.value == 0) &&(form.idparroquia.value == 0)
			&&(form.idcolegioo.value == "" || form.idcolegioo.value == null)
			&&(form.idcolegio.value == "" || form.idcolegio.value == null)
	)
	{
		alert("Introduzca al menos un campo");
		return false;
	} 

}

function buscarContrato(form){
	if ( (form.iddonatario.value=="" || form.iddonatario.value == null) 
			&&(form.numero.value=="" || form.numero.value == null)) {
		alert("Introduzca al menos un campo");
		return false;
	}
	return true;
}

function mostrarMunicipios(idestado){	
	ajax = nuevoAjax();
	ajax.open("GET", "AjaxBuscarMunicipios.jsp?idestado="+idestado, true);
	ajax.onreadystatechange = function() {
		document.getElementById("municipios").innerHTML = ajax.responseText;
	};
	ajax.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	ajax.send(null);	
}

function mostrarParroquias(idmunicipio){	
	ajax = nuevoAjax();
	ajax.open("GET", "AjaxBuscarParroquias.jsp?idmunicipio="+idmunicipio, true);
	ajax.onreadystatechange = function() {
		document.getElementById("parroquias").innerHTML = ajax.responseText;
	};
	ajax.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	ajax.send(null);	
}

function eliminarDonatario(iddonatario){	
	ajax = nuevoAjax();
	ajax.open("GET", "AjaxEliminarDonatario.jsp?iddonatario="+iddonatario, true);
	ajax.onreadystatechange = function() {
		document.getElementById("eliminar").innerHTML = ajax.responseText;
	};
	ajax.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	ajax.send(null);
	return false;
}

function eliminarDocente(iddocente){	
	ajax = nuevoAjax();
	ajax.open("GET", "AjaxEliminarDocente.jsp?iddocente="+iddocente, true);
	ajax.onreadystatechange = function() {
		document.getElementById("eliminar").innerHTML = ajax.responseText;
	};
	ajax.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	ajax.send(null);
	return false;
}

function eliminarColegio(idcolegio){	
	ajax = nuevoAjax();
	ajax.open("GET", "AjaxEliminarColegio.jsp?idcolegio="+idcolegio, true);
	ajax.onreadystatechange = function() {
		document.getElementById("eliminar").innerHTML = ajax.responseText;
	};
	ajax.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	ajax.send(null);
	return false;
}


function nuevoAjax(){
	var xmlhttp=false; 
	try {
		xmlhttp=new ActiveXObject("Msxml2.XMLHTTP"); 
	}
	catch(e){ 
		try	{ 
			xmlhttp=new ActiveXObject("Microsoft.XMLHTTP"); 
		} catch(E) { xmlhttp=false; }
	}
	if (!xmlhttp && typeof XMLHttpRequest!='undefined') {
		xmlhttp=new XMLHttpRequest(); 
	}
	return xmlhttp; 
}
function validarCerrarCaja(form){

	var select = form.tipo.options;
	var indice = form.tipo.selectedIndex;
	var seleccionado = select[indice].value;

	if (seleccionado == 'DON') {
		if (form.donatario.value == 0) {
			alert("No se puede cerrar una caja que fue cerrada previamente o aún no está abierta");
			return false;
		}
	}
	if (seleccionado == 'DOC') {
		if (form.docente.value == 0) {
			alert("No se puede cerrar una caja que fue cerrada previamente o aún no está abierta");
			return false;
		}
	}
	if (form.incidencia.value == null || form.incidencia.value == "")
	{
		alert("Describa el Motivo del Cierre de la Caja");
		return false;
	}
	return true;
}

function validarContrato(form){

	return true;
}

function validarUsuario(form){
	if ((form.usuario.value=="" || form.numero.value == null)||
			(form.nombre.value=="" || form.pdf.value == null))
	{
		alert("No es posible Guardar, Falta Completar Usuario (Login) o Nombre de Usuario");
		return false;
	} 
	return true;
}

function validarContraseña(form){
	if ((form.nueva.value=="" || form.nueva.value == null)||
			(form.anterior.value=="" || form.anterior.value == null) ||
			(form.confirmacion.value=="" || form.confirmacion.value == null)
	)
	{
		alert("No es posible actualizar la contraseña. Todos los datos son obligatorios");
		return false;
	} 
	return true;
}

function validarContratoActualizado(form, contrato){

	return true;
}

function removeAttachmentElement(num_id) {
	var container = document.getElementById('attachment_container');
	container.removeChild( document.getElementById('attachment_'+num_id) );
}


function addAttachmentElement() {
	var container = document.getElementById('attachment_container');
	var counter = document.getElementById('serial_contador').value;
	counter++;
	document.getElementById('serial_contador').value = counter;
	var attachment_div = document.createElement('div');
	attachment_div.setAttribute('id','attachment_'+counter);
	attachment_div.setAttribute('class','attachment');
	 
		var attachment_label = document.createElement('label');
		attachment_label.innerHTML = "";
		attachment_div.appendChild(attachment_label);
	 
		var attachment_input = document.createElement('input');
		attachment_input.setAttribute('type','text');
		attachment_input.setAttribute('size','24');
		attachment_input.setAttribute('id','serial_'+counter);
	      attachment_input.setAttribute('name','serial_'+counter);
		attachment_div.appendChild(attachment_input);
	 
		var attachment_a2 = document.createElement('a');
		attachment_a2.setAttribute('href','');
		attachment_a2.setAttribute('onclick','removeAttachmentElement('+counter+');return false;');
			var attachment_img2 = document.createElement('img');
			attachment_img2.setAttribute('id','RemoveButton_'+counter);
			attachment_img2.setAttribute('src','img/minusButton.png');
			attachment_img2.setAttribute('alt','Remove');
			attachment_img2.setAttribute('onmousedown',"this.src='img/minusButtonDown.png';");
			attachment_img2.setAttribute('onmouseup',"this.src='img/minusButton.png';");
			attachment_a2.appendChild(attachment_img2);
	 
		attachment_div.appendChild(attachment_a2);
	 
	container.appendChild(attachment_div);
	}