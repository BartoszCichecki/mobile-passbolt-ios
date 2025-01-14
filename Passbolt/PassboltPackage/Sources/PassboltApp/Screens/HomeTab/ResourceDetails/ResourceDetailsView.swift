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

import CommonDataModels
import UICommons

internal final class ResourceDetailsView: ScrolledStackView {

  internal var toggleEncryptedFieldTapPublisher: AnyPublisher<ResourceField, Never> {
    toggleEncryptedFieldTapSubject.eraseToAnyPublisher()
  }

  internal var copyFieldNameTapPublisher: AnyPublisher<ResourceField, Never> {
    copyFieldNameTapSubject.eraseToAnyPublisher()
  }

  private let iconView: LetterIconView = .init()
  private let titleLabel: Label = .init()
  private let toggleEncryptedFieldTapSubject: PassthroughSubject<ResourceField, Never> = .init()
  private let copyFieldNameTapSubject: PassthroughSubject<ResourceField, Never> = .init()
  private var fieldUpdates: Dictionary<ResourceField, (Mutation<ResourceDetailsItemView>) -> Void> = [:]

  // Used to identify dynamic items in the stack
  private static let formItemTag: Int = 42

  @available(*, unavailable)
  internal required init?(coder: NSCoder) {
    unreachable("\(Self.self).\(#function) should not be used")
  }

  internal required init() {
    super.init()

    let iconContainer: ContainerView<View> = .init(
      contentView: iconView,
      mutation: .combined(
        .cornerRadius(4, masksToBounds: true)
      )
    )

    mut(iconContainer) {
      .combined(
        .backgroundColor(.clear),
        .heightAnchor(.equalTo, constant: 60)
      )
    }

    mut(iconView) {
      .combined(
        .heightAnchor(.equalTo, constant: 60),
        .widthAnchor(.equalTo, constant: 60)
      )
    }

    mut(titleLabel) {
      .combined(
        .textColor(dynamic: .primaryText),
        .font(.inter(ofSize: 24, weight: .semibold)),
        .textAlignment(.center)
      )
    }

    mut(self) {
      .combined(
        .backgroundColor(dynamic: .background),
        .isLayoutMarginsRelativeArrangement(true),
        .contentInset(.init(top: 24, left: 16, bottom: 8, right: 16)),
        .append(iconContainer),
        .appendSpace(of: 8),
        .append(titleLabel),
        .appendSpace(of: 32)
      )
    }
  }

  internal func update(with config: ResourceDetailsController.ResourceDetailsWithConfig) {
    removeAllArrangedSubviews(withTag: Self.formItemTag)
    fieldUpdates.removeAll()

    let resourceDetails: ResourceDetailsController.ResourceDetails = config.resourceDetails

    iconView.update(from: resourceDetails.name)
    titleLabel.text = resourceDetails.name

    let setupSteps: Array<FieldSetup> = resourceDetails.properties.compactMap { property in
      let encryptedPlaceholder: String = .init(repeating: "*", count: 10)

      let contentButtonMutation: Mutation<ResourceDetailsItemView>
      let titleMutation: Mutation<Label>
      let valueMutation: Mutation<TextView>
      let accessoryButtonMutation: Mutation<ImageButton>

      switch property.field {
      case .name:
        return nil

      case .username:
        contentButtonMutation = .action { [weak self] in
          self?.copyFieldNameTapSubject.send(property.field)
        }
        titleMutation = .text(localized: "resource.detail.field.username", inBundle: .commons)
        valueMutation = .combined(
          .userInteractionEnabled(false),
          .when(
            property.encrypted,
            then: .text(encryptedPlaceholder),
            else: .text(resourceDetails.username ?? "")
          )
        )
        accessoryButtonMutation = .combined(
          .image(named: .copy, from: .uiCommons),
          .action { [weak self] in
            self?.copyFieldNameTapSubject.send(property.field)
          }
        )

      case .password:
        contentButtonMutation = .action { [weak self] in
          self?.copyFieldNameTapSubject.send(property.field)
        }
        titleMutation = .text(localized: "resource.detail.field.passphrase", inBundle: .commons)
        valueMutation = .combined(
          .userInteractionEnabled(false),
          .when(
            property.encrypted,
            then: .text(encryptedPlaceholder),
            else: .text("")
          )
        )

        if config.revealPasswordEnabled {
          accessoryButtonMutation = .when(
            property.encrypted,
            then:
              .combined(
                .image(named: .eye, from: .uiCommons),
                .action { [weak self] in
                  self?.toggleEncryptedFieldTapSubject.send(property.field)
                }
              ),
            else: .hidden(true)
          )
        }
        else {
          accessoryButtonMutation = .hidden(true)
        }
      case .uri:
        contentButtonMutation = .action { [weak self] in
          self?.copyFieldNameTapSubject.send(property.field)
        }
        titleMutation = .text(localized: "resource.detail.field.uri", inBundle: .commons)
        valueMutation = .combined(
          .userInteractionEnabled(true),
          .when(
            property.encrypted,
            then: .text(encryptedPlaceholder),
            else: .attributedString(
              .string(
                resourceDetails.url ?? "",
                attributes: .init(
                  font: .inter(ofSize: 14, weight: .medium),
                  color: .primaryBlue,
                  isLink: true
                ),
                tail: .terminator
              )
            )
          )
        )

        accessoryButtonMutation = .combined(
          .image(named: .copy, from: .uiCommons),
          .action { [weak self] in
            self?.copyFieldNameTapSubject.send(property.field)
          }
        )

      case .description:
        contentButtonMutation = .action { [weak self] in
          self?.copyFieldNameTapSubject.send(property.field)
        }
        titleMutation = .text(localized: "resource.detail.field.description", inBundle: .commons)
        valueMutation = .combined(
          .combined(
            .userInteractionEnabled(false),
            .when(
              property.encrypted,
              then: .text(encryptedPlaceholder),
              else: .text(resourceDetails.description ?? "")
            )
          )
        )
        accessoryButtonMutation = .when(
          property.encrypted,
          then:
            .combined(
              .image(named: .eye, from: .uiCommons),
              .action { [weak self] in
                self?.toggleEncryptedFieldTapSubject.send(property.field)
              }
            ),
          else: .hidden(true)
        )

      case let .undefined(name):
        assertionFailure("Undefined resource field \(name)")
        return nil
      }

      return .init(
        field: property.field,
        contentButtonMutation: contentButtonMutation,
        titleMutation: titleMutation,
        valueMutation: valueMutation,
        accessoryButtonMutation: accessoryButtonMutation
      )
    }

    typealias ItemWithUpdate = (
      itemView: ResourceDetailsItemView,
      fieldUpdate: (Mutation<ResourceDetailsItemView>) -> Void
    )

    let fieldViews: Array<ItemWithUpdate> = setupSteps.map { setup in
      let itemView: ResourceDetailsItemView = .init(field: setup.field)
      itemView.tag = Self.formItemTag

      let fieldUpdate: (Mutation<ResourceDetailsItemView>) -> Void = { itemMutation in
        itemMutation.apply(on: itemView)
      }

      Mutation.combined(
        setup.contentButtonMutation.contramap(\ResourceDetailsItemView.self),
        setup.titleMutation.contramap(\ResourceDetailsItemView.titleLabel),
        setup.valueMutation.contramap(\ResourceDetailsItemView.valueTextView),
        setup.accessoryButtonMutation.contramap(\ResourceDetailsItemView.accessoryButton)
      )
      .apply(on: itemView)

      return (itemView: itemView, fieldUpdate: fieldUpdate)
    }

    fieldViews.forEach { itemWithUpdate in
      fieldUpdates[itemWithUpdate.itemView.field] = itemWithUpdate.fieldUpdate
    }

    mut(self) {
      .forEach(
        in: fieldViews,
        { itemWithUpdate in
          .combined(
            .append(itemWithUpdate.itemView),
            .appendSpace(of: 16, tag: Self.formItemTag)
          )
        }
      )
    }
  }

