package services;

import java.util.HashMap;
import java.util.Map;
import javax.inject.Singleton;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;

@Singleton
@Path("carrera100")
public class Carrera100 {
  private int numAtletasTotal;
  private long tiempoInicio;
  private Map<Integer, Float> tiempo = new HashMap<Integer, Float>();
  private int numPreparados = 0;
  private int numListos = 0;
  private int numLlegada = 0;
  private int numDorsal = 0;
  private String resultados;
  private Object lock = new Object();
  private boolean carreraIniciada = false;

  /**
   * Reinicia la carrera.
   */
  @Path("reinicio")
  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public String reinicio(@QueryParam("num") int num) {
    synchronized (lock) {
      if (!carreraIniciada) {
        carreraIniciada = true;
        numPreparados = 0;
        numListos = 0;
        numLlegada = 0;
        numDorsal = 0;
        tiempo.clear();
        resultados = "";
        numAtletasTotal = num;

        return "\nReinicio\n\n";
      } else {
        return "";
      }
    }
  }

  /**
   * Espera a que todos los atletas hayan llamado a preparado.
   */
  @Path("preparado")
  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public String preparado() {
    synchronized (lock) {
      if (numPreparados < numAtletasTotal - 1) {
        numPreparados++;

        try {
          lock.wait();
        } catch (InterruptedException e) {
          e.printStackTrace();
        }
      } else {
        lock.notifyAll();
        return "Preparados\n";
      }
    }

    return "";
  }

  /**
   * Espera a que todos los atletas hayan llamado a listos.
   */
  @Path("listo")
  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public String listo() {
    synchronized (lock) {
      if (numListos < numAtletasTotal - 1) {
        numListos++;

        try {
          lock.wait();
        } catch (InterruptedException e) {
          e.printStackTrace();
        }
      } else {
        lock.notifyAll();
        tiempoInicio = System.currentTimeMillis();
        return "Listos\nYa!\n";
      }
    }

    return "";
  }

  /**
   * Almacena el tiempo de llegada del atleta.
   */
  @Path("llegada")
  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public String llegada(@QueryParam("dorsal") int dorsal) {
    synchronized (lock) {
      numLlegada++;
      tiempo.put(dorsal, (float) (System.currentTimeMillis() - tiempoInicio) / (float) 1000);
      resultados = resultados.concat(dorsal + " tarda " + tiempo.get(dorsal) + "\n");
    }

    if (numLlegada == numAtletasTotal) {
      return "true&" + tiempo.get(dorsal);
    } else {
      return "false&" + tiempo.get(dorsal);
    }
  }

  /**
   * Devuelve los resultados de la carrera.
   */
  @Path("resultados")
  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public String resultados() {
    carreraIniciada = false;

    return "\nResultados:\n" + resultados;
  }

  /**
   * Devuelve el dorsal a asignar al atleta.
   */
  @Path("dorsal")
  @GET
  @Produces(MediaType.TEXT_PLAIN)
  public String getDorsal() {
    synchronized (lock) {
      numDorsal++;
      return "" + numDorsal;
    }
  }
}
