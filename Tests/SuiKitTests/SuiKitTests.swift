import XCTest
@testable import SuiKit

final class SuiKitTests: XCTestCase {
    func testExample() async throws {
        let restClient = SuiProvider(connection: devnetConnection())
//        let faucetClient = FaucetClient(baseUrl: "https://faucet.devnet.sui.io/gas")
        try await restClient.getNormalizedMoveModulesByPackage("0x2")
    }
}


