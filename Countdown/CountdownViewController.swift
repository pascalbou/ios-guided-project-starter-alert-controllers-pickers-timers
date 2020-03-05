//
//  CountdownViewController.swift
//  Countdown
//
//  Created by Paul Solt on 5/8/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit

class CountdownViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var countdownPicker: UIPickerView!
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss:SS"
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        return formatter
    }()
    
    let countdown = Countdown()
    
    // MARK: - Properties
    
    lazy private var countdownPickerData: [[String]] = {
        // Create string arrays using numbers wrapped in string values: ["0", "1", ... "60"]
        let minutes: [String] = Array(0...60).map { String($0) }
        let seconds: [String] = Array(0...59).map { String($0) }
        
        // "min" and "sec" are the unit labels
        let data: [[String]] = [minutes, ["min"], seconds, ["sec"]]
        return data
    }()
    
    var duration: TimeInterval {
        // convert the selected minutes and seconds from the picker view into a single amount of seconds that the countdown should run for.
        
        let minutes = countdownPicker.selectedRow(inComponent: 0)
        let seconds = countdownPicker.selectedRow(inComponent: 2)
        
        let totalSeconds = TimeInterval(minutes * 60 + seconds)
        
        return totalSeconds
    }
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        countdownPicker.delegate = self
        countdownPicker.dataSource = self
        countdown.delegate = self
        
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 64, weight: .medium)
    }
    
    // MARK: - Actions
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        countdown.start()
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        countdown.reset()
        updateViews()
    }
    
    // MARK: - Private
    
    private func showAlert() {
        let alert = UIAlertController(title: "Timer Finished", message: "Your countdown is over", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func string(from duration: TimeInterval) -> String {
        let date = Date(timeIntervalSinceReferenceDate: duration)
        return dateFormatter.string(from: date)
    }
    
    private func updateViews() {
        switch countdown.state {
        case .started:
            timeLabel.text = string(from: countdown.timeRemaining)
            startButton.isEnabled = false
        case .finished:
            timeLabel.text = string(from: 0)
            startButton.isEnabled = true
        case .reset:
            timeLabel.text = string(from: countdown.duration)
            startButton.isEnabled = true
        }
    }
}

extension CountdownViewController: CountdownDelegate {
    func countdownDidUpdate(timeRemaining: TimeInterval) {
        updateViews()
    }
    
    func countdownDidFinish() {
        showAlert()
        updateViews()
    }
}

extension CountdownViewController: UIPickerViewDataSource {
    
    // how many arrays do we have?
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return countdownPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countdownPickerData[component].count
    }
}

extension CountdownViewController: UIPickerViewDelegate {
    
    // which component is being set up?
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countdownPickerData[component][row]
    }
    
    // gets called when you select a row
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countdown.duration = duration
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 50
    }
}
