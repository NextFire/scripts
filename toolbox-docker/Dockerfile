FROM archlinux
WORKDIR /root
RUN pacman-key --init && pacman -Syu --noconfirm  && \
    pacman -S --noconfirm fish vim ranger python python-pip ffmpeg mkvtoolnix-cli
RUN pip3 install numpy opencv-python sushi-sub
ENTRYPOINT [ "/bin/fish" ]
