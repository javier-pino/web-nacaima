package joins;

import java.io.Serializable;

import beans.Donatario;
import beans.Equipo;
public class DonatarioEquipo implements Serializable {

	private static final long serialVersionUID = -2613276135194561355L;
	private Donatario donatario;
	private Equipo equipo;
	private boolean valido = false;
	
	public boolean isValido() {
		return valido;
	}
	
	public Donatario getDonatario() {
		return donatario;
	}
	
	public void setDonatario(Donatario donatario) {
		if (donatario != null)
			valido = true;
		this.donatario = donatario;
	}
	
	public Equipo getEquipo() {		
		return equipo;
	}
	
	public void setEquipo(Equipo equipo) {
		if (equipo != null)
			valido = true;
		this.equipo = equipo;
	}

	@Override
	public String toString() {
		return "DonatarioEquipo [donatario=" + donatario + ", equipo=" + equipo
				+ ", valido=" + valido + "]";
	}
}
