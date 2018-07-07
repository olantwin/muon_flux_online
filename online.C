void online(TString dir, TString pattern) {
  // Create source with unpackers ----------------------------------------------
  gROOT->SetBatch(true);
  auto source = new ShipEBSource();
  source->WatchPath(dir, pattern);

  // NeuLAND MBS parameters -------------------------------
  source->AddUnpacker(new DriftTubeUnpack());
  source->AddUnpacker(new RPCUnpack());

  // Create online run ---------------------------------------------------------
  auto run = new FairRunOnline(source);
  run->SetOutputFile(outfile);
  run->ActivateHttpServer(true);
  run->SetAutoFinish(true);

  // Create analysis task ------------------------------------------------------
  auto task = new ShipTdcTask("ExampleTask", 1);
  run->AddTask(task);

  // Initialize ----------------------------------------------------------------
  run->Init();

  // Run -----------------------------------------------------------------------
  run->Run(-1, 0); // run over entire file for negative argument.

  /* Int_t nHits = unpacker->GetNHitsTotal(); */
  /* cout << nHits << endl; */

  // run->Finish() // need to finish to write out all data if autofinish
  // disabled
}
