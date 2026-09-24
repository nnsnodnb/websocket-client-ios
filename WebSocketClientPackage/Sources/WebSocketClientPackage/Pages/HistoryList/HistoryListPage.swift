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
  // MARK: - Destination
  public enum Destination: Hashable {
    case historyDetail(HistoryEntity)
  }

  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    var histories: IdentifiedArrayOf<HistoryEntity> = []
    var selectionSortDirection: SortDirection = .descending
    var selectionFilter: Filter = .onlySuccess
    var historyDetail: HistoryDetailReducer.State?
    var isPortrait = false
    var columnVisibility: NavigationSplitViewVisibility = .all

    // MARK: - SortDirection
    public enum SortDirection: CaseIterable, Sendable {
      case ascending
      case descending

      // MARK: - Properties
      var rawValue: String {
        switch self {
        case .ascending:
          String(localized: .historyListNavibarSortDirectionAscending)
        case .descending:
          String(localized: .historyListNavibarSortDirectionDescending)
        }
      }
      var reverse: Bool { self == .descending }
    }

    // MARK: - Filter
    public enum Filter: CaseIterable, Sendable {
      case all
      case onlySuccess
      case onlyFailed

      // MARK: - Properties
      var rawValue: String {
        switch self {
        case .all:
          String(localized: .historyListNavibarFilterAll)
        case .onlySuccess:
          String(localized: .historyListNavibarFilterOnlySuccess)
        case .onlyFailed:
          String(localized: .historyListNavibarFilterOnlyFailed)
        }
      }
    }
  }

  // MARK: - Action
  public enum Action {
    case fetch
    case changedSortDirection(State.SortDirection)
    case changedFilter(State.Filter)
    case changedIsPortrait(Bool)
    case changedColumnVisibility(NavigationSplitViewVisibility)
    case showDestination(Destination?)
    case deleteHistory(IndexSet)
    case historyDetail(HistoryDetailReducer.Action)
    case internalAction(InternalAction)

    // MARK: - InternalAction
    @CasePathable
    public enum InternalAction {
      case fetchResponse([HistoryEntity])
      case deleteHistoryResponse(HistoryEntity)
      case error(Error)
    }

    // MARK: - Error
    @CasePathable
    public enum Error: Swift::Error {
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
          operation: { [reverse = state.selectionSortDirection.reverse, filter = state.selectionFilter] send in
            let predicate: Predicate<HistoryModel>?
            switch filter {
            case .all:
              predicate = nil
            case .onlySuccess:
              predicate = #Predicate<HistoryModel> { $0.isConnectionSuccess }
            case .onlyFailed:
              predicate = #Predicate<HistoryModel> { !$0.isConnectionSuccess }
            }
            let histories = try await databaseClient.fetchHistories(predicate, reverse)
            await send(.internalAction(.fetchResponse(histories)))
          },
          catch: { error, send in
            await send(.internalAction(.error(.fetch)))
            Logger.error("Failed fetching: \(error)")
          }
        )
      case let .changedSortDirection(sortDirection):
        state.selectionSortDirection = sortDirection
        Logger.debug("Changed sort direction to \(sortDirection.rawValue)")
        return .send(.fetch)
      case let .changedFilter(filter):
        state.selectionFilter = filter
        return .send(.fetch)
      case let .changedIsPortrait(isPortrait):
        state.isPortrait = isPortrait
        return .none
      case let .changedColumnVisibility(columnVisibility):
        state.columnVisibility = columnVisibility
        return .none
      case let .showDestination(destination):
        switch destination {
        case let .historyDetail(history):
          state.historyDetail = .init(history: history)
        case .none:
          state.historyDetail = nil
        }
        return .none
      case let .deleteHistory(indexSet):
        guard let index = indexSet.first,
              let history = state.histories[safe: index] else { return .none }
        return .run(
          operation: { send in
            try await databaseClient.deleteHistory(history)
            await send(.internalAction(.deleteHistoryResponse(history)))
          },
          catch: { error, send in
            await send(.internalAction(.error(.deleteHistory)))
            Logger.error("Failed deleting history: \(error)")
          }
        )
      case let .historyDetail(.delegate(.deleted(history))):
        withAnimation {
          state.histories.removeAll(where: { $0.id == history.id })
        }
        state.historyDetail = nil
        return .none
      case .historyDetail:
        return .none
      case let .internalAction(.fetchResponse(histories)):
        withAnimation {
          state.histories = .init(uniqueElements: histories)
        }
        return .none
      case let .internalAction(.deleteHistoryResponse(history)):
        withAnimation {
          state.histories.removeAll(where: { $0.id == history.id })
        }
        return .none
      case .internalAction(.error):
        return .none
      }
    }
    .ifLet(\.historyDetail, action: \.historyDetail) {
      HistoryDetailReducer()
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

  @Dependency(\.mainQueue)
  private var mainQueue
  @Environment(\.horizontalSizeClass)
  private var horizontalSizeClass
  @Environment(\.verticalSizeClass)
  private var verticalSizeClass

  var body: some View {
    NavigationSplitView(
      columnVisibility: $store.columnVisibility.sending(\.changedColumnVisibility),
      sidebar: {
        content
          .navigationTitle(.historyListNavibarTitle)
          .navigationBarTitleDisplayMode(.inline)
          .toolbar(
            sortDirection: $store.selectionSortDirection.sending(\.changedSortDirection),
            filter: $store.selectionFilter.sending(\.changedFilter),
          )
          .modifier {
            if #available(iOS 26.0, *) {
              $0.scrollEdgeEffectStyle(.soft, for: .top)
            } else {
              $0
            }
          }
      },
      detail: {
        if let store = store.scope(\.historyDetail, action: \.historyDetail) {
          HistoryDetailPage(store: store)
        } else {
          DetailNilView(text: .historyListDetailHistoryDetailNilText)
        }
      }
    )
    .navigationSplitViewStyle(.balanced)
    .task {
      store.send(.fetch)
    }
    .onChange(of: store.historyDetail, { oldValue, newValue in
      guard oldValue != newValue, newValue != nil, store.isPortrait else { return }
      store.send(.changedColumnVisibility(.detailOnly))
    })
    .onGeometryChange(
      for: Bool.self,
      of: { proxy in
        proxy.size.width < proxy.size.height
      },
      action: { isPortrait in
        store.send(.changedIsPortrait(isPortrait))
        // 開いた状態
        guard horizontalSizeClass == .regular && verticalSizeClass == .regular else {
          return
        }
        if isPortrait && store.historyDetail == nil {
          // 縦持ちで遷移先がない場合は全カラム
          Task {
            try? await mainQueue.sleep(for: .milliseconds(1))
            store.send(.changedColumnVisibility(.all))
          }
        } else if !isPortrait {
          // 横持ちであれば強制的に全カラム
          store.send(.changedColumnVisibility(.all))
        }
      },
    )
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
        .ignoresSafeArea()
    }
  }

  private var list: some View {
    List(selection: listSelection) {
      ForEach(store.histories, id: \.self) { history in
        row(history: history)
      }
      .onDelete {
        store.send(.deleteHistory($0))
      }
    }
    .listStyle(.insetGrouped)
  }

  private var listSelection: Binding<HistoryEntity?> {
    .init(
      get: { store.historyDetail?.history },
      set: { history in
        if let history {
          store.send(.showDestination(.historyDetail(history)))
        } else {
          store.send(.showDestination(nil))
        }
      },
    )
  }

  private func row(history: HistoryEntity) -> some View {
    HStack {
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
      Spacer()
      Image(systemSymbol: .chevronRight)
        .font(.system(size: 14, weight: .semibold))
        .foregroundColor(.secondary)
        .opacity(0.5)
    }
  }
}

private extension View {
  func toolbar(
    sortDirection: Binding<HistoryListReducer.State.SortDirection>,
    filter: Binding<HistoryListReducer.State.Filter>,
  ) -> some View {
    toolbar {
      ToolbarItemGroup(placement: .topBarTrailing) {
        Menu(
          content: {
            Picker("", selection: sortDirection) {
              ForEach(HistoryListReducer.State.SortDirection.allCases, id: \.self) { sortDirection in
                Text(sortDirection.rawValue)
                  .tag(sortDirection)
              }
            }
          },
          label: {
            Image(systemSymbol: .arrowUpArrowDown)
          },
        )
        Menu(
          content: {
            Picker("", selection: filter) {
              ForEach(HistoryListReducer.State.Filter.allCases, id: \.self) { filter in
                Text(filter.rawValue)
                  .tag(filter)
              }
            }
          },
          label: {
            Image(systemSymbol: .line3HorizontalDecrease)
          },
        )
      }
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
          $0.database.fetchHistories = { _, _ in await [history] }
        }
      ),
    )
  }
}
