import Foundation

public enum UpdateError: Error {
  case invalidField
}

public struct Figure: CustomStringConvertible, Codable {
  var id: String
  var height: Double
  var material: String
  var quantity: Int
  var date: Int
  var photo: String
  var manufacturer: String

  init() {
    self.id = "0"
    self.height = 0.0
    self.material = "0"
    self.quantity = 1
    self.date = 0
    self.photo = ""
    self.manufacturer = "Desconocido"
  }

  init(
    id: String, height: Double, material: String, quantity: Int, date: Int, photo: String,
    manufacturer: String
  ) {
    self.id = id
    self.height = height
    self.material = material
    self.quantity = quantity
    self.date = date
    self.photo = photo
    self.manufacturer = manufacturer
  }

  init?(fields: [String]) {
    guard
      fields.allSatisfy({ !$0.isEmpty }),
      fields.count == 7,
      let height = Double(fields[1]),
      let quantity = Int(fields[3]),
      let date = Int(fields[4]),
      height > 0 && height < 2,
      quantity >= 1,
      date >= 0 && date <= 2100
    else {
      print("Rechazado: \(fields)")
      return nil
    }

    self.id = fields[0]
    self.height = height
    self.material = fields[2]
    self.quantity = quantity
    self.date = date
    self.photo = fields[5]
    self.manufacturer = fields[6]
  }

  public init?(bigLine: String, delimiter: String) {
    guard !bigLine.isEmpty, !delimiter.isEmpty else {
      print("Rechazado: \(bigLine)")
      return nil
    }
    let tokens = bigLine.components(separatedBy: delimiter)
    self.init(fields: tokens)
  }

  public var description: String {
    return
      "{\(id),\t\(height),\t\(material),\t\(quantity),\t\(date)},\t\(photo)},\t\(manufacturer)}\n"
  }

  public mutating func update(
    id: String, height: String, material: String, quantity: String, date: String, photo: String,
    manufacturer: String
  ) throws {
    guard
      let height = Double(height),
      let quantity = Int(quantity),
      let date = Int(date),
      height > 0 && height < 2,
      quantity >= 1,
      date >= 0 && date <= 2100
    else {
      throw UpdateError.invalidField
    }

    self.id = id
    self.height = height
    self.material = material
    self.quantity = quantity
    self.date = date
    self.photo = photo
    self.manufacturer = manufacturer
  }
}
