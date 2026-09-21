//
//  MessageListView.swift
//  WebSocketClient
//
//  Created by Yuya Oka on 2023/05/01.
//

import SwiftUI

struct MessageListView: View {
  let messages: [String]
  let connectivityState: ConnectionReducer.State.ConnectivityState

  var body: some View {
    List {
      if !messages.isEmpty {
        Section {
          ForEach(messages.reversed(), id: \.self) { message in
            Text(message)
          }
        }
      }
      Section {
        connectionStateRow
          .listRowBackground(Color(.systemGroupedBackground))
      }
    }
    .listSectionSpacing(0)
  }

  @ViewBuilder private var connectionStateRow: some View {
    let image = switch connectivityState {
    case .connected:
      Image(systemSymbol: .linkCircleFill)
    case .connecting:
      Image(systemSymbol: .dotRadiowavesUpForward)
    case .disconnected:
      Image(systemSymbol: .linkCircle)
    }
    let color: Color = switch connectivityState {
    case .connected:
      .green
    case .connecting:
      .orange
    case .disconnected:
      .red
    }
    let text: LocalizedStringResource = switch connectivityState {
    case .connected:
      .messageListStateConnected
    case .connecting:
      .messageListStateConnecting
    case .disconnected:
      .messageListStateDisconnected
    }

    Label(
      title: {
        Text(text)
          .font(.system(size: 18, weight: .medium))
      },
      icon: {
        image
          .resizable()
          .frame(width: 18, height: 18)
          .foregroundStyle(color)
          .fontWeight(.bold)
      },
    )
    .frame(maxWidth: .infinity, alignment: .center)
  }
}

struct MessageListView_Previews: PreviewProvider {
  static var previews: some View {
    MessageListView(
      messages: (1...10).map { "Message: \($0)" },
      connectivityState: .connecting,
    )
  }
}
