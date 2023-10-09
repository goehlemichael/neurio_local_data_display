### real time chart your power home consumption

### requires curl, jq, gnuplot

### recommend running in a window manager like screen

### may need to specify bash shebang and env values in script

### make executable

    chmod +x neurio.sh
    ./neurio.sh

### if using a window manager like screen
    screen bash
    ./neurio.sh
### ctrl-a then ctrl-d to detach window

[neurio api docs](https://api-docs.neur.io/#sensor-local-access)

### if using nix you can set things up with the nix shell which will override the terminal type for testing
    nix-shell neurio.nix
