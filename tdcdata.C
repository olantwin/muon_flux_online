{
  struct RawDataHit {
    uint16_t channelId; // Channel Identifier
    uint16_t hitTime;   // Hit time, coarse 25ns based time in MSByte, fine time
                        // in LSByte
    uint16_t extraData[0]; // Optional subdetector specific data items
  };

  struct DataFrameHeader {
    uint16_t size; // Length of the data frame in bytes (including header).
    uint16_t partitionId;     // Identifier of the subdetector and partition.
    uint32_t cycleIdentifier; // SHiP cycle identifier as received from TFC.
    uint32_t frameTime;       // Frame time in 25ns clock periods
    uint16_t timeExtent;      // sequential trigger number
    uint16_t flags;           // Version, truncated, etc.
  };

  struct DataFrame {
    DataFrameHeader header;
    RawDataHit hits[0];
    // DataFrameHeader
    // Address of first raw data hit.
    // for a partition with a fixed hit structure size, the actual number of
    // hits is given by the frame size and the hit size:
    int getHitCount() {
      return (header.size - sizeof(header)) / sizeof(RawDataHit);
    }
  };

  TFile f("tdc.root", "recreate");

  TTree tree("tdctree", "tdctree");

  auto data = new TClonesArray("ShipHit" /*, UINT16_MAX/sizeof(RawDataHit)*/);
  auto &d = *data;

  tree.Branch("hits", &data, UINT16_MAX);

  TH1I channels("channels", "channels", 128, 0, 128);
  TH1I times("times", "times", UINT16_MAX, 0, UINT16_MAX);
  TH1I hits("hits", "hits", UINT16_MAX / sizeof(RawDataHit) / 10, 0,
            UINT16_MAX / sizeof(RawDataHit));

  std::ifstream in("tdcdata.bin", std::ios::binary);

  unsigned char buffer[UINT16_MAX];

  for (auto df = new (buffer) DataFrame();
       in.read(reinterpret_cast<char *>(df), sizeof(DataFrame));) {
    auto nhits = df->getHitCount();
    d.Clear();
    if (in.read(reinterpret_cast<char *>(df->hits),
                nhits * sizeof(RawDataHit))) {
      hits.Fill(nhits);
      for (int i = 0; i < nhits; i++) {
        auto channel = df->hits[i].channelId;
        auto time = df->hits[i].hitTime;
        channels.Fill(channel % 0x0100);
        times.Fill(time);
        new (d[i]) ShipHit(channel, time);
      }
    }
    tree.Fill();
  }

  tree.Write()
}
