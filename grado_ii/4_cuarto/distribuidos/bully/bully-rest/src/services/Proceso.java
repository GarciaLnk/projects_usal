package services;

import java.util.Random;
import java.util.concurrent.ExecutionException;

public class Proceso implements Runnable {
  protected final Object respuestaLock = new Object();
  protected final Object coordinadorLock = new Object();
  private final Servicio miServicio;
  private Integer id;
  private Integer idCoordinador;
  private TipoEstadoEleccion estadoEleccion;
  private boolean activo;
  private boolean respuesta;
  private Integer coordinador;
  private boolean eleccionEnMarcha;

  private enum TipoEstadoEleccion {
    ACUERDO, ELECCION_ACTIVA, ELECCION_PASIVA, INICIANDO
  }

  // Constructor del proceso
  // - id: identificador único del proceso
  // - miServicio: referencia al servidor que crea el proceso
  public Proceso(Integer id, Servicio miServicio) {
    this.id = id;
    this.miServicio = miServicio;
    this.estadoEleccion = TipoEstadoEleccion.INICIANDO;
    this.activo = true;
    this.eleccionEnMarcha = false;
    this.coordinador = -1;
  }

  @Override
  public void run() {
    try {
      // Inicia la elección
      eleccion();
      // Bucle a ejecutar mientras el proceso esté activo
      while (activo) {
        Random rand = new Random();
        // Hace un sleep de 0.5-1s
        Thread.sleep(rand.nextInt(500) + 500);

        // Obtiene el valor de computar del coordinador
        Integer valor = miServicio.computar(coordinador);
        if (valor < 0) {
          // Si el coordinador no está activo se inician elecciones
          eleccion();
        }
      }
    } catch (InterruptedException | ExecutionException e) {
      e.printStackTrace();
    }
  }

  // Funcion computar usada para detectar si el coordinador está vivo
  // Devuelve 1 si está activo y -1 si no
  public Integer computar() {
    if (activo) {
      try {
        Random rand = new Random();
        // Hace un sleep de 0.1-3s
        Thread.sleep(rand.nextInt(100) + 200);
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
      return 1;
    }
    return -1;
  }

  // Función de elección de un líder (coordinador) basada en el algoritmo Bully
  public void eleccion() throws InterruptedException, ExecutionException {
    // Si el proceso no está activo o ya está involucrado en una elección sale de la función
    if (activo && !eleccionEnMarcha) {
      eleccionEnMarcha = true; // Indica que el proceso está en una elección
      boolean fin = false;
      // Bucle a ejecutar hasta que se finalice la elección
      while (!fin) {
        estadoEleccion = TipoEstadoEleccion.ELECCION_ACTIVA;

        // Si el ID del proceso es igual al ID máximo de todos los procesos, el propio proceso se
        // proclama coordinador
        if (miServicio.getMaxId().equals(id)) {
          coordinador = id;
          estadoEleccion = TipoEstadoEleccion.ACUERDO;
          // Llamada asíncrona para enviar a todos los procesos el coordinador
          new Thread(() -> {
            try {
              miServicio.setTodosCoordinador(id);
            } catch (InterruptedException | ExecutionException e) {
              e.printStackTrace();
            }
          }).start();
          eleccionEnMarcha = false; // Fin de la elección
          return;
        }

        // Llamada asíncrona para iniciar una elección en todos los procesos cuyo ID sea superior al
        // del proceso que inicia la elección
        new Thread(() -> {
          try {
            miServicio.iniciarEleccionTodos(id);
          } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
          }
        }).start();

        respuesta = false;
        // El proceso espera como máximo 1s para recibir una respuesta
        synchronized (this.respuestaLock) {
          try {
            this.respuestaLock.wait(1000);
          } catch (InterruptedException e) {
            e.printStackTrace();
          }
        }

        if (respuesta) {
          estadoEleccion = TipoEstadoEleccion.ELECCION_PASIVA;
          coordinador = -1;
          // Si se recibe una respuesta el proceso se queda esperando como máximo 1s para recibir un
          // coordinador
          synchronized (this.coordinadorLock) {
            try {
              this.coordinadorLock.wait();
            } catch (InterruptedException e) {
              e.printStackTrace();
            }
          }

          if (coordinador > 0) {
            estadoEleccion = TipoEstadoEleccion.ACUERDO;
            // Si se recibe un coordinador se finaliza la elección
            eleccionEnMarcha = false;
            return;
          }
          // Si no, continúa el bucle...
        } else {
          coordinador = id;
          estadoEleccion = TipoEstadoEleccion.ACUERDO;
          // Si no se recibe ninguna respuesta de otro proceso, el propio proceso se proclama
          // coordinador
          new Thread(() -> {
            try {
              miServicio.setTodosCoordinador(id);
            } catch (InterruptedException | ExecutionException e) {
              e.printStackTrace();
            }
          }).start();
          eleccionEnMarcha = false;
          fin = true; // Fin de la elección
        }
      }
    }
  }

  public Integer getId() {
    return id;
  }

  public void setId(Integer id) {
    this.id = id;
  }

  public String getEstadoEleccion() {
    return estadoEleccion.toString();
  }

  public boolean isActivo() {
    return activo;
  }

  public void setActivo(boolean activo) {
    this.activo = activo;
  }

  public void setRespuesta(boolean respuesta) {
    this.respuesta = respuesta;
  }

  public void setCoordinador(Integer coordinador) {
    this.coordinador = coordinador;
  }

  public Integer getIdCoordinador() {
    return idCoordinador;
  }

  public void setIdCoordinador(Integer idCoordinador) {
    this.idCoordinador = idCoordinador;
  }

}
