import UIKit

public func importCSV(viewModel: FiguresViewModel, completion: @escaping () -> Void) {
  let fileUrl = URL(
    string:
      "https://gist.githubusercontent.com/GarciaLnk/8f571278f167c237e04813a0e6104125/raw/14420a54089542140c0a8407eccdcda881dcc268/figuras.csv"
  )!

  DispatchQueue.global().async {
    do {
      let content = try String(contentsOf: fileUrl, encoding: .utf8)
      let lines = content.components(separatedBy: "\n")
      let figures = lines.compactMap { Figure(bigLine: $0, delimiter: "\t") }
      viewModel.addFigures(figures: figures)
    } catch {
      print(error.localizedDescription)
    }
    DispatchQueue.main.async {
      completion()
    }
  }
}

public func loadFigures(viewModel: FiguresViewModel) {
  let fileManager = FileManager.default
  let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
  let folderURL = documentsDirectory?.appendingPathComponent("datos_figuras")
  let fileURL = folderURL?.appendingPathComponent("figuras.bin")

  let decoder = PropertyListDecoder()

  if fileManager.fileExists(atPath: fileURL!.path) {
    do {
      let data = try Data(contentsOf: fileURL!)
      let figures = try decoder.decode([Figure].self, from: data)
      viewModel.addFigures(figures: figures)

    } catch {
      print(error.localizedDescription)
    }
  }
}

public func saveFigures(viewModel: FiguresViewModel) {
  let encoder = PropertyListEncoder()
  encoder.outputFormat = .binary

  let fileManager = FileManager.default
  let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
  let folderURL = documentsDirectory?.appendingPathComponent("datos_figuras")

  if !fileManager.fileExists(atPath: folderURL!.path) {
    do {
      try fileManager.createDirectory(at: folderURL!, withIntermediateDirectories: true)
    } catch {
      print(error.localizedDescription)
    }
  }

  let fileURL = folderURL!.appendingPathComponent("figuras.bin")
  do {
    let data = try encoder.encode(viewModel.figures)
    try data.write(to: fileURL)
  } catch {
    print("HALLO")
    print(error.localizedDescription)
  }
}
