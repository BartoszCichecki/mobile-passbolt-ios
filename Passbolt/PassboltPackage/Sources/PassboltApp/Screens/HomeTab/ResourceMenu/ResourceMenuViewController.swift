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
import UIComponents

internal final class ResourceMenuViewController: PlainViewController, UIComponent {

  internal typealias View = ResourceMenuView
  internal typealias Controller = ResourceMenuController

  internal static func instance(
    using controller: Controller,
    with components: UIComponentFactory
  ) -> Self {
    Self(
      using: controller,
      with: components
    )
  }

  internal private(set) var contentView: View = .init()
  internal let components: UIComponentFactory
  private let controller: Controller

  internal init(
    using controller: Controller,
    with components: UIComponentFactory
  ) {
    self.controller = controller
    self.components = components
    super.init()
  }

  internal func setupView() {
    setupSubscriptions()
  }

  private func setupSubscriptions() {
    controller
      .resourceDetailsPublisher()
      .receive(on: RunLoop.main)
      .sink(
        receiveCompletion: { [weak self] completion in
          guard case .failure = completion
          else { return }
          self?.presentingViewController?.presentErrorSnackbar()
          self?.dismiss(ResourceMenuViewController.self)
        },
        receiveValue: { [weak self] resourceDetails in
          self?.title = resourceDetails.name
        }
      )
      .store(in: cancellables)

    controller.availableActionsPublisher()
      .receive(on: RunLoop.main)
      .sink { [weak self] operations in
        self?.contentView.update(operations: operations)
      }
      .store(in: cancellables)

    contentView
      .itemTappedPublisher
      .map { [unowned self] action in
        self.controller
          .performAction(action)
          .receive(on: RunLoop.main)
          .handleEvents(receiveOutput: { [weak self] in
            switch action {
            case .edit, .delete:
              break  // Actions handled elsewhere

            case .openURL:
              self?.dismiss(ResourceMenuViewController.self)

            case .copyURL:
              self?.presentingViewController?.presentInfoSnackbar(
                .localized("resource.menu.item.field.copied"),
                with: [
                  NSLocalizedString("resource.menu.item.url", comment: "")
                ]
              )
              self?.dismiss(ResourceMenuViewController.self)

            case .copyPassword:
              self?.presentingViewController?.presentInfoSnackbar(
                .localized("resource.menu.item.field.copied"),
                with: [
                  NSLocalizedString("resource.menu.item.password", comment: "")
                ]
              )
              self?.dismiss(ResourceMenuViewController.self)

            case .copyUsername:
              self?.presentingViewController?.presentInfoSnackbar(
                .localized("resource.menu.item.field.copied"),
                with: [
                  NSLocalizedString("resource.menu.item.username", comment: "")
                ]
              )
              self?.dismiss(ResourceMenuViewController.self)

            case .copyDescription:
              self?.presentingViewController?.presentInfoSnackbar(
                .localized("resource.menu.item.field.copied"),
                with: [
                  NSLocalizedString("resource.menu.item.description", comment: "")
                ]
              )
              self?.dismiss(ResourceMenuViewController.self)
            }
          })
          .handleErrors(
            ([.canceled, .authorizationRequired], handler: { _ in true /* NOP */ }),
            defaultHandler: { [weak self] _ in
              self?.presentErrorSnackbar()
            }
          )
          .mapToVoid()
          .replaceError(with: Void())
          .eraseToAnyPublisher()
      }
      .switchToLatest()
      .sinkDrop()
      .store(in: cancellables)
  }
}
