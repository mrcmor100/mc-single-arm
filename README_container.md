# mc-single-arm container

This container provides a small machine-readable contract and a run wrapper for
the existing mc-single-arm analysis.

## Build

```bash
docker build -f Containerfile -t hallc/mc-single-arm:contract .
apptainer build --force mc-single-arm.sif docker-daemon://hallc/mc-single-arm:contract
```

## Discover the API

```bash
apptainer exec mc-single-arm.sif mc-single-arm-api describe --format json
apptainer exec mc-single-arm.sif mc-single-arm-api describe --format yaml
```

The contract lists input fields, bundled examples, required mounts, output
locations, and overwrite behavior.

## Run

Prepare a writable data directory:

```bash
mkdir -p mc-data/infiles mc-data/outfiles mc-data/runout mc-data/worksim
```

Run through Apptainer:

```bash
apptainer exec --bind "$PWD/mc-data:/data" mc-single-arm.sif \
  mc-single-arm-run --data-root /data --basename ci_smoke
```

If `/data/infiles/<basename>.inp` is missing and the basename matches a bundled
example, the wrapper copies that example into the mounted data directory before
running. You can also place your own input file in `mc-data/infiles/` or pass
`--input path/to/file.inp`.

The analysis chooses its random seed internally from the clock and prints the
actual value in `runout/<basename>.out` when no seed is supplied. For manual
single-user runs, `mc-single-arm-run --seed <integer>` exports
`MC_SINGLE_ARM_SEED` before launching the analysis.

`hallc-mc-runner` intentionally does not expose or pass this seed controller for
mc-single-arm runs. In that web/API workflow the seed is chosen by
mc-single-arm, then parsed from the log and stored with the run record.

## Overwrite Protection

The wrapper checks for existing artifacts before writing:

- `runout/<basename>.out`
- `outfiles/<basename>.out`
- `worksim/<basename>.root`
- `worksim/<basename>.bin`

In an interactive terminal, it prompts before overwriting existing files. In a
noninteractive process, it refuses to overwrite unless `--force` is supplied.
Use `--force` only in isolated per-run directories, such as directories created
by an automated database-backed runner.
