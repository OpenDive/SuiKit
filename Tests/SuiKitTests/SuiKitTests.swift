import XCTest
@testable import SuiKit

final class SuiKitTests: XCTestCase {
    func testExample() async throws {
        let restClient = SuiClient(clientConfig: ClientConfig(baseUrl: "https://sui-devnet-kr-1.cosmostation.io"))
        let faucetClient = FaucetClient(baseUrl: "https://faucet.devnet.sui.io/gas")
        
    }
}


