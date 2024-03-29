<%@page import="enums.ROL_USUARIO"%>
<%@page import="java.util.*" %>
<%@page import="beans.*"%>
<%@page import="enums.NACIONALIDAD"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.sql.Connection"%>

<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<!-- Iniciar Modelo -->
<%@include file="/WEB-INF/jsp/IniciarModelo.jsp"%>

<!-- Incluir la cabecera -->
<%@include file="/WEB-INF/jsp/GeneradorCabecera.jsp"%>

<script type='text/javascript' src='js/jquery.autocomplete.js'></script>
<link rel="stylesheet" type="text/css" href="style/jquery.autocomplete.css" />

<script type="text/javascript">
	$().ready(function() {		
		$("#colegiotexto").autocomplete("autocompletar_colegio.jsp", {
			extraParams : {
				idestado : function() {
					return $("#idestado").val();
				},
				idmunicipio : function() {
					return $("#idmunicipio").val();
				},
				idparroquia : function() {
					return $("#idparroquia").val();
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
	//Verificamos roles, sino mandamos a su p�gina merecida
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
<jsp:include page="/WEB-INF/jsp/GeneradorMenuAnalista.jsp" flush="true"></jsp:include>
<div id="Middle">
       <div id="Page">
           <div id="Content">
           	 <div class="Part" >
				<h2>Consultar Docentes</h2>
				&nbsp; 
				<div id = "filtro">				
				<form method="post">
				<table align="left">
				
					<tr class="a">
						<td>ID Docente</td>
						<td>Nombre</td>
						<td>C&eacute;dula</td>
						<td>Colegio</td>
					</tr>				
					<tr>
						<td><input size="28" maxlength="10" name = "iddocente" onKeypress="validarNumero(this)"></td>
						<td><input size="28" name = "nombre" onkeypress="validarLetras(this)"></td>
						<td><input size="20" maxlength="10" name = "cedula" onKeypress="validarNumero(this)"></td>
						<td>
				            <input type="text" size="46" name="colegiotexto" id="colegiotexto" />
				      		<input type="hidden" name="idcolegio" id="idcolegio" />
	  			    	</td>
					</tr>
					<tr><td colspan="4" style="height: 12px; "></td></tr>
					</table>
					<table align="left">
					<tr class="a">
						<td>Estado</td>
						<td>Municipio</td>
						<td>Parroquias</td>
						<td>Ciudad</td>
					</tr>
					<tr>
						<td>			
						<SELECT tabindex="1" id="idestado" name="idestado" title="estado" style="width: 150px;" onchange="javascript:mostrarMunicipios(this.value);">
						<%
							int idEstado;
							String nombreEstado = null;
							Estado estado = new Estado();
							Connection con = canaima.solicitarConexion();				
							ArrayList<Estado> estados = Estado.listarEstados(con);
							canaima.liberarConexion(con);
							out.write("<option value=\"" + 0 + "\">--Seleccione--</option>");
							for (int i=0; i < estados.size(); i++) {
								out.write("<option value=\"" + estados.get(i).getID() + "\" >" + estados.get(i).getNombre()  + "</option>");
				   			}
			        	%>
						</SELECT>
					</td>
					<td id= "municipios">
						<SELECT tabindex="2" id="idmunicipio" name="idmunicipio" title="municipio" style="width: 150px;" >
							<option value="0">--Seleccione--</option>
						</SELECT>
					</td>
					<td id= "parroquias">
						<SELECT tabindex="3" id="idparroquia" name="idparroquia" title="parroquia" style="width: 150px;" >
							<option value="0">--Seleccione--</option>
						</SELECT>
					</td>
					<td><input size="30" name = "ciudad"></td>
					</tr>
					<tr><td colspan="4" style="height: 8px; "></td></tr>
					<tr align="center">					
						<td colspan="7" align="center">
							<input value = "Aceptar" name = "Aceptar" style="width: 80px; height: 30px" type="submit" onclick="return validarValoresDocente(form)">
							<input type="button" value="Limpiar Colegio" name="limpiar" style="width: 100px; height: 30px" onclick="limpiarColegio(form)">
						</td>
						
					</tr>
				
				</table>
				</form>
				</div>
				<%if (request.getParameter("idestado") != null) {%>
				&nbsp;
				<script type="text/javascript">
				$(document).ready(function() {
					$("a.docente_link").fancybox({
						'transitionIn'	:	'elastic',
						'transitionOut'	:	'elastic',
						'speedIn'		:	200, 
						'speedOut'		:	200, 
						'overlayShow'	:	false,
						'autoDimensions':	false,
						'width'			:	820,
						'height'		:	480,
						'type'			:	'iframe'			
					});					
				});
				</script>
				<div id = "busqueda">
				<table border="0">
					<tr align="center">
						<td colspan="12" class = "a">RESULTADO DE B&Uacute;SQUEDA</td>
					</tr>
					<tr class = "w" align="center">
						<td class = "largo">ID</td>
						<td class = "largo">Nombre</td>
						<td class = "largo">C&eacute;dula</td>
						<td class = "largo">Estado</td>
						<td class = "largo">Municipio</td>
						<td class = "largo">Ciudad</td>
						<td class = "largo">Colegio</td>
					</tr>
		
<%		
		try { 
			con = canaima.solicitarConexion();		
			
			int idestado =  request.getParameter("idestado") != null && !(request.getParameter("idestado").equals("")) ? Integer.parseInt(request.getParameter("idestado")) : 0;
			int idMunicip = request.getParameter("idmunicipio") != null && !(request.getParameter("idmunicipio").equals("")) ?	Integer.parseInt(request.getParameter("idmunicipio")) : 0;
			int idParroquia = request.getParameter("idparroquia") != null && !(request.getParameter("idparroquia").equals("")) ?	Integer.parseInt(request.getParameter("idparroquia")) : 0;	
			int idColegio = request.getParameter("idcolegio") != null && !(request.getParameter("idcolegio").equals("")) ?	Integer.parseInt(request.getParameter("idcolegio")) : 0;			
			int idDocente = request.getParameter("iddocente") != null && !(request.getParameter("iddocente").equals("")) ?	Integer.parseInt(request.getParameter("iddocente")) : 0;			
			Iterator<Docente> docentes = Docente.listarDocentes(
				con,
				idestado,
				idMunicip,
				request.getParameter("ciudad"),			
				request.getParameter("nombre"),
				request.getParameter("cedula"),
				idDocente,
				idColegio,
				idParroquia
			).iterator();
			Docente docente = null;
			Estado estadoBuscado = new Estado();
			Municipio municipioBuscado = new Municipio();
			Colegio colegioBuscado = new Colegio();
			int i = 0;
						
			while (docentes.hasNext()) {				
				docente = docentes.next();				
				canaima.buscarPorID(docente.getIdestado(), estadoBuscado);
				canaima.buscarPorID(docente.getIdmunicipio(), municipioBuscado);
				canaima.buscarPorID(docente.getIdcolegio(), colegioBuscado);
			%>
				<tr class = "largo">
				<td class = "largo"><%=aFancyBox(response,"" + docente.getID(), docente.getID())%></td>
				<td class = "largo"><%=aFancyBox(response, docente.getNombre(), docente.getID())%></td>				
				<%
					if (docente.getCedula() != null && 
							!docente.getCedula().isEmpty()) {		
				%>		
				<td class = "largo"><%=aFancyBox(response, docente.getNacionalidad() + "-" +
						docente.getCedula(), docente.getID())%> </td>
				<%
					} else {
				%>		
				<td class = "largo"></td>
				<% } %>				
				<td class = "largo"><%=(docente.getIdestado() > 0 ? (aFancyBox(response, estadoBuscado.getNombre(), docente.getID())) : "") %></td>				
				<td class = "largo"><%=(docente.getIdmunicipio() > 0 ? (aFancyBox(response, municipioBuscado.getNombre(), docente.getID())) : "") %></td>				
				<td class = "largo"><%=(docente.getCiudad() != null ? (aFancyBox(response,docente.getCiudad(), docente.getID())) : "")%></td>
				<td class = "largo"><%=(docente.getIdcolegio() > 0 ? (aFancyBox(response,colegioBuscado.getNombre(), docente.getID())) : "")%></td>				
			</tr>
			<%		
			}
			%>
		</table>
		</div>	
<%
		} catch (Exception exc) {	
			exc.printStackTrace();
			request.setAttribute("excepcion", exc);
			pageContext.include("/WEB-INF/jsp/GeneradorMensaje.jsp", true);
		} finally {
			canaima.liberarConexion(con);
		}
	}	
%>			
		</div>
		<p>&nbsp;</p>
	</div>

<%!
	public String aFancyBox (HttpServletResponse response, String texto, int id) {
		String resultado = 			
			"<a href = \"" + response.encodeURL("editarDocente.jsp?iddocente=" + id) 
				+ 	"\" class = \"docente_link\">" + texto +"</a>"
			;
		return resultado;
	} 
%>