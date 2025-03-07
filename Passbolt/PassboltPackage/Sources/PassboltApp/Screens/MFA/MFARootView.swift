//
// Passbolt - Open source password manager for teams
// Copyright (c) 2021 Passbolt SA
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General
// Public License (AGPL) as published by the Free Software Foundation version 3.
//
// The name "Passbolt" is a registered trademark of Passbolt SA, and Passbolt SA hereby declines to grant a trademark
// license to "Passbolt" pursuant to the GNU Affero General Public License version 3 Section 7(e), without a separate
// agreement with Passbolt SA.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License along with this program. If not,
// see GNU Affero General Public License v3 (http://www.gnu.org/licenses/agpl-3.0.html).
//
// @copyright     Copyright (c) Passbolt SA (https://www.passbolt.com)
// @license       https://opensource.org/licenses/AGPL-3.0 AGPL License
// @link          https://www.passbolt.com Passbolt (tm)
// @since         v1.0
//

import UICommons

internal final class MFARootView: KeyboardAwareView {

  internal var tapPublisher: AnyPublisher<Void, Never> { button.tapPublisher }

  private let scrolledStack: ScrolledStackView = .init()
  private let container: View = .init()
  private let button: TextButton = .init()

  @available(*, unavailable, message: "Use init(hideButton:)")
  internal required init() {
    unreachable("\(Self.self).\(#function) should not be used")
  }

  internal init(hideButton: Bool) {
    super.init()

    mut(self) {
      .backgroundColor(dynamic: .background)
    }

    mut(button) {
      .combined(
        .linkStyle(),
        .text(
          localized: "mfa.provider.try.another",
          inBundle: .main
        ),
        .hidden(hideButton)
      )
    }

    mut(scrolledStack) {
      .combined(
        .isLayoutMarginsRelativeArrangement(true),
        .contentInset(.init(top: 0, left: 16, bottom: 8, right: 16)),
        .axis(.vertical),
        .subview(of: self),
        .leadingAnchor(.equalTo, leadingAnchor),
        .trailingAnchor(.equalTo, trailingAnchor),
        .topAnchor(.equalTo, topAnchor),
        .bottomAnchor(.equalTo, keyboardSafeAreaLayoutGuide.bottomAnchor),
        .append(container),
        .append(button)
      )
    }
  }

  internal func setContent(view: UIView) {
    container.subviews.forEach { $0.removeFromSuperview() }

    mut(view) {
      .combined(
        .subview(of: container),
        .edges(equalTo: container)
      )
    }
  }
}
