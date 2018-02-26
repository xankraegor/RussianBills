//
//  FavoriteBillNoteViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 24.12.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import RealmSwift

class FavoriteBillNoteViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!

    let realm = try? Realm()
    var billNr: String? = nil
    lazy var favoriteBill: FavoriteBill_? = {
        return realm?.object(ofType: FavoriteBill_.self, forPrimaryKey: billNr)
    }()

    var oldText: String = ""
    var textBeforeEditing: String? = nil

    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        textView.text = favoriteBill?.note
        textBeforeEditing = favoriteBill?.note
        oldText = favoriteBill?.note ?? ""
        textView.delegate = self
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if oldText.count == 0 {
            textView.becomeFirstResponder()
        }
    }

    // MARK: - Helper functions

    private func updateFavoriteBillNote(withText text: String) {
        guard (textBeforeEditing ?? "") != text else {
            return
        }

        let trimmedText = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        guard trimmedText.count > 0 else {
            return
        }

        if let fav = favoriteBill, let rlm = realm {
            try? rlm.write {
                fav.note = trimmedText
                fav.favoriteUpdatedTimestamp = Date()
            }

            try? SyncMan.shared.iCloudStorage?.store(billSyncContainer: fav.syncProxy)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindFromNoteSegueId" {
            textView.text = oldText
        }
    }

}

extension FavoriteBillNoteViewController: UITextViewDelegate {

    func textViewDidEndEditing(_ textView: UITextView) {
        updateFavoriteBillNote(withText: textView.text)
    }

    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animate(withDuration: duration,
                    delay: TimeInterval(0),
                    options: animationCurve,
                    animations: { self.view.layoutIfNeeded() },
                    completion: nil)
        }
    }

}
