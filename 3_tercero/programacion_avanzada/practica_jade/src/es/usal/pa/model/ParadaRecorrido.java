package es.usal.pa.model;

import java.io.Serializable;

public class ParadaRecorrido implements Serializable, Cloneable {
  private static final long serialVersionUID = 1L;

  private Integer parada;
  private LlegadaLinea llegadaLinea;

  public ParadaRecorrido(Integer parada, LlegadaLinea llegadaLinea) {
    super();
    this.parada = parada;
    this.llegadaLinea = llegadaLinea;
  }

  public Integer getParada() {
    return parada;
  }

  public void setParada(Integer parada) {
    this.parada = parada;
  }

  public LlegadaLinea getLlegadaLinea() {
    return llegadaLinea;
  }

  public void setLlegadaLinea(LlegadaLinea llegadaLinea) {
    this.llegadaLinea = llegadaLinea;
  }

  public Object clone() throws CloneNotSupportedException {
    return super.clone();
  }
}
