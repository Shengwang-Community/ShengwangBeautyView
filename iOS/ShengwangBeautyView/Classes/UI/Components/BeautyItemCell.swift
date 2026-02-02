//
//  BeautyItemCell.swift
//  BeautyView
//
//  Created by HeZhengQing on 2026/1/22.
//

import UIKit

// MARK: - BeautyItemCell

public class BeautyItemCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    public var itemInfo: BeautyItemInfo? {
        didSet {
            updateUI()
        }
    }
    
    public var onItemClick: (() -> Void)?
    
    // MARK: - UI Components
    
    private lazy var iconContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 24
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private var isSelectedState: Bool = false {
        didSet {
            updateSelectionState()
        }
    }
    
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
        
        contentView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        contentView.addSubview(nameLabel)
        
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            iconContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 48),
            iconContainerView.heightAnchor.constraint(equalToConstant: 48),
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.topAnchor.constraint(equalTo: iconContainerView.bottomAnchor, constant: 8)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(itemTapped))
        contentView.addGestureRecognizer(tapGesture)
        contentView.isUserInteractionEnabled = true
    }
    
    // MARK: - Update Methods
    
    private func updateUI() {
        guard let itemInfo = itemInfo else {
            iconImageView.image = nil
            return
        }
        
        iconImageView.image = itemInfo.icon
        nameLabel.text = itemInfo.name.localized
        isSelectedState = itemInfo.isSelected
    }
    
    private func updateSelectionState() {
        if isSelectedState {
            iconContainerView.layer.borderColor = UIColor.beauty_main_accent.cgColor
        } else {
            iconContainerView.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        }
    }
    
    // MARK: - Actions
    
    @objc private func itemTapped() {
        onItemClick?()
    }
    
    // MARK: - Public Methods
    
    public func configure(with itemInfo: BeautyItemInfo) {
        self.itemInfo = itemInfo
        setSelected(itemInfo.isSelected)
    }
    
    public func setSelected(_ selected: Bool) {
        isSelectedState = selected
        itemInfo?.isSelected = selected
    }
}

// MARK: - BeautyImageItemCell

public class BeautyImageItemCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    public var itemInfo: BeautyItemInfo? {
        didSet {
            updateUI()
        }
    }
    
    public var onItemClick: (() -> Void)?
    
    // MARK: - UI Components
    
    private lazy var iconContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 24
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private var isSelectedState: Bool = false {
        didSet {
            updateSelectionState()
        }
    }
    
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
        
        contentView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        contentView.addSubview(nameLabel)
        
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            iconContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 48),
            iconContainerView.heightAnchor.constraint(equalToConstant: 48),
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 44),
            iconImageView.heightAnchor.constraint(equalToConstant: 44),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.topAnchor.constraint(equalTo: iconContainerView.bottomAnchor, constant: 8)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(itemTapped))
        contentView.addGestureRecognizer(tapGesture)
        contentView.isUserInteractionEnabled = true
    }
    
    // MARK: - Update Methods
    
    private func updateUI() {
        guard let itemInfo = itemInfo else {
            iconImageView.image = nil
            return
        }
        
        iconImageView.image = itemInfo.icon
        nameLabel.text = itemInfo.name.localized
        isSelectedState = itemInfo.isSelected
    }
    
    private func updateSelectionState() {
        if isSelectedState {
            iconContainerView.layer.borderColor = UIColor.beauty_main_accent.cgColor
        } else {
            iconContainerView.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        }
    }
    
    // MARK: - Actions
    
    @objc private func itemTapped() {
        onItemClick?()
    }
    
    // MARK: - Public Methods
    
    public func configure(with itemInfo: BeautyItemInfo) {
        self.itemInfo = itemInfo
        setSelected(itemInfo.isSelected)
    }
    
    public func setSelected(_ selected: Bool) {
        isSelectedState = selected
        itemInfo?.isSelected = selected
    }
}

// MARK: - BeautyToggleCell

public class BeautyToggleCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    public var itemInfo: BeautyItemInfo? {
        didSet {
            updateUI()
        }
    }
    
    public var onItemClick: (() -> Void)?
    
    // MARK: - UI Components
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
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
        
        let paddingContainer = UIView()
        paddingContainer.backgroundColor = .clear
        contentView.addSubview(paddingContainer)
        paddingContainer.addSubview(iconImageView)
        contentView.addSubview(nameLabel)
        
        paddingContainer.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            paddingContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            paddingContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            paddingContainer.widthAnchor.constraint(equalToConstant: 48),
            paddingContainer.heightAnchor.constraint(equalToConstant: 48),
            iconImageView.centerXAnchor.constraint(equalTo: paddingContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: paddingContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.topAnchor.constraint(equalTo: paddingContainer.bottomAnchor, constant: 8)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(itemTapped))
        contentView.addGestureRecognizer(tapGesture)
        contentView.isUserInteractionEnabled = true
    }
    
    // MARK: - Update Methods
    
    private func updateUI() {
        guard let itemInfo = itemInfo else {
            iconImageView.image = nil
            nameLabel.text = nil
            return
        }
        
        // Use toggle value from type instead of isSelected
        let isEnabled = itemInfo.type.toggleValue ?? false
        if isEnabled {
            iconImageView.image = UIImage.beautyIcon(named: "beauty_switcher_on")
            nameLabel.text = "beauty_effect_enable".localized
        } else {
            iconImageView.image = UIImage.beautyIcon(named: "beauty_switcher_off")
            nameLabel.text = "beauty_effect_disable".localized
        }
    }
    
    // MARK: - Actions
    
    @objc private func itemTapped() {
        onItemClick?()
    }
    
    // MARK: - Public Methods
    
    public func configure(with itemInfo: BeautyItemInfo) {
        self.itemInfo = itemInfo
        updateUI()
    }
}
