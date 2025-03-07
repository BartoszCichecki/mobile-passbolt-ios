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
import Crypto
import NetworkClient
import UIComponents

public struct AuthorizationController {

  public var accountWithProfilePublisher: () -> AnyPublisher<AccountWithProfile, Never>
  public var accountAvatarPublisher: () -> AnyPublisher<Data?, Never>
  public var updatePassphrase: (String) -> Void
  public var validatedPassphrasePublisher: () -> AnyPublisher<Validated<String>, Never>
  public var biometricStatePublisher: () -> AnyPublisher<BiometricsState, Never>
  // returns true if MFA authorization screen should be displayed
  public var signIn: () -> AnyPublisher<Bool, TheError>
  // returns true if MFA authorization screen should be displayed
  public var biometricSignIn: () -> AnyPublisher<Bool, TheError>
  public var presentForgotPassphraseAlert: () -> Void
  public var presentForgotPassphraseAlertPublisher: () -> AnyPublisher<Bool, Never>
  public var accountNotFoundScreenPresentationPublisher: () -> AnyPublisher<Account, Never>
}

extension AuthorizationController {

  public enum BiometricsState {

    case unavailable
    case faceID
    case touchID
  }
}

extension AuthorizationController: UIController {

  public typealias Context = Account

  public static func instance(
    in context: Context,
    with features: FeatureFactory,
    cancellables: Cancellables
  ) -> Self {
    let accountSettings: AccountSettings = features.instance()
    let accountSession: AccountSession = features.instance()
    let biometry: Biometry = features.instance()
    let diagnostics: Diagnostics = features.instance()
    let networkClient: NetworkClient = features.instance()

    let passphraseSubject: CurrentValueSubject<String, Never> = .init("")
    let forgotAlertPresentationSubject: PassthroughSubject<Bool, Never> = .init()
    let accountNotFoundScreenPresentationSubject: PassthroughSubject<Account, Never> = .init()
    let validator: Validator<String> = .nonEmpty(
      displayable: .localized(
        key: "authorization.passphrase.error",
        bundle: .commons
      )
    )

    let account: Account = context
    let accountWithProfileSubject: CurrentValueSubject<AccountWithProfile, Never> = .init(
      accountSettings.accountWithProfile(account)
    )

    accountSettings
      .updatedAccountIDsPublisher()
      .filter { $0 == account.localID }
      .sink { _ in
        accountWithProfileSubject
          .send(
            accountSettings
              .accountWithProfile(account)
          )
      }
      .store(in: cancellables)

    func accountWithProfilePublisher() -> AnyPublisher<AccountWithProfile, Never> {
      accountWithProfileSubject.eraseToAnyPublisher()
    }

    func accountAvatarPublisher() -> AnyPublisher<Data?, Never> {
      accountWithProfileSubject
        .map { accountWithProfile in
          networkClient.mediaDownload.make(using: .init(urlString: accountWithProfile.avatarImageURL))
            .collectErrorLog(using: diagnostics)
            .map { data -> Data? in data }
            .replaceError(with: nil)
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }

    func updatePassphrase(_ passphrase: String) {
      passphraseSubject.send(passphrase)
    }

    func validatedPassphrasePublisher() -> AnyPublisher<Validated<String>, Never> {
      passphraseSubject
        .map(validator.validate)
        .eraseToAnyPublisher()
    }

    func biometricStatePublisher() -> AnyPublisher<BiometricsState, Never> {
      Publishers.CombineLatest(
        biometry
          .biometricsStatePublisher(),
        accountWithProfileSubject
      )
      .map { biometricsState, accountWithProfile in
        switch (biometricsState, accountWithProfile.biometricsEnabled) {
        case (.unavailable, _), (.unconfigured, _), (.configuredTouchID, false), (.configuredFaceID, false):
          return .unavailable

        case (.configuredTouchID, true):
          return .touchID

        case (.configuredFaceID, true):
          return .faceID
        }
      }
      .eraseToAnyPublisher()
    }

    func performSignIn() -> AnyPublisher<Bool, TheError> {
      passphraseSubject
        .first()
        .map { passphrase in
          accountSession.authorize(
            account,
            .passphrase(.init(rawValue: passphrase))
          )
        }
        .switchToLatest()
        .collectErrorLog(using: diagnostics)
        .handleErrors(
          (
            [.notFound],
            handler: { _ in
              accountNotFoundScreenPresentationSubject.send(context)
              return true
            }
          ),
          defaultHandler: { _ in /* NOP */ }
        )
        .eraseToAnyPublisher()
    }

    func performBiometricSignIn() -> AnyPublisher<Bool, TheError> {
      accountSession
        .authorize(
          account,
          .biometrics
        )
        .collectErrorLog(using: diagnostics)
        .handleErrors(
          (
            [.notFound],
            handler: { _ in
              accountNotFoundScreenPresentationSubject.send(context)
              return true
            }
          ),
          defaultHandler: { _ in /* NOP */ }
        )
        .eraseToAnyPublisher()
    }

    func presentForgotPassphraseAlert() {
      forgotAlertPresentationSubject.send(true)
    }

    func presentForgotPassphraseAlertPublisher() -> AnyPublisher<Bool, Never> {
      forgotAlertPresentationSubject.eraseToAnyPublisher()
    }

    func accountNotFoundScreenPresentationPublisher() -> AnyPublisher<Account, Never> {
      accountNotFoundScreenPresentationSubject.eraseToAnyPublisher()
    }

    return Self(
      accountWithProfilePublisher: accountWithProfilePublisher,
      accountAvatarPublisher: accountAvatarPublisher,
      updatePassphrase: updatePassphrase,
      validatedPassphrasePublisher: validatedPassphrasePublisher,
      biometricStatePublisher: biometricStatePublisher,
      signIn: performSignIn,
      biometricSignIn: performBiometricSignIn,
      presentForgotPassphraseAlert: presentForgotPassphraseAlert,
      presentForgotPassphraseAlertPublisher: presentForgotPassphraseAlertPublisher,
      accountNotFoundScreenPresentationPublisher: accountNotFoundScreenPresentationPublisher
    )
  }
}
