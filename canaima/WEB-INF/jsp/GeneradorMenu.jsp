<%@page import="enums.ROL_USUARIO"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>

<%
	ROL_USUARIO rol = (ROL_USUARIO)request.getAttribute("rolActual");
	if (rol.equals(ROL_USUARIO.VIS)) {	
%>
  	 <div id="Menu">
		<a class="" href="<%= response.encodeURL("visitante.jsp") %>"><span></span></a>		
		<a class="" href="<%= response.encodeURL("visitante.jsp") %>" style="COLOR:BLACK"><span>Visitante</span></a>
   	</div>  	   	
<% 
	} else if (rol.equals(ROL_USUARIO.ANA)) {		
%>
	<div id="Menu">	
		<a class="" href="<%= response.encodeURL("visitante.jsp") %>"><span></span></a>		
		<a class="" href="<%= response.encodeURL("visitante.jsp") %>"><span>Visitante</span></a>
		<a class="" href="<%= response.encodeURL("analista.jsp") %>"><span>Analista</span></a>				
   	</div>
<%
	} else if (rol.equals(ROL_USUARIO.ADM)) {		
%>
	<div id="Menu">
		<a class="" href="<%= response.encodeURL("visitante.jsp") %>"><span></span></a>		
		<a class="" href="<%= response.encodeURL("visitante.jsp") %>"><span>Visitante</span></a>
		<a class="" href="<%= response.encodeURL("analista.jsp") %>"><span>Analista</span></a>
		<a class="" href="<%= response.encodeURL("administrador.jsp") %>"><span>Administrador</span></a>				
   	</div>   	
<%
	}	 
%>

