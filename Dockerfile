FROM ghcr.io/gnu-octave/octave:latest

RUN octave -q --eval "pkg install -forge image" && \
    octave -q --eval "pkg install -forge control" && \
    octave -q --eval "pkg install -forge signal"

COPY ./src /workspace

WORKDIR /workspace