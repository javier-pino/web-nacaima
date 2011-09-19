<%@page import="beans.Estado"%>
<%@page import="beans.Donatario"%>
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

<script type='text/javascript' src='js/jquery.autocomplete.js'></script>
<link rel="stylesheet" type="text/css" href="style/jquery.autocomplete.css" />

<script type="text/javascript">
	$().ready(function() {		
		$("#colegio").autocomplete("autocompletar_colegio.jsp", {
			extraParams : {
				idestado : function() {
					var id = $("#idestado").val(); 
					if (id == "-1")						
						return 0;
					else if (id == "0")
						return "-1";
					else return id;
				},
				idmunicipio : function() {
					return 0;
				},
				idparroquia : function() {
					return 0;
				}
			},
			width : 460,			
			height : 500,
			max : 30,
			minChars : 2,
			matchSubset : false,
			cacheLength : 0
		});
	});
</script>
<%	
	Utilidades.eliminarArchivosTemporales(canaima.DIRECTORIO_TEMPORAL);		
%>  

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
				<div id="CanaimaFiltro" >				
				<form method="post">
				<table align="left"">				
					<tr class="a">
						<td>Estado</td>
						<td>Colegio</td>					
						<td></td>
						<td></td>															
					</tr>				
					<tr>						
						<td>
							<SELECT tabindex="1" id = "idestado" name="idestado" title="estado" onchange="javascript:mostrarMunicipios(this.value);">
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
							<input tabindex="2" type="text" size="71" name="colegiotexto" id="colegio" />
							<input type="hidden" name="idcolegio" id="idcolegio" value="0"/>
						</td>						
						<td>
							<input type="hidden" name = "estado" value = "<%=ESTADO.BUSCAR%>">
							<input value = "Aceptar" name = "Aceptar" type="submit">							
						</td>			
						<td><INPUT tabindex="21" type="button" value="Limpiar Colegio" name="limpiar" onclick="limpiarColegio(form)"></td>		
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
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
</div>