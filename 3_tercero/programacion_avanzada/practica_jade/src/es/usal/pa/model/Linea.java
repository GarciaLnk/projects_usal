package es.usal.pa.model;

import java.io.Serializable;
import java.util.Hashtable;
import java.util.Vector;

public class Linea implements Serializable {
  private static final long serialVersionUID = 1L;

  Vector<Integer> vectorParadas;
  Vector<Float> horarioSalidas;
  Vector<Float> vectorTiempos = new Vector<Float>();
  Hashtable<Integer, Vector<LlegadaLinea>> horarioSalidaParadas =
      new Hashtable<Integer, Vector<LlegadaLinea>>();
  Integer numLinea;

  public Linea() {
    super();
  }

  public Linea(Vector<Integer> vectorParadas, Vector<Float> horarioSalidas,
      Vector<Float> vectorTiempos, Integer numLinea) {
    super();
    if (!vectorParadas.isEmpty()) {
      this.vectorParadas = vectorParadas;
    }

    if (!horarioSalidas.isEmpty()) {
      this.horarioSalidas = horarioSalidas;
    }

    this.vectorTiempos.add(0.0f);
    this.vectorTiempos.addAll(vectorTiempos);

    calcularHorarioSalidaParadas();
  }

  public Vector<Integer> getVectorParadas() {
    return vectorParadas;
  }

  public void setVectorParadas(Vector<Integer> vectorParadas) {
    if (!vectorParadas.isEmpty()) {
      this.vectorParadas = vectorParadas;
    }
  }

  public Vector<Float> getHorarioSalidas() {
    return horarioSalidas;
  }

  public void setHorarioSalidas(Vector<Float> horarioSalidas) {
    if (!horarioSalidas.isEmpty()) {
      this.horarioSalidas = horarioSalidas;
    }
  }

  public Vector<Float> getVectorTiempos() {
    return vectorTiempos;
  }

  public void setVectorTiempos(Vector<Float> vectorTiempos) {
    this.vectorTiempos.clear();
    this.vectorTiempos.add(0.0f);
    this.vectorTiempos.addAll(vectorTiempos);
  }

  public Hashtable<Integer, Vector<LlegadaLinea>> getHorarioSalidaParadas() {
    return horarioSalidaParadas;
  }

  public void calcularHorarioSalidaParadas() {
    Float[] tiempoAcumulado = new Float[horarioSalidas.size()];
    for (int i = 0; i < horarioSalidas.size(); i++) {
      tiempoAcumulado[i] = horarioSalidas.get(i);
    }

    horarioSalidaParadas.clear();

    for (int i = 0; i < vectorParadas.size(); i++) {
      Vector<LlegadaLinea> vectorLlegadaLinea = new Vector<LlegadaLinea>();
      horarioSalidaParadas.put(vectorParadas.get(i), vectorLlegadaLinea);
      for (int j = 0; j < horarioSalidas.size(); j++) {
        tiempoAcumulado[j] += vectorTiempos.get(i);
        horarioSalidaParadas.get(vectorParadas.get(i))
            .add(new LlegadaLinea(numLinea, tiempoAcumulado[j]));
      }
    }
  }

  public Integer getNumLinea() {
    return numLinea;
  }

  public void setNumLinea(Integer numLinea) {
    this.numLinea = numLinea;
  }
}
