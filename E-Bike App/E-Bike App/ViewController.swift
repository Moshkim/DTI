//
//  ViewController.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 6/12/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation
import UIKit


class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = true
        return cv
    }()
    
    
    let cellId = "cellId"
    let loginCellId = "loginCellId"
    
    let pages: [Page] = {
        let firstPage = Page(title: "Welcome to DTI Holdings", Message: "We are ready to serve you!", imageName: "page1")
        let secondPage = Page(title: "Welcome to DTI Holdings", Message: "We are ready to serve you!", imageName: "page2")
        let thirdPage = Page(title: "Welcome to DTI Holdings", Message: "We are ready to serve you!", imageName: "page3")
        let fourthPage = Page(title: "Welcome to DTI Holdings", Message: "We are ready to serve you!", imageName: "page1")
        
        return [firstPage,secondPage, thirdPage, fourthPage]
    }()
    
    
    

    lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.pageIndicatorTintColor = .lightGray
        pc.currentPageIndicatorTintColor = UIColor.DTIRed()
        pc.numberOfPages = self.pages.count + 1
        return pc
    }()
    
    lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(UIColor.red, for: UIControlState.normal)
        button.setTitleColor(UIColor.white, for: UIControlState.highlighted)
        button.showsTouchWhenHighlighted = true
        
        button.addTarget(self, action: #selector(finalPage), for: .touchUpInside)
        
        return button
    }()
    
    
    lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitle("Next>", for: .normal)
        button.setTitleColor(UIColor.red, for: UIControlState.normal)
        button.showsTouchWhenHighlighted = true
        
        button.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        
        return button
    }()
    
    func nextPage() {
        
        if pageControl.currentPage == pages.count {
            return
        }
        
        
        if pageControl.currentPage == pages.count - 1 {
            UIApplication.shared.statusBarStyle = .default
            pageControlBottomAnchor?.constant = 40
            skipButtonTopAnchor?.constant = -40
            nextButtonTopAnchor?.constant = -40
            moveToMapButton.isHidden = false
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()}, completion: nil)
        }
        
        let indexPath = IndexPath(item: pageControl.currentPage + 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

        pageControl.currentPage += 1
        
    }
    
    func finalPage() {
        let value = pages.count - pageControl.currentPage
        let indexPath = IndexPath(item: pageControl.currentPage + value, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        UIApplication.shared.statusBarStyle = .default
        pageControlBottomAnchor?.constant = 40
        skipButtonTopAnchor?.constant = -40
        nextButtonTopAnchor?.constant = -40
        moveToMapButton.isHidden = false
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()}, completion: nil)
        
        pageControl.currentPage = pages.count
    }
    
    
    lazy var moveToMapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Go To Map", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.tintColor = UIColor.DTIBlue()
        button.titleLabel?.shadowColor = UIColor.darkGray
        
        button.addTarget(self, action: #selector(moveToMapView), for: .touchUpInside)
        
        let mapViewController = MapViewController(nibName: "MapViewController", bundle: nil)
        //UINavigationController.pushViewController(MapViewController)
        
        return button
    }()
    
    func moveToMapView() {
    
        performSegue(withIdentifier: "MapViewSegue", sender: moveToMapButton)
    
    }
    
    
    
    
    
    var pageControlBottomAnchor: NSLayoutConstraint?
    var skipButtonTopAnchor: NSLayoutConstraint?
    var nextButtonTopAnchor: NSLayoutConstraint?
    var moveToMapButtonAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        observeKeyboardNotification()
        
        
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(skipButton)
        view.addSubview(nextButton)
        view.addSubview(moveToMapButton)
        view.addGestureRecognizer(tap)
        
        moveToMapButton.isHidden = true
        
        moveToMapButtonAnchor = moveToMapButton.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 160, rightConstant: 0, widthConstant: 0, heightConstant: 30)[3]
        
        pageControlBottomAnchor = pageControl.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 40)[1]
        
        skipButtonTopAnchor = skipButton.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 15, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 30).first
        
        nextButtonTopAnchor = nextButton.anchor(view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: 15, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 30).first
        
        collectionView.anchorToTop(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        collectionView.register(PageCell.self, forCellWithReuseIdentifier: cellId)
        registerCell()
    }
    

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageNumber = Int(targetContentOffset.pointee.x / view.frame.width)
        pageControl.currentPage = pageNumber
        
        
        // When we are on the last page to remove all the controls(skip,next,pageControl) Page Number = 5
        if pageNumber == pages.count {
            UIApplication.shared.statusBarStyle = .default
            pageControlBottomAnchor?.constant = 40
            skipButtonTopAnchor?.constant = -40
            nextButtonTopAnchor?.constant = -40
            moveToMapButton.isHidden = false
            //moveToMapButtonAnchor?.constant = -10
        }
        // Back on the regular page controls, Page Number < 5
        else {
            UIApplication.shared.statusBarStyle = .lightContent
            pageControlBottomAnchor?.constant = 0
            skipButtonTopAnchor?.constant = 15
            nextButtonTopAnchor?.constant = 15
            moveToMapButton.isHidden = true
            //moveToMapButtonAnchor?.constant = 50
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()}, completion: nil)
 
    }
 
    
    private func registerCell() {
        collectionView.register(PageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(LoginPage.self, forCellWithReuseIdentifier: loginCellId)
    
    }
    
    
    
    private func observeKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func keyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        }, completion: nil)
    
    }
    
    func keyboardShow() {
    
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.frame = CGRect(x: 0, y: -70, width: self.view.frame.width, height: self.view.frame.height)
        }, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == pages.count {
            let loginCell = collectionView.dequeueReusableCell(withReuseIdentifier: loginCellId, for: indexPath)
            return loginCell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PageCell
        
        let page = pages[indexPath.item]
        
        cell.page = page
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}



