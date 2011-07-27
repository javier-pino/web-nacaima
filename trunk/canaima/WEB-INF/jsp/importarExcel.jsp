<%@page import="aplicacion.Utilidades"%>
<%@page import="enums.ROL_USUARIO"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="org.apache.poi.hssf.usermodel.*"%>
<%@ page import="org.apache.poi.hssf.util.*"%>
<%@ page import="org.apache.poi.util.IOUtils"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>

<!-- Iniciar Modelo -->
<%@include file="/WEB-INF/jsp/IniciarModelo.jsp"%>

<!-- Incluir la cabecera -->
<%@include file="/WEB-INF/jsp/GeneradorCabecera.jsp"%>

<%
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
	<jsp:include page="/WEB-INF/jsp/GeneradorMenuAdministrador.jsp" flush="true"></jsp:include>
    <div id="Middle">
        <div id="Page">
            <div id="Content">            
<%
				Utilidades.leerArchivoExcel(canaima, canaima.DIRECTORIO_GUARDADO + "Reporte_general_de_colegios.xls");
%>			
			</div>
			<p>&nbsp;</p>
		</div>
    </div>	    
	<br>
	<br>
	<br>
	<br>
</div>

