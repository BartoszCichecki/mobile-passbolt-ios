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

import UIComponents

internal final class TransferInfoCameraRequiredAlertViewController:
  AlertViewController<TransferInfoCameraRequiredAlertController>, UIComponent
{

  internal func setup() {
    mut(self) {
      .combined(
        .title(localized: "transfer.account.camera.access.alert.title"),
        .message(localized: "transfer.account.camera.access.alert.text"),
        .action(
          localized: .cancel,
          inBundle: .commons,
          accessibilityIdentifier: "alert.button.cancel",
          handler: {}
        ),
        .action(
          localized: .settings,
          inBundle: .commons,
          accessibilityIdentifier: "alert.button.dismiss",
          handler: controller.showSettings
        )
      )
    }
  }
}

internal struct TransferInfoCameraRequiredAlertController {

  internal var showSettings: () -> Void
}

extension TransferInfoCameraRequiredAlertController: UIController {

  internal typealias Context = Void

  internal static func instance(
    in context: Context,
    with features: FeatureFactory,
    cancellables: Cancellables
  ) -> Self {
    let linkOpener: LinkOpener = features.instance()
    var cancellable: AnyCancellable?
    _ = cancellable  // silence warning

    return Self(
      showSettings: { cancellable = linkOpener.openAppSettings().sink { _ in } }
    )
  }
}
