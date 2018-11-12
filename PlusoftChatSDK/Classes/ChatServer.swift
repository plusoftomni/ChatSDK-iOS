//
//  ChatServer.swift
//  UOL-ChatSDK
//
//  Created by Danilo Rolim Honorato on 10/3/17.
//  Copyright © 2017 Danilo Rolim Honorato. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import UIKit
import WebKit

class ChatServer  {
    
    // Propriedades
    static var apikey  = ""
    static var session = ""
    static var lastAck = ""
    static var webviewer = ""
    
    static var userFullname = ""
    static var userEmail = ""
    static var userPhone = ""
    
    static var params = [String: Any]()
    
    static var urlAPI = "https://chatsdk-hml.oft.plus/api/"
    
    typealias StartResponse  = (_ result : Bool) -> Void
    typealias SendResponse   = (_ result : Bool) -> Void
    typealias CloseResponse  = (_ result : Bool) -> Void
    typealias AskIdResponse  = (_ result : Bool) -> Void
    typealias RestartResponse  = (_ result : Bool) -> Void
    
    typealias OnResponse  = (_ result : Bool, _ message : String?) -> Void
    
    static func Start(onStartHandler : @escaping StartResponse){
        
        // Objeto de envio
        var parameters: Parameters = [
            "userFullName": userFullname,
            "userEmail": userEmail,
            "userPhone": userPhone
        ]
        
        // Compatibilidade
        if (params.count > 0){
            parameters = params;
        }
        
        Alamofire.request(urlAPI + "start/" + apikey,
                          method: .post,
                          parameters: parameters, encoding: JSONEncoding.default).responseJSON{
                            response in
                            
                            // Confirma se tem sessão
                            if((response.result.value) != nil) {
                                let swiftyJsonVar = JSON(response.result.value!)
                                self.session = swiftyJsonVar["session"].stringValue
                                self.webviewer = swiftyJsonVar["WebViewer"].stringValue
                                
                                // Indica sucesso
                                onStartHandler(swiftyJsonVar["isSuccess"].boolValue);
                            }else{
                                
                                // Indica falha
                                onStartHandler(false);
                            }
        }
    }
    
    static func Send(_ msg:String, onSendHandler : @escaping SendResponse){
        
        // Objeto de envio
        let parameters: Parameters = [
            "msg": msg
        ]
        
        Alamofire.request(urlAPI + "send/" + self.session,
                          method: .post,
                          parameters: parameters, encoding: JSONEncoding.default).responseJSON{
                            response in
                            
                            // Confirma se tem sessão
                            if((response.result.value) != nil) {
                                let swiftyJsonVar = JSON(response.result.value!)
                                lastAck = swiftyJsonVar["id"].stringValue
                                
                                // Resultado
                                onSendHandler(swiftyJsonVar["isSuccess"].boolValue)
                            }else{
                                // Resultado
                                onSendHandler(false)
                            }
                            
        }
    }
    
    static func SendAsk(_ utterance:String, id:String){
        
        // Objeto de envio
        let parameters: Parameters = [
            "utterance": utterance,
            "id": id,
            ]
        
        Alamofire.request(urlAPI + "sendask/" + self.session,
                          method: .post,
                          parameters: parameters, encoding: JSONEncoding.default).responseJSON{
                            response in
                            
                            // Confirma se tem sessão
                            if((response.result.value) != nil) {
                                let swiftyJsonVar = JSON(response.result.value!)
                                lastAck = swiftyJsonVar["id"].stringValue
                                
                                // Resultado
                                //                                onSendHandler(swiftyJsonVar["isSuccess"].boolValue)
                            }else{
                                // Resultado
                                //                                onSendHandler(false)
                            }
                            
        }
    }
    
    static func SendStartTyping(){
        
        Alamofire.request(urlAPI + "typing/start/" + self.session,
                          method: .get,
                          parameters: nil, encoding: JSONEncoding.default).responseJSON{
                            response in
                            
        }
    }
    
