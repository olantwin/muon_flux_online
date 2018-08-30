struct DataFrameHeader {
  uint16_t size;        // Length of the data frame in bytes (including header).
  uint16_t partitionId; // Identifier of the subdetector and partition.
  uint32_t cycleIdentifier; // SHiP cycle identifier as received from TFC.
  uint32_t frameTime;       // Frame time in 25ns clock periods
  uint16_t timeExtent;      // sequential trigger number
  uint16_t flags;           // Version, truncated, etc.
};

struct DataFrame {
  DataFrameHeader header;
  uint16_t hits[0];
  // DataFrameHeader
  // Address of first raw data hit.
  // for a partition with a fixed hit structure size, the actual number of hits
  // is given by the frame size and the hit size:
};

struct ScalerFrame {
  DataFrameHeader header;
  uint16_t PSW;
  uint16_t SPW;
  uint32_t PinStatus;
  uint32_t scalers[16];
  uint32_t slices[0];
  int getSliceCount() { return (header.size - 88) / sizeof(uint32_t); }
};

void trigger_extractor(TString infile) {
  unsigned char buffer[UINT16_MAX];
  auto f = TFile::Open(infile + "?filetype=raw", "read");
  auto mf = new (buffer) DataFrame();
  int nframes = 0;
  while (!f->ReadBuffer(reinterpret_cast<char *>(mf), sizeof(DataFrame))) {
    size_t size = mf->header.size;
    uint16_t partitionId = mf->header.partitionId;
    if (!f->ReadBuffer(reinterpret_cast<char *>(mf->hits),
                       size - sizeof(DataFrame))) {
      nframes++;
      switch (mf->header.frameTime) {
      case 0xFF005C03:
        nframes--;
        continue;
        break;
      case 0xFF005C04:
        nframes--;
        break;
      default:
        continue;
        break;
      }
      switch (partitionId) {
      case 0x8000: {
        Int_t total_size = size;
        total_size -= sizeof(DataFrame);
        auto data = reinterpret_cast<Int_t *>(&(mf->hits));
        while (total_size > 0) {
          auto df = reinterpret_cast<DataFrame *>(data);
          Int_t size = df->header.size;
          uint16_t partitionId = df->header.partitionId;
          switch (partitionId) {
          case 0x0C00: {
            TString dt_metadata(reinterpret_cast<char *>(df->hits),
                                size - sizeof(DataFrame));
            auto tokens = dt_metadata.Tokenize(",:{}\" \n");
            auto triggers_token =
                dynamic_cast<TObjString *>(
                    tokens->After(tokens->FindObject("Triggers")))
                    ->String();
            Int_t triggers_dt =
                TString::BaseConvert(triggers_token, 16, 10).Atoi();
            std::cout << "DT triggers: " << triggers_dt << std::endl;
            break;
          }
          case 0x8100: {
            auto df = reinterpret_cast<ScalerFrame *>(data);
            for (auto i : ROOT::MakeSeq(9)) {
              std::cout << TString::Format("SC%.2d: %d", i, df->scalers[i])
                        << std::endl;
            }
            std::vector<uint16_t> slices(df->slices, df->slices + df->getSliceCount());
            std::cout << "Slices:" << std::endl;
            for (auto &&slice:slices){
              std::cout << slice << std::endl;
            }
            break;
          }
          default:
            break;
          }

          data += size / sizeof(Int_t);
          total_size -= size;
        }
        assert(total_size == 0);
        break;
      }
      case 0x0C00: {
        TString dt_metadata(reinterpret_cast<char *>(mf->hits),
                            size - sizeof(DataFrame));
        auto tokens = dt_metadata.Tokenize(",:{}\" \n");
        auto triggers_token = dynamic_cast<TObjString *>(
                                  tokens->After(tokens->FindObject("Triggers")))
                                  ->String();
        Int_t triggers_dt = TString::BaseConvert(triggers_token, 16, 10).Atoi();
        std::cout << "DT triggers: " << triggers_dt << std::endl;
        break;
      }
      case 0x8100: {
        assert(false);
        break;
      }
      }
      break;
    }
  }
  std::cout << nframes << " data frames (ignoring SoS/EoS frames)."
            << std::endl;
  f->Close();
}
