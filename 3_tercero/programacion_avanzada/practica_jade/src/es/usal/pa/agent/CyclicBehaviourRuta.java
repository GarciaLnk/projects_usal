package es.usal.pa.agent;

import es.usal.pa.model.Conexion;
import es.usal.pa.model.Linea;
import es.usal.pa.model.LlegadaLinea;
import es.usal.pa.model.ParadaRecorrido;
import es.usal.pa.model.Recorrido;
import es.usal.pa.model.Usuario;
import jade.core.Agent;
import jade.core.behaviours.CyclicBehaviour;
import jade.lang.acl.ACLMessage;
import jade.lang.acl.MessageTemplate;
import jade.lang.acl.UnreadableException;
import java.io.IOException;
import java.io.Serializable;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;

public class CyclicBehaviourRuta extends CyclicBehaviour {
  private static final long serialVersionUID = 1L;

  public CyclicBehaviourRuta(Agent a) {
    super(a);
  }

  @Override
  public void action() {
    ACLMessage msgUsuario =
        this.myAgent.blockingReceive(MessageTemplate.MatchPerformative(ACLMessage.REQUEST));

    try {
      Utils.enviarMensaje(this.myAgent, "linea", null);

      // construir el mapa de paradas con los tiempos de llegadas a cada parada
      // calculo tablas de llegada a cada parada
      Hashtable<Integer, Vector<LlegadaLinea>> hashtableParadas =
          new Hashtable<Integer, Vector<LlegadaLinea>>();
      Hashtable<Hashtable<Integer, Integer>, Float> tiempos =
          new Hashtable<Hashtable<Integer, Integer>, Float>();
      Hashtable<Integer, Vector<Conexion>> hashtableGrafo =
          new Hashtable<Integer, Vector<Conexion>>();

      ACLMessage msgLinea1 = this.myAgent
          .blockingReceive(MessageTemplate.and(MessageTemplate.MatchPerformative(ACLMessage.INFORM),
              MessageTemplate.MatchOntology("ontologia1")));

      Linea linea1 = (Linea) msgLinea1.getContentObject();
      agregarHorarioLinea(linea1.getHorarioSalidaParadas(), hashtableParadas);
      cargarMapaTiempos(linea1.getVectorParadas(), linea1.getVectorTiempos(), tiempos);
      crearGrafo(linea1.getVectorParadas(), linea1.getNumLinea(), hashtableGrafo);

      ACLMessage msgLinea2 = this.myAgent
          .blockingReceive(MessageTemplate.and(MessageTemplate.MatchPerformative(ACLMessage.INFORM),
              MessageTemplate.MatchOntology("ontologia2")));

      Linea linea2 = (Linea) msgLinea2.getContentObject();
      agregarHorarioLinea(linea2.getHorarioSalidaParadas(), hashtableParadas);
      cargarMapaTiempos(linea2.getVectorParadas(), linea2.getVectorTiempos(), tiempos);
      crearGrafo(linea2.getVectorParadas(), linea2.getNumLinea(), hashtableGrafo);

      Usuario usuario = (Usuario) msgUsuario.getContentObject();

      // calcular el recorrido mas corto
      Recorrido recorrido = new Recorrido();
      recorrido.setHora(usuario.getHoraSalida());
      recorrido.getVectorParadas().add(new ParadaRecorrido(usuario.getParadaOrigen(), null));

      Recorrido recorridoOptimo = new Recorrido();
      recorridoOptimo.setVectorParadas(new Vector<ParadaRecorrido>());
      calcularRecorridoMinimo(recorrido, usuario.getParadaDestino(), hashtableGrafo,
          hashtableParadas, tiempos, recorridoOptimo);
      recorridoOptimo.calcularParadaFinal();

      ACLMessage msg = msgUsuario.createReply();
      msg.setPerformative(ACLMessage.INFORM);
      msg.setContentObject((Serializable) recorridoOptimo);
      this.myAgent.send(msg);
    } catch (UnreadableException e) {
      e.printStackTrace();
    } catch (IOException e) {
      e.printStackTrace();
    } catch (CloneNotSupportedException e) {
      e.printStackTrace();
    }
  }

