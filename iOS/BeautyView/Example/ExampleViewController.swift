//
//  ExampleViewController.swift
//  BeautyView
//
//  Created by HeZhengQing on 2026/1/23.
//

import UIKit
import ShengwangBeautyView
import AgoraRtcKit
import Foundation

/// Beauty feature example view controller
/// Demonstrates how to initialize and use beauty features
class ExampleViewController: UIViewController {
    
    // MARK: - Properties
    
    private var rtcEngine: AgoraRtcEngineKit?
    private let videoView = UIView()
    private var beautyView: ShengwangBeautyView?
    
    /// Prepared beauty material path (set by prepareBeautyResources(), used by initializeBeauty).
    private var preparedBeautyMaterialPath: String?
    
    var enable: Bool = false {
        didSet {
            ShengwangBeautySDK.shared.enable(enable)
        }
    }
    
    private lazy var beautyButton: VerticalButton = {
        let button = VerticalButton()
        button.setIcon(UIImage(systemName: "sparkles"))
        button.setTitle(NSLocalizedString("Beauty", comment: ""))
        button.tintColor = .white
        button.setTitleColor(.white)
        button.addTarget(self, action: #selector(beautyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var switchCameraButton: VerticalButton = {
        let button = VerticalButton()
        button.setIcon(UIImage(systemName: "camera.rotate.fill"))
        button.setTitle(NSLocalizedString("Switch Camera", comment: ""))
        button.tintColor = .white
        button.setTitleColor(.white)
        button.addTarget(self, action: #selector(switchCameraButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveBeautyButton: VerticalButton = {
        let button = VerticalButton()
        button.setIcon(UIImage(systemName: "square.and.arrow.down"))
        button.setTitle(NSLocalizedString("Save", comment: ""))
        button.tintColor = .white
        button.setTitleColor(.white)
        button.addTarget(self, action: #selector(saveBeautyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var resetBeautyButton: VerticalButton = {
        let button = VerticalButton()
        button.setIcon(UIImage(systemName: "arrow.counterclockwise"))
        button.setTitle(NSLocalizedString("Reset", comment: ""))
        button.tintColor = .white
        button.setTitleColor(.white)
        button.addTarget(self, action: #selector(resetBeautyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var videoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    // MARK: - Initialization
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        prepareBeautyResources()
        initializeBeauty()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Save beauty settings
        beautyView?.saveBeauty()
        // Stop preview
        rtcEngine?.stopPreview()
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        // Setup navigation bar
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .white
        navigationItem.leftBarButtonItem = backButton
        
        // Setup view
        view.backgroundColor = .black
        UIApplication.shared.isIdleTimerDisabled = true
        
        view.addSubview(videoContainerView)
        videoContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            videoContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            videoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let controlBarStackView = UIStackView(arrangedSubviews: [
            beautyButton,
            switchCameraButton,
            saveBeautyButton,
            resetBeautyButton
        ])
        controlBarStackView.axis = .vertical
        controlBarStackView.alignment = .trailing
        controlBarStackView.distribution = .fillEqually
        controlBarStackView.spacing = 20
        controlBarStackView.backgroundColor = .clear
        view.addSubview(controlBarStackView)
        controlBarStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controlBarStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            controlBarStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            controlBarStackView.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
    }
    
    /// Prepare beauty resources (copy to sandbox). Call before initializeBeauty.
    private func prepareBeautyResources() {
        guard let bundlePath = Bundle.main.path(forResource: "AgoraBeautyMaterial", ofType: "bundle") else {
            print("❌ AgoraBeautyMaterial.bundle not found. Please place the material bundle in the Example folder and add it to your project. To obtain the bundle, contact technical support.")
            return
        }
        preparedBeautyMaterialPath = Self.effectiveBeautyMaterialPath(bundlePath: bundlePath)
    }
    
    /// Initialize beauty features
    private func initializeBeauty() {
        // Prevent duplicate initialization
        guard rtcEngine == nil else { return }
        
        guard let materialPath = preparedBeautyMaterialPath else {
            print("❌ Beauty resources not prepared. Ensure prepareBeautyResources() was called")
            return
        }
        
        // Create RTC Engine
        let appId = KeyCenter.AppId
        guard !appId.isEmpty else {
            print("❌ Please configure App ID in KeyCenter.swift")
            return
        }
        let config = AgoraRtcEngineConfig()
        config.appId = appId
        let rtcEngine = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        rtcEngine.enableVideo()
        self.rtcEngine = rtcEngine
        self.enable = true
        
        // Setup video view
        videoContainerView.addSubview(videoView)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            videoView.topAnchor.constraint(equalTo: videoContainerView.topAnchor),
            videoView.leadingAnchor.constraint(equalTo: videoContainerView.leadingAnchor),
            videoView.trailingAnchor.constraint(equalTo: videoContainerView.trailingAnchor),
            videoView.bottomAnchor.constraint(equalTo: videoContainerView.bottomAnchor)
        ])
        
        ShengwangBeautySDK.shared.initBeautySDK(rtcEngine: rtcEngine, materialBundlePath: materialPath)
        ShengwangBeautySDK.shared.enable(enable)
        
        let canvas = AgoraRtcVideoCanvas()
        canvas.view = self.videoView
        canvas.renderMode = .hidden
        canvas.mirrorMode = .auto
        rtcEngine.setupLocalVideo(canvas)
        rtcEngine.startPreview()
        
        // Setup beauty control view
        let beautyView = ShengwangBeautyView(frame: .zero)
        self.beautyView = beautyView
        view.addSubview(beautyView)
        beautyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            beautyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            beautyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            beautyView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            beautyView.heightAnchor.constraint(equalToConstant: 200)
        ])
        beautyView.isHidden = true
        print("✅ Beauty SDK initialized successfully")
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func beautyButtonTapped() {
        beautyView?.isHidden.toggle()
    }
    
    @objc private func switchCameraButtonTapped() {
        rtcEngine?.switchCamera()
    }
    
    @objc private func saveBeautyButtonTapped() {
        guard let beautyView = beautyView else { return }
        beautyView.saveBeauty()
    }
    
    @objc private func resetBeautyButtonTapped() {
        guard let beautyView = beautyView else { return }
        beautyView.resetBeauty()
    }
    
    // MARK: - Cleanup
    
    private func cleanup() {
        guard let rtcEngine = rtcEngine else { return }
        
        rtcEngine.stopPreview()
        
        let canvas = AgoraRtcVideoCanvas()
        canvas.view = nil
        rtcEngine.setupLocalVideo(canvas)
        
        videoView.removeFromSuperview()
        
        ShengwangBeautySDK.shared.unInitBeautySDK()
        self.rtcEngine = nil
        
        UIApplication.shared.isIdleTimerDisabled = false
        print("✅ Cleanup completed")
    }
}

// MARK: - AgoraRtcEngineDelegate

extension ExampleViewController: AgoraRtcEngineDelegate {
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        print("⚠️ RTC Error code: \(errorCode.rawValue), msg: \(AgoraRtcEngineKit.getErrorDescription(errorCode.rawValue))")
    }
}

