//
//  ForgotPasswordViewController.swift
//  HelloAlfred
//
//  Created by admin on 22/05/24.
//

import UIKit

class ForgotPasswordViewController: BaseViewController {

    @IBOutlet var emailPhoneTextFeild: UnderlinedTextField!
    
    let viewModel=AuthViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        emailPhoneTextFeild.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func continueClicked(_ sender: Any) {
        if(isValidEmailOrPhone(emailPhoneTextFeild.text ?? ""))
        {
            generateOTPApiCall()
        }
        else
        {
            showAlert("Please enter valid email.")
        }
    }
    
    @IBAction func LoginClicked(_ sender: Any) {
        navigateTo(viewController: SignInViewController.self, withIdentifier: "SignInViewController")
    }
    
    func generateOTPApiCall() {
        
        let email = emailPhoneTextFeild.text ?? ""
        let otpDataModel = OTPRequestModel(email: email, sms_type: "sms")
        
        viewModel.generateOTP(model: otpDataModel) { [weak self] success in
            if success {
                let userData = SignupUserData(firstName: nil,lastName: nil, email: email, dob: nil, gender: nil, mobile: nil, rtype: nil, education: nil, ssn: nil, insuranceurl: nil, password: nil)
                
                let popup = Constants.mainStoryBoard.instantiateViewController(withIdentifier: "OTPViewController") as? OTPViewController ?? OTPViewController()
                
                if self?.viewModel.commonTokenResponse?.statuscode == 200 {
                    popup.otpSentLabelText = self?.viewModel.commonTokenResponse?.message ?? ""
                } else {
                    popup.otpSentLabelText = ""
                }
                popup.userData = userData
                popup.isFromForgotPassword = true
                popup.modalPresentationStyle = .overCurrentContext
                self?.present(popup, animated: true, completion: nil)
            } else {
                self?.showAlert(self?.viewModel.errorMessage ?? "OTP sent fail")
            }
        }
        
        viewModel.errorMessageAlert = {
            self.showAlert(self.viewModel.errorMessage ?? "OTP sent fail")
        }
    }
    

}
