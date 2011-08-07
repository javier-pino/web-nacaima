// Documento JavaScript
// Esta función cargará las paginas
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
// todo es correcto y ha llegado el momento de poner la información requerida
// en su sitio en la pagina xhtml
function cargarpagina(pagina_requerida, id_contenedor){
if (pagina_requerida.readyState == 4 && (pagina_requerida.status==200 || window.location.href.indexOf("http")==-1))
document.getElementById(id_contenedor).innerHTML=pagina_requerida.responseText;
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
				&&(form.idestado.value == 0)
				&&(form.idmunicipio.value == 0)
				&&(form.ciudad.value=="" || form.ciudad.value == null)
				&&(form.idcolegio.value=="" || form.idcolegio.value == null)
				&&(form.colegio.value=="" || form.colegio.value == null)
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
function validarCerrarCaja(caja, valor){
	if (caja == 0)
	{
		alert("No se puede cerrar una caja que fue cerrada previamente o aún no está abierta");
		return false;
	} 
	if (valor == null || valor == "")
		{
			alert("Describa el Motivo del Cierre de la Caja");
			return false;
		}
	return true;
}

function validarContrato(form){
	if ((form.numero.value=="" || form.numero.value == null)||
		(form.pdf.value=="" || form.pdf.value == null)
	   )
	{
		alert("No es posible Guardar, Falta Completar Nro. Contrato o debe Adjuntar un Contrato");
		return false;
	} 
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
	if (contrato != form.numero.value) {
		if (form.numero.value == "" || form.numero.value == null 
			|| form.pdf.value=="" || form.pdf.value == null ) {
				alert("No es posible Actualizar, Falta Completar Nro. Contrato o debe Adjuntar un Contrato");						
					return false;
		}
	} 
	return true;
}