import UIKit
import WebKit
import SwiftSoup

class HealthHubViewController: UIViewController {
    
    
    @IBOutlet weak var lblWeekDescription: UILabel!
    @IBOutlet weak var lblWeekObjective: UILabel!
    @IBOutlet weak var lblContentDescription: UILabel!
    
    @IBOutlet weak var lblActivities: UILabel!
    
    @IBOutlet weak var lblActivitiesTitle: UILabel!
    @IBOutlet var weeklyContentDetailsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var weeklyContentDescriptionLabel: UILabel!
    @IBOutlet var weeklyContentTitleLabel: UILabel!
    @IBOutlet var weeklyDetailsTableView: UITableView!
    @IBOutlet var selectedWeekLabel: UILabel!
    @IBOutlet var linearProgressBar: SteppedLinearProgressBar!
    @IBOutlet var titleText: UILabel!

    
    let viewModel = DashboardViewModel()
    var healthViewModel = HealthHubViewModel()
    var weeklyContent: [WeeklyContent?] = []
    var selectedWeek = "week0"
    var selectedWeekQuizKey = "pre_test"
    var nextWeekQuizKey:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchInitialData()
    }
    
    private func fetchInitialData() {
         self.activityIndicator(self.view, startAnimate: true)
        guard !healthViewModel.isLoading else { return }
        fetchDropDownApiCall()
        fetchWeeklyUnlockContent()
    }
    
    // MARK: - Button Actions
    
    @IBAction func proceedClicked(_ sender: Any) {
        self.updateHealthHubStatus(type: "Proceed")
    }
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func overViewClicked(_ sender: Any) {
        fetechHealthHubOverview()
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func selectWeekClicked(_ sender: Any) {
        if let currentViewController = Constants.mainStoryBoard.instantiateViewController(withIdentifier: "SelectWeekViewController") as? SelectWeekViewController {
            currentViewController.viewModel = healthViewModel
            currentViewController.delegate = self
            currentViewController.modalPresentationStyle = .overCurrentContext
            present(currentViewController, animated: true)
        }
    }
    
    @IBAction func videoButtonClicked(_ sender: Any) {
        if let currentViewController = Constants.mainStoryBoard.instantiateViewController(withIdentifier: "VideoListViewController") as? VideoListViewController {
            currentViewController.modalPresentationStyle = .overFullScreen
            present(currentViewController, animated: true)
        }
    }
    
    @IBAction func quizButtonClicked(_ sender: Any) {
        let viewModel = QuizViewModel()
        viewModel.fetchQuizData(with: ["week_number" : selectedWeekQuizKey.replacingOccurrences(of: "module_", with: "")])
        viewModel.quizListFetchSuccess = { [weak self] in
            guard let self = self else { return }
            self.activityIndicator(view.self, startAnimate: false)
            
            if !(viewModel.quizResponse?.status ?? true) {
                self.showAlert(viewModel.quizResponse?.message ?? "")
            } else {
                if let currentViewController = Constants.mainStoryBoard.instantiateViewController(withIdentifier: "QuizViewController") as? QuizViewController {
                    currentViewController.modalPresentationStyle = .overFullScreen

                    currentViewController.quizKey = selectedWeekQuizKey.replacingOccurrences(of: "module_", with: "")
                    currentViewController.moduelDisplyNumber = selectedWeekLabel.text ?? ""
                    currentViewController.nextWeekQuizKey_pretest = nextWeekQuizKey
                    currentViewController.needToUpdateWeekStatus = { [weak self] status in
                        self?.updateHealthHubStatus(type: "update_complete_week")
                        self?.healthViewModel.fetchWeeklyContent(weekNumber: self?.selectedWeekQuizKey.replacingOccurrences(of: "week", with: "") ?? "")
                        self?.fetchInitialData()
                        if let data = self?.healthViewModel.dropDownResData {
                            if let dropDownData = data.first {
                                self?.selectedWeekLabel.text = dropDownData.label
                                self?.lblContentDescription.text = dropDownData.title
                                self?.nextWeekQuizKey = self?.nextWeekQuizKey ?? ""
                                self?.selectedWeekQuizKey = dropDownData.quizKey ?? ""
                            }
                        }
                        self?.fetchWeeklyUnlockContent()
                    }
                    present(currentViewController, animated: true)
                }
            }
        }
    }
    
    

    private func updateHealthHubStatus(type: String) {
        var unlockNextWeekKey = nextWeekQuizKey
        
        // Dynamically find the EXACT next module from the chronological dropdown list
        if let dropDownData = healthViewModel.dropDownResData {
            // Find the index of the currently selected module
            let currentWeekValue = selectedWeek.contains("week") ? selectedWeek : "week\(selectedWeek)"
            if let currentIndex = dropDownData.firstIndex(where: { $0.value == currentWeekValue }),
               currentIndex + 1 < dropDownData.count {
                // Grab the quizKey for the next chronological module
                unlockNextWeekKey = dropDownData[currentIndex + 1].value ?? ""
            }
        }
        
        // Build parameters
        let params: [String: Any] = type == "Skip"
        ? ["skip_week": selectedWeek.replacingOccurrences(of: "week", with: "")]
            : [
                "update_current_week": selectedWeek.replacingOccurrences(of: "week", with: ""),
                "unlock_next_week": unlockNextWeekKey.replacingOccurrences(of: "week", with: "")
              ]
        
        print("Sending Params to Unlock Module: \(params)")
        
        healthViewModel.updateHealthHubStatus(params: params)
        healthViewModel.healthHubStatusUpdateSuccess = {
            if case let .dataClass(dataClass) = self.healthViewModel.healthHubUpdateStatusRes?.data {
                if dataClass.quizStatus == false {
                    self.showAlert("Please complete the quiz to proceed")
                } else {
                    if(type == "Proceed"){
                        self.updateUserStatusApiCall()
                    }
                    DispatchQueue.main.async {
                        self.fetchInitialData()
                    }
                }
            }
        }
        
        healthViewModel.loadingStatus = {
            if !self.healthViewModel.isLoading {
                DispatchQueue.main.async {
                    self.activityIndicator(self.view, startAnimate: false)
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            }
        }
        
        healthViewModel.errorMessageAlert = {
            self.showAlert(self.healthViewModel.errorMessage ?? "Error")
        }
    }
}

// MARK:  UITableViewDataSource & UITableViewDelegate
extension HealthHubViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weeklyContent.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeeklyHealthDetailsTableViewCell", for: indexPath) as? WeeklyHealthDetailsTableViewCell ?? WeeklyHealthDetailsTableViewCell()
        let content = weeklyContent[indexPath.row]
        cell.titleLabel.text = content?.title

        cell.videoLink = content?.video
        cell.imageLink = content?.photo
        cell.thumbnailLink = content?.thumbnail
        cell.indexNumber = indexPath.row
        var items: [WeeklyHealthDetailsTableViewCell.MediaType] = []

        if let video = content?.video, !video.isEmpty {
            items.append(.video(video))
        }
        if let photo = content?.photo, !photo.isEmpty {
            items.append(.image(photo))
        }
        
        cell.mediaItems = items
        cell.videoCollectionView.reloadData()

        DispatchQueue.main.async {
            if cell.mediaItems.count > 0 {
                cell.scrollToPage(page: 0, animated: false) // safe initial scroll
            }
        }
	
        if items.isEmpty {
            cell.vwCollection.isHidden = true
            cell.pageControl.numberOfPages = 0
            cell.rightArrowButton.isHidden = true
            cell.leftArrowButton.isHidden = true

        } else if items.count == 1 {
            cell.vwCollection.isHidden = false
            cell.pageControl.numberOfPages = 1
            cell.rightArrowButton.isHidden = true
            cell.leftArrowButton.isHidden = true

        } else {
            cell.vwCollection.isHidden = false
            cell.pageControl.numberOfPages = items.count
            cell.rightArrowButton.isHidden = false
            cell.leftArrowButton.isHidden = false
        }

        let html = content?.description ?? ""
        let options = fetchSelectOptions(from: html)
        let sortedArray = options.sorted { $0.key < $1.key }.map { "\($0.value)" }
        
        print(options)
        print(sortedArray)
        
        cell.descriptionDropDown.optionArray = sortedArray
        //descriptionDropDown.optionIds = option.ids
        cell.descriptionDropDown.checkMarkEnabled = false
        cell.descriptionDropDown.semanticContentAttribute = .forceRightToLeft
        cell.descriptionDropDown.textColor = .black
        cell.descriptionDropDown.arrowSize = 10
        cell.descriptionDropDown.backgroundColor = UIColor.init(red: 244, green: 245, blue: 250, alpha: 1.0)

        if options.count == 0 {
            setHTMLText(html, to: cell.descriptionLabel)
        }
    
        if sortedArray.count > 0 {
            cell.descriptionDropDown.isHidden = false
            cell.descriptionDropDown.placeholder = sortedArray.first
            cell.dropDownHeightConstraint.constant = 30
            cell.dropDownHeightConstraint.isActive = true
            
            cell.descriptionDropDown.placeholder = sortedArray.first
            
            
            
            let divId = "1"
            if let attributedContent = HTMLParser.parseMedicationContent(html: html, divId: divId) {
                
                let mutableAttributedString = NSMutableAttributedString(attributedString: attributedContent)
                let range = NSRange(location: 0, length: mutableAttributedString.length)
                if let customFont = UIFont(name: "Poppins-Regular", size: 13.0) {
                    mutableAttributedString.addAttribute(.font, value: customFont, range: range)
                }
            
                cell.descriptionLabel.attributedText = mutableAttributedString
            } else {
                cell.descriptionLabel.text = "Content not available"
            }
            tableView.beginUpdates()
            tableView.endUpdates()

            
        } else {
            cell.descriptionDropDown.isHidden = true
            cell.dropDownHeightConstraint.constant = 0
            cell.dropDownHeightConstraint.isActive = true
        }
        
        
        cell.descriptionDropDown.didSelect { selectedText, index, id in
            cell.descriptionDropDown.placeholder = selectedText
            let divId = "\(index + 1)"
            if let attributedContent = HTMLParser.parseMedicationContent(html: html, divId: divId) {
                
                let mutableAttributedString = NSMutableAttributedString(attributedString: attributedContent)
                let range = NSRange(location: 0, length: mutableAttributedString.length)
                if let customFont = UIFont(name: "Poppins-Regular", size: 13.0) {
                    mutableAttributedString.addAttribute(.font, value: customFont, range: range)
                }
                cell.descriptionLabel.attributedText = mutableAttributedString
                //                cell.descriptionLabel.attributedText = attributedContent
            } else {
                cell.descriptionLabel.text = "Content not available"
            }
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
        
        return cell
    }

    func fetchSelectOptions(from html: String) -> [String: String] {
        // Regular expression to find the <select> block
        let selectRegex = try! NSRegularExpression(pattern: "<select>(.*?)</select>", options: .dotMatchesLineSeparators)
        
        // Find the <select> content
        if let match = selectRegex.firstMatch(in: html, options: [], range: NSRange(html.startIndex..<html.endIndex, in: html)),
           let selectRange = Range(match.range(at: 1), in: html) {
            let selectContent = String(html[selectRange])
            
            // Regular expression to find all <option> tags within the <select>
            let optionRegex = try! NSRegularExpression(pattern: "<option value=\"(.*?)\">(.*?)</option>", options: [])
            let matches = optionRegex.matches(in: selectContent, options: [], range: NSRange(selectContent.startIndex..<selectContent.endIndex, in: selectContent))
            
            // Extract the value and display text from each <option>
            var options: [String: String] = [:]
            for match in matches {
                if let valueRange = Range(match.range(at: 1), in: selectContent),
                   let textRange = Range(match.range(at: 2), in: selectContent) {
                    let value = String(selectContent[valueRange])
                    let text = String(selectContent[textRange])
                    options[value] = text
                }
            }
            return options
        }
        return [:]
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}

// MARK: UI Helper Methods
extension HealthHubViewController {
    private func setupUI() {
        titleText.attributedText = customizeInitialLetter(categoryText: titleText.text!)
        weeklyContentDetailsTableViewHeightConstraint.constant = 1050
    }
    
    private func calculateTotalTableViewHeight() -> CGFloat {
        return (0..<weeklyDetailsTableView.numberOfRows(inSection: 0)).reduce(0) { total, row in
            total + weeklyDetailsTableView.rectForRow(at: IndexPath(row: row, section: 0)).height
        }
    }
    
    private func updateTableViewHeight() {
        DispatchQueue.main.async {
            self.weeklyDetailsTableView.reloadData()
            self.weeklyContentDetailsTableViewHeightConstraint.constant = self.calculateTotalTableViewHeight()
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: APIS
extension HealthHubViewController {
    
    // MARK: DropDown API
    private func fetchDropDownApiCall() {
        healthViewModel.fetchHealthHubDropDownData() { [weak self] success in
            guard let self = self else { return }
            
            if success {
                self.loadLatestModuleIfReady()
            }
        }
        
        healthViewModel.errorMessageAlert = {
            self.showAlert(self.healthViewModel.errorMessage ?? "Error")
        }
    }
    
    // MARK: Week Unlock Status API
    private func fetchWeeklyUnlockContent() {
        healthViewModel.fetchWeeklyUnlockContent() { [weak self] success in
            
            if success {
                guard let self = self else { return }
                self.activityIndicator(view.self, startAnimate: false)
                
                guard let detailss = self.healthViewModel.weeklyUnlockContent?.data else { return }
                
                self.loadLatestModuleIfReady()
                
                var weeks: [String: Bool] = [:]
                for (key, value) in detailss {
                    weeks[key] = value
                }
                
                // Apply to progress bar
                self.linearProgressBar.progressStates.removeAll()
                self.linearProgressBar.progressStates = [.completed, .completed, .completed, .current]
                self.linearProgressBar.setNeedsDisplay()
                self.linearProgressBar.layoutIfNeeded()
            }
        }
    
        healthViewModel.errorMessageAlert = {
            self.showAlert(self.healthViewModel.errorMessage ?? "Error")
        }
    }
    
    // MARK: Health Hub Overview
    private func fetechHealthHubOverview() {
        healthViewModel.fetechHealthHubOverview() { [weak self] success in
            guard let self = self else { return }
            if success {
                if let data = self.healthViewModel.overviewResData {
                    if let currentViewController = Constants.mainStoryBoard.instantiateViewController(withIdentifier: "HealthHubOverViewViewController") as? HealthHubOverViewViewController {
                        currentViewController.afTopics = data
                        present(currentViewController, animated: true)
                    }
                }
            }
        }
        
        healthViewModel.errorMessageAlert = { [weak self] in
            guard let self = self else { return }
            self.showAlert(self.healthViewModel.errorMessage ?? "Error")
        }
    }
    
    // MARK: Health Hub Week Content
    private func fetchWeeklyContentApiCall(selectedWeek: String) {
        print(selectedWeek)
        healthViewModel.fetchWeeklyContent(weekNumber: selectedWeek) { [weak self] success in
            guard let self = self else { return }
            
            let currentWeekData = self.healthViewModel.weeklyContentResData
            
            self.weeklyContent = currentWeekData?.content ?? []
            
            self.weeklyContentTitleLabel.text = currentWeekData?.week_title ?? ""
            self.weeklyContentDescriptionLabel.text = currentWeekData?.week_desc ?? ""
            self.lblWeekDescription.setHTMLText(currentWeekData?.week_explanation ?? "")
            self.lblWeekObjective.text = currentWeekData?.week_objective ?? ""
            
            if let activity = currentWeekData?.week_activity, !activity.isEmpty {
                self.lblActivities.text = activity
                self.lblActivitiesTitle.text = "Activites:"
            } else {
                self.lblActivities.text = ""
                self.lblActivitiesTitle.text = ""
            }
            weeklyDetailsTableView.reloadData()
            self.updateTableViewHeight()
        }
        
        healthViewModel.errorMessageAlert = {
            self.showAlert(self.healthViewModel.errorMessage ?? "Error")
        }
    }
    
    // MARK: Set User Status
    private func updateUserStatusApiCall() {
        viewModel.setUserStatus(model: UserStatusModel(health_hub: 1)) { [weak self] success in
            if success {
                self?.navigateTo(viewController: DashboardViewController.self, withIdentifier: "DashboardViewController")
            }
        }
        
        viewModel.errorMessageAlert = {
            self.showAlert(self.healthViewModel.errorMessage ?? "Error")
        }
    }
}

// MARK: DropDown Week Selection Delegate
extension HealthHubViewController: WeekViewControllerDelegate {
    func didDismissWithData(_ data: HealthHubDropDownData, nextWeekQuizKey: String) {
        selectedWeek = data.value?.replacingOccurrences(of: "week", with: "") ?? ""
        fetchWeeklyContentApiCall(selectedWeek: data.value?.replacingOccurrences(of: "week", with: "") ?? "")
        //selectedWeekLabel.text = "Week \(selectedWeek)"
        selectedWeekLabel.text = data.label
        lblContentDescription.text = data.title
        self.nextWeekQuizKey = nextWeekQuizKey
        selectedWeekQuizKey = data.quizKey ?? ""
    }
}

// MARK: Helper Methods
extension HealthHubViewController {
    func setHTMLText(_ htmlString: String, to label: UILabel) {
        guard let data = htmlString.data(using: .utf8) else { return }
        
        do {
            let attributedString = try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
            
            let font = label.font ?? .systemFont(ofSize: 16)

            let mutableAttrString = NSMutableAttributedString(attributedString: attributedString)
            
            let fullRange = NSRange(location: 0, length: mutableAttrString.length)
            
            mutableAttrString.enumerateAttribute(.font, in: fullRange, options: []) { value, range, _ in
                if let oldFont = value as? UIFont {
                    let traits = oldFont.fontDescriptor.symbolicTraits
                    if let newDescriptor = font.fontDescriptor.withSymbolicTraits(traits) {
                        let newFont = UIFont(descriptor: newDescriptor, size: font.pointSize)
                        mutableAttrString.addAttribute(.font, value: newFont, range: range)
                    } else {
                        mutableAttrString.addAttribute(.font, value: font, range: range)
                    }
                }
            }
            
            mutableAttrString.addAttribute(.foregroundColor, value: label.textColor ?? .label, range: fullRange)
            
            label.attributedText = mutableAttrString
        } catch {
            print("❌ Error parsing HTML: \(error)")
        }
    }
    
    private func loadLatestModuleIfReady() {
        if let latestModule = healthViewModel.getLatestUnlockedModule() {
            var nextKey = ""
            if let data = healthViewModel.dropDownResData,
               let idx = data.firstIndex(where: {$0.value == latestModule.value}),
               idx + 1 < data.count {
                nextKey = data[idx+1].value ?? ""
            }
            
            // Prevent reloading if already on the correct week
            let newSelectedWeek = latestModule.value?.replacingOccurrences(of: "week", with: "") ?? ""
            if selectedWeek == "week0" || selectedWeek != newSelectedWeek {
                 self.didDismissWithData(latestModule, nextWeekQuizKey: nextKey)
                self.selectedWeek = newSelectedWeek
            }
        } else if let data = healthViewModel.dropDownResData, healthViewModel.weeklyUnlockContent == nil {
             // Fallback for initial load if status is not ready yet or failed
             if let dropDownData = data.first, let nextData = data.dropFirst().first {
                 selectedWeekLabel.text = dropDownData.label
                 lblContentDescription.text = dropDownData.title
                 self.nextWeekQuizKey = nextData.quizKey ?? ""
                 
                 if selectedWeek == "week0" && weeklyContent.isEmpty {
                     let weekVal = dropDownData.value?.replacingOccurrences(of: "week ", with: "") ?? "week0"
                     // Only load if we haven't loaded anything
                      fetchWeeklyContentApiCall(selectedWeek: weekVal.replacingOccurrences(of: "week", with: ""))
                 }
             }
        }
    }
}
