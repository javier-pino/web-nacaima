<%@page import="beans.Equipo"%>
<%@page import="enums.ROL_USUARIO"%>
<%@page import="java.util.*" %>
<%@page import="aplicacion.ExcepcionValidaciones" %>
<%@page import="beans.Municipio"%>
<%@page import="beans.Docente"%>
<%@page import="enums.NACIONALIDAD"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.sql.Connection"%>

<!-- Iniciar Modelo -->
<%@include file="/WEB-INF/jsp/IniciarModelo.jsp"%>

<% 
	if (canaima.getUsuarioActual() == null || canaima.getUsuarioActual().getRol().equals(ROL_USUARIO.VIS)) {
	%>
	<jsp:include page="/WEB-INF/jsp/GeneradorMensaje.jsp">
		<jsp:param value="Acceso No Autorizado" name="titulo"/>
		<jsp:param value="No tiene acceso autorizado para esta ventana con su perfil" name= "texto"/>		
		<jsp:param value="Cierre esta ventana y verifique si su sesión ha expirado" name= "texto"/>
	</jsp:include>	
	<% 	
	return;
	}	
	String docente = "";
	int iddocente = 0;
    if (request.getParameter("iddocente") != null) {
	   docente = (request.getParameter("iddocente"));
	   try {
		 	iddocente = Integer.parseInt(docente);
		 	Docente docenteEliminado = new Docente();		 	
		 	canaima.buscarPorID(iddocente, docenteEliminado);
		 			 	
		 	//Se desactivan, porque decidimos que no se eliminan
		 	docenteEliminado.setActivo(false);
		 	canaima.actualizar(docenteEliminado);	
		 	Connection con = canaima.solicitarConexion();
		 	ArrayList<Equipo> equiposAsociados = Equipo.buscarEquipos(con, 0 ,docenteEliminado.getID(), null);
			Equipo equipoAsociado = null;
			
			for(int i=0; i<equiposAsociados.size(); i++){
				equipoAsociado = equiposAsociados.get(i);
				canaima.eliminarPorID(equipoAsociado);
				
			}
			canaima.liberarConexion(con);		 			 
	   		%>
			 	<jsp:include page="/WEB-INF/jsp/GeneradorMensaje.jsp">
					<jsp:param value="El Docente ha sido eliminado" name="titulo"/>				
					<jsp:param value="Cierre esta ventana y refresque para ver los cambios" name= "texto"/>
				</jsp:include>
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