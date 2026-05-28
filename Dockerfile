FROM postgres:14-bullseye

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    emacs \
    nano \
    vim \
    wget \
    sudo \
    pgloader \
    bzip2 \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# Give postgres user sudo privileges (useful for dev convenience)
RUN usermod -a -G sudo postgres && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER postgres

EXPOSE 5432