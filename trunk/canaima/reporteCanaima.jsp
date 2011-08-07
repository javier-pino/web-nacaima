<%@page import="beans.Estado"%>
<%@page import="beans.Donatario"%>
<%@page import="java.sql.Date"%>
<%@page import="java.util.ArrayList"%>
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
<jsp:include page="/WEB-INF/jsp/GeneradorMenuVisitante.jsp" flush="true"></jsp:include>
<div id="Middle">
	<div id="Page">
		<div id="Content">			
			<div class="Part">
				<h2>Reporte de Canaima</h2>							
				&nbsp; 
				<div id = "estadisticas">				
				<form method="post">
				<table align="left"">				
					<tr class="a">
						<td>Estado</td>
						<td>Código DEA</td>
						<td></td>											
					</tr>				
					<tr>						
						<td>
							<SELECT tabindex="1" name="idestado" title="estado" onchange="javascript:mostrarMunicipios(this.value);">
							<%
								int idEstado;
								String nombreEstado = null;
								Estado estado = new Estado();
								Connection con = canaima.solicitarConexion();				
								ArrayList<Estado> estados = Estado.listarEstados(con);
								canaima.liberarConexion(con);
								out.write("<option value=\"" + -1 + "\">--TODOS LOS ESTADOS--</option>");
								out.write("<option value=\"" + 0 + "\">--SIN ESTADO ESPECIFICADO--</option>");
								for (int i=0; i < estados.size(); i++) {									
									out.write("<option value=\"" + estados.get(i).getID() + "\">" + estados.get(i).getNombre()+ "</option>");								
					   			}
				        	%>
							</SELECT>
						</td>					
						<td>
							<input tabindex="2" size="20" name="coddea"	maxlength="255" value="TODOS">
						</td>						
						<td>
							<input type="hidden" name = "estado" value = "<%=ESTADO.BUSCAR%>">							
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
			pageContext.include("/WEB-INF/jsp/GeneradorDesempenoCanaima.jsp", true);
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