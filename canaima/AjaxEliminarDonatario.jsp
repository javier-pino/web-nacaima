<%@page import="enums.ROL_USUARIO"%>
<%@page import="java.util.*" %>
<%@page import="aplicacion.ExcepcionValidaciones" %>
<%@page import="beans.*"%>
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
	String donatario = "";
	int iddonatario = 0;
    if (request.getParameter("iddonatario") != null) {
	   donatario = (request.getParameter("iddonatario"));
	   try {
		 	iddonatario = Integer.parseInt(donatario);
		 	Donatario donatarioEliminado = new Donatario();		 	
		 	canaima.buscarPorID(iddonatario, donatarioEliminado);
		 			 	
		 	//Se desactivan, porque decidimos que no se eliminan
		 	donatarioEliminado.setActivo(false);
		 	canaima.actualizar(donatarioEliminado);	
		 	
		 	Connection con = canaima.solicitarConexion();
		 	ArrayList<Equipo> equiposAsociados = Equipo.buscarEquipos(con, donatarioEliminado.getID(), 0, null);
			Equipo equipoAsociado = null;
			
			for(int i=0; i<equiposAsociados.size(); i++){
				equipoAsociado = equiposAsociados.get(i);
				canaima.eliminarPorID(equipoAsociado);
				
			}
			canaima.liberarConexion(con);
		 	
		 	ArrayList<Donatario> recientes = canaima.getRecientes();
		 	for (int i = 0; i < recientes.size(); i++) {
		 		if (recientes.get(i).getID() == donatarioEliminado.getID()) {
		 			recientes.set(i, donatarioEliminado);
		 			break;
		 		}
		 	}		 			 
	   		%>
			 	<jsp:include page="/WEB-INF/jsp/GeneradorMensaje.jsp">
					<jsp:param value="El Donatario ha sido eliminado" name="titulo"/>				
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