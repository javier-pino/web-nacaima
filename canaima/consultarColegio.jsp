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
		$().ready(function() {;
		
		$("#colegiotexto").autocomplete("autocompletar_colegio.jsp", {
				width: 460,
				height: 500,
				matchContains: true,
				max: 30,
				minChars: 2,
				multiple: false
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
				<h2>Consultar Colegios</h2>
				&nbsp; 
				<div id = "filtro">				
				<form method="post">
				<table align="left">
				
					<tr class="a">
						<td>ID Colegio</td>
						<td>Colegio</td>
					</tr>				
					<tr>
						<td><input size="28" maxlength="10" name = "idcolegioo" onKeypress="validarNumero(this)"></td>
						<td>
				            <input type="text" size="80" name="colegiotexto" id="colegiotexto" />
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
					</tr>
					<tr>
						<td>			
						<SELECT tabindex="1" name="idestado" title="estado" style="width: 250px;" onchange="javascript:mostrarMunicipios(this.value);">
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
						<SELECT tabindex="2" name="idmunicipio" title="municipio" style="width: 250px;" >
							<option value="0">--Seleccione--</option>
						</SELECT>
					</td>
					<td id= "parroquias">
						<SELECT tabindex="3" name="idparroquia" title="parroquia" style="width: 250px;" >
							<option value="0">--Seleccione--</option>
						</SELECT>
					</td>
					</tr>
					<tr><td colspan="4" style="height: 8px; "></td></tr>
					<tr align="center">
					
						<td colspan="7"><input value = "Aceptar" name = "Aceptar" style="width: 80px; height: 30px" type="submit" onclick="return validarValoresColegio(form)"></td>
					
					</tr>
				
				</table>
				</form>
				</div>
				<%if (request.getParameter("idestado") != null) {%>
				&nbsp;
				<script type="text/javascript">
				$(document).ready(function() {
					$("a.colegio_link").fancybox({
						'transitionIn'	:	'elastic',
						'transitionOut'	:	'elastic',
						'speedIn'		:	200, 
						'speedOut'		:	200, 
						'overlayShow'	:	false,
						'autoDimensions':	false,
						'width'			:	830,
						'height'		:	320,
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
						<td class = "largo">Nombre del Colegio</td>
						<td class = "largo">Estado</td>
						<td class = "largo">Municipio</td>
						<td class = "largo">Parroquia</td>
						<td class = "largo">Direccion</td>
					</tr>
		
<%		
		try { 
			con = canaima.solicitarConexion();		
			
			int idestado =  request.getParameter("idestado") != null && !(request.getParameter("idestado").equals("")) ? Integer.parseInt(request.getParameter("idestado")) : 0;
			int idMunicip = request.getParameter("idmunicipio") != null && !(request.getParameter("idmunicipio").equals("")) ?	Integer.parseInt(request.getParameter("idmunicipio")) : 0;
			int idParroquia = request.getParameter("idparroquia") != null && !(request.getParameter("idparroquia").equals("")) ?	Integer.parseInt(request.getParameter("idparroquia")) : 0;	
			int idColegio = request.getParameter("idcolegio") != null && !(request.getParameter("idcolegio").equals("")) ?	Integer.parseInt(request.getParameter("idcolegio")) : 0;	
			int idColegioo = request.getParameter("idcolegioo") != null && !(request.getParameter("idcolegioo").equals("")) ?	Integer.parseInt(request.getParameter("idcolegioo")) : 0;	
			Iterator<Colegio> colegios = Colegio.listarColegios(
				con,
				idestado,
				idMunicip,
				idParroquia,
				idColegio,
				idColegioo			
			).iterator();
			
			Colegio colegio = null;
			Estado estadoBuscado = new Estado();
			Municipio municipioBuscado = new Municipio();
			Parroquia parroquiaBuscado = new Parroquia();
			int i = 0;
						
			while (colegios.hasNext()) {				
				colegio = colegios.next();				
				canaima.buscarPorID(colegio.getIdestado(), estadoBuscado);
				canaima.buscarPorID(colegio.getIdmunicipio(), municipioBuscado);
				canaima.buscarPorID(colegio.getIdparroquia(), parroquiaBuscado);				
			%>
				<tr class = "largo">
					<td class = "largo"><%=aFancyBox(response,"" + colegio.getID(), colegio.getID())%></td>
					<td class = "largo"><%=aFancyBox(response, colegio.getNombre(), colegio.getID())%></td>
					<td class = "largo"><%=(colegio.getIdestado() > 0 ? (aFancyBox(response, estadoBuscado.getNombre(), colegio.getID())) : "") %></td>				
					<td class = "largo"><%=(colegio.getIdmunicipio() > 0 ? (aFancyBox(response, municipioBuscado.getNombre(), colegio.getID())) : "") %></td>
					<td class = "largo"><%=(colegio.getIdparroquia() > 0 ? (aFancyBox(response, parroquiaBuscado.getNombre(), colegio.getID())) : "") %></td>				
					<td class = "largo"><%=(colegio.getDireccion() != null ? (aFancyBox(response,colegio.getDireccion(), colegio.getID())) : "")%></td>
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
			"<a href = \"" + response.encodeURL("editarColegio.jsp?idcolegio=" + id) 
				+ 	"\" class = \"colegio_link\">" + texto +"</a>"
			;
		return resultado;
	} 
%>