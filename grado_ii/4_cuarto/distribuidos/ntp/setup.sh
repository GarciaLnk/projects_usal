#!/bin/bash

PROJECT_NAME="ntp-rest"

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
project_dir="${script_dir}/${PROJECT_NAME}"
export CATALINA_HOME="${script_dir}/apache-tomcat"

JERSEY_URL="https://repo1.maven.org/maven2/org/glassfish/jersey/bundles/jaxrs-ri/2.35/jaxrs-ri-2.35.tar.gz"
TOMCAT_VER=$(curl --silent https://dlcdn.apache.org/tomcat/tomcat-9/ | grep v9 | awk '{split($5,c,">v") ; split(c[2],d,"/") ; print d[1]}')
TOMCAT_URL="https://dlcdn.apache.org/tomcat/tomcat-9/v${TOMCAT_VER}/bin/apache-tomcat-${TOMCAT_VER}.tar.gz"

TMP="${script_dir}/tmp"

usage() {
    cat <<EOF
Uso: $(basename "${BASH_SOURCE[0]}") [-h] [-l cliente] server1 [server2...]

Script para desplegar el entorno en varios servidores.

Opciones disponibles:
-h, --help       Imprime este mensaje
-c, --clean      Limpiar archivos de los equipos listados
    --full-clean Limpieza mas profunda
-l, --cliente    Direccion IP del cliente
EOF
    exit
}

parse_params() {
    host=''
    clean=false
    fullclean=false

    while :; do
        case "${1-}" in
        -h | --help) usage ;;
        -c | --clean) clean=true ;;
        --full-clean) fullclean=true ;;
        -l | --cliente)
            host="${2-}"
            shift
            ;;
        -?*) echo "Opcion desconocida: $1" && exit 1 ;;
        *) break ;;
        esac
        shift
    done

    args=("$@")

    [[ -z "${host-}" ]] && [[ ${#args[@]} -eq 0 ]] && echo "Hay que especificar al menos un parametro" && exit 1

    return 0
}

setup_makefile() {
    cp -f "${script_dir}/Makefile" "${project_dir}/Makefile"
    cp -rf "${script_dir}/META-INF" "${project_dir}"
}

setup_jersey() {
    wget "${JERSEY_URL}" -O "${TMP}/jaxrs-ri.tar.gz"
    tar -xvzf "${TMP}/jaxrs-ri.tar.gz" -C "${TMP}"
    mkdir -p "${project_dir}/lib"
    mkdir -p "${project_dir}/WebContent/WEB-INF/lib"
    mkdir -p "${project_dir}/WebContent/WEB-INF/classes"
    cp -f "${TMP}/jaxrs-ri/"*/*.jar "${project_dir}/lib"
    cp -f "${TMP}/jaxrs-ri/"*/*.jar "${project_dir}/WebContent/WEB-INF/lib"
    rm -f "${TMP}/jaxrs-ri.tar.gz"
    rm -rf "${TMP}/jaxrs-ri"
}

setup_server() {
    if ! [ -f "${project_dir}/WebContent/WEB-INF/lib/jersey-common.jar" ]; then
        setup_jersey
    fi

    if ! [ -d "${CATALINA_HOME}" ]; then
        wget "${TOMCAT_URL}" -O "${TMP}/apache-tomcat.tar.gz"
        mkdir -p "${CATALINA_HOME}"
        tar -xvzf "${TMP}/apache-tomcat.tar.gz" --strip-components=1 -C "${CATALINA_HOME}"
        rm -f "${TMP}/apache-tomcat.tar.gz"
        chmod a+x "${CATALINA_HOME}/bin/"*.sh
    fi

    cd "${project_dir}" || exit 1
    make server

    cd "${CATALINA_HOME}/bin/" || exit 1
    ./shutdown.sh >/dev/null 2>&1
    ./startup.sh
    cd "${script_dir}" || exit 1
}

setup_client() {
    if ! [ -f "${project_dir}/lib/jersey-common.jar" ]; then
        setup_jersey
    fi

    cd "${project_dir}" || exit 1
    make client
    cd "${script_dir}" || exit 1
}

setup_ssh() {
    ssh-copy-id -i "${HOME}/.ssh/id_rsa.pub" "$1" >/dev/null 2>&1

    remote_home=$(ssh "$1" "echo \${HOME}")
    remote_script_dir="${remote_home}${script_dir#"${HOME}"}"
}

parse_params "$@"
mkdir -p "${TMP}"

[ ! -f "${HOME}/.ssh/id_rsa.pub" ] && ssh-keygen

for server in "${args[@]}"; do
    if [ -n "${server-}" ]; then
        if [ "${server}" = "127.0.0.1" ] || [ "${server}" = "localhost" ] ||
            [[ "$(hostname -I)" == *"${server}"* ]] ||
            { [[ -n "$(dig +short "${server}")" ]] && [[ "$(hostname -I)" == *"$(dig +short "${server}")"* ]]; }; then
            if [ "${clean}" = true ] || [ "${fullclean}" = true ]; then
                cd "${PROJECT_NAME}" || exit 1
                make clean
                if [ -d "${CATALINA_HOME}" ]; then
                    cd "${CATALINA_HOME}/bin" && ./shutdown.sh
                fi
                cd "${script_dir}" || exit 1
                if [ "${fullclean}" = true ]; then
                    rm -rf "${CATALINA_HOME}"
                    rm -rf "${project_dir}/WebContent/WEB-INF/lib"
                fi
            else
                setup_makefile
                setup_server
                echo "Servidor iniciado en: $(hostname -I)"
            fi
        else
            if ! nc -z "${server}" 22 2>/dev/null; then
                echo "No se puede establecer una conexion SSH con el servidor ${server}" && exit 1
            elif [ "${clean}" = true ] || [ "${fullclean}" = true ]; then
                setup_ssh "${server}"
                ssh "${server}" "cd ${remote_script_dir}/apache-tomcat/bin && ./shutdown.sh >/dev/null 2>&1"
                ssh "${server}" "rm -rf ${remote_script_dir}"
            else
                setup_ssh "${server}"
                ssh "${server}" "mkdir -p ${remote_script_dir}"
                #scp -rpq "${script_dir}"/* "${server}":"${remote_script_dir}"
                rsync -az "${script_dir}"/* "${server}":"${remote_script_dir}"
                ssh "${server}" "cd ${remote_script_dir} && ./$(basename "$0") localhost"
            fi
        fi
    fi
done

if [ -n "${host}" ]; then
    if [ "${host}" = "127.0.0.1" ] || [ "${host}" = "localhost" ] ||
        [[ "$(hostname -I)" == *"${host}"* ]] ||
        { [[ -n "$(dig +short "${host}")" ]] && [[ "$(hostname -I)" == *"$(dig +short "${host}")"* ]]; }; then
        if [ "${clean}" = true ] || [ "${fullclean}" = true ]; then
            cd "${PROJECT_NAME}" || exit 1
            make clean
            cd "${script_dir}" || exit 1
            if [ "${fullclean}" = true ]; then
                rm -rf "${project_dir:?}/lib"
                rm -rf "${project_dir}/META-INF"
                rm -rf "${project_dir}/WebContent/WEB-INF/classes"
                rm -rf "${project_dir}/build"
                rm -f "${project_dir}/Makefile"
            fi
        else
            setup_makefile
            setup_client
            echo "Cliente listo para ser lanzado en: $(hostname -I)"
        fi
    else
        if ! nc -z "${host}" 22 2>/dev/null; then
            echo "No se puede establecer una conexion SSH con el host ${host}"
        elif [ "${clean}" = true ] || [ "${fullclean}" = true ]; then
            setup_ssh "${host}"
            ssh "${host}" "rm -rf ${remote_script_dir}"
        else
            setup_ssh "${host}"
            ssh "${host}" "mkdir -p ${remote_script_dir}"
            #scp -rpq "${script_dir}"/* "${host}":"${remote_script_dir}"
            rsync -az "${script_dir}"/* "${host}":"${remote_script_dir}"
            ssh "${host}" "cd ${remote_script_dir} && ./$(basename "$0") -l localhost"
        fi
    fi
fi

rm -rf "${TMP}"
