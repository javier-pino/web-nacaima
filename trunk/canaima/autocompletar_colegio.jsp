<%@page import="java.util.Collections"%>
<%@page import="java.util.Collection"%>
<%@page import="java.util.LinkedList"%>
<%@page import="java.util.List"%>
<%@page import="beans.Parroquia"%>
<%@page import="beans.Municipio"%>
<%@page import="beans.Estado"%>
<%@page import="java.sql.Connection"%>
<%@page import="beans.Colegio"%>
<%@page import="java.util.ArrayList"%>

<%-- Iniciar Modelo --%>
<%@include file="/WEB-INF/jsp/IniciarModelo.jsp"%>
<%
	String nombre = request.getParameter("q"),
		idestado =  request.getParameter("idestado"),
		idmunicipio = request.getParameter("idmunicipio"),
		idparroquia = request.getParameter("idparroquia"); 
	
	Connection con = canaima.solicitarConexion();
	ArrayList<Colegio> colegios = Colegio.listarColegios(con, nombre, idestado, idmunicipio, idparroquia);	
	canaima.liberarConexion(con);
	
	Estado estado = new Estado();
	Municipio municipio = new Municipio();
	Parroquia parroquia = new Parroquia();
	
	for (int i=0; i < colegios.size(); i++){
		
		canaima.buscarPorID(colegios.get(i).getIdestado(), estado);
		canaima.buscarPorID(colegios.get(i).getIdmunicipio(), municipio);
		canaima.buscarPorID(colegios.get(i).getIdparroquia(), parroquia);
		
		out.print(colegios.get(i).getCodigo_dea()+" - " + colegios.get(i).getNombre() +
				"<br>(" + estado.getNombre());
				
				if(colegios.get(i).getIdmunicipio()>0)
					out.print(", " + municipio.getNombre());
				if(colegios.get(i).getIdparroquia()>0)
					out.print(", " + parroquia.getNombre());
						
				out.print( ") |" + colegios.get(i).getIdcolegio() + "\n");	
	}
%>