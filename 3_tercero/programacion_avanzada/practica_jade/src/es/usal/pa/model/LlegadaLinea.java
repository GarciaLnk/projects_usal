package es.usal.pa.model;

import java.io.Serializable;

public class LlegadaLinea implements Serializable, Cloneable {
  private static final long serialVersionUID = 1L;

  private Integer linea;
  private Float hora;

  public LlegadaLinea(Integer linea, Float hora) {
    super();
    this.linea = linea;
    this.hora = hora;
  }

  public Integer getLinea() {
    return linea;
  }

  public void setLinea(Integer linea) {
    this.linea = linea;
  }

  public Float getHora() {
    return hora;
  }

  public void setHora(Float hora) {
    this.hora = hora;
  }

  public Object clone() throws CloneNotSupportedException {
    return super.clone();
  }
}
