package filmoteca.data;

import java.time.LocalDate;

class Actor extends Persona {

  private static final long serialVersionUID = 11L;
  private Integer annoDebut;

  Actor(String nombre) {
    super(nombre);
  }

  Actor(String nombre, LocalDate fechaNac, String nacion, Integer annoDebut) {
    super(nombre, fechaNac, nacion);
    this.annoDebut = annoDebut;
  }

  String actorToTable() {
    return String.format("| %-20s | %-16s | %-15s | %-9s |", getNombre(),
        (getFechaNac() != null) ? getFechaNac() : NO_AVAILABLE, getNacion(),
        (getAnnoDebut() != null) ? getAnnoDebut() : NO_AVAILABLE);
  }

  Integer getAnnoDebut() {
    return annoDebut;
  }

  void setAnnoDebut(Integer annoDebut) {
    if (annoDebut != null) {
      this.annoDebut = annoDebut;
    }
  }
}
