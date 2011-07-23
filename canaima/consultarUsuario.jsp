<%@page import="enums.ROL_USUARIO"%>
<%@page import="java.util.*" %>
<%@page import="beans.*"%>
<%@page import="java.sql.Connection"%>


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
	<jsp:include page="/WEB-INF/jsp/GeneradorMenuAdministrador.jsp"></jsp:include>
	    <div id="Middle">
	        <div id="Page">
	            <div id="Content">            
	            	<div class="Part" >
					<h2>Consultar Usuarios</h2>
				
				&nbsp;
				<script type="text/javascript">
				$(document).ready(function() {
					$("a.usuario_link").fancybox({
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
				<div id = "scrollInf">
				<table border="0">
					<tr align="center">
						<td colspan="12" class = "a">USUARIOS ACTUALES DEL SISTEMA</td>
					</tr>	
					<tr class = "w" align="center">						
						<td class = "extralargo">Usuario</td>												
						<td class = "extralargo">Nombre</td>
						<td class = "extralargo">Rol</td>
						<td class = "extralargo">Est&aacute; Activo</td>						
					</tr>		
<%		
		Connection con = null;
		try { 
			con = canaima.solicitarConexion();					
			Iterator<Usuario> usuarios = Usuario.listarUsuarios(con).iterator();
			Usuario usuario = null;		
			while (usuarios.hasNext()) {				
				usuario = usuarios.next();				
								
			%>
			<tr align="left">				
				<td class = "extralargo"><%=aFancyBox(response, usuario.getUsuario(), usuario.getID())%></td>
				<td class = "largo"><%=usuario.getNombre().toUpperCase()%></td>									
				<td class = "largo"><%=ROL_USUARIO.mostrar(usuario.getRol()).toUpperCase()%> </td>
				<td class = "largo"><%=(usuario.isActivo()? "S&Iacute;" : "NO")%></td>
			</tr>
			<%		
			}
			%>
		</table>
		</div>
		&nbsp;	
<%
		} catch (Exception exc) {	
			exc.printStackTrace();
			request.setAttribute("excepcion", exc);
			pageContext.include("/WEB-INF/jsp/GeneradorMensaje.jsp", true);
		} finally {
			canaima.getPoolConexiones().cerrarConexion(con);
		}	
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

<%!
	public String aFancyBox (HttpServletResponse response, String texto, int id) {
		String resultado = 			
			"<a href = \"" + response.encodeURL("editarUsuario.jsp?idUsuario=" + id) 
				+ 	"\" class = \"usuario_link\">" + texto +"</a>"
			;
		return resultado;
	} 
%>