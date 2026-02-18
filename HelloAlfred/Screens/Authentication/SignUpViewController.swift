//
//  SignUpViewController.swift
//  HelloAlfred
//
//  Created by admin on 01/03/24.


import UIKit
import FlagPhoneNumber

class SignUpViewController: BaseViewController,UIDocumentPickerDelegate
{

//    @IBOutlet var uploadFileTopConstraint: NSLayoutConstraint!
//    @IBOutlet var ssnTextFeild: UnderlinedTextField!
   // @IBOutlet var educationTextFeild: UnderlinedTextField!
    @IBOutlet var mobileTextFeild: FPNTextField!
    @IBOutlet var emailTextFeild: UnderlinedTextField!
    @IBOutlet var firstNameTextFeild: UnderlinedTextField!
    @IBOutlet var dobTextfeild: UnderlinedTextField!
   
    @IBOutlet var lastNameTextFeild: UnderlinedTextField!
    //    @IBOutlet var documentNameLabel: UILabel!
//    @IBOutlet weak var residenceDropDownTextField: UITextField!
    
    @IBOutlet var genderDropDownTextFeild: UITextField!
    var userData:SignupUserData?
    let viewModel=AuthViewModel()

    var isPickerViewShownForGender = false
    var isPickerViewShownForResidence = false
    
    let genderData = ["Others","Male", "Female"]
    let residenceData = ["Others","Home", "Office"]
    
    var isChecked = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPicker(for: genderDropDownTextFeild, with: genderData)
      //  setupPicker(for: residenceDropDownTextField, with: residenceData)
        setupDelegates()
       addDoneButtonToNumberPad(textField: mobileTextFeild)
        setFilledData()
        UserDefaults.standard.set(true, forKey: "IS_APP_OPENED")
       // documentNameLabel.isHidden = true
        // Do any additional setup after loading the view.
    }
    
   func setupDelegates()
    {
        dobTextfeild.delegate = self
       // ssnTextFeild.delegate = self
      //  educationTextFeild.delegate = self
        mobileTextFeild.delegate = self
        firstNameTextFeild.delegate = self
        emailTextFeild.delegate = self
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    @IBAction func continueClicked(_ sender: Any) {
        if(firstNameTextFeild.text == "" || firstNameTextFeild.text == nil) {
//            self.showAlert("Please enter the Full name");
            self.showAlert("Please enter the first name");
        }
        if(lastNameTextFeild.text == "" || lastNameTextFeild.text == nil) {
            self.showAlert("Please enter the last name");
        }
        else if(emailTextFeild.text == "" || emailTextFeild.text == nil) {
            self.showAlert("Please enter the email Id")
        } else if(!self.isValidEmail(email: emailTextFeild.text ?? "")) {
            self.showAlert("Please enter valid email Id")
        } else if(dobTextfeild.text == "" || dobTextfeild.text == nil) {
            self.showAlert("Please select the date of birth")
        } else if(genderDropDownTextFeild.text == "" || genderDropDownTextFeild.text == nil) {
            self.showAlert("Please select the gender")
        } else if(mobileTextFeild.text == "" || mobileTextFeild.text == nil) {
            self.showAlert("Please enter the mobile number")
        }else if(!isChecked) {
            self.showAlert("Please accept the terms and conditions")
        }
        else {
            //validation passed
           // self.activityIndicator(self.view, startAnimate: true)
            generateOTPApiCall()
            
            
        }
        
        
    }
    
    @IBAction func selectFileButtonTapped(_ sender: UIButton) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    @IBAction func termsAndConditionsClicked(_ sender: Any) {
        if let currentViewController = Constants.mainStoryBoard.instantiateViewController(withIdentifier: "TermsAndConditionsViewController") as? TermsAndConditionsViewController {
            currentViewController.isChecked = isChecked
            currentViewController.email = emailTextFeild.text ?? ""
            currentViewController.isAccept = { (isAccept, version) in
                self.isChecked = isAccept
                DispatchQueue.main.async {
                    if let email = self.emailTextFeild.text, !email.isEmpty {
                        let requestModel = TermsAcceptRequest(
                            version: version,
                            email: email,
                            source: "self_signup",
                        )
                        self.viewModel.acceptTermsAndConditions(model: requestModel)
                        
                    } else {
                        self.isChecked = false
                        self.showAlert("Enter valid email address.")
                    }
                }
            }
            
            currentViewController.modalPresentationStyle = .overFullScreen
            present(currentViewController, animated: true)
        }
    }
    
    @IBAction func signinClicked(_ sender: Any) {
        
        navigateTo(viewController: SignInViewController.self, withIdentifier: "SignInViewController")
    }
    // MARK: - UIDocumentPickerDelegate
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            return
        }
        let url = URL(fileURLWithPath: selectedFileURL.absoluteString)
        // display file name
