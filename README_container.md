# mc-single-arm container

This container packages the existing Hall C `mc-single-arm` program with a small
runner that keeps inputs and outputs in predictable container paths. The
simulation code and existing Makefiles are unchanged.

## Build locally with Docker

```bash
docker build -f Containerfile -t mc-single-arm:local .
```

## Inspect inputs

```bash
docker run --rm mc-single-arm:local mc-single-arm-api describe
docker run --rm mc-single-arm:local mc-single-arm-api describe --format json
docker run --rm mc-single-arm:local mc-single-arm-api describe --format yaml
```

The default text output lists input sections, keys, labels, defaults, and data
types. It also lists bundled example input files. For the full input format,
inspect the files in `infiles/` or the bundled container path
`/opt/mc-single-arm/share/infiles`.

## Run with Docker

Create a writable output area on the host:

```bash
mkdir -p mc-data
```

Mount your input file into the container and pass its container-local path:

```bash
docker run --rm \
  -v "$PWD/mc-data:/data" \
  -v "$PWD/my_run.inp:/input/my_run.inp:ro" \
  mc-single-arm:local \
  mc-single-arm-run --input /input/my_run.inp
```

`--input` must be a path that exists inside the container. The runner copies
that file to `/data/infiles/<basename>.inp` before launching `mc_single_arm`.

Outputs are written under the mounted `/data` directory:

- `runout/<basename>.out`
- `outfiles/<basename>.out`
- `worksim/<basename>.root`

To run one of the bundled examples by name:

```bash
docker run --rm \
  -v "$PWD/mc-data:/data" \
  mc-single-arm:local \
  mc-single-arm-run --basename shms_20deg_3gev_10cmtarg_cryo17
```

If `/data/infiles/<basename>.inp` is missing and the basename matches a bundled
example, the runner copies that example from
`/opt/mc-single-arm/share/infiles`.

The program chooses its random seed from the clock and prints the seed in
`runout/<basename>.out`. This container wrapper does not provide a seed option.

## Overwrite behavior

The runner checks for existing artifacts before writing:

- `runout/<basename>.out`
- `outfiles/<basename>.out`
- `worksim/<basename>.root`
- `worksim/<basename>.bin`

In an interactive terminal, it prompts before overwriting. In noninteractive
runs, it refuses to overwrite unless `--force` is supplied.

## Apptainer

Build a SIF from a local Docker image:

```bash
docker build -f Containerfile -t mc-single-arm:local .
apptainer build --force mc-single-arm.sif docker-daemon://mc-single-arm:local
```

Run with a mounted data directory and an input file visible inside the
container:

```bash
mkdir -p mc-data
apptainer exec \
  --bind "$PWD/mc-data:/data" \
  --bind "$PWD/my_run.inp:/input/my_run.inp:ro" \
  mc-single-arm.sif \
  mc-single-arm-run --input /input/my_run.inp
```

Run a bundled example:

```bash
apptainer exec --bind "$PWD/mc-data:/data" mc-single-arm.sif \
  mc-single-arm-run --basename shms_20deg_3gev_10cmtarg_cryo17
```
