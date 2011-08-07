<%@page import="java.sql.Connection"%>
<%@page import="aplicacion.ModeloCanaima"%>
<%@page import="java.sql.SQLException"%>
<%@page import="aplicacion.ExcepcionRoles"%>
<%@page import="aplicacion.ExcepcionValidaciones"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="beans.Donatario"%>
<%@page import="java.util.*" %>
<%@page import="beans.Estado"%>
<%@page import="enums.NACIONALIDAD"%>
<%@page import="beans.Municipio"%>
<%@page import="enums.ROL_USUARIO"%>

<%@include file="/WEB-INF/jsp/IniciarModelo.jsp"%> 
<%!
	public enum ESTADO {	
		POR_GUARDAR,
		INICIAL
	} 
%>

<%
	ESTADO actual = ESTADO.INICIAL;
	if (request.getParameter("estado") != null) {
		actual = ESTADO.valueOf(request.getParameter("estado"));
	}		
	if (actual.equals(ESTADO.POR_GUARDAR)) {
		try {
			Usuario usuario = new Usuario();			
			if (request.getParameter("activo") != null && 
					request.getParameter("activo").equals("true"))
				usuario.setActivo(true);	
			else 
				usuario.setActivo(false);										
			usuario.setRol(ROL_USUARIO.valueOf(request.getParameter("rol")));
			usuario.setUsuario(request.getParameter("usuario"));
			usuario.setNombre(request.getParameter("nombre"));
			usuario.setContrasena(request.getParameter("usuario"));
			canaima.guardar(usuario);					
		} catch (ExcepcionValidaciones val) {
			request.setAttribute("validaciones", val.getValidacionesIncumplidas());
			pageContext.include("/WEB-INF/jsp/GeneradorMensaje.jsp", true);					
		} catch (Exception exc) {	
			exc.printStackTrace();		
			request.setAttribute("excepcion", exc);
			pageContext.include("/WEB-INF/jsp/GeneradorMensaje.jsp", true);
		}
	}
%>
<div class="Part" >
<h2>Registrar Usuario</h2>
&nbsp;  
<div align="left" id="scroll">
<form name="lista" action="registrarUsuario.jsp" method="post" >
<table id="fila_colegio">		
	<tr class="a"> 
		<td>Usuario (Login)</td>
		<td>Nombre de Usuario</td>
		<td>Rol</td>
		<td>Estado</td>		
	</tr>
	<tr>
		<td><input tabindex="1" size="20" name="usuario" maxlength="10" ></td>
		<td><input tabindex="2" size="40" name="nombre" maxlength="255"></td>		
		<td>
			<select tabindex="3" name="rol" >
				<option value ="<%= ROL_USUARIO.VIS %>"> VISITANTE </option>
				<option value ="<%= ROL_USUARIO.ANA %>"> ANALISTA </option>
				<option value ="<%= ROL_USUARIO.ADM %>"> ADMINISTRADOR </option>
			</select>
		</td>
		<td>
			<select name="activo" tabindex="4">
					<option value ="<%= true %>"> ACTIVO </option>
					<option value ="<%= false %>"> INACTIVO </option>
			</select>
		</td>				
	</tr>
	<tr>
		<td align="center" colspan="4">
		<INPUT type="hidden" value="<%= ESTADO.POR_GUARDAR %>" name="estado">
		<INPUT tabindex="5" type="submit" value="Aceptar" onclick="return validarUsuario(form)">
		</td>
	</tr>
</table>
</form>
</div>
<br>
<div align="left" id="scroll">
<table id="fila_donatario">
	<tr>
		<td class="a" colspan="12" >&Uacute;LTIMO USUARIO REGISTRADO</td>
	</tr>
	<tr class="w" align="center">
		<td class="extralargo">Usuario (Login)</td>
		<td class="extralargo">Nombre de Usuario</td>
		<td class="extralargo">Rol</td>
		<td class="extralargo">Estado</td>			
	</tr>
<% 		
	Connection con = canaima.solicitarConexion();
	Usuario usuario = Usuario.ultimoRegistrado(con);	
	canaima.liberarConexion(con);
%>
	<tr class = "largo">
		<td class = "largo"><%=usuario.getUsuario()%> </td>
		<td class = "largo"><%=usuario.getNombre()%> </td>
		<td class = "largo"><%=ROL_USUARIO.mostrar(usuario.getRol()).toUpperCase()%> </td>
		<td class = "largo"><%=usuario.isActivo() ? "ACTIVO" : "INACTIVO"%> </td>
	</tr>
</table>
</div>
&nbsp;
</div>
