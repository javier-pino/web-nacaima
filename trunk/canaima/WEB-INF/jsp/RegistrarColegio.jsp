<%@page import="java.sql.Connection"%>
<%@page import="aplicacion.ModeloCanaima"%>
<%@page import="java.sql.SQLException"%>
<%@page import="aplicacion.ExcepcionRoles"%>
<%@page import="aplicacion.ExcepcionValidaciones"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="beans.Colegio"%>
<%@page import="java.util.*" %>
<%@page import="beans.Estado"%>
<%@page import="enums.NACIONALIDAD"%>
<%@page import="beans.Municipio"%>
<%@page import="beans.Parroquia"%>

<%@include file="/WEB-INF/jsp/IniciarModelo.jsp"%>


<%!
	public enum ESTADO {
		LISTADO,	
		POR_GUARDAR
	} 
%>
<%
	ESTADO actual = ESTADO.LISTADO;
	if (request.getParameter("estado") != null) {
		actual = ESTADO.valueOf(request.getParameter("estado"));
	}		
	if (actual.equals(ESTADO.POR_GUARDAR)) {
		try {
%> 

			<jsp:useBean id="colegio" class = "beans.Colegio" scope="request">
				<jsp:setProperty property="*" name = "colegio"/> </jsp:useBean>
<% 					
			
			//Aqui se valida si no tiene el mismo nombre y cedula
			Connection con = canaima.solicitarConexion();
			colegio.validarColegioUnico(con);			
			canaima.liberarConexion(con);


			colegio.setIdCreadoPor(canaima.getUsuarioActual().getID());						
		
			canaima.guardar(colegio);					
			
						
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
<h2>Registrar</h2>
&nbsp;  
<div align="left" id="scroll1">
<form name="lista" action="registrarColegio.jsp" method="post">
<table id="fila_direccion">
	<tr class="a">
		<td>Estado</td>
		<td>Municipio</td>
		<td>Parroquia</td>
	</tr>	
	<tr>
		<td>			
			<SELECT tabindex="1" name="idestado" title="estado" style="width: 300px;"  onchange="javascript:mostrarMunicipios(this.value);">
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
			<SELECT tabindex="2" id="idmunicipio" name="idmunicipio" title="municipio" style="width: 300px;" onchange="javascript:mostrarParroquias(this.value);">		
				<%out.write("<option value=\"" + 0 + "\">--Seleccione--</option>");%>
			</SELECT>
		</td>
		<td id= "parroquias">
			<SELECT tabindex="3" name="idparroquia" title="parroquia" style="width: 300px;" >	
				<%out.write("<option value=\"" + 0 + "\">--Seleccione--</option>");%>
			</SELECT>
		</td>
	</tr>
</table>
<br>
<table id="fila_colegio" >
	
	<tr class="a">
		<td>Nombre</td>
		<td>Codigo Dea</td>
	</tr>
	<tr>
		<td>
			<input tabindex="4" name="nombre" size="80" value="">
		</td>
		<td class="b">
			<input tabindex="5" name="codigo_dea" size="40">
		</td>
	</tr>
</table>
<br>
<table id="fila_direccion2">		
	<tr class="a"> 
		<td align="center">Direccion</td>
		<td></td>
	</tr>
	<tr>	
		<td>
			<input tabindex="6" name="direccion" size="100" maxlength="255" value="">
		</td>
		<td>
			<INPUT type="hidden" value="<%= ESTADO.POR_GUARDAR %>" name="estado">
			<INPUT tabindex="7" type="submit" value="Aceptar" name="aceptar" style="width: 80px; height: 30px">
		</td>
	</tr>
</table>
</form>
</div>
<br>
<br>
<div align="left" id="consultaColegio">
<table id="fila_consulta">
	<tr>
		<td class="a" colspan="12" >&Uacute;LTIMO 10 COLEGIOS REGISTRADOS</td>
	</tr>
	<tr class="w" align="center">
		<td class="extralargo">ID Colegio</td>
		<td class="extralargo">Nombre de Usuario</td>
		<td class="extralargo">Código DEA</td>
		<td class="extralargo">direccion</td>			
	</tr>
<% 		
	 con = canaima.solicitarConexion();
	ArrayList<Colegio> ultimosColegios = Colegio.ultimosColegios(con);	
	Colegio colegio = new Colegio();
	canaima.liberarConexion(con);
	
	for (int i = 0; i < ultimosColegios.size(); i++)
	{
		colegio = ultimosColegios.get(i);
%>		
	<tr class = "largoColegio">
		<td class = "largoColegio"><%=colegio.getID()%> </td>
		<td class = "largoColegio"><%=colegio.getNombre()%> </td>
		<td class = "largoColegio"><%=colegio.getCodigo_dea()%> </td>
		<td class = "largoColegio"><%=(colegio.getDireccion() != null) ? colegio.getDireccion() : ""%> </td>
	</tr>
	<% 
	}
	%>
</table>
</div>
&nbsp; 
</div>