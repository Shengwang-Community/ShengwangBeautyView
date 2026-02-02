//
//  MainViewController.swift
//  BeautyView
//
//  Created by HeZhengQing on 2026/1/23.
//

import UIKit

/// Main view controller
/// Provides entry point to beauty feature demo
class MainViewController: UIViewController {
    
    // MARK: - Properties
    
    private var permissionHelper: PermissionHelper!
    
    private lazy var startPreviewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("开启预览", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(startPreviewButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "美颜视图示例"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        setupUI()
        setupPermissionHelper()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.restoreDefaultStyle()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(startPreviewButton)
        startPreviewButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startPreviewButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startPreviewButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            startPreviewButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            startPreviewButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            startPreviewButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupPermissionHelper() {
        permissionHelper = PermissionHelper(viewController: self)
    }
    
    // MARK: - Actions
    
    @objc private func startPreviewButtonTapped() {
        // Request permissions
        permissionHelper.checkCameraAndMicPerms(
            granted: { [weak self] in
                // Permissions granted, navigate to beauty feature page
                self?.navigateToBeautyExample()
            },
            unGranted: { [weak self] in
                // Permissions denied
                self?.showAlert(
                    title: "Permission Required",
                    message: "Camera and microphone permissions are required to use beauty features"
                )
            },
            force: false
        )
    }
    
    /// Navigate to beauty feature page
    private func navigateToBeautyExample() {
        let beautyExampleVC = ExampleViewController()
        navigationController?.pushViewController(beautyExampleVC, animated: true)
    }
    
    /// Show alert
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
