package es.usal.pa.agent;

import jade.core.Agent;
import java.util.Arrays;
import java.util.Vector;

public class CyclicBehaviourLinea1 extends CyclicBehaviourLinea {
  private static final long serialVersionUID = 1L;

  public CyclicBehaviourLinea1(Agent a) {
    super(a);

    Vector<Integer> listaParadas =
        new Vector<Integer>(Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10));
    Vector<Float> listaTiempos =
        new Vector<Float>(Arrays.asList(2f, 3f, 2f, 7f, 1f, 4f, 3f, 2f, 1f));
    Vector<Float> horarioSalidaInicial = new Vector<Float>(Arrays.asList(1f, 2f, 150f, 200f, 300f));

    linea.setVectorParadas(listaParadas);
    linea.setVectorTiempos(listaTiempos);
    linea.setHorarioSalidas(horarioSalidaInicial);
    linea.setNumLinea(1);
    linea.calcularHorarioSalidaParadas();
  }
}
