package es.usal.pa.model;

import java.io.Serializable;
import java.util.Vector;

public class Recorrido implements Serializable, Cloneable {
  private static final long serialVersionUID = 1L;

  private Vector<ParadaRecorrido> vectorParadas = new Vector<ParadaRecorrido>();
  private Integer paradaFinal;
  private Float hora;

  public Recorrido() {
    super();
  }

  public Recorrido(Vector<ParadaRecorrido> vectorParadas) {
    super();
    if (!vectorParadas.isEmpty()) {
      this.vectorParadas = vectorParadas;
    }
  }

  public Vector<ParadaRecorrido> getVectorParadas() {
    return vectorParadas;
  }

  public void setVectorParadas(Vector<ParadaRecorrido> vectorParadas) {
    if (!vectorParadas.isEmpty()) {
      this.vectorParadas = vectorParadas;
    }
  }

  public Float getHora() {
    return hora;
  }

  public void setHora(Float hora) {
    this.hora = hora;
  }

  public Integer getParadaFinal() {
    return paradaFinal;
  }

  public void calcularParadaFinal() {
    paradaFinal = vectorParadas.get(vectorParadas.size() - 1).getParada();
  }

  @Override
  public Object clone() throws CloneNotSupportedException {
    return super.clone();
  }
}
