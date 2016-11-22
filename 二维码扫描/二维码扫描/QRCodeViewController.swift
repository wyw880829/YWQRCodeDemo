//
//  QRCodeViewController.swift
//  SwiftWeiBo

//  Created by wyw on 16/9/29.
//  Copyright © 2016年 Style_Y. All rights reserved.
//

import UIKit
import AVFoundation

// 定义一个传值闭包
typealias QRCodeClosure = ( _ qrcStr : String) -> Void

class QRCodeViewController: UIViewController,UITabBarDelegate {

    @IBOutlet weak var CustomBar: UITabBar!
    // 扫描容器View
    @IBOutlet weak var containerView: UIView!
    // 扫描容器高度
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    // 网格顶部约束
    @IBOutlet weak var netImageViewTopContraint: NSLayoutConstraint!
    
    // 传值闭包
    var stringClosure : QRCodeClosure?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CustomBar.delegate = self;
        CustomBar.selectedItem = CustomBar.items![0];
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 1.开始动画
        startAnimotion()
        
        // 2.开始扫描
        startScan()
    }
    
    private func startAnimotion()
    {
      // 1.设置网格的顶部约束
        netImageViewTopContraint.constant = -containerHeightConstraint.constant
        view.layoutIfNeeded()
      
      // 2.设置动画
        UIView.animate(withDuration: 2.0) {
            self.netImageViewTopContraint.constant = self.containerHeightConstraint.constant
            UIView.setAnimationRepeatCount(MAXFLOAT)
            self.view.layoutIfNeeded()  
        }
    }
    
    private func startScan()
    {
        // 1.判断是否能够将输入添加到会话中
        if !session.canAddInput(inputDevice)
        {
          return
        }
        
        // 2.判断是否能够将输出对象添加到会话中
        if !session.canAddOutput(output)
        {
          return
        }
        // 3.将输入设备和输出对象都添加到会话中
        session.addInput(inputDevice)
        session.addOutput(output)
        
        // 4.设置输出能够解析的数据类型 （设置输出类型一定要在输出对象添加到会话之后才可以）
           // 只要设备支持的类型都可以
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        // 5.设置输出对象的代理
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        // 6.添加预览图层，放到最底层
        view.layer.insertSublayer(previewLayer, at: 0)
          // 6.1 将绘线图层添加到预览图层
        previewLayer.addSublayer(drawLayer)
        
        // 7.告诉会话开始扫描
        session.startRunning()
    }
    
    @IBAction func leftItemAction(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func myCardBtnClick(_ sender: AnyObject) {
        
        let VC = QRCodeMyCardViewController()
        navigationController?.pushViewController(VC, animated: true)
    }
    // MARK: - 懒加载
    // 会话
    fileprivate lazy var session : AVCaptureSession = AVCaptureSession()
    // 输入设备
    private lazy var inputDevice : AVCaptureDeviceInput? = {
        
        // 获取摄像头
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            
          let inputDevice = try AVCaptureDeviceInput(device: device)
            return inputDevice
        } catch {
            print(error)
            return nil
        }
    }()
    
    // 输出对象
    private lazy var output : AVCaptureMetadataOutput = AVCaptureMetadataOutput()
    
    // 预览图层
    fileprivate lazy var previewLayer : AVCaptureVideoPreviewLayer = {
      let Layer = AVCaptureVideoPreviewLayer(session: self.session)!
        Layer.frame = UIScreen.main.bounds
        
        return Layer
    }()
    
    // 创建用于绘制边线的图层
    fileprivate lazy var drawLayer : CALayer = {
      let layer = CALayer()
        layer.frame = UIScreen.main.bounds
        return layer
    }()

    // MARK: - UITabBarDelegate
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // 1.设置容器尺寸
        containerHeightConstraint.constant = item.tag == 1 ? 300 : 300 * 0.5
        
        // 2.停止动画
        containerView.layer.removeAllAnimations()
        
        // 3.开始动画
        startAnimotion()
    }
}

extension QRCodeViewController : AVCaptureMetadataOutputObjectsDelegate
{
  func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!)
  {
    // 0 清空图层
    cleanCorners()
    
    // 1.获取扫描到的数据
    let obj : AVMetadataMachineReadableCodeObject? = metadataObjects.last as? AVMetadataMachineReadableCodeObject
    if obj != nil
    {
//        print(obj?.stringValue!)
        if stringClosure != nil
        {
            dismiss(animated: true, completion: { 
                print("扫描到数据 = \(obj?.stringValue)")
                self.stringClosure!((obj?.stringValue)!)
            })
        }
        
        // 2.获取扫描到的二维码的位置
        for obj in metadataObjects {
            if obj is AVMetadataMachineReadableCodeObject {
                // 2.1转换
                let codeObject = previewLayer.transformedMetadataObject(for: obj as! AVMetadataObject) as! AVMetadataMachineReadableCodeObject
                // 2.2 绘制图形
                drawCorner(codeObject : codeObject)
            }
        }
    }
  }
    
    
     private func drawCorner(codeObject : AVMetadataMachineReadableCodeObject) {
        if codeObject.corners.isEmpty {
          return
        }
        
        // 1.创建图层
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 4
        layer.strokeColor = UIColor.green.cgColor
        
        // 2.创建路径
        let path = UIBezierPath()
        var point = CGPoint()
        
          // 2.1 移动到第一个点
        point = CGPoint(dictionaryRepresentation: codeObject.corners[0] as! CFDictionary)!
        path.move(to: point)

          // 2.2 移动到其他点
        for i in 1..<codeObject.corners.count
        {
            point = CGPoint.init(dictionaryRepresentation: codeObject.corners[i] as! CFDictionary)!
            path.addLine(to: point)
        }
          // 2.3 关闭路径
        path.close()
        
          // 2.4 绘制路径
        layer.path = path.cgPath
        
        // 3.将绘制好的图层添加到darwLayer上
        drawLayer.addSublayer(layer)
        
    
        // 停止扫描
        session.stopRunning()
    }
    
    // 清除绘制线
    private func cleanCorners() {
        if drawLayer.sublayers != nil
        {
            for subLayer in drawLayer.sublayers! {
                subLayer.removeFromSuperlayer()
            }
        }
    }
}


