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

import Accounts
import Commons
import NetworkClient
import UIComponents

internal struct AccountDetailsController {

  internal var currentAccountWithProfile: AccountWithProfile
  internal var currentAcountAvatarImagePublisher: () -> AnyPublisher<Data?, Never>
  internal var updateCurrentAccountLabel: (String) -> Void
  internal var validatedAccountLabelPublisher: () -> AnyPublisher<Validated<String>, Never>
  internal var saveChanges: () -> AnyPublisher<Void, TheError>
}

extension AccountDetailsController: UIController {

  internal typealias Context = AccountWithProfile

  internal static func instance(
    in context: Context,
    with features: FeatureFactory,
    cancellables: Cancellables
  ) -> Self {
    let networkClient: NetworkClient = features.instance()
    let accountSettings: AccountSettings = features.instance()

    let accountLabelValidator: Validator<String> =
      .maxLength(
        80,
        displayable: .localized(
          key: "form.field.error.max.length",
          bundle: .commons
        )
      )

    let currentAccountLabelSubject: CurrentValueSubject<Validated<String>, Never> = .init(
      accountLabelValidator.validate(context.label)
    )

    func updateCurrentAccountLabel(_ updated: String) {
      currentAccountLabelSubject
        .send(
          accountLabelValidator
            .validate(updated)
        )
    }

    func validatedAccountLabelPublisher() -> AnyPublisher<Validated<String>, Never> {
      currentAccountLabelSubject
        .eraseToAnyPublisher()
    }

    func currentAcountAvatarImagePublisher() -> AnyPublisher<Data?, Never> {
      networkClient
        .mediaDownload
        .make(using: .init(urlString: context.avatarImageURL))
        .mapToOptional()
        .replaceError(with: nil)
        .eraseToAnyPublisher()
    }

    func saveChanges() -> AnyPublisher<Void, TheError> {
      currentAccountLabelSubject
        .first()
        .setFailureType(to: TheError.self)
        .flatMapResult { validatedLabel -> Result<Void, TheError> in
          let label: String
          if validatedLabel.value.isEmpty {
            label = "\(context.firstName) \(context.lastName)"
          }
          else if validatedLabel.isValid {
            label = validatedLabel.value
          }
          else {
            return .failure(
              .validationError(
                displayable: .localized(
                  key: "form.error.invalid",
                  bundle: .commons
                )
              )
            )
          }
          return
            accountSettings
            .setAccountLabel(label, context.account)
        }
        .eraseToAnyPublisher()
    }

    return Self(
      currentAccountWithProfile: context,
      currentAcountAvatarImagePublisher: currentAcountAvatarImagePublisher,
      updateCurrentAccountLabel: updateCurrentAccountLabel(_:),
      validatedAccountLabelPublisher: validatedAccountLabelPublisher,
      saveChanges: saveChanges
    )
  }
}
