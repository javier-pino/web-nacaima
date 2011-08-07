package joins;

import java.io.Serializable;

import beans.Contrato;
import beans.Donatario;
public class DonatarioContrato implements Serializable {

	private static final long serialVersionUID = -2613276135194561355L;
	private Donatario donatario;
	private Contrato contrato;
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
	public Contrato getContrato() {
		return contrato;
	}
	public void setContrato(Contrato contrato) {
		if (contrato != null)
			valido = true;
		this.contrato = contrato;		
	}
	
	@Override
	public String toString() {
		return "DonatarioContrato [donatario=" + donatario + ", contrato="
				+ contrato + "]";
	}
}
