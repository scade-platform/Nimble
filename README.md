# <img src="https://user-images.githubusercontent.com/15704847/136008333-61eb0538-dd17-4db1-91ad-9aa633354382.png" alt="Nimble logo" height="24" > Nimble

Nimble is a lightweight native editor for macOS based on everything we love about our favorite editors and IDEs.
 
<img width="1392" alt="Dark appearance" src="https://user-images.githubusercontent.com/15704847/136013750-6014f1f5-6b2f-44ed-929a-fe9e1ad198f5.png">

<img width="1392" alt="Light appearance" src="https://user-images.githubusercontent.com/15704847/136013779-ecfcee57-0616-4b55-bfe9-45a9202d9620.png">

We really love Swift, that's why we implemented support for this language in the first place.

**Auto-complition via LSP**

<img width="500" alt="Auto-complition" src="https://user-images.githubusercontent.com/15704847/136015030-009c2b59-b0c8-49b2-b8cf-48f1445ae015.png">
 
**Diagnostics via LSP**

![image](https://user-images.githubusercontent.com/15704847/136015396-2d96659d-013b-4f28-b371-64c9044a2605.png)
  
![image](https://user-images.githubusercontent.com/15704847/136016213-c1e2cf26-3c83-4595-ba93-910d568e303a.png)

**SPM projects**

You can create and work with SPM projects using Nimble. It is faster than using Xcode.

## Motivation

We are developing Nimble as a tools platform for <img width="12" alt="Scade logo" src="https://user-images.githubusercontent.com/15704847/136028976-be275d45-0043-44f4-999b-afe57aa43c30.png"> [SCADE](https://www.scade.io/). <br> <img width="12" alt="Scade logo" src="https://user-images.githubusercontent.com/15704847/136028976-be275d45-0043-44f4-999b-afe57aa43c30.png"> [SCADE](https://www.scade.io/) is a tools, freamework and SDK which allows you implement native crosplatform applications for iOS and Android using Swift.

## Source code

Nimble is a document-based Cocoa application written in Swift.

### Development Environment

- macOS 10.15 Catalina or higher
- Xcode 12.4 or higher
- Swift 5.3.2 or higher

### How to Build

1. Run following commands to resolve dependencies.
    - `git submodule update --init --recursive`
1. Open `Nimble.xcworkspace` in Xcode.
1. Build "Nimble" scheme in the workspace.

### Extendable

We disined it to be extendable by plugins. The [.xctemplate](/Templates) allows every developer create their own plugin in several clicks. To implement yours ideas you can use API which we designed by proof-of-concept priciple. Our plugins such [ProjectNavigator](/Plugins/ProjectNavigator), [CodeEditor](/Plugins/CodeEditor), [BuildSystem](/Plugins/BuildSystem), [SwiftExtensions](/Plugins/SwiftExtensions) show examples of using API.

## License

Copyright © 2021 SCADE Inc. All rights reserved.

The source code is licensed under the terms of the __Apache License, Version 2.0__. See [LICENSE](LICENSE.txt) for details.
