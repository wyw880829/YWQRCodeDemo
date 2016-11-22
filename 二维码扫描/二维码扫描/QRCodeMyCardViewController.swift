//
//  QRCodeMyCardViewController.swift
//  SwiftWeiBo
//
//  Created by wyw on 16/10/6.
//  Copyright © 2016年 Style_Y. All rights reserved.
//

import UIKit

class QRCodeMyCardViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1.设置导航标题
        navigationItem.title = "我的名片"
        
        // 2.添加布局二维码控件
        view.addSubview(codeImageView)
        codeImageView.frame.size = CGSize(width: 200, height: 200)
        codeImageView.center = view.center
        
        // 3.生成二维码
        let codeImage = createCodeImage()
        
        // 4.将生成好的二维码添加到二维码容器上
        codeImageView.image = codeImage
    }
    
    //  生成二维码
    private func createCodeImage() -> UIImage? {
      
        // 1.创建滤镜
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        // 2.还原滤镜默认属性
        filter?.setDefaults()
        
        // 3.设置需要生成的二维码数据
        filter?.setValue("子熙他爸".data(using: String.Encoding.utf8), forKey: "inputMessage")
        
        // 4.从滤镜中取出生成好的图片
        let ciImage = filter?.outputImage
        
        let codeImage = createNonInterpolatedUIImageFormCIImage(image: ciImage!, size: 200)
        
        // 5.创建一个头像
        let iconImage = UIImage(named: "touxiang")

        // 6.合成二维码图片
        let newImage = createImage(bgImage: codeImage, iconImage: iconImage!)

        // 7.返回最终的二维码
        
        return newImage
    }
    
    /**
     根据CIImage生成指定大小的高清UIImage
     
     :param: image 指定CIImage
     :param: size    指定大小
     :returns: 生成好的图片
     */
    private func createNonInterpolatedUIImageFormCIImage(image: CIImage, size: CGFloat) -> UIImage {
        
        let extent: CGRect = image.extent.integral
        let scale: CGFloat = min(size/extent.width, size/extent.height)
        
        // 1.创建bitmap;
        let width  = extent.width * scale
        let height = extent.height * scale
        let cs: CGColorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: 0)!
        
        let context = CIContext(options: nil)
        let bitmapImage: CGImage = context.createCGImage(image, from: extent)!
        
        bitmapRef.interpolationQuality = CGInterpolationQuality.none
        bitmapRef.scaleBy(x: scale, y: scale)
        
        bitmapRef.draw(bitmapImage, in: extent)
        
//        CGContextDrawImage(bitmapRef, extent, bitmapImage)
        
        // 2.保存bitmap到图片
        let scaledImage: CGImage = bitmapRef.makeImage()!
        
        return UIImage(cgImage: scaledImage)
    }
    
    private func createImage(bgImage:UIImage , iconImage:UIImage) -> UIImage {
      
        // 1.开启上下文
        UIGraphicsBeginImageContext(bgImage.size)
        
        // 2.绘制背景图片
        bgImage.draw(in: CGRect(origin: CGPoint.zero, size: bgImage.size))
        
        // 3.绘制头像
        let width : CGFloat = 50
        let height = width
        let X = (bgImage.size.width - width) * 0.5
        let Y = (bgImage.size.height - height) * 0.5

        iconImage.draw(in: CGRect(x:X , y: Y, width: width, height: height))
        
        // 4.取出绘制好的图片
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // 5.关闭上下文
        UIGraphicsEndImageContext()
        
        // 6.返回合成好的图片
        return newImage!
        
    }
    
    // MARK: - 懒加载
    private lazy var codeImageView : UIImageView = UIImageView()
    

}
