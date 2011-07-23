<%@page import="beans.*"%>
<%@page import="java.sql.Connection"%>
<%@page import = "java.util.ArrayList"%>
<%@page import="java.util.*" %>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"   pageEncoding="ISO-8859-1"%>
<%@page import="enums.ROL_USUARIO"%>
<%@page import="java.util.Enumeration"%>
<%@page import="enums.NACIONALIDAD"%>
<%@page import="aplicacion.ExcepcionValidaciones"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<!-- Iniciar Modelo -->
<%@include file="/WEB-INF/jsp/IniciarModelo.jsp"%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link href="estilos.css" rel="stylesheet" type="text/css">
<link rel="stylesheet" type="text/css" href="css.css" >
<script language="JavaScript" type="text/javascript" src="js/jquery-1.5.2.js"></script>
<script language="JavaScript" type="text/javascript" src="codigo.js"></script>
</head>

<%
	if (canaima.getUsuarioActual() == null ||
			!canaima.getUsuarioActual().getRol().equals(ROL_USUARIO.ADM)) {
	%>
	<jsp:include page="/WEB-INF/jsp/GeneradorMensaje.jsp">
		<jsp:param value="Acceso No Autorizado" name="titulo"/>
		<jsp:param value="No est&aacute autorizado a entrar en esta ventana con su perfil" name= "texto"/>		
		<jsp:param value="Cierre esta ventana y verifique si su sesión ha expirado" name= "texto"/>
	</jsp:include>	
	<% 	
	return;
}
%>

<%!
	public enum ESTADO {
		LISTADO,	
		POR_GUARDAR,
		POR_RESTAURAR
	} 
%>
<%
	ESTADO actual = ESTADO.LISTADO;
	if (request.getParameter("estado") != null) {
		actual = ESTADO.valueOf(request.getParameter("estado"));
	}		
	if (actual.equals(ESTADO.POR_GUARDAR)) {
		
		int idUsuario = 0;
		if (request.getParameter("idUsuario")!=null)
			idUsuario = Integer.parseInt(request.getParameter("idUsuario"));	
		try {				%> 			
			<jsp:useBean id= "usuario" class = "beans.Usuario" scope="request">
				<%				
					canaima.buscarPorID(idUsuario, usuario);
					if (request.getParameter("activo") != null && request.getParameter("activo").equals("true") )
						usuario.setActivo(true);	
					else 
						usuario.setActivo(false);										
					usuario.setRol(ROL_USUARIO.valueOf(request.getParameter("rol")));
					usuario.setUsuario(request.getParameter("usuario"));
					usuario.setNombre(request.getParameter("nombre"));
					canaima.actualizar(usuario);
				%>				
			</jsp:useBean>  
<% 						
		} catch (ExcepcionValidaciones val) {
			request.setAttribute("validaciones", val.getValidacionesIncumplidas());
			pageContext.include("/WEB-INF/jsp/GeneradorMensaje.jsp", true);					
		} catch (Exception exc) {					
			request.setAttribute("excepcion", exc);
			pageContext.include("/WEB-INF/jsp/GeneradorMensaje.jsp", true);
			exc.printStackTrace();
		} 
	} else if (actual.equals(ESTADO.POR_RESTAURAR)) {
		
		int idUsuario = 0;
		if (request.getParameter("idUsuario")!=null)
			idUsuario = Integer.parseInt(request.getParameter("idUsuario"));
		
		Usuario usuario = new Usuario(); 
        canaima.buscarPorID(idUsuario, usuario);        
        usuario.setContrasena(usuario.getUsuario());
        canaima.actualizar(usuario);
	%>
		<jsp:include page="/WEB-INF/jsp/GeneradorMensaje.jsp">
			<jsp:param value="Operaci&oacute;n realizada exitosamente" name="titulo"/>
			<jsp:param value="Se modific&oacute; la contrase&ntilde;a del usuario, por lo que ahora es igual a su login" name="texto"/>							
			<jsp:param value="&nbsp;Se aconseja indicarle al usuario que inicie sesi&oacute;n y la modifique" name= "texto"/>
		</jsp:include>				
<%
	return;
	}
	
	int idUsuario = 0;
	if (request.getParameter("idUsuario")!=null)
		idUsuario = Integer.parseInt(request.getParameter("idUsuario"));
	
	Usuario usuario = new Usuario(); 
       canaima.buscarPorID(idUsuario, usuario);
