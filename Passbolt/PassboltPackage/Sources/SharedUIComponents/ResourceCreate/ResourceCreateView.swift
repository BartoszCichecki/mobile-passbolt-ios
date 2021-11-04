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
import Commons
import Features
import UICommons

public final class ResourceCreateView: KeyboardAwareView {

  internal typealias FieldWithView = (field: ResourceField, view: View)

  internal var generateTapPublisher: AnyPublisher<Void, Never> { generateButton.tapPublisher }
  internal var lockTapPublisher: AnyPublisher<Void, Never> { lockButton.tapPublisher }
  internal var createTapPublisher: AnyPublisher<Void, Never> { createButton.tapPublisher }

  internal var lockAnchor: UIView { lockButton }

  private let scrolledStack: ScrolledStackView = .init()
  private let entropyView: EntropyView = .init()
  private let generateButton: ImageButton = .init()
  private let lockButton: ImageButton = .init()
  private let createButton: TextButton = .init()

  private var fieldViews: Dictionary<ResourceField, View> = .init()

  internal required init() {
    super.init()

    mut(scrolledStack) {
      .combined(
        .subview(of: self),
        .leadingAnchor(.equalTo, leadingAnchor),
        .trailingAnchor(.equalTo, trailingAnchor),
        .topAnchor(.equalTo, topAnchor),
        .bottomAnchor(.equalTo, keyboardSafeAreaLayoutGuide.bottomAnchor),
        .isLayoutMarginsRelativeArrangement(true),
        .contentInset(.init(top: 0, left: 16, bottom: 16, right: 16)),
        .backgroundColor(dynamic: .background)
      )
    }

    mut(createButton) {
      .combined(
        .primaryStyle(),
        .text(localized: "resource.form.create.button.title", inBundle: .commons)
      )
    }

    mut(lockButton) {
      .combined(
        .enabled(),
        .image(named: .lock, from: .uiCommons),
        .tintColor(dynamic: .iconAlternative),
        .aspectRatio(1),
        .widthAnchor(.equalTo, constant: 14)
      )
    }

    mut(generateButton) {
      .combined(
        .imageContentMode(.center),
        .imageInsets(.init(top: 8, left: 8, bottom: -8, right: -8)),
        .image(named: .magicWand, from: .uiCommons),
        .tintColor(dynamic: .iconAlternative),
        .backgroundColor(dynamic: .divider),
        .border(dynamic: .divider, width: 1),
        .cornerRadius(4)
      )
    }
  }

