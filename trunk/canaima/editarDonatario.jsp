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
		
		int idDonatario = 0;
		if (request.getParameter("iddonatario")!=null)
			idDonatario = Integer.parseInt(request.getParameter("iddonatario"));
	
		try {				
%> 			
			<jsp:useBean id= "donatario" class = "beans.Donatario" scope="request">
				<%				
					canaima.buscarPorID(idDonatario, donatario);
					donatario.setNombre(request.getParameter("nombre"));
					donatario.setPartidanacimiento(request.getParameter("partidanacimiento" ));
					donatario.setRepresentante_ci(request.getParameter("representante_ci"));
					donatario.setRepresentante_nombre(request.getParameter("representante_nombre" ));
					donatario.setRepresentante_tlf(request.getParameter("representante_tlf"));
					donatario.setIdestado(Integer.valueOf(request.getParameter("idestado")));					  					
					donatario.setIdmunicipio(Integer.valueOf(request.getParameter("idmunicipio")));
					donatario.setIdparroquia(Integer.valueOf(request.getParameter("idparroquia")));
					donatario.setCiudad(request.getParameter("ciudad"));
					donatario.setDireccion(request.getParameter("direccion"));
					donatario.setIdcolegio(Integer.valueOf(request.getParameter("idcolegio")));
						
					/* Se puede guardar asi pero se corre el riesgo de perder la data original
					donatario.setColegio("");
					donatario.setCodigo_dea("");
					*/
					donatario.setColegio(request.getParameter("colegio"));
					donatario.setCodigo_dea(request.getParameter("codigo_dea"));
					donatario.setAno_escolar(Integer.valueOf(request.getParameter("ano_escolar")));
					donatario.setGrado(Integer.valueOf(request.getParameter("grado")));
					donatario.setSeccion(request.getParameter("seccion"));
					donatario.setEquipo_serial(request.getParameter("equipo_serial"));
					donatario.setDirector_nombre(request.getParameter("director_nombre"));
					donatario.setProveedor(request.getParameter("proveedor"));
					donatario.setObservacion(request.getParameter("observacion"));
					donatario.setRepresentante_nac(request.getParameter("representante_nac"));
					if (donatario.getRepresentante_ci() == null || donatario.getRepresentante_ci().isEmpty())			
						donatario.setRepresentante_nac(null);
										
					canaima.actualizar(donatario);
					
					//Aqui se valida si no tiene el mismo nombre y cedula
					Connection con = canaima.solicitarConexion();
					donatario.validarCedulaRepNombreDonatario(con);			
					canaima.getPoolConexiones().cerrarConexion(con);
					
					ArrayList<Donatario> recientes = canaima.getRecientes();
					for (int i = 0; i < recientes.size() ; i++) {
						if (recientes.get(i).getID() == donatario.getID()) {
							recientes.set(i, donatario);
							break;
						}
					}
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
<div align="center" id="editar" class = "edicion">
<form>
	<%  int idDonatario = 0;
		if (request.getParameter("iddonatario")!=null)
			idDonatario = Integer.parseInt(request.getParameter("iddonatario"));
		
		Donatario donatario = new Donatario(); 
        canaima.buscarPorID(idDonatario, donatario);
    %>
    <br><br>
    <table border="1">

    	<tr>
    		<td class = "a"> Nombre Donatario:</td>
    		<td><input tabindex="2" size="28" name = "nombre" value="<%= (donatario.getNombre() != null) ? donatario.getNombre() : ""%>" ></td>
    		<td class = "a"> ID Donatario</td>
    		<td><%= idDonatario %></td> 
    	</tr>
    	<tr>
    		<td class = "a">Nacionalidad Rep.</td>
    		<td align="center"><select name="representante_nac" tabindex="3">
					<option value ="<%= NACIONALIDAD.V %>"
					<%=(donatario.getRepresentante_nac() == NACIONALIDAD.V ? "selected=\"selected\"" : "")%>> V </option>
					<option value ="<%= NACIONALIDAD.E %>"
					<%=(donatario.getRepresentante_nac() == NACIONALIDAD.E ? "selected=\"selected\"" : "")%>> E </option>
				</select>
			</td>
    		<td class = "a">Cédula:</td>
    		<td><input tabindex="4" maxlength="10" type="text" name="representante_ci" size="28" value="<%= (donatario.getRepresentante_ci() != null) ? donatario.getRepresentante_ci() : ""%>" onKeypress="validarNumero(this)"></td>
    	</tr>
    	<tr>
    		<td class = "a">Nombre Rep.</td>
    		<td><input tabindex="5" size="28" name = "representante_nombre" value="<%= (donatario.getRepresentante_nombre() != null) ? donatario.getRepresentante_nombre() : ""%>"></td>
    		<td class = "a">Teléfono:</td>
    		<td><input tabindex="6" maxlength="10" type="text" name="representante_tlf" size="28" value="<%= (donatario.getRepresentante_tlf() != null) ? donatario.getRepresentante_tlf() : ""%>" onKeypress="validarNumero(this)"/></td>
    	</tr>
    	<tr>
    		<td class = "a">Estado:</td>
    		<td><SELECT tabindex="7" name="idestado" title="estado" style="width: 150px;" onchange="javascript:mostrarMunicipios(this.value);">
			<%
				int idEstado;
				String nombreEstado = null;
				Estado estado = new Estado();
				Connection con = canaima.solicitarConexion();				
				ArrayList<Estado> estados = Estado.listarEstados(con);
				canaima.getPoolConexiones().cerrarConexion(con);
				out.write("<option value=\"" + 0 + "\">--Seleccione--</option>");
				for (int i=0; i < estados.size(); i++) {
					if (donatario.getIdestado() > 0 && donatario.getIdestado() == estados.get(i).getID())
						out.write("<option value=\"" + estados.get(i).getID() + "\" selected=\"selected\" >" + estados.get(i).getNombre()  + "</option>");
					else 
						out.write("<option value=\"" + estados.get(i).getID() + "\" >" + estados.get(i).getNombre()  + "</option>");
	   			}
        	%>
				</SELECT>
			</td>
    		<td class = "a">Municipio:</td>
    		<td id= "municipios"> 
    			<SELECT tabindex="8" name="idmunicipio" title="municipio" style="width: 150px;" onchange="javascript:mostrarParroquias(this.value);">
				<%					
					if (donatario.getIdestado() > 0) {
						con = canaima.solicitarConexion();				
						ArrayList<Municipio> municipios = Municipio.listarMunicipiosPorEstado(donatario.getIdestado(), con);
						canaima.getPoolConexiones().cerrarConexion(con);
						out.write("<option value=\"" + 0 + "\">--Seleccione--</option>");
						for (int i=0; i < municipios.size(); i++) {
							if (donatario.getIdmunicipio() > 0 && donatario.getIdmunicipio() == municipios.get(i).getID())
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
			<SELECT tabindex="3" name="idparroquia" title="parroquia" style="width: 150px;" >
			<%					
			if (donatario.getIdmunicipio() > 0) {
				con = canaima.solicitarConexion();
				ArrayList<Parroquia> parroquias = Parroquia.listarParroquiasPorMunicipios(donatario.getIdmunicipio(), con);
				canaima.getPoolConexiones().cerrarConexion(con);
				out.write("<option value=\"" + 0 + "\">--Seleccione--</option>");
				for (int i=0; i < parroquias.size(); i++) {
					if (donatario.getIdparroquia() > 0 && donatario.getIdparroquia() == parroquias.get(i).getID())
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
			<td class = "a">Ciudad:</td>
    		<td><input tabindex="9" size="28" name = "ciudad" value="<%= (donatario.getCiudad() != null) ? donatario.getCiudad() : ""%>"></td>
    	</tr>
    	<tr>
    		<td class = "a">Colegio N:</td> 		
    		<td>
 			
			<%					
			
			if (donatario.getIdcolegio() > 0) {
				
				Colegio cole = new Colegio();
				canaima.buscarPorID(donatario.getIdcolegio(), cole);
				
				out.write("<input tabindex=\"11\" size=\"28\" id=\"colegiotexto\" name=\"colegiotexto\" value=\"" + cole.getNombre() + "\">");
	    		out.write("<input type=\"hidden\" name=\"idcolegio\" id=\"idcolegio\" value=\"" + cole.getIdcolegio() + "\">");
				
			} else {
				out.write("<input tabindex=\"11\" size=\"28\" id=\"colegiotexto\" name=\"colegiotexto\" value=\"\">");
				out.write("<input type=\"hidden\" name=\"idcolegio\" id=\"idcolegio\">");
			}			
			%>			
    		
    		</td>
    		<td class = "a">Dirección:</td>
    		<td><input tabindex="10" size="28" name = "direccion" value="<%= (donatario.getDireccion() != null) ? donatario.getDireccion() : ""%>"></td>
    	
    	</tr>
    	<tr>
    		<td class = "a">Colegio:</td>
    		<td><input tabindex="11" size="28" name="colegio" value="<%= (donatario.getColegio() != null) ? donatario.getColegio() : ""%>"></td>
    		<td class = "a">Ano Escolar</td>
    		<td><select tabindex="12" name="ano_escolar" style="width: 150px;">
				<option value =0 > --Seleccione--	</option>
					<%
						int ini = 2009;			
			 			Calendar cal = Calendar.getInstance();
			 			int fin = cal.get(Calendar.YEAR);
						for (int i = ini; i <= fin ; i++ ) {
					%>
							<option value =<%=i%> <%= (donatario.getAno_escolar() == i ? " selected = \"selected\"" : "") %>>  
								<%= i + "-" + (i+1)%> 
							</option>
					<%
						}
					%>
			</select></td>
    	</tr>
    	<tr>
    		<td class = "a">Grado:</td>
    		<td><select tabindex="13" name="grado">
				<option value="0"> -- </option>
				<option value="1" <%= (donatario.getGrado() == 1 ? " selected = \"selected\"" : "")%>=""> 1° </option> 	
				<option value="2" <%= (donatario.getGrado() == 2 ? " selected = \"selected\"" : "")%>=""> 2° </option> 	
				<option value="3" <%= (donatario.getGrado() == 3 ? " selected = \"selected\"" : "")%>=""> 3° </option>
				<option value="4" <%= (donatario.getGrado() == 4 ? " selected = \"selected\"" : "")%>=""> 4° </option>	
				<option value="5" <%= (donatario.getGrado() == 5 ? " selected = \"selected\"" : "")%>=""> 5° </option>   
				<option value="6" <%= (donatario.getGrado() == 6 ? " selected = \"selected\"" : "")%>=""> 6° </option>
			</select></td>
    		<td class = "a">Sección:</td>
    		<td><input tabindex="14" name="seccion" size="28" value="<%= (donatario.getSeccion() != null) ? donatario.getSeccion() : ""%>"></td>
    	</tr>
    	<tr>
    		<td class = "a">Serial Equipo:</td>
    		<td> <input tabindex="15" name="equipo_serial" size="28" value="<%= (donatario.getEquipo_serial() != null) ? donatario.getEquipo_serial() : ""%>"></td>
    		<td class = "a">Código DEA:</td>
    		<td><input tabindex="16" name="codigo_dea" size="28" value="<%= (donatario.getCodigo_dea() != null) ? donatario.getCodigo_dea() : ""%>"></td>
    	</tr>
    	<tr>
    		<td class = "a">Nombre Director:</td>
    		<td> <input tabindex="17" name="director_nombre" size="28" value="<%= (donatario.getDirector_nombre() != null) ? donatario.getDirector_nombre() : ""%>"></td>
    		<td class = "a">Proveedor:</td>
    		<td><input tabindex="18" name="proveedor" size="28" value="<%= (donatario.getProveedor() != null) ? donatario.getProveedor() : ""%>"></td>
    	</tr>
    	<tr>
    		<td class = "a">Observaciones:</td>
    		<td colspan="4"> <input tabindex="19" name="observacion" size="75" value="<%= (donatario.getObservacion() != null) ? donatario.getObservacion() : ""%>"></td>
    	</tr>
    	<tr>
    		<td colspan="4" align="center">
    			<INPUT type="hidden" value="<%= ESTADO.POR_GUARDAR %>" name="estado">
    			<INPUT type="hidden" value="<%= idDonatario %>" name="iddonatario">    			
    			<INPUT tabindex="20" type="submit" value="Aceptar Cambios"/>
    			<INPUT tabindex="21" type="reset"  value="Eliminar Donatario" id= "botonEliminar" />
    		</td>    
    	<tr>	
    </table>
</form>		
</div>
<div align="center" id = "eliminar" class = "edicion" style="display:none;">

	<br><br> 
	<form action="<%= "javascript:eliminarDonatario(" + idDonatario + ");"%>">
	
	<h1>¿Est&aacute; seguro que desea eliminar al donatario?</h1>
	<br>
	<table border="1">
	   	<tr>
	   		<td class = "a"> ID Donatario</td>
	   		<td class = "extralargo"><%= idDonatario %></td>
	   		<td class = "a"> Nombre Donatario:</td>
	   		<td class = "extralargo" ><%=(donatario.getNombre() != null) ? donatario.getNombre() : ""%></td>
	   		
	   	</tr>
	   	<tr>
	   		<td class = "a">Nacionalidad Rep.</td>
	   		<td class = "extralargo"><%=NACIONALIDAD.mostrar(donatario.getRepresentante_nac())%></td>
	   		<td class = "a">Cédula:</td>
	   		<td class = "extralargo"><%= (donatario.getRepresentante_ci() != null) ? donatario.getRepresentante_ci() : ""%></td>
	   	</tr>
	   	<tr>
	   		<td class = "a">Nombre Rep.</td>
	   		<td class = "extralargo"><%= (donatario.getRepresentante_nombre() != null) ? donatario.getRepresentante_nombre(): "" %></td>
	   		<td class = "a">Teléfono:</td>
	   		<td class = "extralargo"><%= (donatario.getRepresentante_tlf() != null) ? donatario.getRepresentante_tlf() : ""%></td>
	   	</tr>
	   	<tr>
		   	<td colspan="4" align="center">			   	
				<INPUT tabindex="1" type="reset" value="Cancelar" id = "botonCancelar"/>
				<INPUT tabindex="2" type="submit" value="Eliminar Donatario" />
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