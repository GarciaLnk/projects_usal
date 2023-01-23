import UIKit

public class DetailedView: UIViewController, UIImagePickerControllerDelegate,
  UINavigationControllerDelegate
{
  let selectedFigure: Figure
  let viewModel: FiguresViewModel
  let tableView: UITableView

  let idTextField = UITextField()
  let heightTextField = UITextField()
  let materialTextField = UITextField()
  let quantityTextField = UITextField()
  let dateTextField = UITextField()
  let photoTextField = UITextField()
  let manufacturerTextField = UITextField()

  public init(selectedFigure: Figure, viewModel: FiguresViewModel, tableView: UITableView) {
    self.selectedFigure = selectedFigure
    self.viewModel = viewModel
    self.tableView = tableView
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func loadView() {
    super.loadView()

    let saveButton = UIButton(type: .system)
    let cancelButton = UIButton(type: .system)
    let selectImageButton = UIButton(type: .system)

    idTextField.text = selectedFigure.id
    heightTextField.text = String(selectedFigure.height)
    materialTextField.text = selectedFigure.material
    quantityTextField.text = String(selectedFigure.quantity)
    dateTextField.text = String(selectedFigure.date)
    photoTextField.text = selectedFigure.photo
    manufacturerTextField.text = selectedFigure.manufacturer

    let textFields = [
      idTextField, heightTextField, materialTextField, quantityTextField, dateTextField,
      photoTextField, manufacturerTextField,
    ]

    for textField in textFields {
      textField.borderStyle = .bezel
      textField.backgroundColor = .white
      textField.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(textField)
    }

    saveButton.setTitle("Guardar", for: .normal)
    saveButton.addTarget(
      self, action: #selector(saveButtonTapped(_:)), for: .touchUpInside)
    saveButton.translatesAutoresizingMaskIntoConstraints = false
    saveButton.backgroundColor = .white

    cancelButton.setTitle("Cancelar", for: .normal)
    cancelButton.addTarget(self, action: #selector(dismissView(_:)), for: .touchUpInside)
    cancelButton.translatesAutoresizingMaskIntoConstraints = false
    cancelButton.backgroundColor = .white

    selectImageButton.setTitle("Seleccionar imagen", for: .normal)
    selectImageButton.addTarget(
      self, action: #selector(selectImageButtonTapped(_:)), for: .touchUpInside)
    selectImageButton.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(saveButton)
    view.addSubview(cancelButton)
    view.addSubview(selectImageButton)

    let sal = view.safeAreaLayoutGuide

    var constraints: [NSLayoutConstraint] = []

    for i in 0..<textFields.count {
      let currentTextField = textFields[i]
      constraints.append(currentTextField.leadingAnchor.constraint(equalTo: sal.leadingAnchor))
      constraints.append(
        currentTextField.trailingAnchor.constraint(equalTo: sal.trailingAnchor))
      if i == 0 {
        constraints.append(currentTextField.topAnchor.constraint(equalTo: sal.topAnchor))
      } else {
        let previousTextField = textFields[i - 1]
        constraints.append(
          currentTextField.topAnchor.constraint(
            equalTo: previousTextField.bottomAnchor, constant: 8))
      }
    }

    constraints.append(saveButton.leadingAnchor.constraint(equalTo: sal.leadingAnchor))
    constraints.append(saveButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor))
    constraints.append(
      saveButton.topAnchor.constraint(equalTo: manufacturerTextField.bottomAnchor, constant: 8))

    constraints.append(cancelButton.leadingAnchor.constraint(equalTo: saveButton.trailingAnchor))
    constraints.append(cancelButton.trailingAnchor.constraint(equalTo: sal.trailingAnchor))
    constraints.append(
      cancelButton.topAnchor.constraint(equalTo: manufacturerTextField.bottomAnchor, constant: 8))

    constraints.append(
      selectImageButton.trailingAnchor.constraint(equalTo: sal.trailingAnchor, constant: -8))
    constraints.append(selectImageButton.topAnchor.constraint(equalTo: photoTextField.topAnchor))

    NSLayoutConstraint.activate(constraints)
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  @objc func saveButtonTapped(_ sender: UIViewController) {
    do {
      try viewModel.updateFigure(
        oldFigure: selectedFigure, newId: idTextField.text!, height: heightTextField.text!,
        material: materialTextField.text!, quantity: quantityTextField.text!,
        date: dateTextField.text!, photo: photoTextField.text!,
        manufacturer: manufacturerTextField.text!
      )
      dismiss(animated: true, completion: nil)
      tableView.reloadData()
    } catch {
      let alertController = UIAlertController(
        title: "Error", message: "No se pudo actualizar la figura", preferredStyle: .alert
      )
      alertController.addAction(UIAlertAction(title: "OK", style: .default))
      present(alertController, animated: true)
    }
  }

  @objc func dismissView(_ sender: UIViewController) {
    self.presentingViewController?.dismiss(animated: true, completion: nil)
  }

  @objc func selectImageButtonTapped(_ sender: UIButton) {
    let imagePickerController = UIImagePickerController()
    imagePickerController.sourceType = .photoLibrary
    imagePickerController.delegate = self

    present(imagePickerController, animated: true)
  }

  public func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {
    if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      let fileManager = FileManager.default
      let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
      let targetUrl = documentsUrl.appendingPathComponent("datos_figuras")

      if !fileManager.fileExists(atPath: targetUrl.path) {
        do {
          try fileManager.createDirectory(at: targetUrl, withIntermediateDirectories: true)
        } catch {
          print(error)
        }
      }

      let fileUrl = targetUrl.appendingPathComponent("\(UUID().uuidString).png")
      if let data = pickedImage.pngData() {
        do {
          try data.write(to: fileUrl)
          dismiss(animated: true)
          photoTextField.text = fileUrl.lastPathComponent
        } catch {
          print(error)
        }
      }
    }
  }
}
