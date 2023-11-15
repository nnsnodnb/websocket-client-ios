//
//  HistoryListReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/20.
//

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
        case fetchResponse(TaskResult<[HistoryEntity]>)
        case setNavigation(HistoryEntity?)
        case navigationPathChanged([State.Destination])
        case deleteHistory(IndexSet)
        case deleteHistoryResponse(TaskResult<HistoryEntity>)
        case historyDetail(HistoryDetailReducer.Action)
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
                        await send(.fetchResponse(.success(histories)))
                    },
                    catch: { error, send in
                        await send(.fetchResponse(.failure(error)))
                    }
                )
            case let .fetchResponse(.success(histories)):
                state.histories = .init(uniqueElements: histories)
                return .none
            case let .fetchResponse(.failure(error)):
                Logger.error("Failed fetching: \(error)")
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
                        await send(.deleteHistoryResponse(.success(history)))
                    },
                    catch: { error, send in
                        await send(.deleteHistoryResponse(.failure(error)))
                    }
                )
            case let .deleteHistoryResponse(.success(history)):
                state.histories.removeAll(where: { $0.id == history.id })
                return .none
            case let .deleteHistoryResponse(.failure(error)):
                Logger.error("Failed deleting history: \(error)")
                return .none
            case .historyDetail:
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
