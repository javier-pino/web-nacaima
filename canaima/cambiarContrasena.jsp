<%@page import="aplicacion.ExcepcionValidaciones"%>
<%@page import="beans.Estado"%>
<%@page import="enums.ROL_USUARIO"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>

<!-- Iniciar Modelo -->
<%@include file="/WEB-INF/jsp/IniciarModelo.jsp"%>

<!-- Incluir la cabecera -->
<%@include file="/WEB-INF/jsp/GeneradorCabecera.jsp"%>
<%!
	public enum ESTADO {	
		POR_GUARDAR,
		INICIAL
	} 
%>
<%
	//Verificamos roles, y mandamos a su página merecida
	if (canaima.getUsuarioActual() == null) {
		response.sendRedirect("login.jsp");
		return;
	}

	//Incluir el menu de acuerdo al rol
	request.setAttribute("rolActual", canaima.getUsuarioActual()
			.getRol());
	pageContext.include("/WEB-INF/jsp/GeneradorMenu.jsp", true);
	if (canaima.getUsuarioActual().getRol().equals(ROL_USUARIO.VIS)) {
		pageContext.include("/WEB-INF/jsp/GeneradorMenuVisitante.jsp",
				true);
	} else if (canaima.getUsuarioActual().getRol().equals(ROL_USUARIO.ANA)) {
		pageContext.include("/WEB-INF/jsp/GeneradorMenuAnalista.jsp",
				true);
	} else if (canaima.getUsuarioActual().getRol().equals(ROL_USUARIO.ADM)) {
		pageContext.include(
				"/WEB-INF/jsp/GeneradorMenuAdministrador.jsp", true);
	}
%>	
<div id="Middle">
	<div id="Page">
		<div id="Content">
<%		
	ESTADO actual = ESTADO.INICIAL;
	if (request.getParameter("estado") != null) {
		actual = ESTADO.valueOf(request.getParameter("estado"));
	}	
	try {		
		if (actual.equals(ESTADO.POR_GUARDAR)) {
			
			if (request.getParameter("nueva") == null || request.getParameter("nueva").isEmpty()
					||request.getParameter("anterior") == null || request.getParameter("anterior").isEmpty()
					||request.getParameter("confirmacion") == null || request.getParameter("confirmacion").isEmpty()) 
			{
				throw new ExcepcionValidaciones("Todos los campos son obligatorios");	
			}
			
			Usuario usuario = new Usuario();
			canaima.buscarPorID(canaima.getUsuarioActual().getID(), usuario);
			if (usuario.getContrasena().equals(request.getParameter("anterior"))) {
				if (request.getParameter("confirmacion").equals(request.getParameter("nueva"))) {
					usuario.setContrasena(request.getParameter("nueva"));
					canaima.actualizar(usuario);
%>
				<jsp:include page="/WEB-INF/jsp/GeneradorMensaje.jsp">
						<jsp:param value="Modificaci&oacute;n exitosa" name="titulo"/>
						<jsp:param value="La contrase&ntilde;a fue modificada exitosamente" name= "texto"/>
				</jsp:include>					
<%					
				} else {
					throw new ExcepcionValidaciones("La contrase&ntilde;a nueva no coincide con la confirmaci%oacute;n");
				}
			} else {
				throw new ExcepcionValidaciones("La contrase&ntilde;a anterior no coincide con la almacenada en el sistema");
			}
		}	
	} catch (ExcepcionValidaciones val) {
		request.setAttribute("validaciones", val.getValidacionesIncumplidas());
		pageContext.include("/WEB-INF/jsp/GeneradorMensaje.jsp", true);					
	} catch (Exception exc) {	
		exc.printStackTrace();		
		request.setAttribute("excepcion", exc);
		pageContext.include("/WEB-INF/jsp/GeneradorMensaje.jsp", true);
	}
%>		
		
			<div class="Part">
               <h2>Modificar Contrase&ntilde;a </h2>
               &nbsp;
               <div align="left" id="scroll">
               		<form name="lista" action="cambiarContrasena.jsp" method="post" >
					<table id="fila_colegio">		
						<tr class="a"> 
							<td>Contrase&ntilde;a Anterior</td>
							<td>Contrase&ntilde;a Nueva</td>
							<td>Confirme Contrase&ntilde;a</td>
							<td></td>							
						</tr>
						<tr> 
							<td><input type="password" tabindex="1" size="20" name="anterior" maxlength="10" ></td>						
							<td><input type="password" tabindex="2" size="20" name="nueva" maxlength="10" ></td>
							<td><input type="password" tabindex="3" size="20" name="confirmacion" maxlength="10" ></td>						
							<td align="center">
							<INPUT type="hidden" value="<%= ESTADO.POR_GUARDAR %>" name="estado">
							<INPUT tabindex="5" type="submit" value="Aceptar" onclick="return validarContraseña(form)">
							</td>
						</tr>
					</table>
					</form>               		
               </div>
               &nbsp;                                 	              
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

