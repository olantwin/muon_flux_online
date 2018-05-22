void unpack_tdc() {
  // Create source with unpackers ----------------------------------------------
  gROOT->SetBatch(true);
  auto source = new ShipTdcSource();

  // NeuLAND MBS parameters -------------------------------
  auto unpacker = new ShipTdcUnpack();
  source->AddUnpacker(unpacker);

  // Create online run ---------------------------------------------------------
  auto run = new FairRunOnline(source);
  run->SetOutputFile("output.root");
  run->ActivateHttpServer();
  run->SetAutoFinish(true);

  // Create analysis task ------------------------------------------------------
  auto task = new ShipTdcTask("ExampleTask", 1);
  run->AddTask(task);

  // Initialize ----------------------------------------------------------------
  run->Init();

  // Runtime data base ---------------------------------------------------------
  FairRuntimeDb *rtdb = run->GetRuntimeDb();
  Bool_t kParameterMerged = kTRUE;
  FairParRootFileIo *parOut = new FairParRootFileIo(kParameterMerged);
  parOut->open("params.root");
  rtdb->setOutput(parOut);
  rtdb->print();

  // Run -----------------------------------------------------------------------
  run->Run(-1, 0); // run over entire file for negative argument.
  rtdb->saveOutput();

  Int_t nHits = unpacker->GetNHitsTotal();
  cout << nHits << endl;

  // run->Finish() // need to finish to write out all data if autofinish
  // disabled
}
