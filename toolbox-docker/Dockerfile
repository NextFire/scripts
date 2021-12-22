FROM archlinux

RUN pacman-key --init && pacman -Syu --noconfirm  && \
    pacman -S --noconfirm \
    base-devel \
    fish \
    ffmpeg \
    ffms2 \
    git \
    mkvtoolnix-cli \
    python \
    python-pip \
    ranger \
    tree \
    vapoursynth \
    vim

RUN pip3 install \
    numpy \
    opencv-python \
    sushi-sub

RUN git clone https://github.com/dubhater/vapoursynth-wwxd.git && \
    cd vapoursynth-wwxd && \
    gcc -o libwwxd.so -fPIC -shared -O2 -Wall -Wextra -Wno-unused-parameter $(pkg-config --cflags vapoursynth) src/wwxd.c src/detection.c && \
    ln -s $(pwd)/libwwxd.so /lib/vapoursynth/

WORKDIR /root
ENTRYPOINT [ "/bin/fish" ]
