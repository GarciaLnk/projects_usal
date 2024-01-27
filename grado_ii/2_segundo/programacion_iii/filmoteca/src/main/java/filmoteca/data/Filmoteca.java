package filmoteca.data;

import java.io.Serializable;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

class Filmoteca implements Serializable {

  static final String BIN_PELICULAS = "peliculas.bin";
  static final String BIN_DIRECTORES = "directores.bin";
  static final String BIN_ACTORES = "actores.bin";
  static final String TXT_PELICULAS = "peliculas.txt";
  static final String TXT_DIRECTORES = "directores.txt";
  static final String TXT_ACTORES = "actores.txt";
  static final String COL_DIRECTORES = "directores.col";
  static final String HTML_PELICULAS = "peliculas.html";
  private static final long serialVersionUID = 11L;
  private static final String NOMBRE_CARPETA = "Filmot18";
  private static final String NO_AVAILABLE = Pelicula.NO_AVAILABLE;
  private List<Pelicula> peliculas = new ArrayList<>();
  private List<Director> directores = new ArrayList<>();
  private List<Actor> actores = new ArrayList<>();

  void crearPelicula(String titulo, Integer anno, Integer duracion, String pais, String direccion,
      String guion, String musica, String fotografia, String reparto, String productora,
      String genero, String sinopsis, String delimDirAct) {

    Pelicula peliculaBuscada = buscarPelicula(titulo, peliculas);
    if (peliculaBuscada != null) {
      peliculaBuscada.setAnno(anno);
      peliculaBuscada.setDuracion(duracion);
      peliculaBuscada.setPais(pais);
      peliculaBuscada.setDireccion(importDirectores(peliculaBuscada, direccion, delimDirAct));
      peliculaBuscada.setGuion(guion);
      peliculaBuscada.setMusica(musica);
      peliculaBuscada.setFotografia(fotografia);
      peliculaBuscada.setReparto(importActores(peliculaBuscada, reparto, delimDirAct));
      peliculaBuscada.setProductora(productora);
      peliculaBuscada.setGenero(genero);
      peliculaBuscada.setSinopsis(sinopsis);
    } else {
      Pelicula p = new Pelicula(titulo, anno, duracion, pais, guion, musica, fotografia, productora,
          genero, sinopsis);
      p.setDireccion(importDirectores(p, direccion, delimDirAct));
      p.setReparto(importActores(p, reparto, delimDirAct));
      peliculas.add(p);
    }
  }

  void crearDirector(String nombre, LocalDate fechaNac, String nacion, String ocupacion,
      String peliculas, String delimPeli) {

    Director directorBuscado = buscarDirector(nombre, directores);
    if (directorBuscado != null) {
      directorBuscado.setFechaNac(fechaNac);
      directorBuscado.setNacion(nacion);
      directorBuscado.setOcupacion(ocupacion);
      directorBuscado.setPeliculas(importPeliculas(directorBuscado, peliculas, delimPeli));
    } else {
      Director d = new Director(nombre, fechaNac, nacion, ocupacion);
      d.setPeliculas(importPeliculas(d, peliculas, delimPeli));
      directores.add(d);
    }
  }

  void crearActor(String nombre, LocalDate fechaNac, String nacion, Integer annoDebut,
      String peliculas, String delimPeli) {

    Actor actorBuscado = buscarActor(nombre, actores);
    if (actorBuscado != null) {
      actorBuscado.setFechaNac(fechaNac);
      actorBuscado.setNacion(nacion);
      actorBuscado.setAnnoDebut(annoDebut);
      actorBuscado.setPeliculas(importPeliculas(actorBuscado, peliculas, delimPeli));
    } else {
      Actor a = new Actor(nombre, fechaNac, nacion, annoDebut);
      a.setPeliculas(importPeliculas(a, peliculas, delimPeli));
      actores.add(a);
    }
  }

  private List<Pelicula> importPeliculas(Persona persona, String peliculas, String delim) {
    if (peliculas.equals(NO_AVAILABLE)) {
      return Collections.emptyList();
    }

    List<Pelicula> peliculaList = persona.getPeliculas();
    String[] peliculaArray = peliculas.split(delim);

    for (String tituloPelicula : peliculaArray) {
      if (buscarPelicula(tituloPelicula, peliculaList) == null) {
        Pelicula p = new Pelicula(tituloPelicula);
        peliculaList.add(p);
      }
    }

    return peliculaList;
  }

  private List<Director> importDirectores(Pelicula p, String directores, String delim) {
    if (directores.equals(NO_AVAILABLE)) {
      return Collections.emptyList();
    }

    List<Director> directorList = p.getDireccion();
    String[] directorArray = directores.split(delim);

    for (String nombreDirector : directorArray) {
      Director directorBuscado = buscarDirector(nombreDirector, this.directores);
      if (directorBuscado != null) {
        directorBuscado.getPeliculas().add(p);
        directorList.add(directorBuscado);
      } else {
        Director d = new Director(nombreDirector);
        d.getPeliculas().add(p);
        directorList.add(d);
        this.directores.add(d);
      }
    }

    return directorList;
  }

