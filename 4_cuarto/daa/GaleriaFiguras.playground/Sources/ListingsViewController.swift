import UIKit

public class ListingsViewController: UIViewController, UITableViewDelegate {
  let viewModel: FiguresViewModel
  let tableView = UITableView()

  var tableOrder: [String] = []

  public init(viewModel: FiguresViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func loadView() {
    super.loadView()

    tableView.dataSource = viewModel
    tableView.delegate = viewModel
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(FigureCell.self, forCellReuseIdentifier: "value1")

    view.addSubview(tableView)

    let segmentedControl = UISegmentedControl()
    segmentedControl.insertSegment(withTitle: "ID", at: 0, animated: false)
    segmentedControl.insertSegment(withTitle: "Altura", at: 1, animated: false)
    segmentedControl.insertSegment(withTitle: "Material", at: 2, animated: false)
    segmentedControl.insertSegment(withTitle: "Cantidad", at: 3, animated: false)
    segmentedControl.insertSegment(withTitle: "Fecha", at: 4, animated: false)
    segmentedControl.insertSegment(withTitle: "Foto", at: 5, animated: false)
    segmentedControl.insertSegment(withTitle: "Fabricante", at: 6, animated: false)
    segmentedControl.addTarget(self, action: #selector(sortFigures(_:)), for: .valueChanged)
    segmentedControl.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(segmentedControl)

    tableOrder = viewModel.figures.map { $0.id }
    let restoreButton = UIButton(type: .system)
    restoreButton.setTitle("Restaurar", for: .normal)
    restoreButton.addTarget(self, action: #selector(restoreOrder(_:)), for: .touchUpInside)
    restoreButton.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(restoreButton)

    let sal = view.safeAreaLayoutGuide

    NSLayoutConstraint.activate([
      segmentedControl.topAnchor.constraint(equalTo: sal.topAnchor),
      segmentedControl.leadingAnchor.constraint(equalTo: sal.leadingAnchor),
      segmentedControl.trailingAnchor.constraint(equalTo: sal.trailingAnchor),

      restoreButton.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
      restoreButton.centerXAnchor.constraint(equalTo: sal.centerXAnchor),
      restoreButton.widthAnchor.constraint(equalTo: sal.widthAnchor, multiplier: 0.7),

      tableView.topAnchor.constraint(equalTo: restoreButton.bottomAnchor),
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
    tableOrder = viewModel.figures.map { $0.id }
  }

  @objc func restoreOrder(_ sender: UIButton) {
    viewModel.figures.sort { figure1, figure2 in
      let index1 = tableOrder.firstIndex(of: figure1.id)
      let index2 = tableOrder.firstIndex(of: figure2.id)
      return index1! < index2!
    }

    tableView.reloadData()
  }

  @objc
  func sortFigures(_ sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0:
      viewModel.figures.sort { $0.id < $1.id }
    case 1:
      viewModel.figures.sort { $0.height < $1.height }
    case 2:
      viewModel.figures.sort { $0.material < $1.material }
    case 3:
      viewModel.figures.sort { $0.quantity < $1.quantity }
    case 4:
      viewModel.figures.sort { $0.date < $1.date }
    case 5:
      viewModel.figures.sort { $0.photo < $1.photo }
    case 6:
      viewModel.figures.sort { $0.manufacturer < $1.manufacturer }
    default:
      break
    }

    tableView.reloadData()
  }
}
