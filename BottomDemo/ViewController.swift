//
//  ViewController.swift
//  BottomDemo
//
//  Created by satoshi_umaM1 on 2023/10/9.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var tagView: UIView!
    @IBOutlet var tagLabel: UILabel!

    private var buttons: [UIButton] = []
    private let buttonOperationQueue = OperationQueue()
    private var isButtonOperationInProgress = false
    private let buttonHeight: CGFloat = 50
    private var tempTag: Int = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in 0 ... 1 {
            buttonOperationQueue.addOperation {
                DispatchQueue.main.async { [self] in
                    let newButton = createButton()
                    buttons.append(newButton)
                    tagView.addSubview(newButton)
                    updateButtonAddLayout(newButton)
                }
            }
        }
    }

    @objc func buttonTapped(_ sender: UIButton) {
        tagLabel.text = "\(sender.titleLabel?.text ?? "")  tag:\(sender.tag)"
        print("点击按钮: \(sender.titleLabel?.text ?? "") : \(sender.tag)")
    }

    func updateButtonAddLayout(_ sender: UIButton) {
        let buttonCount = buttons.count
        let buttonWidth = tagView.bounds.width / CGFloat(buttonCount)

        for (index, button) in buttons.enumerated() {
            button.tag = index
            if index == buttons.count - 1 {
                button.frame = CGRect(x: tagView.bounds.width, y: 0, width: buttonWidth, height: buttonHeight)
            } else {
                UIView.animate(withDuration: 0.2) { [weak self] in
                    button.frame = CGRect(x: CGFloat(index) * buttonWidth, y: 0, width: buttonWidth, height: self!.buttonHeight)
                }
            }
        }

        UIView.animate(withDuration: 0.2) { [weak self] in
            sender.frame.origin.x = CGFloat(buttonCount - 1) * buttonWidth
            self?.isButtonOperationInProgress = false
        }
    }

    func updateButtonRemoveLayout(_ sender: UIButton) {
        let buttonCount = buttons.count
        let buttonWidth = tagView.bounds.width / CGFloat(buttonCount - 1)

        UIView.animate(withDuration: 0.2) { [self] in
            for (index, button) in buttons.enumerated() {
                button.frame = CGRect(x: CGFloat(index) * buttonWidth, y: 0, width: buttonWidth, height: buttonHeight)
            }
        } completion: { [weak self] _ in
            sender.removeFromSuperview()
            self?.buttons.removeLast()
            self?.isButtonOperationInProgress = false

            self?.tempTag = self!.buttons.count - 1
        }
    }

    @IBAction func addButton(_ sender: UIButton) {
        buttonOperationQueue.addOperation {
            DispatchQueue.main.async { [weak self] in
                guard let self = self, !self.isButtonOperationInProgress else { return }
                self.isButtonOperationInProgress = true
                let newButton = self.createButton()
                self.buttons.append(newButton)
                self.tagView.addSubview(newButton)
                self.updateButtonAddLayout(newButton)
            }
        }
    }

    @IBAction func removeButton(_ sender: UIButton) {
        if buttons.count < 2 { return }
        buttonOperationQueue.addOperation {
            DispatchQueue.main.async { [weak self] in
                guard let self = self, !self.isButtonOperationInProgress, let lastButton = self.buttons.last else { return }
                self.isButtonOperationInProgress = true
                self.updateButtonRemoveLayout(lastButton)
            }
        }
    }

    func createButton() -> UIButton {
        let button = UIButton()
        button.backgroundColor = UIColor.random()
        tempTag = tempTag + 1
        button.tag = tempTag
        button.setTitle("添加：\(tempTag)", for: .normal)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }
}

extension UIColor {
    static func random() -> UIColor {
        let red = CGFloat.random(in: 0 ... 1)
        let green = CGFloat.random(in: 0 ... 1)
        let blue = CGFloat.random(in: 0 ... 1)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
