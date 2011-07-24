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
			<jsp:useBean id="donatario" class = "beans.Donatario" scope="request">
				<jsp:setProperty property="*" name = "donatario"/> </jsp:useBean>
<% 						
			donatario.setIdcreadopor(canaima.getUsuarioActual().getID());								
			donatario.setRepresentante_nac(request.getParameter("representante_nac"));
			
			if (donatario.getRepresentante_ci() != null && !donatario.getRepresentante_ci().isEmpty()) {
				if (donatario.getRepresentante_nac() == null ) {
					donatario.setRepresentante_nac(NACIONALIDAD.V.toString());	
				}				
			} else
				donatario.setRepresentante_nac(null);						
		
			canaima.guardar(donatario);					
			canaima.agregarDonatario(donatario);
			
			//Aqui se valida si no tiene el mismo nombre y cedula
			Connection con = canaima.solicitarConexion();
			donatario.validarCedulaRepNombreDonatario(con);			
			canaima.getPoolConexiones().cerrarConexion(con);			
		} catch (ExcepcionValidaciones val) {
			request.setAttribute("validaciones", val.getValidacionesIncumplidas());
			pageContext.include("/WEB-INF/jsp/GeneradorMensaje.jsp", true);					
		} catch (Exception exc) {	
			exc.printStackTrace();		
			request.setAttribute("excepcion", exc);
			pageContext.include("/WEB-INF/jsp/GeneradorMensaje.jsp", true);
		}		
	}
	Donatario ultimo = canaima.getUltimo();
