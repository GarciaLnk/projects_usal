package filmoteca.data;

import java.time.LocalDate;

class Director extends Persona {

  private static final long serialVersionUID = 11L;
  private String ocupacion;

  Director(String nombre) {
    super(nombre);
    ocupacion = NO_AVAILABLE;
  }

  Director(String nombre, LocalDate fechaNac, String nacion, String ocupacion) {
    super(nombre, fechaNac, nacion);
    this.ocupacion = ocupacion;
  }

  String directorToCol() {
    String tab = "\t";

    return getNombre()
        + tab
        + ((getFechaNac() != null) ? getFechaNac() : NO_AVAILABLE)
        + tab
        + getNacion()
        + tab
        + getOcupacion()
        + tab
        + peliculasToString();
  }

  String directorToTable() {
    return String.format(
        "| %-20s | %-16s | %-15s | %-65s |",
        getNombre(),
        (getFechaNac() != null) ? getFechaNac() : NO_AVAILABLE,
        getNacion(),
        getOcupacion());
  }

  private String getOcupacion() {
    return ocupacion;
  }

  void setOcupacion(String ocupacion) {
    if (!ocupacion.equals(NO_AVAILABLE)) {
      this.ocupacion = ocupacion;
    }
  }
}
