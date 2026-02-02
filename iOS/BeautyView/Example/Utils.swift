//
//  Utils.swift
//  BeautyView
//
//  Created by HeZhengQing on 2026/1/27.
//

import UIKit
import AVFoundation

// MARK: - PermissionHelper

/// Permission helper class
class PermissionHelper {
    
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    /// Check camera and microphone permissions
    /// - Parameters:
    ///   - granted: Callback when permissions are granted
    ///   - unGranted: Callback when permissions are denied
    ///   - force: Whether to force request permissions (not used in iOS)
    func checkCameraAndMicPerms(
        granted: @escaping () -> Void,
        unGranted: @escaping () -> Void,
        force: Bool = false
    ) {
        // Check camera permission
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let micStatus = AVAudioSession.sharedInstance().recordPermission
        
        // If both are authorized, execute success callback directly
        if cameraStatus == .authorized && micStatus == .granted {
            granted()
            return
        }
        
        // If camera is not authorized, request camera permission first
        if cameraStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] cameraGranted in
                DispatchQueue.main.async {
                    if cameraGranted {
                        // Camera permission granted, continue checking microphone permission
                        self?.checkMicPermission(granted: granted, unGranted: unGranted)
                    } else {
                        unGranted()
                    }
                }
            }
        } else if cameraStatus == .denied || cameraStatus == .restricted {
            // Camera permission denied, show alert
            showPermissionAlert(message: "Camera permission is required to use beauty features. Please enable it in Settings.")
            unGranted()
        } else {
            // Camera authorized, check microphone permission
            checkMicPermission(granted: granted, unGranted: unGranted)
        }
    }
    
    /// Check microphone permission
    private func checkMicPermission(
        granted: @escaping () -> Void,
        unGranted: @escaping () -> Void
    ) {
        let micStatus = AVAudioSession.sharedInstance().recordPermission
        
        if micStatus == .granted {
            granted()
        } else if micStatus == .undetermined {
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] micGranted in
                DispatchQueue.main.async {
                    if micGranted {
                        granted()
                    } else {
                        self?.showPermissionAlert(message: "Microphone permission is required to use beauty features. Please enable it in Settings.")
                        unGranted()
                    }
                }
            }
        } else {
            // Microphone permission denied
            showPermissionAlert(message: "Microphone permission is required to use beauty features. Please enable it in Settings.")
            unGranted()
        }
    }
    
    /// Show permission alert
    private func showPermissionAlert(message: String) {
        guard let viewController = viewController else { return }
        
        let alert = UIAlertController(
            title: "Permission Required",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        viewController.present(alert, animated: true)
    }
}

// MARK: - UINavigationBar Extension

extension UINavigationBar {
    
    func setTransparentStyle(tintColor: UIColor = .white) {
        self.tintColor = tintColor
        titleTextAttributes = [.foregroundColor: tintColor]
        if #available(iOS 11.0, *) {
            largeTitleTextAttributes = [.foregroundColor: tintColor]
        }
    }
    
    func restoreDefaultStyle() {
        tintColor = nil
        titleTextAttributes = nil
        if #available(iOS 11.0, *) {
            largeTitleTextAttributes = nil
        }
    }
}
