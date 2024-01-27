import UIKit

public class FilesViewController: UIViewController, UITableViewDelegate {
  let viewModel: FiguresViewModel
  let tableView = UITableView()

  public init(viewModel: FiguresViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func loadView() {
    super.loadView()

    let importButton = UIButton(type: .system)
    importButton.setTitle("Importar CSV", for: .normal)
    importButton.addTarget(self, action: #selector(importCSVonline(_:)), for: .touchUpInside)
    importButton.translatesAutoresizingMaskIntoConstraints = false

    let loadButton = UIButton(type: .system)
    loadButton.setTitle("Cargar binario", for: .normal)
    loadButton.addTarget(self, action: #selector(loadBinary(_:)), for: .touchUpInside)
    loadButton.translatesAutoresizingMaskIntoConstraints = false

    let saveButton = UIButton(type: .system)
    saveButton.setTitle("Guardar binario", for: .normal)
    saveButton.addTarget(self, action: #selector(saveBinary(_:)), for: .touchUpInside)
    saveButton.translatesAutoresizingMaskIntoConstraints = false

    tableView.dataSource = viewModel
    tableView.delegate = viewModel
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(FigureCell.self, forCellReuseIdentifier: "value1")

    view.addSubview(importButton)
    view.addSubview(loadButton)
    view.addSubview(saveButton)
    view.addSubview(tableView)

    let sal = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      importButton.topAnchor.constraint(equalTo: sal.topAnchor),
      importButton.leadingAnchor.constraint(equalTo: sal.leadingAnchor),
      importButton.widthAnchor.constraint(equalTo: loadButton.widthAnchor),

      loadButton.topAnchor.constraint(equalTo: sal.topAnchor),
      loadButton.leadingAnchor.constraint(equalTo: importButton.trailingAnchor, constant: 16),
      loadButton.widthAnchor.constraint(equalTo: saveButton.widthAnchor),

      saveButton.topAnchor.constraint(equalTo: sal.topAnchor),
      saveButton.leadingAnchor.constraint(equalTo: loadButton.trailingAnchor, constant: 16),
      saveButton.trailingAnchor.constraint(equalTo: sal.trailingAnchor),

      tableView.topAnchor.constraint(equalTo: saveButton.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: sal.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: sal.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: sal.bottomAnchor),
    ])
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }

  @objc func importCSVonline(_ sender: UIViewController) {
    viewModel.figures.removeAll()
    importCSV(viewModel: viewModel) { self.tableView.reloadData() }
  }

  @objc func loadBinary(_ sender: UIViewController) {
    viewModel.figures.removeAll()
    loadFigures(viewModel: viewModel)
    tableView.reloadData()
  }

  @objc func saveBinary(_ sender: UIViewController) {
    saveFigures(viewModel: viewModel)
  }
}
