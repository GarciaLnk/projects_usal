#define  __USE_POSIX
#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>

void bifurcar(pid_t * pid1, pid_t * pid2)
{
    *pid1 = fork();
    if (*pid1 != 0)
        *pid2 = fork();
}

void manejadora(int sig, siginfo_t * siginfo, void *context)
{
    printf("SIGTERM(%d) enviada por %d a %d\n", sig, siginfo->si_pid,
           getpid());
}

int main()
{
    pid_t pid38, pid39, pid40, pid41, pid42, pid43, pid44, pid45, pid46,
        pid47, pid48, pid49, pid50, pid51, pid52, pid53, pid54, pid55,
        pid56, pid57, pid58;

    int tam = sizeof(pid_t) * 3;
    int fd = open("pids", O_RDWR | O_CREAT | O_TRUNC);
    if (fd < 0) {
        perror("pids: open");
        return 1;
    }
    if (lseek(fd, tam, SEEK_SET) < 0) {
        perror("lseek");
        close(fd);
        return 1;
    }
    if (write(fd, "0", 1) < 0) {
        perror("write");
        close(fd);
        return 1;
    }

    void *mapfd = mmap(0, tam, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (mapfd == MAP_FAILED) {
        perror("mmap");
        close(fd);
        munmap(mapfd, tam);
        return 1;
    }
    int *proyeccion = mapfd;
    close(fd);
    unlink("pids");

    sigset_t sigterm_mask, nosigterm_mask, orig_mask;
    sigemptyset(&sigterm_mask);
    sigaddset(&sigterm_mask, SIGTERM);
    if (sigprocmask(SIG_BLOCK, &sigterm_mask, &orig_mask) < 0) {
        perror("sigprocmask block");
        munmap(mapfd, tam);
        return 1;
    }
    nosigterm_mask = orig_mask;
    sigdelset(&nosigterm_mask, SIGTERM);

    struct sigaction ss, ssorig;
    ss.sa_sigaction = manejadora;
    sigemptyset(&ss.sa_mask);
    ss.sa_flags = SA_SIGINFO;

    if (sigaction(SIGTERM, &ss, &ssorig) < 0) {
        perror("sigaction sigterm");
        munmap(mapfd, tam);
        return 1;
    }
    printf("%d: SIGTERM(%d) registrada\n", getpid(), SIGTERM);

    pid38 = fork();
    if (pid38 == 0) {
        pid39 = fork();
        if (pid39 == 0) {
            bifurcar(&pid40, &pid41);
            if (pid40 == 0) {
                bifurcar(&pid42, &pid43);
                if (pid42 == 0) {
                    pid46 = fork();
                    if (pid46 == 0) {
                        pid50 = fork();
                        if (pid50 == 0) {
                            pid54 = fork();
                            if (pid54 == 0) {
                                proyeccion[0] = getpid();
                                pid56 = fork();
                                if (pid56 == 0) {
                                    proyeccion[2] = getpid();
                                    pid57 = fork();
                                    if (pid57 == 0) {
                                        pid58 = fork();
                                        if (pid58 == 0) {
                                            sigsuspend(&nosigterm_mask);
                                        } else if (pid58 < 0) {
                                            perror("pid58: fork");
                                            munmap(mapfd, tam);
                                            return 1;
                                        } else {
                                            sigsuspend(&nosigterm_mask);
                                            kill(pid58, SIGTERM);
                                        }
                                    } else if (pid57 < 0) {
                                        perror("pid57: fork");
                                        munmap(mapfd, tam);
                                        return 1;
                                    } else {
                                        sigsuspend(&nosigterm_mask);
                                        kill(pid57, SIGTERM);
                                    }
                                } else if (pid56 < 0) {
                                    perror("pid56: fork");
                                    munmap(mapfd, tam);
                                    return 1;
                                } else {
                                    sigsuspend(&nosigterm_mask);
                                }
                            } else if (pid54 < 0) {
                                perror("pid54: fork");
                                munmap(mapfd, tam);
                                return 1;
                            } else {
                                sigsuspend(&nosigterm_mask);
                            }
                        } else if (pid50 < 0) {
                            perror("pid50: fork");
                            munmap(mapfd, tam);
                            return 1;
                        } else {
                            sigsuspend(&nosigterm_mask);
                            kill(pid50, SIGTERM);
                        }
                    } else if (pid46 < 0) {
                        perror("pid46: fork");
                        munmap(mapfd, tam);
                        return 1;
                    } else {
                        sigsuspend(&nosigterm_mask);
                        kill(pid46, SIGTERM);
                    }
                } else if (pid43 == 0) {
                    pid47 = fork();
                    if (pid47 == 0) {
                        pid51 = fork();
                        if (pid51 == 0) {
                            sigsuspend(&nosigterm_mask);
                            kill(proyeccion[0], SIGTERM);
                        } else if (pid51 < 0) {
                            perror("pid51: fork");
                            munmap(mapfd, tam);
                            return 1;
                        } else {
                            sigsuspend(&nosigterm_mask);
                            kill(pid51, SIGTERM);
                        }
                    } else if (pid47 < 0) {
                        perror("pid47: fork");
                        munmap(mapfd, tam);
                        return 1;
                    } else {
                        sigsuspend(&nosigterm_mask);
                        kill(pid47, SIGTERM);
                    }
                } else if (pid42 < 0 || pid43 < 0) {
                    perror("pid42/43: fork");
                    munmap(mapfd, tam);
                    return 1;
                } else {
                    sigsuspend(&nosigterm_mask);
                    kill(pid42, SIGTERM);
                    kill(pid43, SIGTERM);
                }
            } else if (pid41 == 0) {
                bifurcar(&pid44, &pid45);
                if (pid44 == 0) {
                    pid48 = fork();
                    if (pid48 == 0) {
                        pid52 = fork();
                        if (pid52 == 0) {
                            pid55 = fork();
                            if (pid55 == 0) {
                                proyeccion[1] = getpid();
                                sigsuspend(&nosigterm_mask);
                                kill(proyeccion[2], SIGTERM);
                            } else if (pid55 < 0) {
                                perror("pid55: fork");
                                munmap(mapfd, tam);
                                return 1;
                            } else {
                                sigsuspend(&nosigterm_mask);
                            }
                        } else if (pid52 < 0) {
                            perror("pid52: fork");
                            munmap(mapfd, tam);
                            return 1;
                        } else {
                            sigsuspend(&nosigterm_mask);
                            kill(pid52, SIGTERM);
                        }
                    } else if (pid48 < 0) {
                        perror("pid48: fork");
                        munmap(mapfd, tam);
                        return 1;
                    } else {
                        sigsuspend(&nosigterm_mask);
                        kill(pid48, SIGTERM);
                    }
                } else if (pid45 == 0) {
                    pid49 = fork();
                    if (pid49 == 0) {
                        pid53 = fork();
                        if (pid53 == 0) {
                            sigsuspend(&nosigterm_mask);
                            kill(proyeccion[1], SIGTERM);
                        } else if (pid53 < 0) {
                            perror("pid53: fork");
                            munmap(mapfd, tam);
                            return 1;
                        } else {
                            sigsuspend(&nosigterm_mask);
                            kill(pid53, SIGTERM);
                        }
                    } else if (pid49 < 0) {
                        perror("pid49: fork");
                        munmap(mapfd, tam);
                        return 1;
                    } else {
                        sigsuspend(&nosigterm_mask);
                        kill(pid49, SIGTERM);
                    }
                } else if (pid44 < 0 || pid45 < 0) {
                    perror("pid44/45: fork");
                    munmap(mapfd, tam);
                    return 1;
                } else {
                    sigsuspend(&nosigterm_mask);
                    kill(pid44, SIGTERM);
                    kill(pid45, SIGTERM);
                }
            } else if (pid40 < 0 || pid41 < 0) {
                perror("pid40/41: fork");
                munmap(mapfd, tam);
                return 1;
            } else {
                sigsuspend(&nosigterm_mask);
                kill(pid40, SIGTERM);
                kill(pid41, SIGTERM);
            }
        } else if (pid39 < 0) {
            perror("pid39: fork");
            munmap(mapfd, tam);
            return 1;
        } else {
            sigsuspend(&nosigterm_mask);
            kill(pid39, SIGTERM);
        }
    } else if (pid38 < 0) {
        perror("pid38: fork");
        munmap(mapfd, tam);
        return 1;
    } else {
        sigsuspend(&nosigterm_mask);
        kill(pid38, SIGTERM);
    }

    munmap(mapfd, tam);

    if (sigaction(SIGTERM, &ssorig, NULL) < 0) {
        perror("sigaction restaurar sigterm");
        return 1;
    }

    if (sigprocmask(SIG_SETMASK, &orig_mask, NULL) < 0) {
        perror("sigprocmask");
        return 1;
    }

    return 0;
}
