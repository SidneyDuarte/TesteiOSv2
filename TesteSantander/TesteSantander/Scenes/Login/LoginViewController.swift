//
//  LoginViewController.swift
//  TesteSantander
//
//  Created by Sidney Silva on 11/05/19.
//  Copyright (c) 2019 Sakura Soft. All rights reserved.
//

import UIKit

protocol LoginDisplayLogic: class {
    func getData(viewModel: LoginModel.Login.ViewModel)
    func displayErrorAlert(error: String)
    func fillLastUsername(username: String)
}

class LoginViewController: UIViewController, LoginDisplayLogic {
    var interactor: LoginBusinessLogic?
    var router: (NSObjectProtocol & LoginRoutingLogic & LoginDataPassing)?

    // MARK: Object lifecycle
  
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
  
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
  
    // MARK: Setup
  
    private func setup() {
        let viewController = self
        let interactor = LoginInteractor()
        let presenter = LoginPresenter()
        let router = LoginRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
  
    // MARK: Routing
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
  
    // MARK: View lifecycle
  
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoadingView()
        getLastUsername()
        setupNotification()
    }
    
    // MARK: Outlets
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var loadingView: Loading?
    @IBOutlet weak var usernameConstraint: NSLayoutConstraint!
    
    func setupLoadingView() {
        loadingView = Loading.instanceFromNib(rect: self.view.frame)
    }
    
    func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        usernameConstraint.constant = 75
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        usernameConstraint.constant = 105
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func startLoadingView() {
        guard let loading = loadingView else { return }
        loading.activityIndicator.startAnimating()
        self.view.addSubview(loading)
    }
    
    func removeLoadingView() {
        self.loadingView?.activityIndicator.stopAnimating()
        self.loadingView?.removeFromSuperview()
    }
    
    func getLastUsername() {
        interactor?.getLastUserName()
    }
    
    func performLogin() {
        let request = LoginModel.Login.Request(user: userTextField.text, password: passwordTextField.text)
        interactor?.performLogin(request: request)
    }
  
    func getData(viewModel: LoginModel.Login.ViewModel) {
        removeLoadingView()
        self.performSegue(withIdentifier: Constants.Identifiers.statementSegue, sender: self)
    }
    
    func displayErrorAlert(error: String) {
        removeLoadingView()
        let alert = UIAlertController(title: "erro", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func fillLastUsername(username: String) {
        userTextField.text = username
    }
    
    @IBAction func tapLogin(_ sender: Any) {
        startLoadingView()
        performLogin()
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.returnKeyType {
        case .next:
            passwordTextField.becomeFirstResponder()
            return true
        case .go:
            textField.resignFirstResponder()
            startLoadingView()
            performLogin()
            return true
        default:
            textField.resignFirstResponder()
            return true
        }
    }
}
