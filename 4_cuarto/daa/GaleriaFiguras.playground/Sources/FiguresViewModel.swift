import UIKit

public class FiguresViewModel: NSObject, UITableViewDataSource, UITableViewDelegate {
  var figures: [Figure] = []

  func addFigure(figure: Figure) {
    var newFigure = figure
    while figures.contains(where: { $0.id == newFigure.id }) {
      newFigure.id = UUID.init().uuidString
    }

    figures.append(newFigure)
  }

  public func addFigures(figures: [Figure]) {
    figures.forEach { figure in
      addFigure(figure: figure)
    }
  }

  public func updateFigure(
    oldFigure: Figure, newId: String, height: String, material: String, quantity: String,
    date: String, photo: String,
    manufacturer: String
  ) throws {
    if oldFigure.id != newId && figures.contains(where: { $0.id == newId }) {
      throw UpdateError.invalidField
    }

    if let index = figures.firstIndex(where: { $0.id == oldFigure.id }) {
      try figures[index].update(
        id: newId, height: height, material: material, quantity: quantity, date: date,
        photo: photo,
        manufacturer: manufacturer
      )
    } else {
      throw UpdateError.invalidField
    }

  }

  func deleteFigure(id: String) {
    figures.removeAll(where: { $0.id == id })
  }

  public func numberOfSections(in tableView: UITableView) -> Int {
    return Set(figures.map { $0.material }).sorted().count
  }

  public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return Set(figures.map { $0.material }).sorted()[section]
  }

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return figures.filter { $0.material == Set(figures.map { $0.material }).sorted()[section] }
      .count
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: "value1", for: indexPath)
    cell.textLabel?.numberOfLines = 0
    cell.textLabel?.font = UIFont.systemFont(ofSize: 24)

    let figure = figures.filter {
      $0.material == Set(figures.map { $0.material }).sorted()[indexPath.section]
    }[indexPath.row]
    cell.textLabel?.text = figure.id
    cell.detailTextLabel?.text = figure.manufacturer
    cell.backgroundColor = .systemGray6

    let customImageView = UIImageView()
    if let path = Bundle.main.path(forResource: figure.photo, ofType: "", inDirectory: "images") {
      customImageView.image = UIImage(contentsOfFile: path)
    } else {
      let fileManager = FileManager.default
      let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
      let folderURL = documentsDirectory?.appendingPathComponent("datos_figuras")
      let fileURL = folderURL?.appendingPathComponent(figure.photo)

      do {
        let data = try Data.init(contentsOf: fileURL!)
        if let image = UIImage(data: data) {
          customImageView.image = image
        } else {
          customImageView.image = UIImage(imageLiteralResourceName: "missing32")
        }
      } catch {
        customImageView.image = UIImage(imageLiteralResourceName: "missing32")
      }
    }
    cell.imageView?.image = customImageView.image

    return cell
  }

}
