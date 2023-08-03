//
//  HistoryListReducer.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/20.
//

import ComposableArchitecture
import Foundation

struct HistoryListReducer: ReducerProtocol {
    // MARK: - State
    struct State: Equatable {
        var histories: IdentifiedArrayOf<HistoryEntity> = []
        var selectionHistory: Identified<HistoryEntity, HistoryDetailReducer.State?>?
        var paths: [Destination] = []

        // MARK: - Destination
        enum Destination {
            case historyDetail
        }
    }

    // MARK: - Action
    enum Action: Equatable {
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

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetch:
                return .task {
                    await .fetchResponse(
                        TaskResult {
                            try await databaseClient.fetchHistories(
                                NSPredicate(format: "isConnectionSuccess == %d", true)
                            )
                        }
                    )
                }
            case let .fetchResponse(.success(histories)):
                state.histories = .init(uniqueElements: histories)
                return .none
            case .fetchResponse(.failure):
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
                return .task {
                    await .deleteHistoryResponse(
                        TaskResult {
                            try await databaseClient.deleteHistory(history)
                            return history
                        }
                    )
                }
            case let .deleteHistoryResponse(.success(history)):
                state.histories.removeAll(where: { $0.id == history.id })
                return .none
            case .deleteHistoryResponse(.failure):
                return .none
            case .historyDetail:
                return .none
            }
        }
        .ifLet(\.selectionHistory, action: /Action.historyDetail) {
            EmptyReducer()
                .ifLet(\.value, action: .self) {
                    HistoryDetailReducer()
                }
        }
    }
}
