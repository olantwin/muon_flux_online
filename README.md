# Muon flux online and data processing code

## How to convert rawdata to ROOT

```
./unpack.py --help
usage: unpack.py [-h] -f INPUT -o OUTPUT [-n RUN] [--charm]

optional arguments:
  -h, --help            show this help message and exit
  -f INPUT, --input INPUT
                        Input file (can be on EOS)
  -o OUTPUT, --output OUTPUT
                        Output file
  -n RUN, --run RUN     Run number
  --charm               Unpack charm data (default: muon flux)
```

e.g.

```
./unpack.py -f SPILLDATA_8000_0514224200_20180711_210040.raw -o
SPILLDATA_8000_0514224200_20180711_210040.root -n 2142
```

**Note:** Add the `--charm` argument to enable the unpackers for the charm
x-section measurement and the correct DT channel map.

When running the python script, make sure the SHiP environment is loaded with
the desired version of `FairShip`: `master` in most cases,
`old_scintillator_conversion` to study the normalisation.

## Docker

The docker image was used to run the online conversion during data taking. It's
currently out of date.
