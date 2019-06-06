import argparse
import ROOT

# Fix https://root-forum.cern.ch/t/pyroot-hijacks-help/15207 :
ROOT.PyConfig.IgnoreCommandLineOptions = True


def main():
    source = ROOT.ShipTdcSource(args.input)

    unpackers = [
        ROOT.DriftTubeUnpack(args.charm),
        ROOT.RpcUnpack(),
        ROOT.ScalerUnpack(),
    ]
    if args.charm:
        unpackers += [
            ROOT.PixelUnpack(0x0800),
            ROOT.PixelUnpack(0x0801),
            ROOT.PixelUnpack(0x0802),
            ROOT.SciFiUnpack(),
        ]

    for unpacker in unpackers:
        source.AddUnpacker(unpacker)

    run = ROOT.FairRunOnline(source)
    run.SetOutputFile(args.output)
    run.SetAutoFinish(True)
    run.SetRunId(args.run)

    run.Init()

    run.Run(-1, 0)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--input", required=True)
    parser.add_argument("-o", "--output", required=True)
    parser.add_argument("-n", "--run", default=0, type=int)
    parser.add_argument("-c", "--charm", action="store_true")
    args = parser.parse_args()
    ROOT.gROOT.SetBatch(True)
    main()
