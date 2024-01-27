import UIKit

public class GalleryViewController: UIViewController, UITableViewDelegate {
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

    let addFigureButton = UIButton(type: .system)
    addFigureButton.setTitle("Añadir Figura", for: .normal)
    addFigureButton.addTarget(self, action: #selector(addFigure), for: .touchUpInside)
    addFigureButton.translatesAutoresizingMaskIntoConstraints = false

    let detailedViewButton = UIButton(type: .system)
    detailedViewButton.setTitle("Vista Detallada", for: .normal)
    detailedViewButton.addTarget(self, action: #selector(detailedView), for: .touchUpInside)
    detailedViewButton.translatesAutoresizingMaskIntoConstraints = false

    let deleteFigureButton = UIButton(type: .system)
    deleteFigureButton.setTitle("Eliminar Figura", for: .normal)
    deleteFigureButton.addTarget(self, action: #selector(deleteFigure), for: .touchUpInside)
    deleteFigureButton.translatesAutoresizingMaskIntoConstraints = false

    tableView.dataSource = viewModel
    tableView.delegate = viewModel
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(FigureCell.self, forCellReuseIdentifier: "value1")

    view.addSubview(addFigureButton)
    view.addSubview(detailedViewButton)
    view.addSubview(deleteFigureButton)
    view.addSubview(tableView)

    let sal = view.safeAreaLayoutGuide

    NSLayoutConstraint.activate([
      addFigureButton.topAnchor.constraint(equalTo: sal.topAnchor),
      addFigureButton.leadingAnchor.constraint(equalTo: sal.leadingAnchor),
      addFigureButton.widthAnchor.constraint(equalTo: detailedViewButton.widthAnchor),

      detailedViewButton.topAnchor.constraint(equalTo: sal.topAnchor),
      detailedViewButton.leadingAnchor.constraint(
        equalTo: addFigureButton.trailingAnchor, constant: 16),
      detailedViewButton.trailingAnchor.constraint(
        equalTo: deleteFigureButton.leadingAnchor, constant: -16),
      detailedViewButton.widthAnchor.constraint(equalTo: deleteFigureButton.widthAnchor),

      deleteFigureButton.topAnchor.constraint(equalTo: sal.topAnchor),
      deleteFigureButton.trailingAnchor.constraint(equalTo: sal.trailingAnchor),

      tableView.topAnchor.constraint(equalTo: addFigureButton.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: sal.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: sal.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: sal.bottomAnchor),
    ])
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FigureCell")
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }

  @objc func detailedView() {
    guard let selectedRow = tableView.indexPathForSelectedRow else { return }
    let selectedFigure = viewModel.figures.filter {
      $0.material == Set(viewModel.figures.map { $0.material }).sorted()[selectedRow.section]
    }[selectedRow.row]
    let detailedView = DetailedView(
      selectedFigure: selectedFigure, viewModel: viewModel, tableView: tableView)
    present(detailedView, animated: true, completion: nil)
  }

  @objc func addFigure() {
    let newFigure = Figure()
    viewModel.addFigure(figure: newFigure)
    tableView.reloadData()
  }

  @objc func deleteFigure() {
    guard let selectedRow = tableView.indexPathForSelectedRow else { return }
    let selectedFigure = viewModel.figures.filter {
      $0.material == Set(viewModel.figures.map { $0.material }).sorted()[selectedRow.section]
    }[selectedRow.row]
    viewModel.deleteFigure(id: selectedFigure.id)
    tableView.reloadData()
  }
}
