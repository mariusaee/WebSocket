//
//  ViewController.swift
//  WebSocket
//
//  Created by Marius Malyshev on 22.04.2022.
//

import UIKit

class ViewController: UIViewController, URLSessionWebSocketDelegate {
    
    private var webSocket: URLSessionWebSocketTask?
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Close connection", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWebSocket()
        closeButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        view.addSubview(closeButton)
        closeButton.center = view.center
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    
    func ping() {
        webSocket?.sendPing { error in
            if let error = error {
                print("Ping error: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func close() {
        webSocket?.cancel(with: .goingAway, reason: "Demo ended".data(using: .utf8))
    }
    
    func send() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            self.send()
            self.webSocket?.send(.string("Send new message: \(Int.random(in: 1...1000))")) { error in
                if let error = error {
                    print("Send error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func receive() {
        webSocket?.receive(completionHandler: { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    print("Got Data: \(data)")
                case .string(let message):
                    print("Got String Message: \(message)")
                @unknown default:
                    break
                }
            case .failure(let error):
                print("Receive error: \(error.localizedDescription)")
            }
            self?.receive()
        })
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Did connect to socket")
        ping()
        receive()
        send()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Did close connect with reason: ")
    }
    
    func configureWebSocket() {
        let session = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: OperationQueue()
        )
        
        guard let url = URL(string: "wss://demo.piesocket.com/v3/channel_1?api_key=oCdCMcMPQpbvNjUIzqtvF1d2X2okWpDQj4AwARJuAgtjhzKxVEjQU6IdCjwm&notify_self") else { return }
        
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
    }
    
}

