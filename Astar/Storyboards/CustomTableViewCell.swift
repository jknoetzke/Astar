//
//  CustomTableViewCell.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-12-16.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var txtFTP: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        txtFTP.borderStyle = .roundedRect
        txtFTP.translatesAutoresizingMaskIntoConstraints = false
        txtFTP.font = UIFont.systemFont(ofSize: 15)
        
        txtFTP.delegate = self
        
        txtFTP.keyboardType = .numberPad

        let defaults = UserDefaults.standard
        let ftp = defaults.string(forKey: "FTP")

        if ftp == nil {
            txtFTP.placeholder = "FTP"
        } else {
            txtFTP.text = ftp
        }



    }
    
    @IBAction func txtFieldEditingChanged(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.setValue(txtFTP.text, forKey: "FTP")

    }
    
    
}

extension CustomTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        let num = Int(updatedText)
        
        if num == nil && updatedText.count != 0  {
            return false
        }
        
        // make sure the result is under 3 characters
        return updatedText.count <= 3
    }
}
