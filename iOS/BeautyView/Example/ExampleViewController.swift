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
    private let beautyMaterialPath: String
    
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
    
    init(beautyMaterialPath: String) {
        self.beautyMaterialPath = beautyMaterialPath
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        initializeBeauty()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(videoContainerTapped))
        videoContainerView.addGestureRecognizer(tap)
        
        let controlBarStackView = UIStackView(arrangedSubviews: [
            beautyButton,
            switchCameraButton,
            saveBeautyButton,
            resetBeautyButton
        ])
        controlBarStackView.axis = .vertical
        controlBarStackView.alignment = .center
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
    
    /// Initialize beauty features
    private func initializeBeauty() {
        // Prevent duplicate initialization
        guard rtcEngine == nil else { return }
        
        // Verify resources exist
        guard FileManager.default.fileExists(atPath: beautyMaterialPath) else {
            print("❌ Beauty resources not found at path: \(beautyMaterialPath)")
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
        config.eventDelegate = self
        let rtcEngine = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        rtcEngine.enableVideo()
        self.rtcEngine = rtcEngine
        self.enable = true
        ShengwangBeautySDK.shared.beautyEventListener = { key, value in
            print("📩 Beauty event callback on app side: key=\(key), value=\(value)")
        }
        
        // Setup video view
        videoContainerView.addSubview(videoView)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            videoView.topAnchor.constraint(equalTo: videoContainerView.topAnchor),
            videoView.leadingAnchor.constraint(equalTo: videoContainerView.leadingAnchor),
            videoView.trailingAnchor.constraint(equalTo: videoContainerView.trailingAnchor),
            videoView.bottomAnchor.constraint(equalTo: videoContainerView.bottomAnchor)
        ])
        
        ShengwangBeautySDK.shared.initBeautySDK(rtcEngine: rtcEngine, materialBundlePath: beautyMaterialPath)
        ShengwangBeautySDK.shared.enable(enable)
        
        let canvas = AgoraRtcVideoCanvas()
        canvas.view = self.videoView
        canvas.renderMode = .hidden
        canvas.mirrorMode = .auto
        rtcEngine.setupLocalVideo(canvas)
        
        // Switch VideoEncoder config
        let encoderConfig = AgoraVideoEncoderConfiguration()
        encoderConfig.dimensions = CGSize(width: 720, height: 1280)
        encoderConfig.frameRate = 24
        rtcEngine.setVideoEncoderConfiguration(encoderConfig)
        
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
    
    @objc private func videoContainerTapped() {
        guard let beautyView = beautyView, !beautyView.isHidden else { return }
        beautyView.isHidden = true
    }
    
    @objc private func switchCameraButtonTapped() {
        rtcEngine?.switchCamera()
    }
    
    @objc private func saveBeautyButtonTapped() {
        guard let beautyView = beautyView else { return }
        beautyView.saveBeauty(.beauty)
        beautyView.saveBeauty(.styleMakeup)
        beautyView.saveBeauty(.filter)
        showAutoAlert(message: NSLocalizedString("beauty_setting_saved_info", comment: ""))
    }
    
    @objc private func resetBeautyButtonTapped() {
        guard let beautyView = beautyView else { return }
        beautyView.resetBeauty(.beauty)
        beautyView.resetBeauty(.styleMakeup)
        beautyView.resetBeauty(.filter)
        showAutoAlert(message: NSLocalizedString("beauty_setting_reseted_info", comment: ""))
    }
    
    private func showAutoAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak alert] in
            alert?.dismiss(animated: true)
        }
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
        ShengwangBeautySDK.shared.beautyEventListener = nil
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

extension ExampleViewController: AgoraMediaFilterEventDelegate {
    func onEventWithContext(_ context: AgoraExtensionContext, key: String?, value: String?) {
        ShengwangBeautySDK.shared.handleExtensionEventWithContext(context, key: key, value: value)
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
