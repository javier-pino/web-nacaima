<%@page import="enums.CAJA_TIPO"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="enums.ROL_USUARIO"%>
<%@page import="java.sql.Connection" %>
<%@page import="beans.*"%>

<!-- Iniciar Modelo -->
<%@include file="/WEB-INF/jsp/IniciarModelo.jsp"%>
	
	<%
		Usuario actual = canaima.getUsuarioActual();
		Connection con = canaima.solicitarConexion();
		
		int ultimoDon = Donatario.getUltimoDonatarioRegistrado(actual, con);
		int ultimoConDon = Contrato.getUltimoContratoDonatarioRegistrado(actual, con);
		int ultimoDoc = Docente.getUltimoDocenteRegistrado(actual, con);
		int ultimoConDoc = Contrato.getUltimoContratoDonatarioRegistrado(actual, con);
		
		int ultimaCajDon = Caja.getUltimaCajaRegistrada(con, actual, CAJA_TIPO.DON), 
			ultimaCajDoc = Caja.getUltimaCajaRegistrada(con, actual, CAJA_TIPO.DOC);				
		int ultimoLotDon = 0, ultimoLotDoc = 0;
		int numeroLotDon = 0, numeroLotDoc = 0;
		
		//Calcular las estadisticas de contratos de donatarios
		Lote lote = new Lote();				
		if (ultimaCajDon > 0 ) {					
			canaima.buscarPorID(Lote.getLoteActual(con, ultimaCajDon), lote);
			ultimoLotDon = lote.getNumero();					
			numeroLotDon = Lote.getNumeroDeLotes(con, ultimaCajDon);					
		}	
		int numeroConDon = 0, numeroConDoc = 0;
		if (ultimoLotDon > 0)
			numeroConDon = Contrato.getNumeroDeContratos(con,ultimoLotDon);
		
		//Calcular las estadisticas de los contratos de docentes
		lote = new Lote();				
		if (ultimaCajDoc > 0 ) {					
			canaima.buscarPorID(Lote.getLoteActual(con, ultimaCajDoc), lote);
			ultimoLotDoc = lote.getNumero();					
			numeroLotDoc = Lote.getNumeroDeLotes(con, ultimaCajDoc);					
		}				
		if (ultimoLotDoc > 0)
			numeroConDoc = Contrato.getNumeroDeContratos(con,ultimoLotDoc);
		canaima.liberarConexion(con);				
	%>
			
	&nbsp;  
	<div id = "estadisticas">
		<table border="0">
			<tr class = "a" align="center">
				<td colspan="5" > 
					&Uacute;ltimos valores
				</td>
				<td colspan="8" > 
					Contratos Donatarios
				</td>
				<td colspan="8" > 
					Contratos Docentes
				</td>
			</tr>
			<tr class = "w" align="center">
				<td class = "largo">&Uacute;ltimo Donatario Registrado</td>									
				<td class = "largo">&Uacute;ltimo Contrato Donatario</td>
				<td class = "largo">&Uacute;ltimo Docente Registrado</td>
				<td class = "largo">&Uacute;ltimo Contrato Docente</td>
				<td class = "largo"></td>
				<td class = "largo">Lote Actual </td>
				<td class = "largo">#Contratos en Lote</td>
				<td class = "largo">M&aacute;ximo</td>
				<td class = "largo"></td>				
				<td class = "largo">Caja Actual</td>
				<td class = "largo">#Lotes en Caja</td>
				<td class = "largo">M&aacute;ximo</td>
				<td class = "largo"></td>
				<td class = "largo">Lote Actual </td>
				<td class = "largo">#Contratos en Lote</td>
				<td class = "largo">M&aacute;ximo</td>
				<td class = "largo"></td>				
				<td class = "largo">Caja Actual</td>
				<td class = "largo">#Lotes en Caja</td>
				<td class = "largo">M&aacute;ximo</td>			
			</tr>		
			<tr class = "a">
				<td class = "largo"><%=(ultimoDon > 0 ? ultimoDon : "")%></td>									
				<td class = "largo"><%=(ultimoConDon > 0 ? ultimoConDon : "")%></td>
				<td class = "largo"><%=(ultimoDoc > 0 ? ultimoDoc : "")%></td>										
				<td class = "largo"><%=(ultimoConDoc > 0 ? ultimoConDoc : "")%></td>
				<td class = "largo"></td>
				<td class = "largo"><%=(ultimoLotDon > 0 ? ultimoLotDon : "") %></td>
				<td class = "largo"><%=(numeroConDon > 0 ? numeroConDon : "") %></td>
				<td class = "largo"><%= canaima.MAX_CONTRATOS_X_LOTE %></td>
				<td class = "largo"></td>
				<td class = "largo"><%=(ultimaCajDon > 0 ? ultimaCajDon : "")%></td>
				<td class = "largo"><%=(numeroLotDon > 0 ? numeroLotDon : "")%></td>
				<td class = "largo"><%= canaima.MAX_LOTES_X_CAJA %></td>																
				<td class = "largo"></td>
				<td class = "largo"><%=(ultimoLotDoc > 0 ? ultimoLotDoc : "") %></td>
				<td class = "largo"><%=(numeroConDoc > 0 ? numeroConDoc : "") %></td>
				<td class = "largo"><%= canaima.MAX_CONTRATOS_X_LOTE %></td>
				<td class = "largo"></td>
				<td class = "largo"><%=(ultimaCajDoc > 0 ? ultimaCajDoc : "")%></td>
				<td class = "largo"><%=(numeroLotDoc > 0 ? numeroLotDoc : "")%></td>
				<td class = "largo"><%= canaima.MAX_LOTES_X_CAJA %></td>
			</tr>
		 </table>
	</div>
	&nbsp;