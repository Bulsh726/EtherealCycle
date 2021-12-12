//
//  ViewController.swift
//  CarouselTest
//
//  Created by 李林峰 on 2021/12/7.
//

import UIKit

class ViewController: UIViewController,CarouselViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        let carouselView = CarouselView(CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height:  200),
                                        ["img2.jpg","img3.jpg","img4.jpg"],
                                        placeHolderImage: UIImage.creatImageWithColor(color: .black),
                                        pageLocation: .LeftBottom(leading: 20, bottom: 15),
                                        autoScrollDelay: 3)
        carouselView.pageIndicatorTintColor = .red
        carouselView.delegate = self
        self.view.addSubview(carouselView)
    }


}


