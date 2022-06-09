package es.usal.pa.agent;

import jade.core.Agent;
import java.util.Arrays;
import java.util.Vector;

public class CyclicBehaviourLinea2 extends CyclicBehaviourLinea {
  private static final long serialVersionUID = 1L;

  public CyclicBehaviourLinea2(Agent a) {
    super(a);

    Vector<Integer> listaParadas = new Vector<Integer>(Arrays.asList(11, 4, 12, 9, 13));
    Vector<Float> listaTiempos = new Vector<Float>(Arrays.asList(3f, 4f, 3f, 2f));
    Vector<Float> horarioSalidaInicial = new Vector<Float>(Arrays.asList(1f, 7f, 15f, 320f, 350f));

    linea.setVectorParadas(listaParadas);
    linea.setVectorTiempos(listaTiempos);
    linea.setHorarioSalidas(horarioSalidaInicial);
    linea.setNumLinea(2);
    linea.calcularHorarioSalidaParadas();
  }
}
