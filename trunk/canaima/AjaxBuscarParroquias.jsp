<%@page import="enums.ROL_USUARIO"%>
<%@page import="java.util.*" %>
<%@page import="beans.Parroquia"%>
<%@page import="beans.Donatario"%>
<%@page import="enums.NACIONALIDAD"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.sql.Connection"%>

<!-- Iniciar Modelo -->
<%@include file="/WEB-INF/jsp/IniciarModelo.jsp"%>
<% 
	String municipio = "";
	int idmunicipio = 0;
    if (request.getParameter("idmunicipio") != null) {
    	municipio = (request.getParameter("idmunicipio"));
	   try {
		 	idmunicipio = Integer.parseInt(municipio);  
	   } catch (Exception e) {
		   e.printStackTrace();
		   
	   } 
    }	
%>
<td width="15" id= "parroquias">
	<SELECT tabindex="3" id="idparroquia" name="idparroquia" title="parroquia">
	<%
		int idParroquia;
		String nombreMunicipio = null;  
		Donatario ultimo = canaima.getUltimo();
		Connection con = canaima.solicitarConexion(); 				   				
		ArrayList<Parroquia> listaParroquia = Parroquia.listarParroquiasPorMunicipios(idmunicipio, con);
		canaima.liberarConexion(con);
		out.write("<option value=\"" + 0 + "\">--Seleccione--</option>");
		for (int i=0; i < listaParroquia.size(); i++) {				
			out.write("<option value=\"" + listaParroquia.get(i).getID() + "\">" + listaParroquia.get(i).getNombre()  + "</option>");
		}
	%>
	</select>
</td>
