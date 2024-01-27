; Algoritmo de unificación en LISP
; Autores: Alberto García Martín
;          Iván Campos Alamillo

(defvar fallo 'FALLO)

; Determina si exp es una variable
(defun esvar (exp)
  (cond ((and (listp exp) (equal (first exp) '?)) t)
        (t nil)))

; Determina si exp es un atomo o variable
(defun atomovar (exp)
  (cond ((atom exp) t)
        ((esvar exp) t)
        (t nil)))

; Determina si un elemento pertenece a la lista
(defun no_miembro (elemento lista)
  (if (listp lista)
      (cond ((equal elemento (first lista)) nil)
            ((equal lista '()) t)
            (t (not (member elemento (rest lista)))))
      t))

; Primera parte del algoritmo de unificacion
(defun unif_cabeza (e1 e2)
  (cond ((equal e1 e2) '())
        ((esvar e1) (if (no_miembro e1 e2) (list (list e2 e1)) fallo))
        ((esvar e2) (list (list e1 e2)))
        (t fallo)))

; Devuelve el primer elemento de P1 sustituido por su correspondiente constante,
; en caso de que haya una regla en S1 que coincida
(defun comprobar_reglas (s1 p1)
  (let ((r1 (first s1)))
    (if (equal r1 '()) (first p1)
        (if (equal (second r1) (first p1)) (first r1)
            (comprobar_reglas (rest s1) p1)))))

; Realiza la aplicación de S1 sobre P1
(defun aplicar (s1 p1)
  (if (equal s1 nil) (return-from aplicar p1))
  (unless (equal p1 '())
    (if (and (listp (first p1)) (not (esvar (first p1))))
        (cons (aplicar s1 (first p1)) (aplicar s1 (rest p1)))
        (cons (comprobar_reglas s1 p1) (aplicar s1 (rest p1))))))

; Devuelve la aplicación de S2 sobre los numeradores de S1, para la composición
(defun aplicar_num (s2 s1)
  (unless (equal s1 '())
    (cond ((esvar (first (first s1)))
            (cons
              (nconc (aplicar s2 (list (first (first s1)))) (rest (first s1)))
              (aplicar_num s2 (rest s1))))
          ((listp (first (first s1)))
            (cons
              (cons (aplicar s2 (first (first s1))) (rest (first s1)))
              (aplicar_num s2 (rest s1))))
          (t (cons (first s1) (aplicar_num s2 (rest s1)))))))

; Determina si el denominador de R1 aparece en S1, para la composición
(defun no_den_miembro (r1 s1)
  (cond ((equal s1 '()) t)
        ((equal (second r1) (second (first s1))) nil)
        (t (no_den_miembro r1 (rest s1)))))

; Devuelve las reglas de S2 que no aparecen en S1, para la composición
(defun reglas_extra (s1 s2)
  (unless (equal s2 '())
    (if (no_den_miembro (first s2) s1)
        (cons (first s2) (reglas_extra s1 (rest s2)))
        (reglas_extra s1 (rest s2)))))

; Realiza la composición de S1 y S2
(defun componer (s1 s2)
  (cond ((equal s1 nil) (return-from componer s2))
        ((equal s2 nil) (return-from componer s1)))
  (nconc (aplicar_num s2 s1) (reglas_extra s1 s2)))

; Segunda parte del algoritmo de unificacion
(defun unif_lista (e1 e2)
  (let ((z1 (unificar (first e1) (first e2))))
    (when (equal z1 fallo) (return-from unif_lista fallo))
    (let ((z2 (unificar (aplicar z1 (rest e1)) (aplicar z1 (rest e2)))))
      (when (equal z2 fallo) (return-from unif_lista fallo))
      (componer z1 z2))))

(defun unificar (e1 e2)
  (handler-case
      (cond ((atomovar e1) (unif_cabeza e1 e2))
            ((atomovar e2) (unif_cabeza e2 e1))
            (t (unif_lista e1 e2)))
    (error (fallo))))
