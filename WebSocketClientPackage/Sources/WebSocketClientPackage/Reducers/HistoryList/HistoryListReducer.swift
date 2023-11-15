//
//  HistoryListReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/20.
//

import CasePaths
import ComposableArchitecture
import Foundation

@Reducer
public struct HistoryListReducer {
    // MARK: - State
    public struct State: Equatable {
        var histories: IdentifiedArrayOf<HistoryEntity> = []
        var selectionHistory: Identified<HistoryEntity, HistoryDetailReducer.State?>?
        var paths: [Destination] = []

        // MARK: - Destination
        public enum Destination {
            case historyDetail
        }
    }

    // MARK: - Action
    public enum Action: Equatable {
        case fetch
        case fetchResponse([HistoryEntity])
        case setNavigation(HistoryEntity?)
        case navigationPathChanged([State.Destination])
        case deleteHistory(IndexSet)
        case deleteHistoryResponse(HistoryEntity)
        case historyDetail(HistoryDetailReducer.Action)
        case error(Error)

        // MARK: - Error
        @CasePathable
        public enum Error: Swift.Error {
            case fetch
            case deleteHistory
        }
    }

    @Dependency(\.databaseClient)
    var databaseClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetch:
                return .run(
                    operation: { send in
                        let histories = try await databaseClient.fetchHistories(
                            NSPredicate(format: "isConnectionSuccess == %d", true)
                        )
                        await send(.fetchResponse(histories))
                    },
                    catch: { error, send in
                        await send(.error(.fetch))
                        Logger.error("Failed fetching: \(error)")
                    }
                )
            case let .fetchResponse(histories):
                state.histories = .init(uniqueElements: histories)
                return .none
            case let .setNavigation(.some(history)):
                state.paths.append(.historyDetail)
                state.selectionHistory = .init(.init(history: history), id: history)
                return .none
            case .setNavigation(.none):
                state.paths = []
                state.selectionHistory = nil
                return .none
            case .historyDetail(.deleted):
                guard let history = state.selectionHistory?.id else { return .none }
                state.histories.removeAll(where: { $0.id == history.id })
                return .send(.setNavigation(nil))
            case let .navigationPathChanged(paths):
                state.paths = paths
                return .none
            case let .deleteHistory(indexSet):
                guard let index = indexSet.first,
                      let history = state.histories[safe: index] else { return .none }
                return .run(
                    operation: { send in
                        try await databaseClient.deleteHistory(history)
                        await send(.deleteHistoryResponse(history))
                    },
                    catch: { error, send in
                        await send(.error(.deleteHistory))
                        Logger.error("Failed deleting history: \(error)")
                    }
                )
            case let .deleteHistoryResponse(history):
                state.histories.removeAll(where: { $0.id == history.id })
                return .none
            case .historyDetail:
                return .none
            case .error:
                return .none
            }
        }
        .ifLet(\.selectionHistory, action: \.historyDetail) {
            EmptyReducer()
                .ifLet(\.value, action: .self) {
                    HistoryDetailReducer()
                }
        }
    }
}
