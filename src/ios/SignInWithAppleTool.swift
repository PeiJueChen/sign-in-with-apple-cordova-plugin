//
//  SignInWithAppleCordovaPlugin.swift
//  signInWithAppleDemo
//
//  Created by 陈培爵 on 2019/12/27.
//  Copyright © 2019 陈培爵. All rights reserved.
//

import UIKit
import AuthenticationServices

public typealias CallbackType = (Any?) -> ()

@objc open class SignInWithAppleTool: NSObject {
    var viewController: UIViewController! = nil
    private var callback_: CallbackType? = nil
    required public init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    @objc public var canShowButton: Bool {
        var r = false
        if #available(iOS 13.0, *) {r = true}
        return r
    }
    
    @objc public func login(callback: @escaping CallbackType ) {
        
        if !canShowButton {return};
        
        guard #available(iOS 13.0, *) else {
            callback(["state" : -1, "errCode" : "0","errDesc": "only ios13 or above"])
            return
        }
        callback_ = callback
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()

    }
    
    @objc public func checkState(withUserID userID: String,callback: @escaping CallbackType) {
        guard #available(iOS 13.0, *) else {return}
        
        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: userID) { (credentialState, error) in
            switch(credentialState){
            case .authorized:
                // Apple ID Credential is valid
                callback(["state":1,"errDesc": "Apple ID Credential is valid"])
                break
            case .revoked:
                // Apple ID Credential revoked, handle unlink
                callback(["state":-1, "errDesc": "Apple ID Credential revoked, handle unlink"])
                fallthrough
            case .notFound:
                // Credential not found, show login UI
                callback(["state":-2, "errDesc": "Credential not found, show login UI"])
                break
            default:
                callback(["state":-3, "errDesc": "Other"])
                break
            }
        }
    }
    
}
extension SignInWithAppleTool: ASAuthorizationControllerDelegate {
    
    /*
    ∙ User ID: Unique, stable, team-scoped user ID，苹果用户唯一标识符，该值在同一个开发者账号下的所有 App 下是一样的，开发者可以用该唯一标识符与自己后台系统的账号体系绑定起来。

    ∙ Verification data: Identity token, code，验证数据，用于传给开发者后台服务器，然后开发者服务器再向苹果的身份验证服务端验证本次授权登录请求数据的有效性和真实性，详见 Sign In with Apple REST API。如果验证成功，可以根据 userIdentifier 判断账号是否已存在，若存在，则返回自己账号系统的登录态，若不存在，则创建一个新的账号，并返回对应的登录态给 App。

    ∙ Account information: Name, verified email，苹果用户信息，包括全名、邮箱等。

    ∙ Real user indicator: High confidence indicator that likely real user，用于判断当前登录的苹果账号是否是一个真实用户，取值有：unsupported、unknown、likelyReal。*/
    @available(iOS 13.0, *)
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            let state = appleIdCredential.state ?? ""
            let userIdentifier = appleIdCredential.user
            let familyName = appleIdCredential.fullName?.familyName ?? ""
            let givenName = appleIdCredential.fullName?.givenName ?? ""
            let nickname = appleIdCredential.fullName?.nickname ?? ""
            let middleName = appleIdCredential.fullName?.middleName ?? ""
            let namePrefix = appleIdCredential.fullName?.namePrefix ?? ""
            let nameSuffix = appleIdCredential.fullName?.nameSuffix ?? ""
            
            let familyName_phone = appleIdCredential.fullName?.phoneticRepresentation?.familyName ?? ""
            let givenName_phone = appleIdCredential.fullName?.phoneticRepresentation?.givenName ?? ""
            let nickname_phone = appleIdCredential.fullName?.phoneticRepresentation?.nickname ?? ""
            let namePrefix_phone = appleIdCredential.fullName?.phoneticRepresentation?.namePrefix ?? ""
            let nameSuffix_phone = appleIdCredential.fullName?.phoneticRepresentation?.nameSuffix ?? ""
            let middleName_phone = appleIdCredential.fullName?.phoneticRepresentation?.middleName ?? ""
            
            let email = appleIdCredential.email ?? ""
            let identityToken = String(bytes: appleIdCredential.identityToken ?? Data(), encoding: .utf8) ?? ""
            let authCode = String(bytes: appleIdCredential.authorizationCode ?? Data(), encoding: .utf8) ?? ""
            let realUserStatus = appleIdCredential.realUserStatus.rawValue
            let info = [
                "state": state,
                "userIdentifier": userIdentifier,
                "familyName": familyName,
                "givenName": givenName,
                "nickname": nickname,
                "middleName": middleName,
                "namePrefix": namePrefix,
                "nameSuffix": nameSuffix,
                "familyName_phone": familyName_phone,
                "givenName_phone": givenName_phone,
                "nickname_phone": nickname_phone,
                "namePrefix_phone": namePrefix_phone,
                "nameSuffix_phone": nameSuffix_phone,
                "middleName_phone": middleName_phone,
                "email": email,
                "identityToken": identityToken,
//                "identityTokenData": appleIdCredential.identityToken ?? Data(),
                "authCode": authCode,
//                "authCodeData": appleIdCredential.authorizationCode ?? Data(),
                "realUserStatus": realUserStatus
                ] as [String : Any]
            print("success:=\(info)")
            let p = ["state" : 1, "errCode" : "", "info": info] as [String : Any]
            callback_?(p)
        default:
            let p = ["state" : -1, "errCode" : "0",] as [String : Any]
            callback_?(p)
            break
        }
    }

    @available(iOS 13.0, *)
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("error:\(error.localizedDescription)")
        let err = error as NSError
        var errCode = 0;
        var errDesc = "Other"
        switch err.code {
        case ASAuthorizationError.canceled.rawValue:
            print("用户取消了授权请求")
            errCode = -1;
            errDesc = "User cancelled authorization request"
            break;
        case ASAuthorizationError.failed.rawValue:
            print("授权请求失败")
            errCode = -2;
            errDesc = "Authorization request failed"
            break;
        case ASAuthorizationError.invalidResponse.rawValue:
            print("授权请求无响应")
            errCode = -3;
            errDesc = "Authorization request is not responding"
            break;
        case ASAuthorizationError.notHandled.rawValue:
            print("未能处理授权请求")
            errCode = -4;
            errDesc = "Failed to process authorization request"
            break;
        case ASAuthorizationError.unknown.rawValue:
            print("授权请求失败未知原因")
            errCode = -5;
            errDesc = "Authorization request failed : unknown reason"
            break;
        default:
            print("other")
            break;
        }
        let p = ["state" : -1, "errCode" : errCode, "errDesc": errDesc] as [String : Any]
        callback_?(p)
        
    }
}
extension SignInWithAppleTool: ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        viewController.view.window ?? UIWindow()
    }
}
