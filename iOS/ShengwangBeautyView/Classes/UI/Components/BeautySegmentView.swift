//
//  BeautySegmentView.swift
//  BeautyView
//
//  Created by HeZhengQing on 2026/1/22.
//

import UIKit

/// Tab switching component
public class BeautySegmentView: UIView {
    
    // MARK: - Properties
    
    /// Tab selection callback
    public var onTabSelected: ((Int) -> Void)?
    
    /// Current selected tab index
    public var selectedIndex: Int = 0 {
        didSet {
            guard selectedIndex != oldValue else { return }
            updateSelectedTab()
        }
    }
    
    /// Tab titles
    public var titles: [String] = [] {
        didSet {
            let oldCount = oldValue.count
            let newCount = titles.count
            
            // 1. Compare count to decide whether to add, remove, or keep unchanged
            if newCount > oldCount {
                // Add new tab buttons
                for index in oldCount..<newCount {
                    let button = createTabButton(title: titles[index], index: index)
                    stackView.addArrangedSubview(button)
                    tabButtons.append(button)
                }
            } else if newCount < oldCount {
                // Remove excess tab buttons
                for index in newCount..<oldCount {
                    tabButtons[index].removeFromSuperview()
                }
                tabButtons.removeLast(oldCount - newCount)
            }
            
            // Ensure indicator exists
            if !tabButtons.isEmpty && indicatorView == nil {
                let indicator = createIndicatorView()
                addSubview(indicator)
                indicatorView = indicator
            }
            
            // 2. Update all titles
            for (index, title) in titles.enumerated() {
                if index < tabButtons.count {
                    tabButtons[index].setTitle(title, for: .normal)
                    tabButtons[index].tag = index
                }
            }
            
            // Update selected state
            if !tabButtons.isEmpty {
                updateSelectedTab()
            }
        }
    }
    
    // MARK: - UI Components
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.alignment = .center
        return stackView
    }()
    
    private var tabButtons: [UIButton] = []
    private var indicatorView: UIView?
    private var indicatorConstraints: [NSLayoutConstraint] = []
    
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
        
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    // MARK: - Tab Management
    
    private func createTabButton(title: String, index: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.beauty_tab_deselect, for: .normal)
        button.setTitleColor(.beauty_tab_select, for: .selected)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        button.tag = index
        button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        return button
    }
    
    private func createIndicatorView() -> UIView {
        let indicator = UIView()
        indicator.backgroundColor = .beauty_tab_select
        indicator.layer.cornerRadius = 1.0
        return indicator
    }
    
    // MARK: - Selection Management
    
    private func updateSelectedTab() {
        guard selectedIndex >= 0 && selectedIndex < tabButtons.count else {
            return
        }
        
        for (index, button) in tabButtons.enumerated() {
            button.isSelected = (index == selectedIndex)
        }
        
        updateIndicatorPosition()
    }
    
    private func updateIndicatorPosition() {
        guard let indicator = indicatorView,
              selectedIndex >= 0 && selectedIndex < tabButtons.count else {
            return
        }
        
        let selectedButton = tabButtons[selectedIndex]
        
        if indicator.superview == nil {
            addSubview(indicator)
        }
        indicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.deactivate(indicatorConstraints)
        indicatorConstraints.removeAll()
        let indicatorWidth: CGFloat = 30
        indicatorConstraints = [
            indicator.centerXAnchor.constraint(equalTo: selectedButton.centerXAnchor),
            indicator.bottomAnchor.constraint(equalTo: bottomAnchor),
            indicator.widthAnchor.constraint(equalToConstant: indicatorWidth),
            indicator.heightAnchor.constraint(equalToConstant: 2.0)
        ]
        NSLayoutConstraint.activate(indicatorConstraints)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            self.layoutIfNeeded()
        }, completion: nil)
        
        scrollToTab(at: selectedIndex)
    }
    
    private func scrollToTab(at index: Int) {
        guard index >= 0 && index < tabButtons.count else {
            return
        }
        
        let button = tabButtons[index]
        let buttonFrame = button.frame
        let scrollViewFrame = scrollView.frame
        
        let buttonMinX = buttonFrame.minX
        let buttonMaxX = buttonFrame.maxX
        let scrollViewMinX = scrollView.contentOffset.x
        let scrollViewMaxX = scrollView.contentOffset.x + scrollViewFrame.width
        
        var newOffset = scrollView.contentOffset.x
        
        if buttonMinX < scrollViewMinX {
            newOffset = buttonMinX - 20
        } else if buttonMaxX > scrollViewMaxX {
            newOffset = buttonMaxX - scrollViewFrame.width + 20
        }
        
        let maxOffset = max(0, scrollView.contentSize.width - scrollViewFrame.width)
        newOffset = max(0, min(newOffset, maxOffset))
        
        UIView.animate(withDuration: 0.3) {
            self.scrollView.contentOffset = CGPoint(x: newOffset, y: 0)
        }
    }
    
    // MARK: - Actions
    
    @objc private func tabButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        
        guard index >= 0 && index < tabButtons.count else {
            return
        }
        
        selectedIndex = index
        onTabSelected?(index)
    }
}
