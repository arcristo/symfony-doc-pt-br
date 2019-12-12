# Development

## Installation

1. Install [Docker][docker-install] and [Docker Compose][compose-install],
   and add the binaries to the `PATH` environment variable.

2. Then you can execute the helper scripts from the `.deploy/local/bin` folder:

    ```
    .deploy/local
    ├── bin
    │   ├── check-env.sh
    │   ├── install-env.sh
    │   └── set-aliases.sh
    ├── services
    │   └── nginx
    ├── docker-compose.yaml
    └── .env.dist
    .env
    ```

## Environment Variables

1. Access the `.deploy/local` directory, create an `.env` file from `.env.dist`,
   and set up the variables used on the containers:

    | Variable                | Description                                            |
    | ----------------------- | ------------------------------------------------------ |
    | COMPOSE_FILE            | The project docker-compose yaml file(s).               |
    | COMPOSE_PROJECT_DIR     | The project docker-compose directory for local config. |
    | COMPOSE_PROJECT_NAME    | Project name used as prefix when creating containers.  |
    | DEV_DOCKER_IMAGE_PYTHON | Docker image used by the python service.               |
    | DEV_HOST_PORT_HTTP      | HTTP port used on the host machine. Default: 80.       |
    | DEV_HOST_PORT_HTTPS     | HTTPS port used on the host machine. Default: 443.     |
    | DEV_GID                 | The group id used by PHP, in the format "gid".         |
    | DEV_UID                 | The user id used by PHP, in the format "uid".          |

    To get the `$GID` and `$UID` run the following commands:

    ```
    id -u <user>
    id -g <group>
    ```

## Installation

1. From the **project root folder**, run the following commands to create
   aliases for the development tools:

    ```
    COMPOSE_PROJECT_DIR=${PWD}/.deploy/local

    . .deploy/local/bin/install-env.sh
    ```

2. The following aliases will be created:

    * dc
    * make

## Containers

1. Build the docker images:

    ```
    docker build -t ${DEV_DOCKER_IMAGE_PYTHON}:base .deploy/docker/base

    dc build --parallel
    ```

1. Run the containers:

    ```
    dc up -d
    ```

    Make sure the host ports set up to the services on the `docker-compose.yaml`
    file are free. The `ports` directive maps ports on the host machine to ports
    on the containers and follows the format `<host-port>:<container-port>`.
    More info on the [Compose file reference][compose-ports].

1. To stop the containers, run:

    ```
    dc down
    ```

## Documentation

1. To build the documentation, run:

    ```
    make html
    ```

[compose-install]: https://docs.docker.com/compose/install/
[compose-ports]: https://docs.docker.com/compose/compose-file/#ports
[docker-install]: https://docs.docker.com/install/
