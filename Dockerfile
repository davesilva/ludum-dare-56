FROM davesilva/godot-ci:3.5.3 AS build

WORKDIR /root

RUN mkdir -p /root/build

COPY . /root

RUN godot --no-window --verbose --export-pack "Linux/X11" build/server-bundle.pck


FROM davesilva/godot-ci:3.5.3 AS run

EXPOSE 10567
COPY --from=build /root/build/server-bundle.pck /root/server-bundle.pck

ENTRYPOINT [ "godot", "--no-window", "--main-pack", "/root/server-bundle.pck", "-" ]
CMD [ "--server" ]
