<%@page import="beans.Estado"%>
<%@page import="beans.Donatario"%>
<%@page import="java.sql.Date"%>
<%@page import="java.util.Calendar"%>
<%@page import="aplicacion.Utilidades"%>
<%@page import="enums.ROL_USUARIO"%>
<%@page import="java.sql.Connection"%>

<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>

<!-- Iniciar Modelo -->
<%@include file="/WEB-INF/jsp/IniciarModelo.jsp"%>

<!-- Incluir la cabecera -->
<%@include file="/WEB-INF/jsp/GeneradorCabecera.jsp"%>

<%!
	public enum ESTADO {
		INICIAL,
		BUSCAR
	}
%>

<%		
	if (canaima.getUsuarioActual() == null) {
		response.sendRedirect("login.jsp");
		return;
	} 
	//Incluir el menu de acuerdo al rol
	request.setAttribute("rolActual", canaima.getUsuarioActual().getRol());	
	pageContext.include("/WEB-INF/jsp/GeneradorMenu.jsp");
	
	ESTADO actual = ESTADO.INICIAL;
	if (request.getParameter("estado") != null) {
		actual = ESTADO.valueOf(request.getParameter("estado"));
	} 
%>
<jsp:include page="/WEB-INF/jsp/GeneradorMenuAnalista.jsp" flush="true"></jsp:include>
<div id="Middle">
	<div id="Page">
		<div id="Content">			
			<div class="Part">
				<h2>Reporte de Desempeño</h2>							
				&nbsp; 
				<div id="DesempeñoFiltro" >				
				<form method="post">
				<table align="left"">				
					<tr class="a">
						<td>Fecha Inicio</td>
						<td>Fecha Fin</td>
						<td></td>
											
					</tr>				
					<tr>
						<%
							Calendar calendario = Calendar.getInstance();
							Date fecha_hoy = new Date(calendario.getTimeInMillis());
							Connection con = canaima.solicitarConexion();							
							Donatario primer = Donatario.primerDonatarioRegistrado(con);							
							canaima.getPoolConexiones().cerrarConexion(con);
						%>
						<td>
							<input tabindex="1" size="20" name="fechaInicial" onclick="scwShow(this, event)"  
								value="<%= Utilidades.mostrarFecha(primer.getFecha_carga())%> ">
						</td>					
						<td>
							<input tabindex="1" size="20" name="fechaFinal" onclick="scwShow(this, event)"  
								value="<%= Utilidades.mostrarFecha(fecha_hoy)%> ">
						</td>						
						<td>
							<input type="hidden" name = "estado" value = "<%=ESTADO.BUSCAR%>">
							<input type="hidden" name = "inicial" value = "<%=Utilidades.mostrarFecha(primer.getFecha_carga())%>">
							<input type="hidden" name = "final" value = "<%=Utilidades.mostrarFecha(fecha_hoy)%>">
							<input value = "Aceptar" name = "Aceptar" type="submit">
						</td>					
					</tr>				
				</table>
				</form>
				&nbsp;				
				</div>				
				&nbsp;
	<%
		if (actual.equals(ESTADO.BUSCAR)) {
			pageContext.include("/WEB-INF/jsp/GeneradorDesempeno.jsp", true);
		}
	%>
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