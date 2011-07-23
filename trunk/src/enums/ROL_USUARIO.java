/**
 ROL.java - 04/04/2011
 Autor: Javier Pino
 */
package enums;

/**
 * Descripción: Enumera los roles del usuario en la base de datos
 * @author Javier Pino
 */
public enum ROL_USUARIO {
	
	/** Visitante */
	VIS,
	/** Analista */
	ANA, 
	/** Administrador */
	ADM; 
				
	/** Formatea el enum para mostrarlo*/
	public static String mostrar(ROL_USUARIO rol) {
		
		String resultado = "Desconocido";
		if (rol != null) {
			switch (rol) {
			case VIS:
				resultado = "Visitante";
				break;
			case ANA:
				resultado = "Analista";
				break;
			case ADM:
				resultado = "Administrador";
				break;
			}
		}
		return resultado; 		
	}
	
	/** Formatea el enum para mostrarlo*/
	public static String ventana(ROL_USUARIO rol) {
		
		String resultado = "login.jsp";
		if (rol != null) {
			switch (rol) {
			case VIS:
				resultado = "visitante.jsp";
				break;
			case ANA:
				resultado = "analista.jsp";
				break;
			case ADM:
				resultado = "administrador.jsp";
				break;
			}
		}
		return resultado; 		
	}
}
