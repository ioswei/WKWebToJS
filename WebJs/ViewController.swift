//
//  ViewController.swift
//  WebJs
//
//  Created by Skx-iOSAwei on 2024/5/14.
//

import UIKit

import WebKit

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let channelName = "SkxJSInterface"
        
        // 创建网页配置对象
        let config = WKWebViewConfiguration()

        // 设置内容JavaScript是否启用，这是iOS 14.0之后的替代方案
        let webpagePreferences = WKWebpagePreferences()
        webpagePreferences.allowsContentJavaScript = true
        config.defaultWebpagePreferences = webpagePreferences

        // 自定义的WKScriptMessageHandler 是为了解决内存不释放的问题
        let weakScriptMessageDelegate = SkxCommunityJavaScriptDelegate(delegate: self)
        // 这个类主要用来做native与JavaScript的交互管理
        let wkUController = WKUserContentController()
        wkUController.add(weakScriptMessageDelegate, name: channelName)
        let wrapperSource = String(format: "window.%@ = webkit.messageHandlers.%@;", channelName, channelName)
        let wrapperScript = WKUserScript(source: wrapperSource, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        
        wkUController.addUserScript(wrapperScript)

        config.userContentController = wkUController

        let webView = WKWebView(frame: UIScreen.main.bounds, configuration: config)
        // UI代理
        webView.uiDelegate = self
        // 导航代理
        webView.navigationDelegate = self
        // 是否允许手势左滑返回上一级, 类似导航控制的左滑返回
        webView.allowsBackForwardNavigationGestures = false
        view.addSubview(webView)
        
        self.webView = webView

        let path = Bundle.main.path(forResource: "JStoOC", ofType: "html")
        if let path = path, let htmlString = try? String(contentsOfFile: path, encoding: .utf8) {
            webView.loadHTMLString(htmlString, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
        }
        
        
    }
    
    func AAAAA() {
        
        // 构建要传递给HTML的参数
        let parameters = ["key1": "value1", "key2": "value2"]
        do {
            // 将参数转换为JSON格式的字符串
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                // 在JavaScript环境中设置一个全局变量，将参数传递给HTML页面
                if let data = jsonString.data(using: .utf8) {
                    let base64String = data.base64EncodedString()
                    print("Base64 编码的字符串为: \(base64String)")
                    let setParametersScript = "javascript:onConfigCallback('\(base64String)')"
                    webView?.evaluateJavaScript(setParametersScript, completionHandler: { (_, error) in
                        if let error = error {
                            print("Failed to set parameters: \(error)")
                        } else {
                            print("Parameters set successfully")
                        }
                    })
                }
            }
        } catch {
            print("Error converting parameters to JSON: \(error)")
        }
        
    }
    
    

}

extension ViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let message =  message.body as? Dictionary<String, Any> {
            
            if message.keys.contains("params") {
                self.AAAAA()
            }
            
        }
    }
    
}

