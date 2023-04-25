import XCTest
@testable import SuiKit

final class SuiKitTests: XCTestCase {
    func testExample() async throws {
        let restClient = SuiClient(clientConfig: ClientConfig(baseUrl: "https://sui-devnet-kr-1.cosmostation.io"))
        let info = try await restClient.info()
        let value = try await restClient.totalSupply()
        print(value)
        print(info)
    }
}
