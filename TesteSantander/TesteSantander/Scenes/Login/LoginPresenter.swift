//
//  LoginPresenter.swift
//  TesteSantander
//
//  Created by Sidney Silva on 11/05/19.
//  Copyright (c) 2019 Sakura Soft. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol LoginPresentationLogic {
    func presentLogin(response: LoginModel.Login.Response)
    func presentLoginError(error: String)
}

class LoginPresenter: LoginPresentationLogic {
    weak var viewController: LoginDisplayLogic?
    
    func presentLogin(response: LoginModel.Login.Response) {
        let viewModel = LoginModel.Login.ViewModel(name: response.user?.userAccount?.name ?? "",
                                                   bankAccount: response.user?.userAccount?.bankAccount ?? "",
                                                   agency: response.user?.userAccount?.agency ?? "",
                                                   balance: response.user?.userAccount?.balance ?? 0.0)
        viewController?.getData(viewModel: viewModel)
    }
    
    func presentLoginError(error: String) {
        viewController?.displayErrorAlert(error: error)
    }
}
