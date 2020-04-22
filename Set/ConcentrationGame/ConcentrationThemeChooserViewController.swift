//
//  ConcentrationThemeChooserViewController.swift
//  Set
//
//  Created by Dmitry Reshetnik on 22.04.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import UIKit

class ConcentrationThemeChooserViewController: UIViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.backgroundColor = UIColor.clear
        tabBarController?.tabBar.backgroundImage = UIImage()
        tabBarController?.tabBar.shadowImage = UIImage()
        // Remove UITabBar top border line in iOS 13.
        tabBarController?.tabBar.layer.borderWidth = 0
        tabBarController?.tabBar.clipsToBounds = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        splitViewController?.delegate = self
    }
    
    public var themes: [String: Theme] = ["Helloween": Theme(name: "helloween", emoji: ["👻🎃😈💀🧛🏻‍♂️🦇🕸🕷🧟‍♂️🧙🏻🧞👹"], color: #colorLiteral(red: 0.9952403903, green: 0.7589642406, blue: 0.1794864237, alpha: 1), backgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)),
                                          "Animals": Theme(name: "animals", emoji: ["🐶🐱🐭🐹🐰🦊🐻🐼🐵🐨🐷🦁"], color: #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), backgroundColor: #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)),
                                          "Sports": Theme(name: "sports", emoji: ["⚽️🏀🏈⚾️🥎🎾🏐🏉🎱🏓🥏🏸"], color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), backgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)),
                                          "Faces": Theme(name: "faces", emoji: ["😁😊😅😆😂😎🤪🤓🥳😜😉🤩"], color: #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1), backgroundColor: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)),
                                          "Fruits": Theme(name: "fruits", emoji: ["🍏🍐🍊🍋🍌🍉🍓🍑🥭🍇🥝🍒"], color: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), backgroundColor: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)),
                                          "Flowers": Theme(name: "flowers", emoji: ["💐🌷🌹🥀🌺🌸🌼🌻🍀☘️🍄🌵"], color: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), backgroundColor: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1))]
    
    private var splitViewDetailConcentrationViewController: ConcentrationViewController? {
        return splitViewController?.viewControllers.last as? ConcentrationViewController
    }
    
    private var lastSeguedToConcentrationViewController: ConcentrationViewController?
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if let concentrationVC = secondaryViewController as? ConcentrationViewController {
            if concentrationVC.theme == nil {
                return true
            }
        }
        
        return false
    }
    
    @IBAction func changeTheme(_ sender: Any) {
        if let concentrationVC = splitViewDetailConcentrationViewController {
            if let themeName = (sender as? UIButton)?.currentTitle {
                if let theme = themes[themeName]?.emoji, let themeColor = themes[themeName]?.color, let backgroundThemeColor = themes[themeName]?.backgroundColor {
                    concentrationVC.theme = theme.first
                    concentrationVC.themeColor = themeColor
                    concentrationVC.backgroundThemeColor = backgroundThemeColor
                }
            }
        } else if let concentrationVC = lastSeguedToConcentrationViewController {
            if let themeName = (sender as? UIButton)?.currentTitle {
                if let theme = themes[themeName]?.emoji, let themeColor = themes[themeName]?.color, let backgroundThemeColor = themes[themeName]?.backgroundColor {
                    concentrationVC.theme = theme.first
                    concentrationVC.themeColor = themeColor
                    concentrationVC.backgroundThemeColor = backgroundThemeColor
                }
                navigationController?.pushViewController(concentrationVC, animated: true)
            }
        } else {
            performSegue(withIdentifier: "Choose Theme", sender: sender as? UIButton)
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "Choose Theme" {
            if let themeName = (sender as? UIButton)?.currentTitle {
                if let theme = themes[themeName]?.emoji, let themeColor = themes[themeName]?.color, let backgroundThemeColor = themes[themeName]?.backgroundColor {
                    if let concentrationVC = segue.destination as? ConcentrationViewController {
                        concentrationVC.theme = theme.first
                        concentrationVC.themeColor = themeColor
                        concentrationVC.backgroundThemeColor = backgroundThemeColor
                        lastSeguedToConcentrationViewController = concentrationVC
                    }
                }
            }
        }
    }

}
