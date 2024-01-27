package es.usal.pa.model;

import java.io.Serializable;

public class Conexion implements Serializable {
  private static final long serialVersionUID = 1L;

  private Integer parada;
  private Integer linea;

  public Conexion(Integer parada, Integer linea) {
    super();
    this.parada = parada;
    this.linea = linea;
  }

  public Integer getParada() {
    return parada;
  }

  public void setParada(Integer parada) {
    this.parada = parada;
  }

  public Integer getLinea() {
    return linea;
  }

  public void setLinea(Integer linea) {
    this.linea = linea;
  }
}
