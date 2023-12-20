// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct ObjectFilter: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    package: GraphQLNullable<SuiAddressApollo> = nil,
    module: GraphQLNullable<String> = nil,
    ty: GraphQLNullable<String> = nil,
    owner: GraphQLNullable<SuiAddressApollo> = nil,
    objectIds: GraphQLNullable<[SuiAddressApollo]> = nil,
    objectKeys: GraphQLNullable<[ObjectKey]> = nil
  ) {
    __data = InputDict([
      "package": package,
      "module": module,
      "ty": ty,
      "owner": owner,
      "objectIds": objectIds,
      "objectKeys": objectKeys
    ])
  }

  public var package: GraphQLNullable<SuiAddressApollo> {
    get { __data["package"] }
    set { __data["package"] = newValue }
  }

  public var module: GraphQLNullable<String> {
    get { __data["module"] }
    set { __data["module"] = newValue }
  }

  public var ty: GraphQLNullable<String> {
    get { __data["ty"] }
    set { __data["ty"] = newValue }
  }

  public var owner: GraphQLNullable<SuiAddressApollo> {
    get { __data["owner"] }
    set { __data["owner"] = newValue }
  }

  public var objectIds: GraphQLNullable<[SuiAddressApollo]> {
    get { __data["objectIds"] }
    set { __data["objectIds"] = newValue }
  }

  public var objectKeys: GraphQLNullable<[ObjectKey]> {
    get { __data["objectKeys"] }
    set { __data["objectKeys"] = newValue }
  }
}