  internal func applyOn(
    field: ResourceField,
    buttonMutation: Mutation<ImageButton>,
    valueTextViewMutation: Mutation<TextView>
  ) {
    guard let itemViewUpdate = fieldUpdates[field]
    else { return }

    itemViewUpdate(
      .combined(
        buttonMutation.contramap(\ResourceDetailsItemView.accessoryButton),
        valueTextViewMutation.contramap(\ResourceDetailsItemView.valueTextView)
      )
    )
  }
}

internal final class ResourceDetailsItemView: Button {

  fileprivate var field: ResourceField
  fileprivate var titleLabel: Label = .init()
  fileprivate var valueTextView: TextView = .init()
  fileprivate var accessoryButton: ImageButton = .init()

  @available(*, unavailable)
  internal required init?(coder: NSCoder) {
    unreachable("\(Self.self).\(#function) should not be used")
  }

  @available(*, unavailable, message: "Use init(fieldName:)")
  internal required init() {
    unreachable("\(Self.self).\(#function) should not be used")
  }

  internal init(field: ResourceField) {
    self.field = field
    super.init()

    mut(self) {
      .combined(
        .backgroundColor(dynamic: .background),
        .subview(titleLabel, valueTextView, accessoryButton),
        .heightAnchor(.greaterThanOrEqualTo, constant: 52)
      )
    }

    mut(titleLabel) {
      .combined(
        .leadingAnchor(.equalTo, leadingAnchor),
        .trailingAnchor(.equalTo, accessoryButton.leadingAnchor, constant: -8),
        .topAnchor(.equalTo, topAnchor, constant: 4),
        .bottomAnchor(.equalTo, valueTextView.topAnchor, constant: -8),
        .textColor(dynamic: .primaryText),
        .font(.inter(ofSize: 12, weight: .semibold))
      )
    }

    mut(valueTextView) {
      .combined(
        .leadingAnchor(.equalTo, titleLabel.leadingAnchor),
        .trailingAnchor(.equalTo, titleLabel.trailingAnchor),
        .heightAnchor(.greaterThanOrEqualTo, constant: 20),
        .bottomAnchor(.equalTo, bottomAnchor, constant: -8),
        .textColor(dynamic: .secondaryText),
        .lineBreakMode(.byWordWrapping),
        .font(.inter(ofSize: 14, weight: .medium)),
        .set(\.contentInset, to: .zero),
        .set(\.textContainerInset, to: .init(top: 0, left: -5, bottom: 0, right: 0)),
        .set(\.isScrollEnabled, to: false),
        .set(\.isEditable, to: false)
      )
    }

    mut(accessoryButton) {
      .combined(
        .trailingAnchor(.equalTo, trailingAnchor),
        .centerYAnchor(.equalTo, centerYAnchor),
        .widthAnchor(.equalTo, constant: 32),
        .heightAnchor(.equalTo, constant: 32),
        .tintColor(dynamic: .iconAlternative),
        .imageContentMode(.scaleAspectFit),
        .imageInsets(.init(top: 4, left: 4, bottom: -4, right: -4))
      )
    }
  }
}

fileprivate struct FieldSetup {

  fileprivate var field: ResourceField
  fileprivate var contentButtonMutation: Mutation<ResourceDetailsItemView>
  fileprivate var titleMutation: Mutation<Label>
  fileprivate var valueMutation: Mutation<TextView>
  fileprivate var accessoryButtonMutation: Mutation<ImageButton>
}
