//
//  MainViewController.swift
//  BeautyView
//
//  Created by HeZhengQing on 2026/1/23.
//

import UIKit
import CryptoKit

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
        
        // Calculate and compare hashes
        let startTime = CFAbsoluteTimeGetCurrent()
        guard let bundleHash = calculateHash(atPath: bundlePath) else {
            print("[Beauty] Failed to calculate bundle hash")
            return false
        }
        let elapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("[Beauty] Hash calculated in \(String(format: "%.2f", elapsed))s")
        
        let storedHash = UserDefaults.standard.string(forKey: hashStorageKey)
        return storedHash != bundleHash
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
            
            // Save hash
            if let hash = calculateHash(atPath: sourcePath) {
                UserDefaults.standard.set(hash, forKey: hashStorageKey)
            }
            
            let elapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("[Beauty] Resources copied in \(String(format: "%.2f", elapsed))s")
        } catch {
            print("[Beauty] Copy failed: \(error.localizedDescription)")
        }
    }
    
    func calculateHash(atPath path: String) -> String? {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(atPath: path) else { return nil }
        
        var filePaths: [String] = []
        while let relativePath = enumerator.nextObject() as? String {
            let fullPath = (path as NSString).appendingPathComponent(relativePath)
            var isDirectory: ObjCBool = false
            if fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory), !isDirectory.boolValue {
                filePaths.append(relativePath)
            }
        }
        
        guard !filePaths.isEmpty else { return nil }
        
        filePaths.sort()
        var hasher = SHA256()
        
        for relativePath in filePaths {
            let fullPath = (path as NSString).appendingPathComponent(relativePath)
            if let fileData = fileManager.contents(atPath: fullPath),
               let pathData = relativePath.data(using: .utf8) {
                hasher.update(data: pathData)
                hasher.update(data: fileData)
            }
        }
        
        let digest = hasher.finalize()
        return digest.map { String(format: "%02x", $0) }.joined()
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
