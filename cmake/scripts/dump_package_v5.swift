
import Foundation

do {
    let inputData = FileHandle.standardInput.readDataToEndOfFile()
    let json = try JSONSerialization.jsonObject(with: inputData, options: []) as! [String: Any]

    print(json["name"] as! String)

    let deps = json["dependencies"] as! [Any]
    for dep in deps {
        let depDict = dep as! [String: Any]
        if let sourceControlDep = depDict["sourceControl"] {
            let sourceControlDepDict = (sourceControlDep as! [Any])[0] as! [String: Any]
            print(sourceControlDepDict["identity"] as! String)
        } else {
            fatalError("Unsupported dependency type")
        }
    }

    print("TARGETS")

    let targs = json["targets"] as! [Any]
    for targAny in targs {
        let targ = targAny as! [String: Any]
        if let isTest = targ["isTest"] as? Bool {
            if isTest {
                continue
            }
        }

        if let targType = targ["type"] as? String {
            if targType == "test" {
                continue
            }
        }

        var targString = targ["name"] as! String
        var targPath = ""
        if let p = targ["path"] as? String {
            targPath = p
        }

        if targPath.isEmpty {
            targString += " <empty>"
        } else {
            targString += " " + targPath
        }


        let deps = targ["dependencies"] as! [Any]
        for dep in deps {
            let depDict = dep as! [String: Any]
#if swift(>=5.0)
            if let byNameDep = depDict["byName"] {
                let byNameDepArr = byNameDep as! [Any?]
                targString += " " + (byNameDepArr[0] as! String)
            }

            if let targetDep = depDict["target"] {
                let targetDepArr = targetDep as! [Any?]
                targString += " " + (targetDepArr[0] as! String)
            }
#else            
            targString += " " + (depDict["name"] as! String)
#endif            
        }

        print(targString)
    }

    print("PRODUCTS")

    let products = json["products"] as! [Any]
    for prodAny in products {
        let prod = prodAny as! [String: Any]

        var prodString = prod["name"] as! String
        prodString += " "

#if swift(>=5.0)
        let prodType = prod["type"] as! [String: Any]
        
        if let lib = prodType["library"] {
            if let libType = lib as? [String] {
                if libType.contains("dynamic") {
                    prodString += "DYNAMIC_LIBRARY"
                } else {
                    prodString += "STATIC_LIBRARY"
                }   
            }            
        } else if let _ = prodType["executable"] {
            prodString += "EXECUTABLE"
        } else {
            fatalError ("Unknown product type")
        }
#else
        let prodType = prod["product_type"] as! String

        if prodType == "executable" {
            prodString += "EXECUTABLE"
        } else if prodType == "library" {
            if let libType = prod["type"] as? String {
                if libType == "dynamic" {
                    prodString += "DYNAMIC_LIBRARY"
                } else {
                    prodString += "STATIC_LIBRARY"
                }
            } else {
                prodString += "STATIC_LIBRARY"
            }
        }
#endif        
        let targets = prod["targets"] as! [String]
        for targ in targets {
            prodString += " " + targ
        }

        print(prodString)
    }
}
catch {
    print("\(error)")
    exit(1)
}

