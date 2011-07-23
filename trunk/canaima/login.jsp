<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@page import="enums.ROL_USUARIO"%>
<%@page import="beans.Usuario"%>

<!-- Iniciar Modelo -->
<%@page import="enums.ROL_USUARIO"%>
<%@include file="/WEB-INF/jsp/IniciarModelo.jsp"%>

<!-- Incluir la cabecera -->
<%@include file="/WEB-INF/jsp/GeneradorCabecera.jsp"%>
<%!
	public enum ESTADO {		
		SIN_CONECTAR,	
		CONECTANDO,
		USUARIO_INVALIDO,		
	} 
%>
<%
	ESTADO login_estado = ESTADO.SIN_CONECTAR;	
	if (request.getParameter("login_estado") != null) {
		login_estado = ESTADO.valueOf(request.getParameter("login_estado"));
	}
	if (canaima.getUsuarioActual() != null) {
		response.sendRedirect(response.encodeRedirectURL(
				ROL_USUARIO.ventana(canaima.getUsuarioActual().getRol())		
		));
		return;
	}					
	
%>
<HTML>
	<HEAD>
		<META http-equiv="pragma" content="no-cache"> 
		<META http-equiv="expires" content="-1"> 
		<META http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<META name="GENERATOR" content="IBM WebSphere Studio">
		<META http-equiv="Content-Style-Type" content="text/css">
		<LINK href="theme/Master.css" rel="stylesheet" type="text/css">
		<STYLE type=text/css>
			.mensaje {FONT: 10.0pt Arial; COLOR: #0049aa; TEXT-DECORATION: none; text-align: left; background-color: #C1DCFF; font-weight: bold}
			.mensajeIMG {COLOR: #0049aa; TEXT-DECORATION: none; text-align: right; background-color: #C1DCFF}
		</STYLE>
		<script language="JavaScript" src="scriptsValidacion.js"></script>
		<TITLE>Bienvenidos a Canaima</TITLE>
		<SCRIPT> javascript:history.go(1); </SCRIPT>
	</head>
	<body onLoad="document.FORMLOGIN.Login.focus();document.FORMLOGIN.Login.select();">
	   <br><br><br><br>
	   <FORM NAME=FORMLOGIN METHOD="POST" action="login.jsp">
	      <TABLE ID=DATOS CELLSPACING=1 CELLPADDING=1 WIDTH="100%" BORDER=0>
	         <TR><TD COLSPAN=4 HEIGHT=20>&nbsp;</TD></TR>
	         <TR>
	            <TD WIDTH="35%">&nbsp;</TD>
	            <TD WIDTH="15%" VALIGN="MIDDLE" ALIGN="CENTER" BGCOLOR=#5c9510><SPAN style="FONT-SIZE: 12pt; COLOR: #ffffff; FONT-FAMILY: Arial">Usuario</SPAN></TD>
	            <TD WIDTH="15%" VALIGN=TOP WIDTH=20><INPUT TYPE="TEXT" Style="FONT-SIZE: 12pt; COLOR: #000000; FONT-FAMILY: Arial; TEXT-ALIGN: left;width=100%" maxLength=10 name="usuario" value=""></TD>
	            <TD WIDTH="35"">&nbsp;</TD>
	         </TR>
	         <TR>
	            <TD width="35%">&nbsp;</TD>
	            <TD width="15%" vAlign="middle" align="center" bgColor=#5c9510><SPAN style="FONT-SIZE: 12pt; COLOR: #ffffff; FONT-FAMILY: Arial">Clave</SPAN></TD>
	            <TD width="15%" vAlign=top width=20><INPUT type="password" style="FONT-SIZE: 12pt; COLOR: #000000; FONT-FAMILY: Arial; TEXT-ALIGN: left;width=100%" maxLength=10 name=contrasena></TD>
	            <TD width="35%">&nbsp;</TD>
	         </TR>
	         <TR><TD COLSPAN=4>&nbsp;</TD></TR>
	         <TR ID=BUT1>
	            <TD ALIGN="CENTER" COLSPAN=4><FONT FACE=ARIAL SIZE=-1>
	            <INPUT type="submit" name="Validar" value="Aceptar">
	            <INPUT type="hidden" name="login_estado" value="<%= ESTADO.CONECTANDO %>">	           
	            </FONT></TD>	            
	         </TR>
		   </TABLE>	         	   	  
   <%
	if (login_estado.equals(ESTADO.CONECTANDO)) {
		if (request.getParameter("usuario") != null) {			
			if (request.getParameter("contrasena") != null) {
				Usuario actual = canaima.iniciarSesion(
						request.getParameter("usuario"), 
						request.getParameter("contrasena"));				
				if (actual != null) {
					
					if (actual.isActivo()) {
						canaima.setUsuarioActual(actual);					
						response.sendRedirect(response.encodeRedirectURL(
							ROL_USUARIO.ventana(actual.getRol())		
						));
						return;	
					} else {
						//Mostrar diciendo que no está autorizado
					%>					
					<TABLE cellSpacing=0 cellPadding=1 width="100%" border=0 >
				      <tr><TD align=center width="50%" style="font-SIZE:9pt; FONT-FAMILY:ARIAL;COlor:RED;">
				         <B>Usuario No Autorizado</B></TD></TR>
				      <tr><TD align=center width="50%" style="font-SIZE:9pt; FONT-FAMILY:ARIAL;COlor:RED;">
				          <B>&nbsp;</B></TD></TR>
				    </TABLE>
					<%
					}
				} else {
					//Mostrar diciendo que no existe
				%>
				<TABLE cellSpacing=0 cellPadding=1 width="100%" border=0 >
					      <tr><TD align=center width="50%" style="font-SIZE:9pt; FONT-FAMILY:ARIAL;COlor:RED;">
					         <B>Usuario Inv&aacute;lido o Contrase&ntilde;a Incorrecta</B></TD></TR>
				</TABLE>				
				<%
				}
			}
		}	
	}
%>	     
	   </FORM>
	   <br><br><br><br>
	<br>
	<br>
	<br>
	<br>	
	</body>
</HTML>