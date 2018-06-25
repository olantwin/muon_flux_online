void unpack_tdc(std::string infile="SPILLDATA_0C00_1526641008.rawdata", TString outfile="output.root") {
  // Create source with unpackers ----------------------------------------------
  gROOT->SetBatch(true);
  auto source = new ShipTdcSource(infile);

  // NeuLAND MBS parameters -------------------------------
  auto unpacker = new DriftTubeUnpack();
  source->AddUnpacker(unpacker);

  // Create online run ---------------------------------------------------------
  auto run = new FairRunOnline(source);
  run->SetOutputFile(outfile);
  run->ActivateHttpServer();
  run->SetAutoFinish(true);

  // Create analysis task ------------------------------------------------------
  auto task = new ShipTdcTask("ExampleTask", 1);
  run->AddTask(task);

  // Initialize ----------------------------------------------------------------
  run->Init();

  // Run -----------------------------------------------------------------------
  run->Run(-1, 0); // run over entire file for negative argument.

  Int_t nHits = unpacker->GetNHitsTotal();
  cout << nHits << endl;

  // run->Finish() // need to finish to write out all data if autofinish
  // disabled
}