%>
<div class="Part" >
<h2>Registrar</h2>
&nbsp;  
<div align="left" id="scroll1">
<form name="lista" action="agregarDonatario.jsp" method="post">
<table id="fila_direccion">
	<tr class="a">
		<td>Estado</td>
		<td>Municipio</td>
		<td>Ciudad</td>		
		<td>Serial Eq.*</td>
	</tr>	
	<tr >
		<td>			
			<SELECT tabindex="1" name="idestado" title="estado" onchange="javascript:mostrarMunicipios(this.value);">
			<%
				int idEstado;
				String nombreEstado = null;
				Estado estado = new Estado();
				Connection con = canaima.solicitarConexion();				
				ArrayList<Estado> estados = Estado.listarEstados(con);
				canaima.getPoolConexiones().cerrarConexion(con);
				out.write("<option value=\"" + 0 + "\">--Seleccione--</option>");
				for (int i=0; i < estados.size(); i++) {
					if (ultimo.getIdestado() > 0 && ultimo.getIdestado() == estados.get(i).getID())
						out.write("<option value=\"" + estados.get(i).getID() + "\" selected=\"selected\" >" + estados.get(i).getNombre()  + "</option>");
					else 
						out.write("<option value=\"" + estados.get(i).getID() + "\" >" + estados.get(i).getNombre()  + "</option>");
	   			}
        	%>
			</SELECT>
		</td>
		<td id= "municipios">
			<SELECT tabindex="2" name="idmunicipio" title="municipio" >
			<%					
			if (ultimo.getID() > 0 && ultimo.getIdestado() > 0) {
				con = canaima.solicitarConexion();				
				ArrayList<Municipio> municipios = Municipio.listarMunicipiosPorEstado(ultimo.getIdestado(), con);
				canaima.getPoolConexiones().cerrarConexion(con);
				out.write("<option value=\"" + 0 + "\">--Seleccione--</option>");
				for (int i=0; i < municipios.size(); i++) {
					if (ultimo.getIdmunicipio() > 0 && ultimo.getIdmunicipio() == municipios.get(i).getID())
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
		<td>
			<input tabindex="3" name="ciudad" size="20" value="<%= (ultimo.getCiudad() != null) ? ultimo.getCiudad() : ""%>">
		</td>
		<td class="b" height="19" width="90">
			<input tabindex="4" type="text" name="equipo_serial" size="10"></td>
		</tr>
</table>
<br>
<table id="fila_colegio">		
	<tr class="a"> 
		<td>DEA</td>
		<td>Colegio</td>
		<td>Grado</td>
		<td>Secci�n</td>
		<td>A�o Escolar</td>
		<td>Direccion</td>
	</tr>
	<tr>
		<td><input tabindex="5" size="20" name="codigo_dea" size="10" value="<%= (ultimo.getCodigo_dea() != null) ? ultimo.getCodigo_dea() : ""%>"></td>
		<td><input tabindex="6" name="colegio" size="20" value="<%= (ultimo.getColegio() != null) ? ultimo.getColegio() : ""%>"></td>
		<td>
			<select tabindex="7" name="grado">
				<option value =0 > -- </option>
				<option value =1 <%= (ultimo.getGrado() == 1 ? " selected = \"selected\"" : "")%> > 1&deg; </option> 	
				<option value =2 <%= (ultimo.getGrado() == 2 ? " selected = \"selected\"" : "")%> > 2&deg; </option> 	
				<option value =3 <%= (ultimo.getGrado() == 3 ? " selected = \"selected\"" : "")%> > 3&deg; </option>
				<option value =4 <%= (ultimo.getGrado() == 4 ? " selected = \"selected\"" : "")%> > 4&deg; </option>	
				<option value =5 <%= (ultimo.getGrado() == 5 ? " selected = \"selected\"" : "")%> > 5&deg; </option>   
				<option value =6 <%= (ultimo.getGrado() == 6 ? " selected = \"selected\"" : "")%> > 6&deg; </option>
			</select>
		</td>
		<td>
			<input tabindex="8" name="seccion" size="10" value="<%= (ultimo.getSeccion() != null) ? ultimo.getSeccion() : ""%>">
		</td>
		<td>
			<select tabindex="9" name="ano_escolar">
				<option value =0 > --Seleccione--	</option>
		<%
			int ini = 2009;			
 			Calendar cal = Calendar.getInstance();
 			int fin = cal.get(Calendar.YEAR);
			for (int i = ini; i <= fin ; i++ ) {
		%>
				<option value =<%=i%> <%= (ultimo.getAno_escolar() == i ? " selected = \"selected\"" : "") %>>  
					<%= i + "-" + (i+1)%> 
				</option>
		<%
			}
		%>
			</select>
		</td>
		<td>
			<input tabindex="10" name="direccion" size="35" maxlength="255" value="<%= (ultimo.getDireccion() != null) ? ultimo.getDireccion() : ""%>">
		</td>
	</tr>
</table>
<br>
<table>
	<tr class="a">
		<td class="b" height="10" width="90">Nombre</td>
		<td class="b" height="10" width="80">Nac. Rep.</td>
		<td class="b" height="10" width="80">C�dula. Rep.</td>
		<td class="b" height="19" width="90">Nombre. Rep.</td>
		<td class="b" height="19" width="90">Nro. Tel�fono</td>
		<td class="b" height="19" width="90">Nombre. Dir</td>
		<td class="b" height="19" width="90">Proveedor</td>
	</tr>
	<tr>
		<td class="b" height="15" width="90">
			<input tabindex="11" type="text"  size="17"	name="nombre">
		</td>
		<td align="center">
			<select tabindex="12" name="representante_nac">
				<option value ="<%= NACIONALIDAD.V %>"> V </option>
				<option value ="<%= NACIONALIDAD.E %>"> E </option>
			</select></td>
		<td class="b" height="19" width="80">
			<input tabindex="13" maxlength="10" size="10" type="text" name="representante_ci" size="8" onKeypress="validarNumero(this)"></td>
		<td class="b" height="19" width="90">
			<input tabindex="14" type="text" size="17" name="representante_nombre"></td>
		<td class="b" height="19" width="90">
			<input tabindex="15" type="text" maxlength="12" name="representante_tlf" size="10" value="<%= (ultimo.getRepresentante_tlf() != null) ? ultimo.getRepresentante_tlf() : ""%>" onKeypress="validarNumero(this)"></td>
		<td class="b" height="19" width="90">
		<input tabindex="16" type="text" name="director_nombre" size="17" value="<%= (ultimo.getDirector_nombre() != null) ? ultimo.getDirector_nombre() : ""%>" ></td>
		<td class="b" height="19" width="90">
		<input tabindex="17" type="text" name="proveedor" size="17" value="<%= (ultimo.getProveedor() != null) ? ultimo.getProveedor() : ""%>"></td>
		
	</tr>
	<tr>
		<td align="center">
		<INPUT type="hidden" value="<%= ESTADO.POR_GUARDAR %>" name="estado">
		<INPUT tabindex="18" type="submit" value="Aceptar" name="aceptar">
		</td>
	</tr>
</table>
</form>
</div>
<br>
<script type="text/javascript">
$(document).ready(function() {
	$("a.donatario_link").fancybox({
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

<div align="center" id="scroll">
<table id="fila_donatario">
	<tr>
		<td class="a" colspan="12" >&Uacute;LTIMOS <%= ModeloCanaima.TAM_RECIENTES%> DONATARIOS REGISTRADOS</td>
	</tr>
	<tr class="w" align="center">
		<td class = "largo">ID</td>
		<td class = "largo">Nombre</td>
		<td class = "largo">DEA</td>
		<td class = "largo">Colegio</td>
		<td class = "largo">Grado</td>
		<td class = "largo">Secci�n</td>
		<td class = "largo">A�o Escolar</td>		
		<td class = "largo">C�dula. Rep.</td>
		<td class = "largo">Nombre. Rep.</td>
		<td class = "largo">Nro. Tel�fono</td>
	</tr>
	<% 	
	Donatario d = null;
	ListIterator<Donatario> recientes = canaima.getRecientes().listIterator(canaima.getRecientes().size());
	while (recientes.hasPrevious()) {
		d = recientes.previous();		
		if (!d.isActivo()) 
			continue;
	%>
	<tr class = "largo">
		<td class = "largo"><%=aFancyBox(response, "" + d.getID(), d.getID())%> </td>
		<td class = "largo"><%=aFancyBox(response, d.getNombre(), d.getID())%> </td>
		<td class = "largo"><%=aFancyBox(response, d.getCodigo_dea(), d.getID())%> </td>
		<td class = "largo"><%=aFancyBox(response, d.getColegio(), d.getID())%> </td>
		<%
			if (d.getGrado() > 0)	{			
		%>		
		<td class = "largo"><%=aFancyBox(response,d.getGrado() + "&deg;", d.getID())%> </td>
		<%
			} else {
		%>	
		<td class = "largo"> </td>
		<%
			}
		%>
		<td class = "largo"><%=aFancyBox(response, d.getSeccion(), d.getID())%> </td>
		<% 	if (d.getAno_escolar() > 0) 
			{
		%>
		<td class = "largo"><%=aFancyBox(response, d.getAno_escolar()+"-"+(d.getAno_escolar()+1) , d.getID())%> </td>
		<% } else {
		%>
		<td class = "largo"> </td>
		<%	}	
			if (d.getRepresentante_ci() != null && !d.getRepresentante_ci().isEmpty()) {		
		%>		
		<td class = "largo"><%=aFancyBox(response, d.getRepresentante_nac() + "-" + d.getRepresentante_ci(), d.getID())%> </td>
		<%
			} else {
		%>		
		<td class = "largo"> </td>
		<% } %>
		<td class = "largo"><%=aFancyBox(response, d.getRepresentante_nombre(), d.getID())%> </td>
		<td class = "largo"><%=aFancyBox(response, d.getRepresentante_tlf(), d.getID())%> </td>
	</tr>
	<%		
	}
	%>
</table>
</div>
&nbsp;
</div>

<%! 
	public String aFancyBox (HttpServletResponse response, String texto, int id) {
		String resultado = 			
			"<a href = \"" + response.encodeURL("editarDonatario.jsp?iddonatario=" + id) 
				+ 	"\" class = \"donatario_link\">" + texto +"</a>"
			;
		return resultado;
	} 
%>