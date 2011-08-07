<%@page import="enums.ROL_USUARIO"%>
<%@page import="java.util.*" %>
<%@page import="beans.Municipio"%>
<%@page import="beans.Donatario"%>
<%@page import="enums.NACIONALIDAD"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.sql.Connection"%>

<!-- Iniciar Modelo -->
<%@include file="/WEB-INF/jsp/IniciarModelo.jsp"%>
<% 
	String estado = "";
	int idestado = 0;
    if (request.getParameter("idestado") != null) {
	   estado = (request.getParameter("idestado"));
	   try {
		 	idestado = Integer.parseInt(estado);  
	   } catch (Exception e) {
		   e.printStackTrace();
		   
	   } 
    }	
%>
<td width="15" id= "municipios">
	<SELECT tabindex="2" name="idmunicipio" title="municipio" onchange="javascript:mostrarParroquias(this.value);">
	<%
		int idMunicipio;
		String nombreMunicipio = null;  
		Donatario ultimo = canaima.getUltimo();
		Connection con = canaima.solicitarConexion(); 				   				
		ArrayList<Municipio> listaMunicipio = Municipio.listarMunicipiosPorEstado(idestado, con);
		canaima.liberarConexion(con);
		out.write("<option value=\"" + 0 + "\">--Seleccione--</option>");
		for (int i=0; i < listaMunicipio.size(); i++) {				
			out.write("<option value=\"" + listaMunicipio.get(i).getID() + "\">" + listaMunicipio.get(i).getNombre()  + "</option>");
		}
	%>
	</select>
</td>
