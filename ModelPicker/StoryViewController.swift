//
//  StoryViewController.swift
//  ModelPicker
//
//  Created by Kyubo Shim on 2022/12/02.
//

import UIKit

class StoryViewController: UIViewController {
    let backView = UIView(frame: UIScreen.main.bounds)
    let contentView = UIView(frame: UIScreen.main.bounds)
    
    init() {
            super.init(nibName: "OverLayerView", bundle: nil)
            self.modalPresentationStyle = .overFullScreen
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.yellow
        backView.backgroundColor = .green
        contentView.backgroundColor = .red
        // Do any additional setup after loading the view.
    }
    
    private func configView() {
            self.view.backgroundColor = .clear
            self.backView.backgroundColor = .black.withAlphaComponent(0.6)
            self.backView.alpha = 0
            self.contentView.alpha = 0
            self.contentView.layer.cornerRadius = 10
        }
        
        private func show() {
            UIView.animate(withDuration: 1, delay: 0.2) {
                self.backView.alpha = 1
                self.contentView.alpha = 1
            }
        }
        
        func hide() {
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut) {
                self.backView.alpha = 0
                self.contentView.alpha = 0
            } completion: { _ in
                self.dismiss(animated: false)
                self.removeFromParent()
            }
        }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
