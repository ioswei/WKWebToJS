//
//  AAA.swift
//  WebJs
//
//  Created by Skx-iOSAwei on 2024/5/14.
//

import UIKit
import WebKit

// WKWebView 内存不释放的问题解决
class SkxCommunityJavaScriptDelegate: NSObject, WKScriptMessageHandler {
    
    // WKScriptMessageHandler 这个协议类专门用来处理JavaScript调用原生OC的方法
    weak var scriptDelegate: WKScriptMessageHandler?
    
    init(delegate: WKScriptMessageHandler) {
        self.scriptDelegate = delegate
    }
    
    // 遵循WKScriptMessageHandler协议，必须实现如下方法，然后把方法向外传递
    // 通过接收JS传出消息的name进行捕捉的回调方法
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.scriptDelegate?.userContentController(userContentController, didReceive: message)
    }
}
