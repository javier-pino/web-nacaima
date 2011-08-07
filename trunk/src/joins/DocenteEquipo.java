package joins;

import java.io.Serializable;

import beans.Docente;
import beans.Equipo;
public class DocenteEquipo implements Serializable {

	private static final long serialVersionUID = -2613276135194561355L;
	private Docente docente;
	private Equipo equipo;
	private boolean valido = false;
	
	public boolean isValido() {
		return valido;
	}
	
	public Equipo getEquipo() {		
		return equipo;
	}
	
	public void setEquipo(Equipo equipo) {
		if (equipo != null)
			valido = true;
		this.equipo = equipo;
	}

	public Docente getDocente() {
		return docente;
	}

	public void setDocente(Docente docente) {
		this.docente = docente;
	}

	@Override
	public String toString() {
		return "DocenteEquipo [docente=" + docente + ", equipo=" + equipo
				+ ", valido=" + valido + "]";
	}
	
}
