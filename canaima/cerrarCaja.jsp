<%@page import="enums.CAJA_TIPO"%>
<%@page import="enums.ROL_USUARIO"%>
<%@page import="java.sql.Connection" %>
<%@page import="beans.*"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>

<!-- Iniciar Modelo -->
<%@include file="/WEB-INF/jsp/IniciarModelo.jsp"%>

<!-- Incluir la cabecera -->
<%@include file="/WEB-INF/jsp/GeneradorCabecera.jsp"%>

<%
	//Verificamos roles, sino mandamos a su página merecida
	if (canaima.getUsuarioActual() == null) {
		response.sendRedirect("login.jsp");
		return;
	} else if (canaima.getUsuarioActual().getRol().equals(ROL_USUARIO.VIS)) {
		response.sendRedirect(response.encodeRedirectURL("visitante.jsp"));
		return;
	}	
	//Incluir el menu de acuerdo al rol
	request.setAttribute("rolActual", canaima.getUsuarioActual().getRol());	
	pageContext.include("/WEB-INF/jsp/GeneradorMenu.jsp", true);
%>

<%!
	public enum ESTADO {
		LISTADO,	
		POR_GUARDAR
	} 
%>
<%
	Usuario usuarioActual = canaima.getUsuarioActual();	
	ESTADO actual = ESTADO.LISTADO;	
	
	if (request.getParameter("estado") != null) {
		actual = ESTADO.valueOf(request.getParameter("estado"));
	}
	Connection con = canaima.solicitarConexion();
	if (actual.equals(ESTADO.POR_GUARDAR)) {
			
		int donatario = Integer.parseInt(request.getParameter("donatario"));
		int docente = Integer.parseInt(request.getParameter("docente"));
		CAJA_TIPO tipo = CAJA_TIPO.valueOf(request.getParameter("tipo"));		
		Caja caja = new Caja();
		
		if (tipo.equals(CAJA_TIPO.DON)) {
			canaima.buscarPorID(donatario, caja);	
		} else if ( tipo.equals(CAJA_TIPO.DOC)) { 
			canaima.buscarPorID(docente, caja);
		}
		caja.setIncidencia(request.getParameter("incidencia"));
		caja.cerrarCaja(con);
	}
		
	int ultimaCajDon = Caja.getUltimaCajaRegistrada(con, usuarioActual, CAJA_TIPO.DON);
	int ultimaCajDoc = Caja.getUltimaCajaRegistrada(con, usuarioActual, CAJA_TIPO.DOC);
	canaima.liberarConexion(con);
%> 
	   <jsp:include page="/WEB-INF/jsp/GeneradorMenuAnalista.jsp" flush="true"></jsp:include>
	   <div id="Middle" align="center">
	        <div id="Page">
	            <div id="Content">
	            	<div class="Part" >	            	
		            	<h2>Estad&iacute;sticas de Cerrar Caja</h2>
						&nbsp; 	            	
	            		<jsp:include page="/WEB-INF/jsp/GeneradorEstadisticas.jsp" flush="true"></jsp:include>
	            		&nbsp;	
	            		<div id = "estadisticas">
	            		<p>&nbsp;</p>
	            		<p>&nbsp;</p>	            		
	            		<form method="post">
		            		<table>
							<tr class="a">
								<td>Tipo de Caja a cerrar</td>
								<td>Describa el motivo del cierre manual</td>
								<td>Confirmar</td>
							</tr>
							<tr>								
								<td align="center">
									<select tabindex="1" name="tipo">
										<option value="<%= CAJA_TIPO.DON%>" selected="selected">Contratos Donatario</option>	
										<option value="<%= CAJA_TIPO.DOC%>">Contratos Docente</option>
									</select>
								</td>
								<td><input tabindex="2" name="incidencia" size="70" style="width: 600px; "></td>							
								<td align="center" colspan="2"">				            		
				            		<INPUT type="hidden" value="<%= ESTADO.POR_GUARDAR %>" name="estado">
				            		<INPUT type="hidden" value="<%= ultimaCajDon %>" name="donatario">
				            		<INPUT type="hidden" value="<%= ultimaCajDoc %>" name="docente">
			            			<INPUT tabindex="3" type="submit" value="Aceptar" name="aceptar" onclick="return validarCerrarCaja(form)"/>
			            	</td>
							</tr>
				     		</table>
				     	</form>   
			     	</div>
			     	&nbsp;
	           		</div>
					<p>&nbsp;</p>
				</div>
	    	</div>	
			<br>
			<br>
			<br>
			<br>
		</div>
		

