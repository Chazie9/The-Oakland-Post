//
//  HomeViewController.swift
//  The Oakland Post
//
//  Tab 1.
//
//  The entry point for the app. Contains the main newsfeed.
//
//  Created by Andrew Clissold on 7/13/14.
//  Copyright (c) 2014 Andrew Clissold. All rights reserved.
//

import UIKit

// Provides global access to this instance as an alternative to NSNotificationCenter broadcasts,
// since it's around for the lifetime of the app anyway.
var homeViewController: HomeViewController!

class HomeViewController: PostTableViewController, TopScrollable {

    var canScrollToTop = false
    var logInBarButtonItem, favoritesBarButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        SVProgressHUD.show()

        baseURL = "http://www.oaklandpostonline.com/search/?t=article"

        logInBarButtonItem = UIBarButtonItem(title: "Log In", style: .Bordered, target: self, action: "logIn")
        favoritesBarButtonItem = UIBarButtonItem(image: UIImage(named: "Favorites"), style: .Bordered, target: self, action: "showFavorites")

        homeViewController = self
        if let user = PFUser.currentUser() {
            navigationItem.rightBarButtonItem = favoritesBarButtonItem
        } else {
            navigationItem.rightBarButtonItem = logInBarButtonItem
        }

        if PFUser.currentUser() != nil { findStarredPosts() }

        super.viewDidLoad() // must be called after baseURL is set

    }

    func findStarredPosts() {
        let maxQueryLimit = 1000
        let query = PFQuery(className: "Item")
        query.limit = maxQueryLimit
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if error != nil {
                showAlertForErrorCode(error.code)
            } else {
                starredPosts = objects
                self.tableView.reloadData()

                // Only for FavoritesViewController to reload its data if it was on-screen before starred posts were found.
                NSNotificationCenter.defaultCenter().postNotificationName(foundStarredPostsNotification, object: nil)
            }
        }
    }

    override func viewDidLayoutSubviews() {
        if logInBarButtonItem == nil && navigationItem.rightBarButtonItem?.title == "Log In" {
            logInBarButtonItem = navigationItem.rightBarButtonItem
        }
    }

    func logIn() {
        performSegueWithIdentifier(logInID, sender: self)
    }

    func showFavorites() {
        let favoritesViewController = storyboard!.instantiateViewControllerWithIdentifier(favoritesID) as FavoritesViewController
        navigationController!.pushViewController(favoritesViewController, animated: true)
    }

    func unwindToHomeViewController() {
        // Called from InfoViewController.
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: TopScrollable

    override func viewDidAppear(animated: Bool) {
        canScrollToTop = true
    }

    override func viewDidDisappear(animated: Bool) {
        canScrollToTop = false
    }

    func scrollToTop() {
        let rect = CGRect(origin: CGPointZero, size: CGSize(width: 1, height: 1))
        tableView.scrollRectToVisible(rect, animated: true)
    }

}
