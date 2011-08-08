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
	if (canaima.getUsuarioActual() == null || canaima.getUsuarioActual().getRol().equals(ROL_USUARIO.VIS)) {
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
		POR_GUARDAR
	} 
%>
<%
	ESTADO actual = ESTADO.LISTADO;
	if (request.getParameter("estado") != null) {
		actual = ESTADO.valueOf(request.getParameter("estado"));
	}		
	if (actual.equals(ESTADO.POR_GUARDAR)) {
		
		int idColegio = 0;
		if (request.getParameter("idcolegio")!=null)
			idColegio = Integer.parseInt(request.getParameter("idcolegio"));
	
		try {				
%> 			
			<jsp:useBean id= "colegio" class = "beans.Colegio" scope="request">
				<%				
					canaima.buscarPorID(idColegio, colegio);
					colegio.setNombre(request.getParameter("nombre"));
					colegio.setCodigo_dea(request.getParameter("codigo_dea"));
					
					colegio.setIdestado(Integer.valueOf(request.getParameter("idestado")));					  					
					colegio.setIdmunicipio(Integer.valueOf(request.getParameter("idmunicipio")));
					colegio.setIdparroquia(Integer.valueOf(request.getParameter("idparroquia")));
					
					colegio.setDireccion(request.getParameter("direccion"));
					
					canaima.actualizar(colegio);
					
					//Aqui se valida si no tiene el mismo nombre y cedula
					Connection con = canaima.solicitarConexion();
					colegio.validarColegioUnico(con);		
					canaima.liberarConexion(con);
					
					/*ArrayList<Colegio> recientes = canaima.getRecientes();
					for (int i = 0; i < recientes.size() ; i++) {
						if (recientes.get(i).getID() == donatario.getID()) {
							recientes.set(i, donatario);
							break;
						}
					}*/
				%>				
			</jsp:useBean>  
<% 						
		} catch (ExcepcionValidaciones val) {
			request.setAttribute("validaciones", val.getValidacionesIncumplidas());
			pageContext.include("/WEB-INF/jsp/GeneradorMensaje.jsp", true);					
		} catch (Exception exc) {					
			request.setAttribute("excepcion", exc);
			pageContext.include("/WEB-INF/jsp/GeneradorMensaje.jsp", true);
		} 
	}
