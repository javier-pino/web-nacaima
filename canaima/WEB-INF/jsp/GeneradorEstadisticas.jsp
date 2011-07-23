<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@page import="enums.ROL_USUARIO"%>
<%@page import="java.sql.Connection" %>
<%@page import="beans.*"%>

<!-- Iniciar Modelo -->
<%@include file="/WEB-INF/jsp/IniciarModelo.jsp"%>
	&nbsp;  
	<div id = "estadisticas">
		<table border="0">
			<tr align="center">
				<td colspan="12" class = "a">ESTAD&Iacute;STICAS</td>
			</tr>
			<tr class = "w" align="center">
				<td class = "largo">&Uacute;ltimo Donatario Registrado</td>									
				<td class = "largo">&Uacute;ltimo Contrato Registrado</td>
				<td class = "largo"></td>
				<td class = "largo">Lote Actual</td>
				<td class = "largo">#Contratos en Lote</td>
				<td class = "largo">M&aacute;ximo</td>
				<td class = "largo"></td>
				<td class = "largo">Caja Actual</td>
				<td class = "largo">#Lotes en Caja</td>
				<td class = "largo">M&aacute;ximo</td>
			</tr>
			<%
				Usuario actual = canaima.getUsuarioActual();
				Connection con = canaima.solicitarConexion();
				int ultimoDon = Donatario.getUltimoDonatarioRegistrado(actual, con);
				int ultimoCon = Contrato.getUltimoContratoRegistrado(actual, con);
				int ultimaCaj = Caja.getUltimaCajaRegistrada(con, actual);
				int ultimoLot = 0;
				int numeroLot = 0;
				if (ultimaCaj > 0 ) {
					Lote lote = new Lote();
					canaima.buscarPorID(Lote.getLoteActual(con, ultimaCaj), lote);
					ultimoLot = lote.getNumero();					
					numeroLot = Lote.getNumeroDeLotes(con, ultimaCaj);
					
					Caja caja = new Caja();
					canaima.buscarPorID(ultimaCaj, caja);
					ultimaCaj = caja.getNumero();
				}	
				int numeroCon = 0;
				if (ultimoLot > 0)
					numeroCon = Contrato.getNumeroDeContratos(con,ultimoLot);
				canaima.getPoolConexiones().cerrarConexion(con);
			%>
			
			
			<tr class = "a">
				<td class = "largo"><%=(ultimoDon > 0 ? ultimoDon : "")%></td>									
				<td class = "largo"><%=(ultimoCon > 0 ? ultimoCon : "")%></td>									
				<td class = "largo"></td>
				<td class = "largo"><%=(ultimoLot > 0 ? ultimoLot : "") %></td>
				<td class = "largo"><%=(numeroCon > 0 ? numeroCon : "") %></td>
				<td class = "largo"><%= canaima.MAX_CONTRATOS_X_LOTE %></td>
				<td class = "largo"></td>
				<td class = "largo"><%=(ultimaCaj > 0 ? ultimaCaj : "")%></td>
				<td class = "largo"><%=(numeroLot > 0 ? numeroLot : "")%></td>
				<td class = "largo"><%= canaima.MAX_LOTES_X_CAJA %></td>																
			</tr>
		 </table>
	</div>
	&nbsp;