//        documentNameLabel.text = url.lastPathComponent
//        uploadFileTopConstraint.constant = 44
//        documentNameLabel.isHidden = false
//        print("Selected file URL: \(url.lastPathComponent)")
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // Handle cancellation
        print("Document picker was cancelled")
    }
    
    func setFilledData()
    {
        if userData != nil
        {
            firstNameTextFeild.text = userData?.firstName
            lastNameTextFeild.text = userData?.lastName

            emailTextFeild.text = userData?.email
          //  ssnTextFeild.text = userData?.ssn
            genderDropDownTextFeild.text = userData?.gender
            mobileTextFeild.text = userData?.mobile
            dobTextfeild.text = userData?.dob
//            educationTextFeild.text = userData?.education
//            residenceDropDownTextField.text = userData?.rtype
        }
    }
    func generateOTPApiCall() {
        let countryCode = mobileTextFeild.selectedCountry?.phoneCode ?? ""
        let mobileNumber = mobileTextFeild.text?.replacingOccurrences(of: " ", with: "") ?? ""
        let fullMobile = "\(countryCode)\(mobileNumber)"
     
        self.view.endEditing(true)

        let email = emailTextFeild.text ?? ""
        let username = firstNameTextFeild.text ?? ""

        let otpDataModel = OTPRequestModel(
            email: email,
            username: username,
            mobile: fullMobile,
            sms_type: "sms"
        )
       
        viewModel.generateOTP(model: otpDataModel) { [self] success in
            if success {
                let userData = SignupUserData(firstName: firstNameTextFeild.text ?? "",lastName: lastNameTextFeild.text ?? "", email: emailTextFeild.text ?? "", dob: self.dobTextfeild.text ?? "", gender: genderDropDownTextFeild.text ?? "", mobile: mobileTextFeild.text ?? "",
                rtype: nil,
                education: nil, ssn: nil, insuranceurl: nil, password: nil)
                
                let popup = Constants.mainStoryBoard.instantiateViewController(withIdentifier: "OTPViewController") as? OTPViewController ?? OTPViewController()
                if viewModel.commonTokenResponse?.statuscode == 200 {
                    popup.otpSentLabelText = self.viewModel.commonTokenResponse?.message ?? ""
                } else {
                    self.showAlert(self.viewModel.errorMessage ?? "OTP sent failed. Please try again.")
                }
                popup.userData = userData
                popup.modalPresentationStyle = .overCurrentContext
                present(popup, animated: true, completion: nil)
            }
        }
        
        viewModel.errorMessageAlert = {
            self.showAlert(self.viewModel.errorMessage ?? "OTP sent failed. Please try again.")
        }
    }
    
}

extension SignUpViewController:UIPickerViewDelegate, UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return genderData.count
        } else if pickerView.tag == 2 {
            return residenceData.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == 1 {
            return genderData[row]
        } else if pickerView.tag == 2 {
            return residenceData[row]
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("did select")
        if pickerView.tag == 1 {
            genderDropDownTextFeild.text = genderData[row]
            genderDropDownTextFeild.resignFirstResponder() // Close the picker
            
        } else if pickerView.tag == 2 {
//            residenceDropDownTextField.text = residenceData[row]
//            residenceDropDownTextField.resignFirstResponder() // Close the picker
            
        }
    }
    
    // MARK: - Helper method to set up UIPickerView for a UITextField
    
    func setupPicker(for textField: UITextField, with data: [String]) {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.tag = textField.tag // Assign a unique tag to differentiate between pickers
        
        textField.inputView = pickerView
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        
        textField.inputAccessoryView = toolbar
    }
    @objc func doneButtonTapped() {
       

        //print
        view.endEditing(true) // Dismiss the keyboard or picker view
    }
}


extension SignUpViewController:DatePickerDelegate
{
    
    func selectedDate(date: String) {
        let validDate = validateDateOfBirth(dateString: date)
        if(validDate)
        {
            dobTextfeild.text = date;
        }
        else
        {
            showAlert("Sorry! Age limit should be between 18 and 120 years")
        }
    }
    
    func cancelDateSelection() {
        
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
      if textField == dobTextfeild {
        self.view.endEditing(true)
          let storyboard = UIStoryboard(name: "Main", bundle: .main)
          let popup = storyboard.instantiateViewController(withIdentifier: "DatePickerViewController") as! DatePickerViewController
          popup.isTimePicker = false
          popup.modalPresentationStyle = .overCurrentContext
          popup.delegate = self
          present(popup, animated: true, completion: nil)
        return false
      }else{
        return true
      }
    }
}