%>
<body>
<br>
<div align="center" id="editar" class = "edicionColegio">
<form>
	<%  int idColegio = 0;
		if (request.getParameter("idcolegio")!=null)
			idColegio = Integer.parseInt(request.getParameter("idcolegio"));
		
		Colegio colegio = new Colegio(); 
        canaima.buscarPorID(idColegio, colegio);
    %>
    <br><br>
    <table border="1">

    	
    	<tr>
    		<td class = "a"> ID Colegio</td>
    		<td><%= idColegio%></td>
    	</tr>
    	<tr>
    		<td class = "a"> Nombre Colegio:</td>
    		<td><input tabindex="2" size="28" name = "nombre" value="<%= (colegio.getNombre() != null) ? colegio.getNombre() : ""%>" ></td>
    		<td class = "a"> Codigo DEA</td>
    		<td><input tabindex="2" size="28" name = "codigo_dea" value="<%= (colegio.getCodigo_dea() != null) ? colegio.getCodigo_dea() : ""%>" ></td> 
    	</tr>
       	<tr>
    		<td class = "a">Estado:</td>
    		<td><SELECT tabindex="7" name="idestado" title="estado" style="width: 200px;" onchange="javascript:mostrarMunicipios(this.value);">
			<%
				int idEstado;
				String nombreEstado = null;
				Estado estado = new Estado();
				Connection con = canaima.solicitarConexion();				
				ArrayList<Estado> estados = Estado.listarEstados(con);
				canaima.liberarConexion(con);
				out.write("<option value=\"" + 0 + "\">--Seleccione--</option>");
				for (int i=0; i < estados.size(); i++) {
					if (colegio.getIdestado() > 0 && colegio.getIdestado() == estados.get(i).getID())
						out.write("<option value=\"" + estados.get(i).getID() + "\" selected=\"selected\" >" + estados.get(i).getNombre()  + "</option>");
					else 
						out.write("<option value=\"" + estados.get(i).getID() + "\" >" + estados.get(i).getNombre()  + "</option>");
	   			}
        	%>
				</SELECT>
			</td>
    		<td class = "a">Municipio:</td>
    		<td id= "municipios"> 
    			<SELECT tabindex="8" name="idmunicipio" title="municipio" style="width: 200px;" onchange="javascript:mostrarParroquias(this.value);">
				<%					
					if (colegio.getIdestado() > 0) {
						con = canaima.solicitarConexion();				
						ArrayList<Municipio> municipios = Municipio.listarMunicipiosPorEstado(colegio.getIdestado(), con);
						canaima.liberarConexion(con);
						out.write("<option value=\"" + 0 + "\">--Seleccione--</option>");
						for (int i=0; i < municipios.size(); i++) {
							if (colegio.getIdmunicipio() > 0 && colegio.getIdmunicipio() == municipios.get(i).getID())
								out.write("<option value=\"" + municipios.get(i).getID() + "\" selected=\"selected\" >" + municipios.get(i).getNombre()  + "</option>");
							else 
								out.write("<option value=\"" + municipios.get(i).getID() + "\" >" + municipios.get(i).getNombre()  + "</option>");
			   			}		
					} else {
						out.write("<option value=\"" + 0 + "\">--Seleccione--</option>");
					}			
				%>			
				</SELECT>
			</td>
    	</tr>
    	<tr>
    		<td class = "a">Parroquia:</td>
    		<td id= "parroquias">
			<SELECT tabindex="3" name="idparroquia" title="parroquia" style="width: 200px;" >
			<%					
			if (colegio.getIdmunicipio() > 0) {
				con = canaima.solicitarConexion();
				ArrayList<Parroquia> parroquias = Parroquia.listarParroquiasPorMunicipios(colegio.getIdmunicipio(), con);
				canaima.liberarConexion(con);
				out.write("<option value=\"" + 0 + "\">--Seleccione--</option>");
				for (int i=0; i < parroquias.size(); i++) {
					if (colegio.getIdparroquia() > 0 && colegio.getIdparroquia() == parroquias.get(i).getID())
						out.write("<option value=\"" + parroquias.get(i).getID() + "\" selected=\"selected\" >" + parroquias.get(i).getNombre()  + "</option>");
					else 
						out.write("<option value=\"" + parroquias.get(i).getID() + "\" >" + parroquias.get(i).getNombre()  + "</option>");
	   			}		
			} else {
				out.write("<option value=\"" + 0 + "\">--Seleccione--</option>");
			}			
			%>			
			</SELECT>
			</td>
			<td class = "a">Dirección:</td>
    		<td><input tabindex="10" size="28" name = "direccion" value="<%= (colegio.getDireccion() != null) ? colegio.getDireccion() : ""%>"></td>
    	</tr>
    	<tr>
    		
    	</tr>
    	
    	<tr>
    		<td colspan="4" align="center">
    			<INPUT type="hidden" value="<%= ESTADO.POR_GUARDAR %>" name="estado">
    			<INPUT type="hidden" value="<%= idColegio%>" name="idcolegio">    			
    			<INPUT tabindex="20" type="submit" style="width: 140px; height: 30px" value="Aceptar Cambios"/ >
    			<INPUT tabindex="21" type="reset"  style="width: 140px; height: 30px" value="Eliminar Colegio" id= "botonEliminar" />
    		</td>    
    	<tr>	
    </table>
</form>		
</div>
<div align="center" id = "eliminar" class = "edicionColegio" style="display:none;">

	<br><br> 
	<form action="<%= "javascript:eliminarColegio(" + idColegio + ");"%>">
	
	<h1>¿Est&aacute; seguro que desea eliminar el Colegio?</h1>
	<br>
	<table border="1">
	   	<tr>
	   		<td class = "a"> ID Colegio</td>
	   		<td class = "extralargo"><%= idColegio %></td>
	   		
	   	</tr>
	   	<tr>
	   		<td class = "a"> Nombre Colegio:</td>
	   		<td class = "extralargo" ><%=(colegio.getNombre() != null) ? colegio.getNombre() : ""%></td>
	   		<td class = "a">Codigo DEA.</td>
	   		<td class = "extralargo"><%= (colegio.getCodigo_dea() != null) ? colegio.getCodigo_dea(): "" %></td>
	   	</tr>
	   	<tr>
		   	<td colspan="4" align="center">			   	
				<INPUT tabindex="1" type="reset" value="Cancelar" id = "botonCancelar"/>
				<INPUT tabindex="2" type="submit" value="Eliminar Colegio" />
		   	</td>	  
	   	</tr>    
	   </table>			
	</form>
</div>
<script>
	$('#botonEliminar').click(function() {
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