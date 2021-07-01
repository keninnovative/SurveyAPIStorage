//
//  ViewController.swift
//  TapResearchTest
//
//  Created by Ken Nyame on 6/30/21.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    var storeOffers: [NSManagedObject] = []
    private let surveyOfferButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitleColor(.link, for: .normal)
        button.setTitle("Survey Offer", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.link.cgColor
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //view.translatesAutoresizingMaskIntoConstraints = false
        addSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkOfferInStore()
    }
    
    private func addSubviews() {
        addSurveyButton()
    }
    
    private func addSurveyButton() {
        view.addSubview(surveyOfferButton)
        surveyOfferButton.widthAnchor.constraint(equalToConstant: 160).isActive = true
        surveyOfferButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        surveyOfferButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        surveyOfferButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        surveyOfferButton.addTarget(self, action: #selector(onSurveuOffer(sender:)), for: .touchUpInside)
        disableSurveyButton()
    }
    
    private func enableSurveyButton() {
        surveyOfferButton.isEnabled = true
        surveyOfferButton.alpha = 1.0
    }
    
    private func disableSurveyButton() {
        surveyOfferButton.isEnabled = false
        surveyOfferButton.alpha = 0.2
    }

    private func showModal(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "OK", style: .cancel) { action in
        }
        alert.addAction(actionOk)
        self.present(alert, animated: true)
    }
    
    @objc func onSurveuOffer(sender: UIButton) {
        disableSurveyButton()
        
        WebServices().getSurveysOffer { [weak self] offer, error in
            if let error = error {
                self?.showModal(title: "Error", message: error.localizedDescription)
                self?.enableSurveyButton()
            }
            else {
                guard let offerURL = offer?.offerUrl else {
                    self?.showModal(title: "", message: "No survey available")
                    self?.enableSurveyButton()
                    return
                }

                DispatchQueue.main.async {
                    self?.storeOffer(hasOffer: offer!.hasOffer, offerUrl: offerURL.absoluteString)
                    let webViewVC = WebViewViewController(url: offerURL)
                    self?.present(webViewVC, animated: true, completion: {
                        self?.enableSurveyButton()
                    })
                }
            }
        }
    }
    
    // MARK: - Storage functions
    
    private func checkOfferInStore() {
        
        // fetch offer stored
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            enableSurveyButton()
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Offer")
        
        do {
            storeOffers = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            enableSurveyButton()
        }
        
        // Check if offer stored available in 30 seconds.
        guard let offer = storeOffers.last else {
            enableSurveyButton()
            return
        }
        let createdDateTimeInterval = offer.value(forKeyPath: "createdDate") as! TimeInterval
        let intervalSeconds = Date().timeIntervalSince(Date(timeIntervalSince1970: createdDateTimeInterval))
        if Int(intervalSeconds) <= 30 {
            let offerUrlString = offer.value(forKeyPath: "offerUrl") as! String
            let webViewVC = WebViewViewController(url: URL(string: offerUrlString)!)
            self.present(webViewVC, animated: true, completion: {
            })
        }
        self.enableSurveyButton()
    }
    
    private func storeOffer(hasOffer: Bool, offerUrl: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Offer", in: managedContext)!
        let offerResponse = NSManagedObject(entity: entity, insertInto: managedContext)
        offerResponse.setValue(hasOffer, forKey: "hasOffer")
        offerResponse.setValue(offerUrl, forKey: "offerUrl")
        offerResponse.setValue(Date().timeIntervalSince1970, forKey: "createdDate")
        
        do {
            try managedContext.save()
            storeOffers.append(offerResponse)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

