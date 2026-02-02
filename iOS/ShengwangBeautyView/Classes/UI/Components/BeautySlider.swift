//
//  BeautySlider.swift
//  BeautyView
//
//  Created by HeZhengQing on 2026/1/22.
//

import UIKit

/// Beauty slider component
/// Custom slider with value display
///
/// Features:
/// - Supports float and int value ranges
/// - Value change callback (only triggered when released)
/// - Label formatter for displaying values
public class BeautySlider: UIView {
    
    // MARK: - Properties
    
    /// Minimum value
    public var minimumValue: Float = 0.0 {
        didSet {
            slider.minimumValue = minimumValue
        }
    }
    
    /// Maximum value
    public var maximumValue: Float = 1.0 {
        didSet {
            slider.maximumValue = maximumValue
        }
    }
    
    /// Current value
    public var value: Float {
        get {
            return slider.value
        }
        set {
            slider.value = newValue
            updateValueLabel()
            updateSliderLabelPosition()
        }
    }
    
    /// Value change callback (triggered only when user releases the slider)
    public var onValueChanged: ((Float) -> Void)?
    
    /// Whether the value range is integer (for formatting)
    private var isIntegerRange: Bool {
        return maximumValue > 1.0
    }
    
    // MARK: - UI Components
    
    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.value = 0.0
        
        // Customize appearance to match reference style
        slider.minimumTrackTintColor = .beauty_main_accent
        slider.maximumTrackTintColor = .beauty_slider_tint
        slider.thumbTintColor = .white
        
        // Add target for value changes
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderTouchDown(_:)), for: .touchDown)
        slider.addTarget(self, action: #selector(sliderTouchUp(_:)), for: [.touchUpInside, .touchUpOutside])
        
        return slider
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.text = "0"
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private var isTracking: Bool = false
    private var sliderLabelCenterCons: NSLayoutConstraint?
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        backgroundColor = .clear
        
        addSubview(slider)
        addSubview(valueLabel)
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            slider.leadingAnchor.constraint(equalTo: leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: trailingAnchor),
            slider.bottomAnchor.constraint(equalTo: bottomAnchor),
            slider.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -3).isActive = true
        valueLabel.heightAnchor.constraint(equalToConstant: 17).isActive = true
        sliderLabelCenterCons = valueLabel.centerXAnchor.constraint(equalTo: slider.leadingAnchor)
        sliderLabelCenterCons?.isActive = true
        
        updateValueLabel()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if slider.bounds.width > 0 {
            updateSliderLabelPosition()
        }
    }
    
    // MARK: - Actions
    
    @objc private func sliderTouchDown(_ sender: UISlider) {
        isTracking = true
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        // Only update label during tracking, don't call callback
        updateValueLabel()
        updateSliderLabelPosition()
    }
    
    @objc private func sliderTouchUp(_ sender: UISlider) {
        isTracking = false
        // Call callback only when user releases the slider
        let finalValue = sender.value
        if isIntegerRange {
            let intValue = Int(finalValue)
            sender.value = Float(intValue)
            updateValueLabel()
            updateSliderLabelPosition()
            onValueChanged?(Float(intValue))
        } else {
            updateSliderLabelPosition()
            onValueChanged?(finalValue)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Update value label with formatted value
    private func updateValueLabel() {
        if isIntegerRange {
            valueLabel.text = String(format: "%d", Int(slider.value))
        } else {
            // Display as decimal (0.0-1.0) for float values - keep 2 decimal places, e.g., 0.99
            valueLabel.text = String(format: "%.2f", slider.value)
        }
    }
    
    /// Update slider label position to follow thumb
    private func updateSliderLabelPosition() {
        let trackRect = slider.trackRect(forBounds: slider.bounds)
        let thumbRect = slider.thumbRect(forBounds: slider.bounds, trackRect: trackRect, value: slider.value)
        sliderLabelCenterCons?.constant = thumbRect.midX - 2.5
        sliderLabelCenterCons?.isActive = true
    }
    
    /// Configure slider with item info
    /// - Parameter itemInfo: Beauty item information
    public func configure(with itemInfo: BeautyItemInfo) {
        // Clear previous callbacks
        onValueChanged = nil
        
        // Set range
        minimumValue = itemInfo.valueRange.lowerBound
        maximumValue = itemInfo.valueRange.upperBound
        
        // Set value (without triggering callback)
        if itemInfo.valueRange.upperBound > 1.0 {
            slider.value = Float(Int(itemInfo.value))
        } else {
            slider.value = itemInfo.value
        }
        updateValueLabel()
        updateSliderLabelPosition()
        
        // Set callback
        onValueChanged = { value in
            // Update itemInfo.value and call callback (updates SDK config)
            if itemInfo.valueRange.upperBound > 1.0 {
                itemInfo.value = Float(Int(value))
            } else {
                itemInfo.value = value
            }
            itemInfo.onValueChanged?(value)
        }
    }
}
