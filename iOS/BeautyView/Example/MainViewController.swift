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
    
    // MARK: - Constants
    
    private let sandboxSubpath = "AgoraBeautyMaterial.bundle"
    private let hashStorageKey = "com.agora.beauty.resource.sha256"
    
    // MARK: - Properties
    
    private var permissionHelper: PermissionHelper!
    
    private lazy var startPreviewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Start Preview", comment: ""), for: .normal)
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
        title = NSLocalizedString("Beauty View Example", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = false
        
        setupUI()
        setupPermissionHelper()
        prepareBeautyResourcesInBackground()
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
        permissionHelper.checkCameraAndMicPerms(
            granted: { [weak self] in
                self?.navigateToBeautyExample()
            },
            unGranted: { [weak self] in
                self?.showAlert(
                    title: "Permission Required",
                    message: "Camera and microphone permissions are required to use beauty features"
                )
            },
            force: false
        )
    }
    
    private func navigateToBeautyExample() {
        guard let beautyMaterialPath = getSandboxPath() else {
            showAlert(title: "Error", message: "Unable to get beauty resource path")
            return
        }
        
        let beautyExampleVC = ExampleViewController(beautyMaterialPath: beautyMaterialPath)
        navigationController?.pushViewController(beautyExampleVC, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Beauty Resource Management
    
    private func prepareBeautyResourcesInBackground() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.prepareBeautyResources()
        }
    }
}

// MARK: - Beauty Resource Management

private extension MainViewController {
    
    func prepareBeautyResources() {
        guard let bundlePath = Bundle.main.path(forResource: "AgoraBeautyMaterial", ofType: "bundle") else {
            print("[Beauty] Bundle not found in app resources")
            return
        }
        
        guard let sandboxPath = getSandboxPath() else {
            print("[Beauty] Unable to determine sandbox path")
            return
        }
        
        // Check if resources need update
        if shouldUpdateResources(bundlePath: bundlePath, sandboxPath: sandboxPath) {
            copyResources(from: bundlePath, to: sandboxPath)
        } else {
            print("[Beauty] Resources up to date")
        }
    }
    
    func shouldUpdateResources(bundlePath: String, sandboxPath: String) -> Bool {
        // If sandbox doesn't exist, need to copy
        guard FileManager.default.fileExists(atPath: sandboxPath) else {
            return true
        }
        
        // Read bundle.md5 from app bundle (no runtime hash calculation)
        guard let md5FilePath = Bundle.main.path(forResource: "bundle", ofType: "md5"),
              let bundleMd5 = try? String(contentsOfFile: md5FilePath, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines) else {
            print("[Beauty] bundle.md5 not found, will re-copy resources")
            return true
        }
        
        let storedMd5 = UserDefaults.standard.string(forKey: hashStorageKey)
        print("[Beauty] MD5 check - bundleMd5: \(bundleMd5), storedMd5: \(storedMd5 ?? "nil")")
        return storedMd5 != bundleMd5
    }
    
    func copyResources(from sourcePath: String, to destinationPath: String) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let fileManager = FileManager.default
        
        // Remove existing resources if any
        if fileManager.fileExists(atPath: destinationPath) {
            try? fileManager.removeItem(atPath: destinationPath)
        }
        
        // Copy resources
        do {
            let destinationURL = URL(fileURLWithPath: destinationPath)
            try fileManager.createDirectory(at: destinationURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try fileManager.copyItem(atPath: sourcePath, toPath: destinationPath)
            
            // Save md5 from bundle.md5 file
            if let md5FilePath = Bundle.main.path(forResource: "bundle", ofType: "md5"),
               let bundleMd5 = try? String(contentsOfFile: md5FilePath, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines) {
                UserDefaults.standard.set(bundleMd5, forKey: hashStorageKey)
            }
            
            let elapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("[Beauty] Resources copied in \(String(format: "%.2f", elapsed))s")
        } catch {
            print("[Beauty] Copy failed: \(error.localizedDescription)")
        }
    }
    

    
    func getSandboxPath() -> String? {
        let base: URL?
        if let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            base = appSupport
        } else if let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            base = caches
        } else {
            return nil
        }
        
        let sandboxURL = base!.appendingPathComponent(sandboxSubpath)
        return sandboxURL.path
    }
}
