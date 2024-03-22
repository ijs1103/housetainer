//
//  UIViewController+.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/14.
//

import UIKit

extension UIViewController {
    func setupCustomBackButton(with customView: UIView = UIImageView(image: Icon.arrowLeft)) {
        let tgr = UITapGestureRecognizer(target: self, action: #selector(popViewController))
        customView.addGestureRecognizer(tgr)
        customView.isUserInteractionEnabled = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customView)
    }
    
    @objc private func popViewController() {
        if let navigationController, navigationController.viewControllers.first !== self{
            navigationController.popViewController(animated: true)
        }else{
            dismiss(animated: true)
        }
    }
    
    func setupScrollViewAndContentView(_ scrollView: UIScrollView, _ contentView: UIView) {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.snp.width)
        }
        let contentViewHeight = contentView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor)
        contentViewHeight.priority = .defaultLow
        contentViewHeight.isActive = true
    }
    
    func hidesBackButton() {
        navigationItem.hidesBackButton = true
    }
    
    func presentFullScreenModalWithNavigation(_ viewController: UIViewController) {
        let vc = UINavigationController(rootViewController: viewController)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false)
    }
    
    func setupKeyboardDismissGestureRecognizerToScrollView(_ scrollView: UIScrollView) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupKeyboardNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        guard let keyboardFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        if view.frame.origin.y == 0 {
            view.frame.origin.y -= keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
}
