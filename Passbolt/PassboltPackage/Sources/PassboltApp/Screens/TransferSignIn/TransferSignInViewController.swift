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

internal final class TransferSignInViewController: PlainViewController, UIComponent {
  
  internal typealias View = AuthorizationView
  internal typealias Controller = TransferSignInController
  
  internal static func instance(
    using controller: Controller,
    with components: UIComponentFactory
  ) -> Self {
    Self(
      using: controller,
      with: components
    )
  }
  
  internal private(set) lazy var contentView: View = .init()
  internal var components: UIComponentFactory
  
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
    mut(navigationItem) {
      .combined(
        .leftBarButtonItem(
          Mutation<UIBarButtonItem>
            .combined(
              .backStyle(),
              .accessibilityIdentifier("button.exit"),
              .action { [weak self] in
                self?.controller.presentExitConfirmation()
              }
            )
            .instantiate()
        ),
        .title(localized: "sign.in.title")
      )
    }
    
    mut(contentView) {
      .backgroundColor(dynamic: .background)
    }
    
    setupSubscriptions()
  }
  
  private func setupSubscriptions() {
    controller
      .accountProfilePublisher()
      .receive(on: RunLoop.main)
      .sink { [weak self] details in
        self?.contentView.applyOn(name: .text("\(details.label)"))
        self?.contentView.applyOn(email: .text(details.username))
        self?.contentView.applyOn(url: .text(details.domain))
        self?.contentView.applyOn(biometricButtonContainer: .hidden(true))
      }
      .store(in: cancellables)
    
    controller
      .accountAvatarPublisher()
      .receive(on: RunLoop.main)
      .sink { [weak self] data in
        guard let imageData = data,
          let image: UIImage = .init(data: imageData) else {
          return
        }
        
        self?.contentView.applyOn(image: .image(image))
      }
      .store(in: cancellables)
    
    contentView
      .secureTextPublisher
      .receive(on: RunLoop.main)
      .sink { [weak self] passphrase in
        self?.controller.updatePassphrase(passphrase)
      }
      .store(in: cancellables)
    
    controller
      .validatedPassphrasePublisher()
      .first() // skipping error just to update intial value
      .map { Validated.valid($0.value) }
      .merge(
        with: controller
          .validatedPassphrasePublisher()
          .dropFirst()
      )
      .receive(on: RunLoop.main)
      .sink { [weak self] validatedPassphrase in
        self?.contentView.update(from: validatedPassphrase)
        self?.contentView.applyOn(
          signInButton: .when(
            validatedPassphrase.isValid,
            then: .enabled(),
            else: .disabled()
          )
        )
      }
      .store(in: cancellables)
    
    controller
      .validatedPassphrasePublisher()
      .map(\.isValid)
      .receive(on: RunLoop.main)
      .sink { [weak self] isValid in
        self?.contentView.applyOn(
          signInButton: .when(
            isValid,
            then: .enabled(),
            else: .disabled()
          )
        )
      }
      .store(in: cancellables)
    
    contentView
      .signInTapPublisher
      .receive(on: RunLoop.main)
      .sink { [weak self] in
        guard let self = self else { return }
        self.controller
          .completeTransfer()
          .receive(on: RunLoop.main)
          .sink(receiveCompletion: { [weak self] completion in
            // swiftlint:disable:next explicit_type_interface
            guard case let .failure(error) = completion
            else { return }
            
            self?.present(
              snackbar: Mutation<UICommons.View>
                .snackBarErrorMessage(localized: "sign.in.error.message")
                .instantiate(),
              hideAfter: 2
            )
          })
          .store(in: self.cancellables)
      }
      .store(in: cancellables)
    
    contentView
      .forgotTapPublisher
      .receive(on: RunLoop.main)
      .sink { [weak self] in
        self?.controller.presentForgotPassphraseAlert()
      }
      .store(in: cancellables)
    
    controller
      .presentForgotPassphraseAlertPublisher()
      .receive(on: RunLoop.main)
      .sink { [weak self] presented in
        guard let self = self else { return }
        
        if presented {
          self.present(ForgotPassphraseAlertViewController.self)
        } else {
          self.dismiss(ForgotPassphraseAlertViewController.self)
        }
      }
      .store(in: cancellables)
    
    controller
      .exitConfirmationPresentationPublisher()
      .receive(on: RunLoop.main)
      .sink { [weak self] presented in
        if presented {
          self?.present(TransferSignInExitConfirmationViewController.self)
        } else {
          self?.dismiss(TransferSignInExitConfirmationViewController.self)
        }
      }
      .store(in: cancellables)
    
    controller
      .resultPresentationPublisher()
      .receive(on: RunLoop.main)
      .sink(receiveCompletion: { [weak self] completion in
        switch completion {
        case .finished:
          self?.push(BiometricsInfoViewController.self)
          
        case .failure(.canceled):
          self?.pop(to: TransferInfoScreenViewController.self)
        // swiftlint:disable:next explicit_type_interface
        case let .failure(error):
          self?.push(
            AccountTransferFailureViewController.self,
            in: error
          )
        }
      })
      .store(in: cancellables)
  }
}