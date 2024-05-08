### real time chart your power home energy consumption
### tested with original neurio energy monitors
### requires access to same network neurio is running

### requires curl, jq, gnuplot

    chmod +x neurio_no_pw_endpoint.sh
    ./neurio_no_pw_endpoint.sh

##  endpoint protected with password

    chmod +x neurio_with_pw_endpoint.sh
    ./neurio_with_pw_endpoint.sh

[neurio api docs](https://api-docs.neur.io/#sensor-local-access)

### using nix shell (note: overrides the terminal type)
### protected endpoint

    cd nix_dev_shell
    nix-shell neurio_protected.nix

### unprotected endpoint

    cd nix_dev_shell
    nix-shell neurio_unprotected.nix

### Can use gnuplot environment variables 
## The default terminal type setup is x11, you can override with this env variable

    TERM_NAME=''

[gnuplot terminal types](http://www.gnuplot.info/docs_4.2/node341.html)
