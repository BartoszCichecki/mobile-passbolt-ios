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
import CommonDataModels
import Resources
import UIComponents

public struct ResourceEditController {

  internal var createsNewResource: Bool
  internal var resourcePropertiesPublisher: () -> AnyPublisher<Array<ResourceProperty>, TheError>
  internal var fieldValuePublisher: (ResourceField) -> AnyPublisher<Validated<String>, Never>
  internal var passwordEntropyPublisher: () -> AnyPublisher<Entropy, Never>
  internal var sendForm: () -> AnyPublisher<Void, TheError>
  internal var setValue: (String, ResourceField) -> AnyPublisher<Void, TheError>
  internal var generatePassword: () -> Void
  internal var presentExitConfirmation: () -> Void
  internal var exitConfirmationPresentationPublisher: () -> AnyPublisher<Bool, Never>
  internal var cleanup: () -> Void
}

extension ResourceEditController: UIController {

  public typealias Context = (editedResource: Resource.ID?, completion: (Resource.ID) -> Void)

  public static func instance(
    in context: Context,
    with features: FeatureFactory,
    cancellables: Cancellables
  ) -> Self {

    let diagnostics: Diagnostics = features.instance()
    let resources: Resources = features.instance()
    let resourceForm: ResourceEditForm = features.instance()
    let randomGenerator: RandomStringGenerator = features.instance()

    let resourcePropertiesSubject: CurrentValueSubject<Array<ResourceProperty>, TheError> = .init([])
    let exitConfirmationPresentationSubject: PassthroughSubject<Bool, Never> = .init()

    if let editedResource: Resource.ID = context.editedResource {
      resourceForm
        .editResource(editedResource)
        .sink(
          receiveCompletion: { completion in
            guard case let .failure(error) = completion
            else { return }
            resourcePropertiesSubject.send(completion: .failure(error))
          },
          receiveValue: { /* NOP */  }
        )
        .store(in: cancellables)
    }
    else {
      /* NOP */
    }

    resourceForm
      .resourceTypePublisher()
      .map(\.properties)
      .sink(
        receiveCompletion: { completion in
          resourcePropertiesSubject.send(completion: completion)
        },
        receiveValue: { properties in
          resourcePropertiesSubject.send(properties)
        }
      )
      .store(in: cancellables)

    func resourcePropertiesPublisher() -> AnyPublisher<Array<ResourceProperty>, TheError> {
      resourcePropertiesSubject
        .eraseToAnyPublisher()
    }

    func fieldValuePublisher(field: ResourceField) -> AnyPublisher<Validated<String>, Never> {
      resourceForm
        .fieldValuePublisher(field)
        .map { validatedFieldValue -> Validated<String> in
          Validated<String>(
            value: validatedFieldValue.value.stringValue,
            errors: validatedFieldValue.errors
          )
        }
        .eraseToAnyPublisher()
    }

    func setValue(
      _ value: String,
      for field: ResourceField
    ) -> AnyPublisher<Void, TheError> {
      resourcePropertiesPublisher()
        .map { properties -> AnyPublisher<Void, TheError> in
          guard let property: ResourceProperty = properties.first(where: { $0.field == field })
          else {
            return Fail(error: .invalidOrMissingResourceType())
              .eraseToAnyPublisher()
          }

          return
            resourceForm
            .setFieldValue(.init(fromString: value, forType: property.type), field)
        }
        .switchToLatest()
        .collectErrorLog(using: diagnostics)
        .eraseToAnyPublisher()
    }

    func passwordEntropyPublisher() -> AnyPublisher<Entropy, Never> {
      resourceForm
        .fieldValuePublisher(.password)
        .map { validated in
          randomGenerator.entropy(
            validated.value.stringValue,
            CharacterSets.all
          )
        }
        .eraseToAnyPublisher()
    }

    func sendForm() -> AnyPublisher<Void, TheError> {
      resourceForm
        .sendForm()
        .map { resourceID -> AnyPublisher<Resource.ID, TheError> in
          resources
            .refreshIfNeeded()
            .map { resourceID }
            .eraseToAnyPublisher()
        }
        .switchToLatest()
        .handleEvents(
          receiveOutput: { resourceID in
            context.completion(resourceID)
          },
          receiveCompletion: { completion in
            guard case .finished = completion
            else { return }

            cleanup()
          }
        )
        .mapToVoid()
        .collectErrorLog(using: diagnostics)
        .eraseToAnyPublisher()
    }

    func generatePassword() {
      let password: String = randomGenerator.generate(
        CharacterSets.all,
        18,
        Entropy.veryStrongPassword
      )

      resourceForm
        .setFieldValue(.string(password), .password)
        .sinkDrop()
        .store(in: cancellables)
    }

    func presentExitConfirmation() {
      exitConfirmationPresentationSubject.send(true)
    }

    func exitConfirmationPresentationPublisher() -> AnyPublisher<Bool, Never> {
      exitConfirmationPresentationSubject.eraseToAnyPublisher()
    }

    func cleanup() {
      features.unload(ResourceEditForm.self)
    }

    return Self(
      createsNewResource: context.editedResource == nil,
      resourcePropertiesPublisher: resourcePropertiesPublisher,
      fieldValuePublisher: fieldValuePublisher,
      passwordEntropyPublisher: passwordEntropyPublisher,
      sendForm: sendForm,
      setValue: setValue(_:for:),
      generatePassword: generatePassword,
      presentExitConfirmation: presentExitConfirmation,
      exitConfirmationPresentationPublisher: exitConfirmationPresentationPublisher,
      cleanup: cleanup
    )
  }
}
