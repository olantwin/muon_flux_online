# Muon flux online and data processing code

## How to convert rawdata to ROOT

```
./unpacker
  -f [ --infile ] arg   Input file (can be on EOS)
  -o [ --outfile ] arg  Output file
  -n [ --run ] arg      Run number
  --charm               Unpack charm data (default: muon flux)
```

e.g.

```
./unpacker -f SPILLDATA_8000_0514224200_20180711_210040.raw -o
SPILLDATA_8000_0514224200_20180711_210040.root -n 2142
```

**Note:** Add the `--charm` argument to enable the unpackers for the charm
x-section measurement and the correct DT channel map.

To compile the binary, run `make` without target with the desired version of
`FairShip`: `master` in most cases, `old_scintillator_conversion` to study the
normalisation.

## Docker

The docker image was used to run the online conversion during data taking. It's
currently out of date.