  private List<Actor> importActores(Pelicula p, String actores, String delim) {
    if (actores.equals(NO_AVAILABLE)) {
      return Collections.emptyList();
    }

    List<Actor> actorList = p.getReparto();
    String[] actorArray = actores.split(delim);

    for (String nombreActor : actorArray) {
      Actor actorBuscado = buscarActor(nombreActor, this.actores);
      if (actorBuscado != null) {
        actorBuscado.getPeliculas().add(p);
        actorList.add(actorBuscado);
      } else {
        Actor a = new Actor(nombreActor);
        a.getPeliculas().add(p);
        actorList.add(a);
        this.actores.add(a);
      }
    }

    return actorList;
  }

  boolean eliminarPelicula(String titulo) {
    Pelicula peliculaEliminar = buscarPelicula(titulo, peliculas);

    if (peliculaEliminar != null) {
      for (Actor actorGuardado : actores) {
        Pelicula peliculaActorEliminar = buscarPelicula(titulo, actorGuardado.getPeliculas());
        if (peliculaActorEliminar != null) {
          actorGuardado.getPeliculas().remove(peliculaActorEliminar);
        }
      }

      for (Director directorGuardado : directores) {
        Pelicula peliculaDirectorEliminar = buscarPelicula(titulo, directorGuardado.getPeliculas());
        if (peliculaDirectorEliminar != null) {
          directorGuardado.getPeliculas().remove(peliculaDirectorEliminar);
        }
      }

      peliculas.remove(peliculaEliminar);
      return true;
    } else {
      return false;
    }
  }

  String eliminarDirector(String nombre) {
    boolean enPelicula = false;
    String peliculasDirector;
    StringBuilder sb = new StringBuilder();
    Director directorEliminar = buscarDirector(nombre, directores);
    String prefix = "";

    if (directorEliminar != null) {
      for (Pelicula peliculaBuscada : peliculas) {
        Director directorPelicula = buscarDirector(nombre, peliculaBuscada.getDireccion());
        if (directorPelicula != null) {
          enPelicula = true;
          sb.append(prefix);
          prefix = ", ";
          sb.append(peliculaBuscada.getTitulo());
        }
      }

      if (!enPelicula) {
        directores.remove(directorEliminar);
        peliculasDirector = "_exito";
      } else {
        peliculasDirector = sb.toString();
      }
      return peliculasDirector;
    } else {
      return "_noEncontrado";
    }
  }

  String eliminarActor(String nombre) {
    boolean enPelicula = false;
    String peliculasActor;
    StringBuilder sb = new StringBuilder();
    Actor actorEliminar = buscarActor(nombre, actores);
    String prefix = "";

    if (actorEliminar != null) {
      for (Pelicula peliculaBuscada : peliculas) {
        Actor actorPelicula = buscarActor(nombre, peliculaBuscada.getReparto());
        if (actorPelicula != null) {
          enPelicula = true;
          sb.append(prefix);
          prefix = ", ";
          sb.append(peliculaBuscada.getTitulo());
        }
      }

      if (!enPelicula) {
        actores.remove(actorEliminar);
        peliculasActor = "_exito";
      } else {
        peliculasActor = sb.toString();
      }
      return peliculasActor;
    } else {
      return "_noEncontrado";
    }
  }

  Pelicula buscarPelicula(String titulo, List<Pelicula> peliculas) {
    for (Pelicula peliculaBuscada : peliculas) {
      if (titulo.equalsIgnoreCase(peliculaBuscada.getTitulo())) {
        return peliculaBuscada;
      }
    }
    return null;
  }

  Director buscarDirector(String nombre, List<Director> directores) {
    for (Director directorGuardado : directores) {
      if (nombre.equalsIgnoreCase(directorGuardado.getNombre())) {
        return directorGuardado;
      }
    }
    return null;
  }

  Actor buscarActor(String nombre, List<Actor> actores) {
    for (Actor actorGuardado : actores) {
      if (nombre.equalsIgnoreCase(actorGuardado.getNombre())) {
        return actorGuardado;
      }
    }
    return null;
  }

  String getPeliculasAsTable(List<Pelicula> peliculas) {
    StringBuilder sb = new StringBuilder();
    String prefix = "";

    for (Pelicula p : peliculas) {
      sb.append(prefix);
      prefix = "\n";
      sb.append(p.peliculaToTable());
    }

    return sb.toString();
  }

  String getDirectoresAsTable() {
    StringBuilder sb = new StringBuilder();
    String prefix = "";

    for (Director d : directores) {
      sb.append(prefix);
      prefix = "\n";
      sb.append(d.directorToTable()).append(d.peliculasToTableField());
    }

    return sb.toString();
  }

  String getActoresAsTable() {
    StringBuilder sb = new StringBuilder();
    String prefix = "";

    for (Actor a : actores) {
      sb.append(prefix);
      prefix = "\n";
      sb.append(a.actorToTable()).append(a.peliculasToTableField());
    }

    return sb.toString();
  }

  String getNombreCarpeta() {
    return NOMBRE_CARPETA;
  }

  List<Pelicula> getPeliculas() {
    return peliculas;
  }

  void setPeliculas(List<Pelicula> peliculas) {
    this.peliculas = peliculas;
  }

  List<Director> getDirectores() {
    return directores;
  }

  void setDirectores(List<Director> directores) {
    this.directores = directores;
  }

  List<Actor> getActores() {
    return actores;
  }

  void setActores(List<Actor> actores) {
    this.actores = actores;
  }
}
