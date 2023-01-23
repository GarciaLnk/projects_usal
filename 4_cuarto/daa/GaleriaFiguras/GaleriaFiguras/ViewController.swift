//
//  ViewController.swift
//  GaleriaFiguras
//
//  Created by Alberto García on 12/15/22.
//

import UIKit

class ViewController: UIViewController, UIApplicationDelegate, UITabBarDelegate {
  let viewModel = FiguresViewModel()

  override func loadView() {
    let view = UIView()
    view.backgroundColor = .white
    self.view = view

    let tabBarController = UITabBarController()

    tabBarController.tabBar.tintColor = .systemBlue
    tabBarController.tabBar.unselectedItemTintColor = .darkGray

    let filesViewController = FilesViewController(viewModel: viewModel)
    let galleryViewController = GalleryViewController(viewModel: viewModel)
    let listingsViewController = ListingsViewController(viewModel: viewModel)

    tabBarController.viewControllers = [
      filesViewController, galleryViewController, listingsViewController,
    ]

    filesViewController.tabBarItem = UITabBarItem(
      title: "Archivos", image: UIImage(systemName: "folder"), tag: 0)
    galleryViewController.tabBarItem = UITabBarItem(
      title: "Galería", image: UIImage(systemName: "photo"), tag: 1)
    listingsViewController.tabBarItem = UITabBarItem(
      title: "Listados", image: UIImage(systemName: "list.bullet"), tag: 2)

    tabBarController.selectedIndex = 0

    tabBarController.view.translatesAutoresizingMaskIntoConstraints = false

    addChild(tabBarController)
    view.addSubview(tabBarController.view)
    tabBarController.didMove(toParent: self)

    let sal = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      tabBarController.view.leadingAnchor.constraint(equalTo: sal.leadingAnchor),
      tabBarController.view.trailingAnchor.constraint(equalTo: sal.trailingAnchor),
      tabBarController.view.bottomAnchor.constraint(equalTo: sal.bottomAnchor),
      tabBarController.view.topAnchor.constraint(equalTo: sal.topAnchor),
    ])
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let fileManager = FileManager.default
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    let folderURL = documentsDirectory?.appendingPathComponent("datos_figuras")
    let fileURL = folderURL!.appendingPathComponent("figuras.bin")

    if fileManager.fileExists(atPath: fileURL.path) {
      loadFigures(viewModel: viewModel)
    } else {
      do {
        let csvUrl = Bundle.main.url(forResource: "figuras", withExtension: "csv")!
        let content = try String(contentsOf: csvUrl, encoding: .utf8)
        let lines = content.components(separatedBy: "\n")
        let figures = lines.compactMap { Figure(bigLine: $0, delimiter: "\t") }
        viewModel.addFigures(figures: figures)
        let successNotification = UIAlertController(
          title: "Éxito",
          message:
            "Se han leído \(lines.count) líneas y el \(figures.count / lines.count * 100)% son válidas.",
          preferredStyle: .alert)
        self.present(successNotification, animated: true, completion: nil)
      } catch {
        let errorNotification = UIAlertController(
          title: "Error",
          message:
            "No se ha podido cargar el archivo CSV. La aplicación puede que no funcione correctamente.",
          preferredStyle: .alert)
        self.present(errorNotification, animated: true, completion: nil)
      }
    }
  }

  func applicationWillTerminate(_ application: UIApplication) {
    saveFigures(viewModel: viewModel)
  }
}
