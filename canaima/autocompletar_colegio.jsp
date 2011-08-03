<%@page import="java.sql.Connection"%>
<%@page import="beans.Colegio"%>
<%@page import="java.util.ArrayList"%>

<!-- Iniciar Modelo -->
<%@include file="/WEB-INF/jsp/IniciarModelo.jsp"%>

<%
	String nombre = request.getParameter("q");
	Connection con = canaima.solicitarConexion();
	ArrayList<Colegio> colegios = Colegio.listarColegioPorNombre(con, nombre);
	canaima.getPoolConexiones().cerrarConexion(con);
	
	for (int i=0; i < colegios.size(); i++){
		out.print(colegios.get(i).getNombre() + "|" + colegios.get(i).getIdcolegio() + "\n");	
	}
%>