//
//  HistoryListPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/20.
//

import ComposableArchitecture
import DependenciesInterfaces
import SFSafeSymbols
import SwiftUI

@Reducer
public struct HistoryListReducer: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    var histories: IdentifiedArrayOf<HistoryEntity> = []
    var selectionHistory: Identified<HistoryEntity, HistoryDetailReducer.State?>?
    var paths: [Destination] = []

    // MARK: - Destination
    public enum Destination: Sendable {
      case historyDetail
    }
  }

  // MARK: - Action
  public enum Action: Sendable, Equatable {
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

  @Dependency(\.database)
  var databaseClient

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetch:
        return .run(
          operation: { send in
            let histories = try await databaseClient.fetchHistories(
              #Predicate<HistoryModel> { $0.isConnectionSuccess }
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
        .ifLet(\.value, action: \.self) {
          HistoryDetailReducer()
        }
    }
  }
}

struct HistoryListPage: View {
  @Bindable var store: StoreOf<HistoryListReducer>

  private static let dateFormatter: DateFormatter = {
    @Dependency(\.calendar)
    var calendar
    @Dependency(\.timeZone)
    var timeZone

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    dateFormatter.calendar = calendar
    dateFormatter.timeZone = timeZone
    dateFormatter.locale = .init(identifier: "en_US_POSIX")
    return dateFormatter
  }()

  var body: some View {
    NavigationStack(
      path: $store.paths.sending(\.navigationPathChanged),
      root: {
        content
          .navigationTitle(.historyListNavibarTitle)
          .navigationBarTitleDisplayMode(.inline)
          .modifier {
            if #available(iOS 26.0, *) {
              $0
                .scrollEdgeEffectStyle(.soft, for: .top)
            } else {
              $0
            }
          }
      },
    )
    .task {
      store.send(.fetch)
    }
    .analyticsScreen(screenName: .historyList)
  }

  @ViewBuilder private var content: some View {
    if store.histories.isEmpty {
      emptyView
    } else {
      list
    }
  }

  private var emptyView: some View {
    ContentUnavailableView(
      label: {
        VStack(spacing: 16) {
          Image(systemSymbol: .noteText)
            .resizable()
            .frame(width: 56, height: 56)
          Text(.historyListContentTitleEmpty)
            .font(.title2)
            .fontWeight(.bold)
        }
        .foregroundStyle(.orange)
      }
    )
    .background {
      Color(UIColor.systemGroupedBackground)
    }
  }

  private var list: some View {
    List {
      ForEach(store.histories) { history in
        row(history: history)
      }
      .onDelete {
        store.send(.deleteHistory($0))
      }
    }
    .navigationDestination(
      for: HistoryListReducer.State.Destination.self,
      destination: { destination in
        switch destination {
        case .historyDetail:
          if let store = store.scope(\.selectionHistory?.value, action: \.historyDetail) {
            HistoryDetailPage(store: store)
          }
        }
      }
    )
  }

  private func row(history: HistoryEntity) -> some View {
    HStack {
      Button(
        action: {
          store.send(.setNavigation(history))
        },
        label: {
          VStack(alignment: .leading, spacing: 12) {
            Text(history.url.absoluteString)
              .font(.system(size: 18))
              .foregroundStyle(history.isConnectionSuccess ? .primary : Color.secondary)
            HStack(alignment: .center, spacing: 4) {
              Image(systemSymbol: history.isConnectionSuccess ? .checkmarkCircleFill : .xmarkCircleFill)
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundStyle(history.isConnectionSuccess ? Color.green : Color.red)
              Text(history.isConnectionSuccess ? .historyListContentIsConnectionSuccess : .historyListContentIsConnectionFailure)
                .font(.system(size: 14))
                .foregroundColor(.primary)
              Spacer()
              Text(Self.dateFormatter.string(from: history.createdAt))
                .font(.system(size: 12))
                .foregroundStyle(Color.gray.opacity(0.8))
            }
          }
        }
      )
      Spacer()
      Image(systemSymbol: .chevronRight)
        .font(.system(size: 14, weight: .semibold))
        .foregroundColor(.secondary)
        .opacity(0.5)
    }
  }
}

struct HistoryListPage_Previews: PreviewProvider {
  static var history: HistoryEntity {
    return .init(
      id: .init(0),
      url: URL(string: "wss://echo.websocket.org")!,
      customHeaders: [],
      messages: [],
      isConnectionSuccess: false,
      createdAt: .init()
    )
  }

  static var previews: some View {
    HistoryListPage(
      store: .init(
        initialState: HistoryListReducer.State(
          histories: [history],
        ),
        reducer: {
          HistoryListReducer()
        },
        withDependencies: {
          $0.database.fetchHistories = { _ in await [history] }
        }
      ),
    )
  }
}
