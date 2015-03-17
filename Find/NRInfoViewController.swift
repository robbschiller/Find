//
//  NRInfoViewController.swift
//  Find
//
//  Created by Jonathon Toon on 3/2/15.
//  Copyright (c) 2015 Jonathon Toon. All rights reserved.
//

import UIKit

class NRInfoViewController: UIViewController, NRInfoManagerDelegate, UITableViewDataSource, UITableViewDelegate {

    var result: NRResult!
    
    var manager: NRInfoManager!
    var info: NRInfo!
    
    var tableView: UITableView!
    var actionButton: NRActionButton!
    
    init(result: NRResult!) {
        super.init(nibName: nil, bundle: nil)
        
        self.result = result
        
        manager = NRInfoManager()
        manager.communicator = NRInfoCommunicator()
        manager.communicator.delegate = manager
        manager.delegate = self
        
        startFetchingInfo()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backButtonItem: UIBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButtonItem
        
        let subTitleView: NRNavigationBarTitleView = NRNavigationBarTitleView(frame:CGRectMake(-100, 0, 200, self.navigationController!.navigationBar.frame.size.height), title: self.result.domain, subTitle: self.result.availability?.capitalizedString)
        self.navigationItem.titleView = subTitleView
        self.navigationItem.titleView?.backgroundColor = UIColor.clearColor()
        self.navigationItem.titleView?.layer.backgroundColor = UIColor.clearColor().CGColor
        
        self.view.backgroundColor = NRColor().domainrBackgroundGreyColor()
        
        tableView = UITableView(frame: self.view.frame, style: UITableViewStyle.Grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(NRDefaultCell.self, forCellReuseIdentifier: "NRDefaultCell")
        tableView.registerClass(NRInfoViewRegistrarCell.self, forCellReuseIdentifier: "NRInfoViewRegistrarCell")
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 120.0, 0)
        tableView.backgroundColor = NRColor().domainrBackgroundGreyColor()
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.view.addSubview(tableView)
        
        let buttonFrame: CGRect = CGRectMake(0, (self.view.frame.size.height - 64.0) - 50.0, self.view.frame.size.width, 50.0)
        if result.availability == "available" {
           actionButton = NRActionButton(frame: buttonFrame, buttonType: ButtonType.Available)
        } else if result.availability == "taken" {
           actionButton = NRActionButton(frame: buttonFrame, buttonType: ButtonType.Taken)
        } else if result.availability == "maybe" {
           println("maybe")
           actionButton = NRActionButton(frame: buttonFrame, buttonType: ButtonType.ComingSoon)
        }
        
        if actionButton != nil {
            println("Not nil")
            actionButton.addTarget(self, action: "presentAction", forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addSubview(actionButton)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentAction() {
        println("pressed")
        let registerURL: NSURL! = NSURL(string: info.register_url!)

        let registerViewController: SVModalWebViewController = SVModalWebViewController(URL: registerURL)
        registerViewController.title = info.registrars?.objectAtIndex(0).valueForKey("name") as? String
        registerViewController.navigationBar.barTintColor = UIColor.whiteColor()
        registerViewController.navigationBar.translucent = false
        registerViewController.navigationBar.tintColor = NRColor().domainrBlueColor()

        self.presentedViewController?.presentViewController(registerViewController, animated: true, completion: nil)
        
    }
    
    func startFetchingInfo() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        manager.fetchInfoForDomain(result.domain)
    }
    
    // #pragma mark - NRResultsManagerDelegate
    
    func didReceiveInfo(info: NRInfo!) {
        self.info = info
        
        println(self.info)
        
        dispatch_async(dispatch_get_main_queue(), {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.tableView.reloadData()
        });
    }
    
    func fetchingInfoFailedWithError(error: NSError!) {
        NSLog("Error %@; %@", error, error.localizedDescription)
    }

    // #pragma mark - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        var sectionTotal: Int = 1
        
        if info != nil {
            if info.registrars != nil {
                sectionTotal++
            }
        }
        
        return sectionTotal
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows: Int = 0
        
        if info != nil {
            if section == 0 {
                if info.whois_url != nil {
                    numberOfRows++
                }
                
                if info.tld?.valueForKey("wikipedia_url") != nil {
                   numberOfRows++
                }
            }
            
            if section == 1 {
                if info.registrars?.count < 6 {
                    numberOfRows = info.registrars!.count
                } else {
                    numberOfRows = 7
                }
            }
        }
        
        return numberOfRows
        
    }
    
    // #pragma mark - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        var height: CGFloat = 36.0
        
        if section == 1 {
            height = 46.0
        }
        
        return height
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        if indexPath.section == 0 {
            cell = createDefaultCell(indexPath)
        } else if indexPath.section == 1 {
            cell = createRegistrarCell(indexPath)
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 45.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                
                let whoisURL: NSURL! = NSURL(string: info.whois_url!)
                let whoisViewController: SVWebViewController = SVWebViewController(URL: whoisURL)
                whoisViewController.title = "Whois Info"
                self.navigationController?.pushViewController(whoisViewController, animated: true)
                
            } else if indexPath.row == 1 {
                
                let wikipediaURL: NSURL! = NSURL(string: info.tld!.valueForKey("wikipedia_url") as String)
                let wikipediaViewController: SVWebViewController = SVWebViewController(URL: wikipediaURL)
                wikipediaViewController.title = "TLD Wikipedia Article"
                self.navigationController?.pushViewController(wikipediaViewController, animated: true)
            
            }
        
        } else if indexPath.section == 1 {
            
            if indexPath.row >= 6 {
                
                let newArray: NSArray = info.registrars!.objectsAtIndexes(NSIndexSet(indexesInRange: NSMakeRange(6, info.registrars!.count-8))) as NSArray
                let registrarsViewController: NRRegistrarViewController = NRRegistrarViewController(registrars: newArray)
                self.navigationController?.pushViewController(registrarsViewController, animated: true)
            
            } else {
                
                let registrarURL: NSURL! = NSURL(string: info.registrars!.objectAtIndex(indexPath.row).valueForKey("register_url") as String)
                let registrarViewController: SVWebViewController = SVWebViewController(URL: registrarURL)
                registrarViewController.title = info.registrars!.objectAtIndex(indexPath.row).valueForKey("name") as? String
                self.navigationController?.pushViewController(registrarViewController, animated: true)
                
            }
            
        }
        
    }
    
    func createDefaultCell(indexPath: NSIndexPath!) -> NRDefaultCell {
        
        var cell: NRDefaultCell? = tableView.dequeueReusableCellWithIdentifier("NRDefaultCell", forIndexPath: indexPath) as? NRDefaultCell
        
        if cell == nil {
            cell = NRDefaultCell(style: .Default, reuseIdentifier: "NRDefaultCell")
        }

        cell?.textLabel?.text = "Whois Info"
        cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        if indexPath.row == 1 {
            cell?.textLabel?.text = "TLD Wikipedia Article"
        }

        return cell!
        
    }
    
    func createRegistrarCell(indexPath: NSIndexPath!) -> NRInfoViewRegistrarCell {
        
        var cell: NRInfoViewRegistrarCell? = tableView.dequeueReusableCellWithIdentifier("NRInfoViewRegistrarCell", forIndexPath: indexPath) as? NRInfoViewRegistrarCell
        
        if cell == nil {
            cell = NRInfoViewRegistrarCell(style: .Default, reuseIdentifier: "NRInfoViewRegistrarCell")
        }
        
        cell?.textLabel?.text = NSString(format: "View %d ", info.registrars!.count - 6) + "Others"
        cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        
        if indexPath.row < 6 {
            cell?.textLabel?.text = info.registrars!.objectAtIndex(indexPath.row).valueForKey("name") as NSString
        }
        
        return cell!
        
    }
}
