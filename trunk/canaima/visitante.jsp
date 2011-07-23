<%@page import="enums.ROL_USUARIO"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>

<!-- Iniciar Modelo -->
<%@include file="/WEB-INF/jsp/IniciarModelo.jsp"%>

<!-- Incluir la cabecera -->
<%@include file="/WEB-INF/jsp/GeneradorCabecera.jsp"%>

<%		
	if (canaima.getUsuarioActual() == null) {
		response.sendRedirect("login.jsp");
		return;
	} 
	//Incluir el menu de acuerdo al rol
	request.setAttribute("rolActual", canaima.getUsuarioActual().getRol());	
	pageContext.include("/WEB-INF/jsp/GeneradorMenu.jsp", true);
%>
	    <jsp:include page="/WEB-INF/jsp/GeneradorMenuVisitante.jsp" flush="true"></jsp:include>
	    <div id="Middle">
	        <div id="Page">
	            <div id="Content">
					
					<jsp:include page="/WEB-INF/jsp/GeneradorMensaje.jsp">
						<jsp:param value="Cuadro de mensajes" name="titulo"/>
						<jsp:param value="Aquí recibirás mensajes de la aplicación: " name= "texto"/>
						<jsp:param value="&nbsp;- Si hubo un error en el ingreso de los datos" name= "texto"/>
						<jsp:param value="&nbsp;- Si fue exitoso el ingreso de información" name= "texto"/>
						<jsp:param value="&nbsp;Para desaparecer este mensaje haz click en la caja" name= "texto"/>
					</jsp:include>									
					<div class="Part">
	                <h2>Marco de Funcionalidades </h2>
	                <p> Acá estar&aacute;n las distintas opciones</p>                  	               
					</div> 	
				</div>
				<p>&nbsp;</p>
			</div>
	    </div>	
	<br>
	<br>
	<br>
	<br>
</div>