  internal func update(with properties: Array<ResourceProperty>) {
    fieldViews =
      properties
      .compactMap { resourceProperty -> (ResourceField, View)? in
        switch resourceProperty.field {
        case .name:
          return (
            field: resourceProperty.field,
            view: Mutation<TextInput>
              .combined(
                .backgroundColor(dynamic: .background),
                .isRequired(resourceProperty.required),
                .custom { (input: TextInput) in
                  input.applyOn(
                    text: .combined(
                      .primaryStyle(),
                      .attributedPlaceholderString(
                        .localized(
                          "resource.create.name.field.placeholder",
                          inBundle: .main,
                          font: .inter(ofSize: 14, weight: .medium),
                          color: .secondaryText
                        )
                      )
                    )
                  )
                  input.applyOn(
                    description: .text(localized: "resource.create.field.name.label", inBundle: .main)
                  )
                }
              )
              .instantiate()
          )

        case .uri:
          return (
            field: resourceProperty.field,
            view: Mutation<TextInput>
              .combined(
                .backgroundColor(dynamic: .background),
                .isRequired(resourceProperty.required),
                .custom { (input: TextInput) in
                  input.applyOn(
                    text: .combined(
                      .primaryStyle(),
                      .attributedPlaceholderString(
                        .localized(
                          "resource.create.url.field.placeholder",
                          inBundle: .main,
                          font: .inter(ofSize: 14, weight: .medium),
                          color: .secondaryText
                        )
                      )
                    )
                  )
                  input.applyOn(
                    description: .text(localized: "resource.create.field.url.label", inBundle: .main)
                  )
                }
              )
              .instantiate()
          )

        case .username:
          return (
            field: resourceProperty.field,
            view: Mutation<TextInput>
              .combined(
                .backgroundColor(dynamic: .background),
                .isRequired(resourceProperty.required),
                .custom { (input: TextInput) in
                  input.applyOn(
                    text: .combined(
                      .primaryStyle(),
                      .attributedPlaceholderString(
                        .localized(
                          "resource.create.username.field.placeholder",
                          inBundle: .main,
                          font: .inter(ofSize: 14, weight: .medium),
                          color: .secondaryText
                        )
                      )
                    )
                  )
                  input.applyOn(
                    description: .text(localized: "resource.create.field.username.label", inBundle: .main)
                  )
                }
              )
              .instantiate()
          )

        case .password:
          return (
            field: resourceProperty.field,
            view: Mutation<SecureTextInput>
              .combined(
                .backgroundColor(dynamic: .background),
                .isRequired(resourceProperty.required),
                .custom { (input: TextInput) in
                  input.applyOn(
                    text: .combined(
                      .primaryStyle(),
                      .attributedPlaceholderString(
                        .localized(
                          "resource.create.password.field.placeholder",
                          inBundle: .main,
                          font: .inter(ofSize: 14, weight: .medium),
                          color: .secondaryText
                        )
                      )
                    )
                  )
                  input.applyOn(
                    description: .text(localized: "resource.create.field.password.label", inBundle: .main)
                  )
                }
              )
              .instantiate()
          )

        case .description:
          return (
            field: resourceProperty.field,
            view: Mutation<TextViewInput>
              .combined(
                .isRequired(resourceProperty.required),
                .attributedPlaceholder(
                  .localized(
                    "resource.create.description.field.placeholder",
                    inBundle: .main,
                    font: .inter(ofSize: 14, weight: .medium),
                    color: .secondaryText
                  )
                ),
                .isRequired(false),
                .custom { (input: TextViewInput) in
                  input.applyOn(
                    text: .formStyle()
                  )
                  input.applyOn(
                    description: .text(localized: "resource.create.field.description.label", inBundle: .main)
                  )
                }
              )
              .instantiate()
          )

        case let .undefined(name):
          assertionFailure("Undefined field: \(name)")
          return nil
        }
      }
      .reduce(
        into: Dictionary<ResourceField, View>(),
        { (partialResult, fieldWithView: FieldWithView) in
          partialResult[fieldWithView.field] = fieldWithView.view
        }
      )

    scrolledStack.removeAllArrangedSubviews()

    mut(scrolledStack) {
      .combined(
        .forEach(
          in: fieldViews.sorted { $0.key < $1.key },
          { [unowned self] fieldView in
            switch fieldView.key {
            case .password:
              let container: View =
                Mutation
                .combined(
                  .backgroundColor(dynamic: .background)
                )
                .instantiate()

              mut(fieldView.value) {
                .combined(
                  .subview(of: container),
                  .leadingAnchor(.equalTo, container.leadingAnchor),
                  .trailingAnchor(.equalTo, container.trailingAnchor, constant: -60),
                  .topAnchor(.equalTo, container.topAnchor)
                )
              }

              let textFieldCenterYAnchor: NSLayoutYAxisAnchor =
                (fieldView.value as? TextInput)?.textFieldCenterYAnchor ?? fieldView.value.centerYAnchor

              mut(self.generateButton) {
                .combined(
                  .subview(of: container),
                  .trailingAnchor(.equalTo, container.trailingAnchor),
                  .centerYAnchor(.equalTo, textFieldCenterYAnchor),
                  .widthAnchor(.equalTo, constant: 48),
                  .aspectRatio(1)
                )
              }

              mut(self.entropyView) {
                .combined(
                  .subview(of: container),
                  .leadingAnchor(.equalTo, container.leadingAnchor),
                  .trailingAnchor(.equalTo, fieldView.value.trailingAnchor),
                  .topAnchor(.equalTo, fieldView.value.bottomAnchor),
                  .bottomAnchor(.equalTo, container.bottomAnchor)
                )
              }

              return .combined(
                .append(container),
                .appendSpace(of: 4)
              )

            case .description:
              if let textViewInput = fieldView.value as? TextViewInput {
                textViewInput.set(
                  accessory: self.lockButton,
                  with: .zero
                )
              }

              fallthrough
            case _:
              return .combined(
                .append(fieldView.value),
                .appendSpace(of: 4)
              )
            }
          }
        ),
        .appendFiller(minSize: 20),
        .append(createButton)
      )
    }
  }

  internal func update(
    validated: Validated<String>,
    for field: ResourceField
  ) {
    guard let fieldView: View = fieldViews.first(where: { $0.key == field })?.value
    else {
      assertionFailure("Missing field for key: \(field)")
      return
    }

    switch field {
    case .name, .uri, .username, .password:
      guard let textInput: TextInput = fieldView as? TextInput
      else {
        assertionFailure("Field is not a TextInput")
        return
      }

      textInput.update(from: validated)
    case .description:
      guard let textViewInput: TextViewInput = fieldView as? TextViewInput
      else {
        assertionFailure("Field is not a TextViewInput")
        return
      }

      textViewInput.update(from: validated)
    case let .undefined(name):
      return assertionFailure("Undefined field: \(name)")
    }
  }

  internal func fieldValuePublisher(
    for field: ResourceField
  ) -> AnyPublisher<String, Never> {
    guard let fieldView: View = fieldViews.first(where: { $0.key == field })?.value
    else {
      return Empty(completeImmediately: true)
        .eraseToAnyPublisher()
    }

    switch field {
    case .name, .uri, .username, .password:
      guard let textInput: TextInput = fieldView as? TextInput
      else {
        return Empty(completeImmediately: true)
          .eraseToAnyPublisher()
      }

      return textInput.textPublisher

    case .description:
      guard let textViewInput: TextViewInput = fieldView as? TextViewInput
      else {
        return Empty(completeImmediately: true)
          .eraseToAnyPublisher()
      }

      return textViewInput.textPublisher

    case let .undefined(name):
      assertionFailure("Undefined field: \(name)")
      return Empty(completeImmediately: true)
        .eraseToAnyPublisher()
    }
  }

  internal func update(entropy: Entropy) {
    entropyView.update(entropy: entropy)
  }
}