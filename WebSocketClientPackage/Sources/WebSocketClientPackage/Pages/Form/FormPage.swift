//
//  FormPage.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/04/14.
//

import ComposableArchitecture
import FirebaseAnalytics
import SFSafeSymbols
import SwiftUI

struct FormPage: View {
  @Bindable var store: StoreOf<FormReducer>

  @FocusState private var isFocused: Bool

  var body: some View {
    NavigationStack {
      form
        .navigationTitle("WebSocket Client")
    }
    .fullScreenCover(
      item: $store.scope(state: \.connection, action: \.connection),
      content: { store in
        ConnectionPage(store: store)
      }
    )
    .analyticsScreen(name: "form-page")
  }

  private var form: some View {
    Form {
      firstSection
      secondSection
      thirdSection
    }
    .keyboardToolbar {
      isFocused = false
    }
  }

  private var firstSection: some View {
    Section(
      content: {
        urlTextField
      },
      header: {
        Text(.formSectionFirstTitleHeader)
      }
    )
  }

  private var urlTextField: some View {
    HStack {
      Image(systemSymbol: .link)
        .foregroundColor(Color.blue)
      TextField(
        "wss://echo.websocket.org",
        text: .init(
          get: {
            store.url?.absoluteString ?? ""
          },
          set: {
            store.send(.urlChanged($0))
          }
        )
      )
      .focused($isFocused)
      .frame(maxHeight: .infinity)
    }
  }

  private var secondSection: some View {
    Section(
      content: {
        customHeaders
      },
      header: {
        Text(.formSectionSecondTitleHeader)
      }
    )
  }

  private var customHeaders: some View {
    Group {
      ForEach(0..<store.customHeaders.count, id: \.self) { index in
        customHeaderTextField(index: index)
      }
      .onDelete(
        perform: {
          store.send(.removeCustomHeader($0), animation: .default)
        }
      )
      addCustomHeaderButton
    }
  }

  private func customHeaderTextField(index: Int) -> some View {
    GeometryReader { proxy in
      HStack {
        TextField(
          String(localized: .formSectionSecondTitleName),
          text: .init(
            get: {
              store.customHeaders[safe: index]?.name ?? ""
            },
            set: {
              store.send(.customHeaderNameChanged(index, $0))
            }
          )
        )
        .focused($isFocused)
        .frame(maxWidth: proxy.frame(in: .local).width / 3, maxHeight: .infinity)
        Divider()
        TextField(
          String(localized: .formSectionSecondTitleValue),
          text: .init(
            get: {
              store.customHeaders[safe: index]?.value ?? ""
            },
            set: {
              store.send(.customHeaderValueChanged(index, $0))
            }
          )
        )
        .focused($isFocused)
        .frame(maxHeight: .infinity)
      }
    }
  }

  private var addCustomHeaderButton: some View {
    Button(
      action: {
        store.send(.addCustomHeader, animation: .default)
      },
      label: {
        Label(
          title: {
            Text(.formSectionSecondTitleAddButton)
              .offset(x: -12)
          },
          icon: {
            Image(systemSymbol: .plusSquareFill)
          }
        )
      }
    )
    .frame(maxWidth: .infinity)
  }

  private var thirdSection: some View {
    Section(
      content: {
        connectButton
      }
    )
  }

  private var connectButton: some View {
    Button(
      action: {
        store.send(.connect, animation: .default)
      },
      label: {
        Text(.formSectionThirdTitleConnectButton)
          .frame(maxWidth: .infinity)
      }
    )
    .disabled(store.isConnectButtonDisable)
  }
}

@MainActor
private extension View {
  func keyboardToolbar(closeAction: @escaping () -> Void) -> some View {
    toolbar {
      ToolbarItemGroup(placement: .keyboard) {
        Spacer()
        Button(action: closeAction) {
          Text(.formKeyboardTitleCloseButton)
            .bold()
        }
        .padding(.trailing, 8)
      }
    }
  }
}

struct FormPage_Previews: PreviewProvider {
  static var previews: some View {
    FormPage(
      store: Store(
        initialState: FormReducer.State(
          url: URL(string: "wss://echo.websocket.org")!,
          isConnectButtonDisable: false
        )
      ) {
        FormReducer()
      }
    )
  }
}
