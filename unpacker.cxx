#include "DriftTubeUnpack.h"
#include "FairRootFileSink.h"
#include "FairRunOnline.h"
#include "PixelUnpack.h"
#include "RPCUnpack.h"
#include "ScalerUnpack.h"
#include "ShipTdcSource.h"
#include "TROOT.h"
#include "TString.h"
#include "boost/program_options.hpp"
#include "fairlogger/Logger.h"

int main(int argc, char **argv)
{
   std::string infile, outfile;
   try {
      int run_number = 0;
      /** Define and parse the program options
       */
      namespace po = boost::program_options;
      po::options_description desc("Options");
      desc.add_options()("infile,f", po::value<std::string>(&infile)->required(),
                         "Input file")("outfile,o", po::value<std::string>(&outfile)->required(), "Output file")(
         "run,n", po::value<int>(), "Output file")("add", "additional options")("like", "this");

      po::variables_map vm;
      try {
         po::store(po::parse_command_line(argc, argv, desc),
                   vm); // can throw

         po::notify(vm); // throws on error, so do after help in case
                         // there are any problems
      } catch (po::error &e) {
         LOG(error) << "ERROR: " << e.what();
         LOG(error) << desc;
         return 1;
      }

      gROOT->SetBatch(true);
      auto source = new ShipTdcSource(infile.data());

      // NeuLAND MBS parameters -------------------------------
      source->AddUnpacker(new DriftTubeUnpack());
      source->AddUnpacker(new RPCUnpack());
      source->AddUnpacker(new ScalerUnpack());
      source->AddUnpacker(new PixelUnpack(0x0800));
      source->AddUnpacker(new PixelUnpack(0x0801));
      source->AddUnpacker(new PixelUnpack(0x0802));

      // Create online run ---------------------------------------------------------
      auto run = new FairRunOnline(source);
      run->SetSink(new FairRootFileSink(outfile.data()));
      run->SetAutoFinish(true);
      run->SetRunId(run_number);

      // Initialize ----------------------------------------------------------------
      run->Init();

      // Run -----------------------------------------------------------------------
      run->Run(-1, 0); // run over entire file for negative argument.

   } catch (std::exception &e) {
      LOG(error) << "Unhandled Exception reached the top of main: " << e.what() << ", application will now exit";
      return 2;
   }

   return 0;
}
