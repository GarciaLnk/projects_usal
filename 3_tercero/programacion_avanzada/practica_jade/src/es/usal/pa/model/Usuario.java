package es.usal.pa.model;

import java.io.Serializable;

public class Usuario implements Serializable {
  private static final long serialVersionUID = 1L;

  private Float horaSalida;
  private Integer paradaOrigen;
  private Integer paradaDestino;

  public Usuario(Float horaSalida, Integer paradaOrigen, Integer paradaDestinoInteger) {
    super();
    this.setHoraSalida(horaSalida);
    this.paradaOrigen = paradaOrigen;
    this.paradaDestino = paradaDestinoInteger;
  }

  public Float getHoraSalida() {
    return horaSalida;
  }

  public void setHoraSalida(Float horaSalida) {
    this.horaSalida = horaSalida;
  }

  public Integer getParadaOrigen() {
    return paradaOrigen;
  }

  public void setParadaOrigen(Integer paradaOrigen) {
    this.paradaOrigen = paradaOrigen;
  }

  public Integer getParadaDestino() {
    return paradaDestino;
  }

  public void setParadaDestino(Integer paradaDestino) {
    this.paradaDestino = paradaDestino;
  }
}
