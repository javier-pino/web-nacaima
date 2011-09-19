<%@page import="aplicacion.Utilidades"%>
<%@page import="aplicacion.ExcepcionValidaciones"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.io.FileDescriptor"%>
<%@page import="java.io.File"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
    
<!-- Iniciar Modelo -->
<%@include file="/WEB-INF/jsp/IniciarModelo.jsp"%>

<%
	Utilidades.eliminarArchivosTemporales(canaima.DIRECTORIO_TEMPORAL);		
%>   
 
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
</head>
<body>
<%
	String direccion = "";
	if (canaima.getArchivoTemporal() == null) {		 
		response.sendRedirect(response.encodeRedirectUrl("analista.jsp"));
	} else {
		direccion = "/canaima/temp/" + canaima.getArchivoTemporal();
	%>
		<embed src="<%= direccion %>" width="800" height="450">
	<%
		}
	%>
</body>
</html>