  private void calcularRecorridoMinimo(Recorrido recorrido, Integer paradaDestino,
      Hashtable<Integer, Vector<Conexion>> hashtableGrafo,
      Hashtable<Integer, Vector<LlegadaLinea>> hashtableParadas,
      Hashtable<Hashtable<Integer, Integer>, Float> tiempos, Recorrido recorridoOptimo)
      throws CloneNotSupportedException {
    Integer origenParada =
        recorrido.getVectorParadas().get(recorrido.getVectorParadas().size() - 1).getParada();
    Vector<Conexion> vectorParadas = hashtableGrafo.get(origenParada);
    Vector<LlegadaLinea> vectorLlegadaLinea = hashtableParadas.get(origenParada);

    if (origenParada.equals(paradaDestino)) {
      if (recorridoOptimo.getHora() == null || recorridoOptimo.getHora() > recorrido.getHora()) {
        recorridoOptimo.getVectorParadas().clear();

        for (ParadaRecorrido parada : recorrido.getVectorParadas()) {
          recorridoOptimo.getVectorParadas().add((ParadaRecorrido) parada.clone());
        }

        recorridoOptimo.setHora(recorrido.getHora());
      }

      return;
    }

    if (vectorParadas == null) {
      return;
    }

    for (LlegadaLinea llegadaLinea : vectorLlegadaLinea) {
      if (recorrido.getHora() <= llegadaLinea.getHora()) {
        recorrido.getVectorParadas().get(recorrido.getVectorParadas().size() - 1)
            .setLlegadaLinea(llegadaLinea);

        for (Conexion conexion : vectorParadas) {
          if (!conexion.getLinea().equals(llegadaLinea.getLinea())) {
            continue;
          }

          Integer destinoParada = conexion.getParada();
          Float tiempoAnterior;

          recorrido.getVectorParadas().add(new ParadaRecorrido(destinoParada, null));
          tiempoAnterior = recorrido.getHora();

          Hashtable<Integer, Integer> clave = new Hashtable<Integer, Integer>();
          clave.put(origenParada, destinoParada);
          recorrido.setHora(llegadaLinea.getHora() + tiempos.get(clave));

          calcularRecorridoMinimo(recorrido, paradaDestino, hashtableGrafo, hashtableParadas,
              tiempos, recorridoOptimo);
          recorrido.getVectorParadas().remove(recorrido.getVectorParadas().size() - 1);
          recorrido.setHora(tiempoAnterior);
        }
      }
    }
  }

  private void crearGrafo(Vector<Integer> vectorParadas, Integer numLinea,
      Hashtable<Integer, Vector<Conexion>> hashtableGrafo) {
    for (int i = 0; i < vectorParadas.size() - 1; i++) {
      Vector<Conexion> vectorConexiones;

      if (hashtableGrafo.get(vectorParadas.get(i)) == null) {
        vectorConexiones = new Vector<Conexion>();
      } else {
        vectorConexiones = hashtableGrafo.get(vectorParadas.get(i));
      }

      vectorConexiones.add(new Conexion(vectorParadas.get(i + 1), numLinea));
      hashtableGrafo.put(vectorParadas.get(i), vectorConexiones);
    }
  }

  private void cargarMapaTiempos(Vector<Integer> vectorParadas, Vector<Float> vectorTiempos,
      Hashtable<Hashtable<Integer, Integer>, Float> tiempos) {
    for (int i = 1; i < vectorParadas.size(); i++) {
      Hashtable<Integer, Integer> tmp = new Hashtable<Integer, Integer>();
      tmp.put(vectorParadas.get(i - 1), vectorParadas.get(i));
      tiempos.put(tmp, vectorTiempos.get(i));
    }
  }

  private void agregarHorarioLinea(Hashtable<Integer, Vector<LlegadaLinea>> hashtableParadas,
      Hashtable<Integer, Vector<LlegadaLinea>> hashtableParadasFinal) {
    Enumeration<Integer> claves = hashtableParadas.keys();
    Integer clave;

    while (claves.hasMoreElements()) {
      clave = claves.nextElement();

      if (hashtableParadasFinal.get(clave) == null) {
        hashtableParadasFinal.put(clave, hashtableParadas.get(clave));
      } else {
        hashtableParadasFinal.get(clave).addAll(hashtableParadas.get(clave));
      }
    }
  }
}
