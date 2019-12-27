//
//  SignInWithAppleCordovaPlugin.swift
//  signInWithAppleDemo
//
//  Created by Marco Cheung on 27/12/2019.
//  Copyright © 2019 陈培爵. All rights reserved.
//

import UIKit

@objc(SignInWithAppleCordovaPlugin) class SignInWithAppleCordovaPlugin : CDVPlugin {
    
    private var signInTool_: SignInWithAppleTool!
    
    override func pluginInitialize() {
        signInTool_ = SignInWithAppleTool(viewController: self.viewController)
        canShowButton = signInTool_.canShowButton
    }
    
    @objc(getShowButtonStatus:) func getShowButtonStatus(_ command: CDVInvokedUrlCommand) {
        let pluginResult = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: canShowButton
        )
        self.commandDelegate?.send(
            pluginResult,
            callbackId: command.callbackId
        )
    }
    
    @objc(canShowButton) var canShowButton = false
    
    @objc(login:) func login(_ command: CDVInvokedUrlCommand) {
        
        signInTool_.login { [weak self] (result) in
            var r: [String: Any] = [:]
            if let info = result as? [String : Any] {
                r = info
            }
            
            let pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: r
            )
            self?.commandDelegate?.send(
                pluginResult,
                callbackId: command.callbackId
            )
        }
        
    }
    
    @objc(checkStateWithUserID:) func checkStateWithUserID(_ command: CDVInvokedUrlCommand) {
        guard let id = command.argument(at: 0) as? String else {return}
        signInTool_.checkState(withUserID: id) { [weak self] (result) in
            var r: [String: Any] = [:]
            if let info = result as? [String : Any] {
                r = info
            }
            let pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: r
            )
            self?.commandDelegate?.send(
                pluginResult,
                callbackId: command.callbackId
            )
        }
    }
    
}
