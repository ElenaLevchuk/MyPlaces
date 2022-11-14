//
//  RatingControl.swift
//  MyPlaces
//
//  Created by Lena on 02.11.2022.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    
    // MARK: - Properties
    var rating = 0 { didSet { updateButtonSelectionState() } }
    private var ratingButtons = [UIButton]()
    
    @IBInspectable var starSize: CGSize = CGSize (width: 44.0, height: 44.0){
        didSet{ setupButtons() }
    }
    
    @IBInspectable var starCount: Int = 5 {
        didSet { setupButtons() }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init (coder:coder)
        setupButtons()
    }
    
    // MARK: - Private Methods
    private func setupButtons(){
        for button in ratingButtons {
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        for _ in 0..<starCount {
            
            //   Load button image
            
            let bundle = Bundle(for: type(of: self))
            
            let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
            
            let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
            
            let highlightedStar = UIImage(named: "highlightedStar", in: bundle, compatibleWith: self.traitCollection)
            
            let button = UIButton()
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            button.addTarget(self,
                             action: #selector (ratingButtonTaped(button: )),
                             for: .touchUpInside)
            
            addArrangedSubview(button)
            ratingButtons.append(button)
        }
        updateButtonSelectionState()
    }
    
    private func updateButtonSelectionState () {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
    
    // MARK: - Button Action
    @objc func ratingButtonTaped(button: UIButton){
        guard let index = ratingButtons.firstIndex(of: button) else { return }
        // if select selected star - set rating zero
        let selectedRating = index + 1
        rating = (selectedRating == rating) ? 0 : selectedRating
    }
    
}

