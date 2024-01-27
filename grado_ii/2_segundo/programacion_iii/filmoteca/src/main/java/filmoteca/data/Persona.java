package filmoteca.data;

import java.io.Serializable;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

class Persona implements Serializable {

  static final String NO_AVAILABLE = Pelicula.NO_AVAILABLE;
  static final long serialVersionUID = 11L;
  private final String nombre;
  private LocalDate fechaNac;
  private String nacion;
  private List<Pelicula> peliculas = new ArrayList<>();

  Persona(String nombre) {
    this.nombre = nombre;
    nacion = NO_AVAILABLE;
  }

  Persona(String nombre, LocalDate fechaNac, String nacion) {
    this.nombre = nombre;
    this.fechaNac = fechaNac;
    this.nacion = nacion;
  }

  String peliculasToString() {
    if (getPeliculas() == null || getPeliculas().isEmpty()) {
      return NO_AVAILABLE;
    }

    StringBuilder sb = new StringBuilder();
    String prefix = "";
    for (Pelicula p : getPeliculas()) {
      sb.append(prefix);
      prefix = ", ";
      sb.append(p.getTitulo());
    }
    return sb.toString();
  }

  String peliculasToTableField() {
    return String.format(" %-150s |", peliculasToString());
  }

  String getNombre() {
    return nombre;
  }

  LocalDate getFechaNac() {
    return fechaNac;
  }

  void setFechaNac(LocalDate fechaNac) {
    if (fechaNac != null) {
      this.fechaNac = fechaNac;
    }
  }

  String getNacion() {
    return nacion;
  }

  void setNacion(String nacion) {
    if (!nacion.equals(NO_AVAILABLE)) {
      this.nacion = nacion;
    }
  }

  List<Pelicula> getPeliculas() {
    return peliculas;
  }

  void setPeliculas(List<Pelicula> peliculas) {
    if (!peliculas.isEmpty()) {
      this.peliculas = peliculas;
    }
  }
}
