//
//  File.swift
//  
//
//  Created by Marcus Arnett on 5/3/23.
//

import Foundation

public struct SuiValidatorSummary {
    public let suiAddress: SuiAddress
    public let protocolPubkeyBytes: String
    public let networkPubkeyBytes: String
    public let workerPubkeyBytes: String
    public let proofOfPossessionBytes: String
    public let operationCapId: String
    public let name: String
    public let description: String
    public let imageUrl: String
    public let projectUrl: String
    public let p2pAddress: String
    public let netAddress: String
    public let primaryAddress: String
    public let workerAddress: String
    public let nextEpochProtocolPubkeyBytes: String
    public let nextEpochProofOfPossession: String
    public let nextEpochNetworkPubkeyBytes: String
    public let nextEpochWorkerPubkeyBytes: String
    public let nextEpochNetAddress: String
    public let nextEpochP2pAddress: String
    public let nextEpochPrimaryAddress: String
    public let nextEpochWorkerAddress: String
    public let votingPower: String
    public let gasPrice: String
    public let commissionRate: String
    public let nextEpochStake: String
    public let nextEpochGasPrice: String
    public let nextEpochCommissionRate: String
    public let stakingPoolId: String
    public let stakingPoolActivationEpoch: String
    public let stakingPoolDeactivationEpoch: String
    public let stakingPoolSuiBalance: String
    public let rewardsPool: String
    public let poolTokenBalance: String
    public let pendingStake: String
    public let pendingPoolTokenWithdraw: String
    public let pendingTotalSuiWithdraw: String
    public let exchangeRatesId: String
    public let exchangeRatesSize: String
}

public typealias SuiAddress = String
