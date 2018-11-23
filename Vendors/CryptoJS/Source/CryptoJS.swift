import Foundation
import JavaScriptCore

private var cryptoJScontext = JSContext()


private final class BundleToken {}

public class CryptoJS{

    public class AES: CryptoJS {

        fileprivate var encryptFunction: JSValue!
        fileprivate var decryptFunction: JSValue!

        public override init(){
            super.init()

            // Retrieve the content of aes.js
            let cryptoJSpath = Bundle.main.path(forResource: "crypto-js", ofType: "js")

            if cryptoJSpath != nil {

                do {
                    let cryptoJS = try String(contentsOfFile: cryptoJSpath!, encoding: String.Encoding.utf8)
                    print("Loaded aes.js")

                    // Evaluate aes.js
                    let values = cryptoJScontext?.evaluateScript(cryptoJS)

                    // Reference functions
//                    *     var ciphertext = CryptoJS.AES.encrypt(message, key, cfg);
//                    *     var plaintext  = CryptoJS.AES.decrypt(ciphertext, key, cfg);
                    encryptFunction = cryptoJScontext?.objectForKeyedSubscript("CryptoJS.AES.encrypt")
                    decryptFunction = cryptoJScontext?.objectForKeyedSubscript("CryptoJS.AES.decrypt")
                } catch {
                    print("Unable to load aes.js")
                }
            } else {
                print("Unable to find aes.js")
            }
        }

        public func encrypt(_ message: String,
                            password: String,
                            options: Any? = nil) -> String {
            if let unwrappedOptions = options {
                return "\(encryptFunction.call(withArguments: [message, password, unwrappedOptions])!)"
            } else {
                return "\(encryptFunction.call(withArguments: [message, password])!)"
            }
        }
        public func decrypt(_ message: String,
                            password: String,
                            options: Any? = nil) -> String {
            if let unwrappedOptions = options {
                return "\(decryptFunction.call(withArguments: [message, password, unwrappedOptions])!)"
            } else {
                return "\(decryptFunction.call(withArguments: [message, password])!)"
            }
        }
    }
}