%>
<body>
<br>
<div align="center" id="editar" class = "edicion">
<form>
    <br><br>
    <table border="1">
    	<tr>
    		<td class = "a"> Usuario (Login):</td>
    		<td><input tabindex="2" size="10" name = "usuario" value="<%= (usuario.getUsuario() != null) ? usuario.getUsuario() : ""%>" ></td>
    		<td class = "a"> ID Usuario:</td>
    		<td><%= idUsuario %></td> 
    	</tr>
    	<tr>
    		<td class = "a">Rol:</td>
    		<td align="center">
    			<select name="rol" tabindex="3">
					<option value ="<%= ROL_USUARIO.VIS %>"
					<%=(usuario.getRol() == ROL_USUARIO.VIS ? "selected=\"selected\"" : "")%>> VISITANTE </option>
					<option value ="<%= ROL_USUARIO.ANA %>"
					<%=(usuario.getRol() == ROL_USUARIO.ANA ? "selected=\"selected\"" : "")%>> ANALISTA </option>
					<option value ="<%= ROL_USUARIO.ADM %>"
					<%=(usuario.getRol() == ROL_USUARIO.ADM ? "selected=\"selected\"" : "")%>> ADMINISTRADOR </option>
				</select>
			</td>			
			<td class = "a">Estado:</td>
			<td> 
				<select name="activo" tabindex="4">
					<option value ="<%= true %>"
					<%=(usuario.isActivo() ? "selected=\"selected\"" : "")%>> ACTIVO </option>
					<option value ="<%= false %>"
					<%=(!usuario.isActivo() ? "selected=\"selected\"" : "")%>> INACTIVO </option>
				</select>
			</td>
		</tr>
		<tr>
			<td class = "a">Nombre:</td>
    		<td colspan="4"> <input tabindex="5" name="nombre" size="60" maxlength="255" value="<%= (usuario.getNombre() != null) ? usuario.getNombre() : ""%>"></td>
    	</tr>
    	<tr>    	
    		<td colspan="4" align="center">
    			<INPUT type="hidden" value="<%= ESTADO.POR_GUARDAR %>" name="estado">
    			<INPUT type="hidden" value="<%= idUsuario %>" name="idUsuario">    			
    			<INPUT tabindex="6" type="submit" value="Aceptar Cambios"/>
    			<INPUT tabindex="7" type="reset"  value="Restaurar Contrase&ntilde;a" id= "botonRestaurar" />    			
    		</td>
    	</tr>
    </table>
</form>		
</div>

<div align="center" id = "eliminar" class = "edicion" style="display:none;">
	<h1>¿Est&aacute; seguro que desea restaurar la contrase&ntilde;a del usuario?</h1>	
	Esto ocasionar&aacute; que se modifique la contrase&ntilde;a del usuario, y sea igual a su login.
	<br><br>
	<form>
	&nbsp; 
	<table border="1">
    	<tr>
    		<td class = "a"> Usuario (Login):</td>
    		<td><%= (usuario.getUsuario() != null) ? usuario.getUsuario() : ""%></td>
    		<td class = "a"> ID Usuario:</td>
    		<td><%= idUsuario %></td> 
    	</tr>
    	<tr>
    		<td class = "a">Rol:</td>
    		<td align="center"><%= ROL_USUARIO.mostrar(usuario.getRol())%></td>			
			<td class = "a">Estado:</td>
			<td> <%=(usuario.isActivo() ? "ACTIVO" : "INACTIVO")%> </td>
		</tr>
		<tr>
			<td class = "a">Nombre:</td>
    		<td colspan="4"><%= (usuario.getNombre() != null) ? usuario.getNombre() : ""%></td>
    	</tr>
    	<tr>    	
    		<td colspan="4" align="center">	
    			<INPUT type="hidden" value="<%= ESTADO.POR_RESTAURAR %>" name="estado">
    			<INPUT type="hidden" value="<%= idUsuario %>" name="idUsuario">	   	
				<INPUT tabindex="1" type="reset" value="Cancelar" id = "botonCancelar"/>
				<INPUT tabindex="2" type="submit" value="Confirmar Restauraci&oacute;n" />
		   	</td>	  
	   	</tr>    
	   </table>			
	</form>
</div>
<script>
	$('#botonRestaurar').click(function() {
	  $('#editar').hide('fast');	  
	  $('#eliminar').show('fast');
	});	
</script>
<script>
	$('#botonCancelar').click(function() {
	  $('#editar').show('fast');  
	  $('#eliminar').hide('fast');  
	});	
</script>


</body>
</html>