// MARK: - VerticalButton

/// Vertical icon button with image on top and text below
/// 上图下字结构的按钮类
class VerticalButton: UIButton {
    
    // MARK: - Properties
    
    private let iconImageView = UIImageView()
    internal let customTitleLabel = UILabel()
    private let containerStackView = UIStackView()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        
        // Configure icon image view
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconImageView.isUserInteractionEnabled = false
        
        // Configure title label
        customTitleLabel.textAlignment = .center
        customTitleLabel.textColor = .white
        customTitleLabel.font = .systemFont(ofSize: 12)
        customTitleLabel.numberOfLines = 0
        customTitleLabel.isUserInteractionEnabled = false
        
        // Configure stack view
        containerStackView.axis = .vertical
        containerStackView.alignment = .center
        containerStackView.distribution = .fill
        containerStackView.spacing = 4
        containerStackView.isUserInteractionEnabled = false
        
        containerStackView.addArrangedSubview(iconImageView)
        containerStackView.addArrangedSubview(customTitleLabel)
        
        addSubview(containerStackView)
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    // MARK: - Public Methods
    
    /// Set button icon
    /// - Parameter image: Icon image
    func setIcon(_ image: UIImage?) {
        iconImageView.image = image
    }
    
    /// Set button title
    /// - Parameter title: Button title text
    func setTitle(_ title: String?) {
        customTitleLabel.text = title
    }
    
    /// Set button tint color (affects icon color)
    /// - Parameter color: Tint color
    override var tintColor: UIColor! {
        didSet {
            iconImageView.tintColor = tintColor
        }
    }
    
    /// Set title color
    /// - Parameter color: Title text color
    func setTitleColor(_ color: UIColor) {
        customTitleLabel.textColor = color
    }
    
    /// Set title font
    /// - Parameter font: Title font
    func setTitleFont(_ font: UIFont) {
        customTitleLabel.font = font
    }
}

// MARK: - Beauty Resource Sandbox

private extension ExampleViewController {
    static let beautyResourceSandboxSubpath = "AgoraBeautyMaterial.bundle"
    static let beautyMaterialFunctionalName = "beauty_material_functional"
    
    /// Returns the full sandbox path for beauty resources (Application Support). Creates parent directory if needed. Returns nil if base directory is unavailable.
    static func beautyResourceSandboxPath() -> String? {
        let base: URL?
        if let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            base = appSupport
        } else if let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            base = caches
        } else {
            return nil
        }
        let sandboxURL = base!.appendingPathComponent(beautyResourceSandboxSubpath)
        let parent = sandboxURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: parent.path) {
            try? FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true)
        }
        return sandboxURL.path
    }
    
    static func hasValidBeautyResources(atBundlePath bundlePath: String) -> Bool {
        let functionalPath = (bundlePath as NSString).appendingPathComponent(beautyMaterialFunctionalName)
        return FileManager.default.fileExists(atPath: functionalPath)
    }
    
    /// Copies the bundle at sourcePath to sandboxPath. If sandboxPath already exists, removes it first. Returns true on success.
    static func copyBeautyBundle(from sourcePath: String, to sandboxPath: String) -> Bool {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: sandboxPath) {
            do {
                try fileManager.removeItem(atPath: sandboxPath)
            } catch {
                print("[Example] Failed to remove existing sandbox path before copy: \(error)")
                return false
            }
        }
        do {
            let sandboxURL = URL(fileURLWithPath: sandboxPath)
            try fileManager.createDirectory(at: sandboxURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try fileManager.copyItem(atPath: sourcePath, toPath: sandboxPath)
            return true
        } catch {
            print("[Example] Failed to copy beauty bundle to sandbox: \(error)")
            return false
        }
    }
    
    /// Resolves the path to use for beauty SDK: sandbox if it has valid resources, else copy from bundlePath to sandbox, or fallback to bundlePath.
    static func effectiveBeautyMaterialPath(bundlePath: String) -> String {
        guard let sandboxPath = beautyResourceSandboxPath() else { return bundlePath }
        if hasValidBeautyResources(atBundlePath: sandboxPath) {
            return sandboxPath
        }
        if copyBeautyBundle(from: bundlePath, to: sandboxPath) {
            return sandboxPath
        }
        return bundlePath
    }
}
