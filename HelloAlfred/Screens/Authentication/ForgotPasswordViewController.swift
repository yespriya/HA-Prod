//
//  ForgotPasswordViewController.swift
//  HelloAlfred
//
//  Created by admin on 22/05/24.
//

import UIKit

class ForgotPasswordViewController: BaseViewController {

    @IBOutlet var emailPhoneTextField: UnderlinedTextField!
    
    let viewModel=AuthViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        emailPhoneTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func continueClicked(_ sender: Any) {
        
        guard let input = emailPhoneTextField.text, !input.isEmpty else {
            self.showAlert("Please enter email or mobile number.")
            return
        }
        
        if isValidEmailOrPhone(input) {
            generateOTPApiCall(input: input)
        } else {
            self.showAlert("Please enter email or mobile number.")
        }
    }
    
    @IBAction func LoginClicked(_ sender: Any) {
        navigateTo(viewController: SignInViewController.self, withIdentifier: "SignInViewController")
    }
    
    func generateOTPApiCall(input: String) {
        var otpDataModel: OTPRequestModel
        
        if isValidMobile(input){
            otpDataModel = OTPRequestModel(mobile: input, sms_type: "sms")
        } else {
            otpDataModel = OTPRequestModel(email: input, sms_type: "sms")
        }
        
        viewModel.generateOTP(model: otpDataModel) { [weak self] success in
            if success {
                var userData: SignupUserData
                
                if self?.isValidMobile(input) ?? false {
                    userData = SignupUserData(mobile: input)
                } else {
                    userData = SignupUserData(email: input)
                }
                
                let popup = Constants.mainStoryBoard.instantiateViewController(withIdentifier: "OTPViewController") as? OTPViewController ?? OTPViewController()
                
                if self?.viewModel.commonTokenResponse?.statuscode == 200 {
                    popup.otpSentLabelText = self?.viewModel.commonTokenResponse?.message ?? ""
                } else {
                    popup.otpSentLabelText = ""
                }
                popup.userData = userData
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