    static func SendStopTyping(){
        
        Alamofire.request(urlAPI + "typing/start/" + self.session,
                          method: .get,
                          parameters: nil, encoding: JSONEncoding.default).responseJSON{
                            response in
                            
        }
    }
    
    static func CloseConnection(_ reason: String, onCloseHandler : @escaping CloseResponse){
        
        
        Alamofire.request(urlAPI + "close/" + self.session + "/" + reason,
                          method: .get, encoding: JSONEncoding.default).responseJSON{
                            response in
                            
                            // Confirma se tem sessão
                            if((response.result.value) != nil) {
                                let swiftyJsonVar = JSON(response.result.value!)
                                self.session = ""
                                self.lastAck = swiftyJsonVar["ack"].stringValue
                                
                                // Resultado
                                onCloseHandler(swiftyJsonVar["isSuccess"].boolValue)
                            }else{
                                
                                // Indica Falha
                                onCloseHandler(false);
                            }
                            
        }
    }
    
    static func postImage (image : UIImage, onSendHandler : @escaping SendResponse) {
        
        let url = urlAPI + "upload/" + self.session
        
        // Begin upload
        Alamofire.upload( multipartFormData: { (multipartFormData) in
            
            if let imageData = UIImageJPEGRepresentation(image, 0.80) {
                multipartFormData.append(imageData, withName: "file", fileName: "file.jpeg", mimeType: "image/*")
                
                let name = "file.jpeg"
                multipartFormData.append(name.data(using: String.Encoding.utf8)!, withName: "name")
            }
            
        },
                          to: url,
                          encodingCompletion:
            { (encodingResult) in
                switch encodingResult {
                case .success(let upload,_,_):
                    upload.responseJSON { response in
                        if response.result.value != nil {
                            onSendHandler(true)
                        }
                    }
                case .failure(let error):
                    onSendHandler(false)
                }
        })
    }
    
    static func AVIApi(message: WKScriptMessage, onAskIdResponse : @escaping AskIdResponse) {
        
        var _json = ""
        _json = message.body as! String
        
        if let dataFromString = _json.data(using: .utf8) {
            
            //let json = JSON(data: dataFromString)
            
            do{
                let json = try JSON(data: dataFromString)
                
                if let statusType = json["type"].string {
                    
                    switch statusType {
                    case "onRedirect" :
                        if let url = URL(string: json["data"].string!) {
                            onAskIdResponse(true);
                            //                            UIApplication.shared.open(url, options: [:])
                        }
                    case "onAskId" :
                        print(json["data"].string)
                        let _id = json["data"]["id"].numberValue
                        ChatServer.SendAsk(json["data"]["utterance"].string!, id: _id.stringValue)
                    default:
                        print("default")
                    }
                    
                }
                
            }catch {
                print (error)
            }
        }
    }
    
    static func RestartConnection(_ onRestartHandler : @escaping RestartResponse){
        
        
        Alamofire.request(urlAPI + "restart/" + self.session,
                          method: .get, encoding: JSONEncoding.default).responseJSON{
                            response in
                            
                            // Confirma se tem sessão
                            if((response.result.value) != nil) {
                                let swiftyJsonVar = JSON(response.result.value!)
                                if (swiftyJsonVar["isSuccess"].boolValue){
                                    self.webviewer = swiftyJsonVar["WebViewer"].stringValue
                                    self.lastAck   = swiftyJsonVar["ack"].stringValue
                                }else{
                                    self.session = ""
                                    self.webviewer = ""
                                    self.lastAck = swiftyJsonVar["ack"].stringValue
                                }
                                
                                // Resultado
                                onRestartHandler(swiftyJsonVar["isSuccess"].boolValue)
                            }else{
                                
                                // Indica Falha
                                onRestartHandler(false);
                            }
                            
        }
    }
    
    
    
}
