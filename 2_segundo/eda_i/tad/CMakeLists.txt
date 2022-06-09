cmake_minimum_required(VERSION 3.13)
project(entregaTAD C)

set(CMAKE_C_STANDARD 90)

include_directories("${PROJECT_SOURCE_DIR}")

add_executable(entregaTAD main.c listas/lista.c listas/lista.h pilas/pila.c pilas/pila.h colas/cola.c colas/cola.h)
