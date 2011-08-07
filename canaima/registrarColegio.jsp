<%@page import="java.sql.Connection"%>
<%@page import="aplicacion.ModeloCanaima"%>
<%@page import="java.sql.SQLException"%>
<%@page import="aplicacion.ExcepcionRoles"%>
<%@page import="aplicacion.ExcepcionValidaciones"%>
<%@page import="java.util.*" %>
<%@page import="enums.ROL_USUARIO"%>

<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
    <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<!-- Iniciar Modelo -->
<%@include file="/WEB-INF/jsp/IniciarModelo.jsp"%>

<!-- Incluir la cabecera -->
<%@include file="/WEB-INF/jsp/GeneradorCabecera.jsp"%>
    
<%!
	public enum ESTADO {
		LISTADO,	
		POR_GUARDAR,
		INICIAL
	} 
%>


<%
	ESTADO actual = ESTADO.INICIAL;

	//Verificamos roles, y mandamos a su página merecida
	if (canaima.getUsuarioActual() == null) {
		response.sendRedirect("login.jsp");
		return;
	} else if (canaima.getUsuarioActual().getRol().equals(ROL_USUARIO.ANA)) {
		response.sendRedirect(response.encodeRedirectURL("analista.jsp"));
		return;	
	} else if (canaima.getUsuarioActual().getRol().equals(ROL_USUARIO.VIS)) {
		response.sendRedirect(response.encodeRedirectURL("visitante.jsp"));
		return;
	}
	//Incluir el menu de acuerdo al rol
	request.setAttribute("rolActual", canaima.getUsuarioActual().getRol());	
	pageContext.include("/WEB-INF/jsp/GeneradorMenu.jsp", true);
%>
<jsp:include page="/WEB-INF/jsp/GeneradorMenuAnalista.jsp" flush="true"></jsp:include>

<div id="Middle">
    <div id="Page">
          <div id="Content">          
				<jsp:include page="/WEB-INF/jsp/RegistrarColegio.jsp"></jsp:include>		               
		   </div>
			<p>&nbsp;</p>
			</div>
	    </div>	
	<br>
	<br>
	<br>
	<br>
</div>