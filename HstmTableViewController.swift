//
//  HstmTableViewController.swift
//  HSTM
//  Created by Esha Sidhu
//

import UIKit
import os.log
import UserNotifications

class HstmTableViewController: UITableViewController, UNUserNotificationCenterDelegate {
    
    //Properties
    
    var hstms = [HSTM]()
    //var sortedhstms = [HSTM]()
    
    //std hours if Rating is <4, double otherwise
    //eg HW with rating of 3, uses 1 Hrs, rating 4 HW uses 2 hrs
    let HWHours = 1
    let QuizHours = 2
    let XtraHours = 2
    let MaxDayHours = 6

    let center = UNUserNotificationCenter.current()
    let options: UNAuthorizationOptions = [.alert, .badge, .sound];

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Load any saved events
        if let savedHstms = loadHstms() {
            hstms += savedHstms
        }
        
        //requesting for authorization
        
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hstms.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "HstmTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? HstmTableViewCell  else {
            fatalError("The dequeued cell is not an instance of HstmTableViewCell.")
        }
        
        // Fetches the appropriate event for the data source layout.
        let hstm = hstms[indexPath.row]
        
        cell.name.text = hstm.name
        ////cell.photoImageView.image = UIImage(named: "homework")
        cell.photoImageView.image = hstm.photo
        //cell.ratingControl.rating = hstm.rating
        //cell.eventtype.text = hstm
        cell.eventdescription.text = hstm.eventdescription
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        cell.eventdate.text = dateFormatter.string(from: hstm.eventdate!)
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            hstms.remove(at: indexPath.row)
            saveHstms()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            //hstms.insert(newElement: hstm, at: indexPath.row)
            //saveHstms()
            //tableView.insertRows(at: [indexPath], with: .automatic)
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    //Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "AddItem":
            os_log("Adding a new event.", log: OSLog.default, type: .debug)
            
        case "ShowDetail":
            guard let hstmDetailViewController = segue.destination as? HstmViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedHstmCell = sender as? HstmTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedHstmCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedHstm = hstms[indexPath.row]
            hstmDetailViewController.hstm = selectedHstm
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }

    
    //ctions
    
    @IBAction func unwindToHstmList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? HstmViewController, let hstm = sourceViewController.hstm {
            
            let calendar = Calendar.current
            let year1 = calendar.component(.year, from: hstm.eventdate ?? Date())
            let month1 = calendar.component(.month, from: hstm.eventdate ?? Date())
            let day1 = calendar.component(.day, from: hstm.eventdate ?? Date())
            let hour1 = calendar.component(.hour, from: hstm.eventdate ?? Date())
            let minute1 = calendar.component(.minute, from: hstm.eventdate ?? Date())
            let sec1 = calendar.component(.second, from: hstm.eventdate ?? Date())
            print(year1,"/",month1,"/",day1," ",hour1,":",minute1,":",sec1)

            
            //if there are no events in the queue, just add it and return
            if hstms.count == 0 {
                print("adding event in empty queue")
                os_log("adding event in empty queue", log: OSLog.default, type: .debug)
                let newIndexPath = IndexPath(row: hstms.count, section: 0)
                hstms.append(hstm)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
                // Save the events.
                saveHstms()
                return
            }
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing event.
                hstms[selectedIndexPath.row] = hstm
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
                // Save the events.
                saveHstms()
                return
            }
            else {
                
              //is the new event of highest date, if so add to the end
              if hstms[hstms.count-1].eventdate?.compare(hstm.eventdate!) == .orderedAscending {
                    print("Last stored event date is smaller")
                    print(hstms[hstms.count-1].name, ",", hstm.name)
                    // Add a new event.
                    let newIndexPath = IndexPath(row: hstms.count, section: 0)
                    hstms.append(hstm)
                    tableView.insertRows(at: [newIndexPath], with: .automatic)
                    // Save the events.
                    saveHstms()
                    return
              } else {
                
                //find a place in array using due date
                
                var hoursUsed = 0 //hours used on a given day
                var difficultyMultiplier = 1 //converts rating into hours for event

                for i in 0...(hstms.count-1) {
                    let ind = hstms.count - i
                    let temphstm = hstms[ind-1]
                    
                    let year = calendar.component(.year, from: temphstm.eventdate ?? Date())
                    let month = calendar.component(.month, from: temphstm.eventdate ?? Date())
                    let day = calendar.component(.day, from: temphstm.eventdate ?? Date())
                    let hour = calendar.component(.hour, from: temphstm.eventdate ?? Date())
                    let minute = calendar.component(.minute, from: temphstm.eventdate ?? Date())
                    let sec = calendar.component(.second, from: temphstm.eventdate ?? Date())
                    print(year,"/",month,"/",day," ",hour,":",minute,":",sec)

                    if (year == year1) && (month == month1) && (day == day1) {
                    //if temphstm.eventdate?.compare(hstm.eventdate!) == .orderedSame {
                        print("Stored event date is same")
                        print(temphstm.name, ",", hstm.name)

                        if temphstm.rating > 3 {
                            difficultyMultiplier = 2
                        }
                        switch temphstm.eventtype {
                            case "Homework":
                                hoursUsed += (HWHours * difficultyMultiplier)
                            case "Quiz":
                                hoursUsed += ( QuizHours * difficultyMultiplier)
                            case "Xtra":
                                hoursUsed += (XtraHours * difficultyMultiplier)
                            default:
                                fatalError("Incorrect event type detected")
                        }
                        
                        //compute  hours being added by new event
                        var newHoursbeingAdded = 0
                        if hstm.rating > 3 {
                            difficultyMultiplier = 2
                        }
                        switch hstm.eventtype {
                        case "Homework":
                            newHoursbeingAdded = (HWHours * difficultyMultiplier)
                        case "Quiz":
                            newHoursbeingAdded = ( QuizHours * difficultyMultiplier)
                        case "Xtra":
                            newHoursbeingAdded = (XtraHours * difficultyMultiplier)
                        default:
                            fatalError("Incorrect event type detected")
                        }
                        
                        if hoursUsed + newHoursbeingAdded > MaxDayHours {
                            //we have exceed the allowed hours, User should get Notification
                            
                            let content = UNMutableNotificationContent()
                            content.title = "Scheduling Error"
                            content.body = "Your day is Full, Please plan task a day earlier"
                            content.badge = 1
                            
                            //it will be called after 1 seconds
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                            
                            //getting the notification request
                            let request = UNNotificationRequest(identifier: "SimplifiedIOSNotification", content: content, trigger: trigger)
                            
                            UNUserNotificationCenter.current().delegate = self
                            
                            //adding the notification to notification center
                            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)

                            print("Exceeded hours for the given day", hoursUsed + newHoursbeingAdded )
                            return
                        }
                        
                    } else if temphstm.eventdate?.compare(hstm.eventdate!) == .orderedDescending {
                        print("Stored event date is greater, keep looking")
                        print(temphstm.name, ",", hstm.name)

                    } else if temphstm.eventdate?.compare(hstm.eventdate!) == .orderedAscending {
                        print("Stored event date is smaller, adding event")
                        print(temphstm.name, ",", hstm.name)

                        hstms.insert(hstm, at: ind)
                        let newIndexPath = IndexPath(row: ind, section: 0)
                        tableView.insertRows(at: [newIndexPath], with: .automatic)
                        // Save the events.
                        saveHstms()
                        return
                    }
                } //for loop on existing events
                
                //if you get here we have to add it to the top of the queue
                hstms.insert(hstm, at: 0)
                let newIndexPath = IndexPath(row: 0, section: 0)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
                // Save the events.
                saveHstms()
                return
                
              } //ifelse -  add in array
            } //ifelse -  updating existing element
            
        }
    }
    
    //Private Methods
    
    private func loadSampleHstms() {
    }
    
    private func saveHstms() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(hstms, toFile: HSTM.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Events successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save events...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadHstms() -> [HSTM]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: HSTM.ArchiveURL.path) as? [HSTM]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //displaying the ios local notification when app is in foreground
        completionHandler([.alert, .badge, .sound])
    }
    
    
}
