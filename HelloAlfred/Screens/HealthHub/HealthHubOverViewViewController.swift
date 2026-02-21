//
//  HealthHubViewController.swift
//  HelloAlfred
//
//  Created by admin on 03/08/24.
//

import UIKit

class HealthHubOverViewViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var afTopics: [HealthhubOverView] = []
    
    @IBOutlet var overViewTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        overViewTableView.delegate = self
        overViewTableView.dataSource = self
    }
    
    
    // MARK: - Navigation
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return afTopics.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HealthHubOverviewTableViewCell") as! HealthHubOverviewTableViewCell
        cell.titleLabel.text = "Module \(indexPath.row+1)"
        cell.weekLabel.text = afTopics[indexPath.row].title
        let combinedText = afTopics[indexPath.row].list.joined(separator: "\n• ")
        cell.detail1Label.text = "• " + combinedText
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Call this method when you want to dismiss and send data back
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
}
