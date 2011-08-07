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
	Connection con = canaima.solicitarConexion();
	int ultimaCaj = Caja.getUltimaCajaRegistrada(con, usuarioActual);
	ESTADO actual = ESTADO.LISTADO;
	
	if (request.getParameter("estado") != null) {
		actual = ESTADO.valueOf(request.getParameter("estado"));
	}	

	if (actual.equals(ESTADO.POR_GUARDAR)) {
		
		Caja caja = new Caja();
		canaima.buscarPorID(ultimaCaj, caja);
		caja.setIncidencia(request.getParameter("incidencia"));
		caja.cerrarCaja(con);
		ultimaCaj = 0;
	}
	canaima.liberarConexion(con);
%> 
	   <jsp:include page="/WEB-INF/jsp/GeneradorMenuAnalista.jsp" flush="true"></jsp:include>
<form>	    
	    <div id="Middle" align="center">
	        <div id="Page">
	            <div id="Content">
	            	<div class="Part" >
	            		<jsp:include page="/WEB-INF/jsp/GeneradorEstadisticas.jsp" flush="true"></jsp:include>
	            		&nbsp;	            
	           		</div>	       
	           		    		 							
					<p>&nbsp;</p>
					<div>
					<table>
					<tr><td>Describa el motivo del cierre de la Caja Manual</td></tr>
					<tr><td><input name="incidencia" id="incidencia" size="70" style="width: 600px; "></td></tr>
	    			<tr>
	            		<td align="center">
		            		<h2>¿Est&aacute; seguro que desea Cerrar esta Caja?</h2>
		            		<INPUT type="hidden" value="<%= ESTADO.POR_GUARDAR %>" name="estado">
	            			<INPUT type="submit" value="Aceptar" name="aceptar" onclick="return validarCerrarCaja(<%=ultimaCaj%>,form.incidencia.value)"/>
	            		</td>
	            	</tr>
	     			</table>
	     			</div>
				</div>
	    	</div>	
			<br>
			<br>
			<br>
			<br>
		</div>
</form>		

