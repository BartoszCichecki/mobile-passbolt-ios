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

import Commons
import UICommons
import UIKit

public final class SheetMenuContentView: View {

  internal var closeActionPublisher: AnyPublisher<Void, Never> {
    closeActionSubject.eraseToAnyPublisher()
  }

  private let closeActionSubject: PassthroughSubject<Void, Never> = .init()
  private let titleLabel: Label = .init()
  private let content: View = .init()
  private let container: View = .init()

  public required init() {
    super.init()

    mut(self) {
      .backgroundColor(dynamic: .overlayBackground)
    }

    let overlay: View = .init()
    mut(overlay) {
      .combined(
        .subview(of: self),
        .backgroundColor(.clear),
        .leadingAnchor(.equalTo, leadingAnchor),
        .trailingAnchor(.equalTo, trailingAnchor),
        .topAnchor(.equalTo, topAnchor),
        .tapGesture { [weak self] _ in
          self?.closeActionSubject.send()
        }
      )
    }

    mut(content) {
      .combined(
        .backgroundColor(dynamic: .sheetBackground),
        .shadow(color: .black, opacity: 0),
        .cornerRadius(
          8,
          corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner],
          masksToBounds: true
        ),
        .subview(of: self),
        .leadingAnchor(.equalTo, leadingAnchor),
        .trailingAnchor(.equalTo, trailingAnchor),
        .topAnchor(.equalTo, overlay.bottomAnchor),
        .heightAnchor(.lessThanOrEqualTo, heightAnchor, multiplier: 0.8),
        .bottomAnchor(.equalTo, bottomAnchor)
      )
    }

    mut(titleLabel) {
      .combined(
        .lineBreakMode(.byTruncatingTail),
        .font(.inter(ofSize: 20, weight: .semibold)),
        .textColor(dynamic: .primaryText),
        .numberOfLines(1),
        .subview(of: content),
        .leadingAnchor(.equalTo, content.leadingAnchor, constant: 16),
        .topAnchor(.equalTo, content.topAnchor, constant: 16)
      )
    }

    let closeButton: ImageButton = .init()
    mut(closeButton) {
      .combined(
        .image(named: .close, from: .uiCommons),
        .tintColor(dynamic: .primaryText),
        .action { [weak self] in
          self?.closeActionSubject.send()
        },
        .subview(of: content),
        .leadingAnchor(.equalTo, titleLabel.trailingAnchor, constant: 8),
        .trailingAnchor(.equalTo, content.trailingAnchor, constant: -16),
        .centerYAnchor(.equalTo, titleLabel.centerYAnchor),
        .widthAnchor(.equalTo, constant: 24),
        .heightAnchor(.equalTo, constant: 24)
      )
    }

    let divider: View = .init()
    mut(divider) {
      .combined(
        .backgroundColor(dynamic: .divider),
        .subview(of: content),
        .heightAnchor(.equalTo, constant: 1),
        .leadingAnchor(.equalTo, content.leadingAnchor, constant: 16),
        .trailingAnchor(.equalTo, content.trailingAnchor, constant: -16),
        .topAnchor(.equalTo, closeButton.bottomAnchor, constant: 8)
      )
    }

    mut(container) {
      .combined(
        .subview(of: content),
        .leadingAnchor(.equalTo, content.leadingAnchor),
        .trailingAnchor(.equalTo, content.trailingAnchor),
        .topAnchor(.equalTo, divider.bottomAnchor),
        .bottomAnchor(.equalTo, content.bottomAnchor)
      )
    }
  }

  public func setTitle(_ text: String) {
    titleLabel.text = text
  }

  public func setContent(view: UIView) {
    container.subviews.forEach { $0.removeFromSuperview() }

    mut(view) {
      .combined(
        .subview(of: container),
        .edges(equalTo: container)
      )
    }
  }
}

public struct SheetMenuController<ContentContext> {

  public var contentContext: ContentContext
}

extension SheetMenuController: UIController {

  public typealias Context = ContentContext

  public static func instance(
    in context: Context,
    with features: FeatureFactory,
    cancellables: Cancellables
  ) -> SheetMenuController<Context> {
    Self(
      contentContext: context
    )
  }
}

public final class SheetMenuViewController<Content: UIComponent>: PlainViewController, UIComponent {

  public typealias View = SheetMenuContentView
  public typealias Controller = SheetMenuController<Content.Controller.Context>

  public static func instance(
    using controller: Controller,
    with components: UIComponentFactory
  ) -> Self {
    Self(
      using: controller,
      with: components
    )
  }

  public private(set) lazy var contentView: View = .init()
  public var components: UIComponentFactory

  private let controller: Controller
  private var observationToken: NSKeyValueObservation?

  internal init(
    using controller: Controller,
    with components: UIComponentFactory
  ) {
    self.controller = controller
    self.components = components
    super.init()
    modalPresentationStyle = .overFullScreen
    modalTransitionStyle = .crossDissolve
  }

  public func setupView() {
    let child: Content = addChild(
      Content.self,
      in: controller.contentContext,
      viewSetup: { parentView, childView in
        parentView.setContent(view: childView)
      }
    )

    observationToken = child.observe(\.title, options: [.initial, .new]) { [weak self] _, change in
      guard
        let newValue: String? = change.newValue,
        newValue != change.oldValue,
        let childTitle: String = newValue
      else { return }

      self?.contentView.setTitle(childTitle)
    }

    setupSubscriptions()
  }

  private func setupSubscriptions() {
    contentView
      .closeActionPublisher
      .sink { [weak self] in
        self?.dismiss(Self.self)
      }
      .store(in: cancellables)
  }
}
