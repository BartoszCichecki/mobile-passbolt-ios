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

public struct HelpMenuController {

  public var actions: () -> Array<Action>
  public var logsPresentationPublisher: () -> AnyPublisher<Void, Never>
  public var websiteHelpPresentationPublisher: () -> AnyPublisher<Void, Never>
}

extension HelpMenuController: UIController {

  public struct Action {

    public let iconName: ImageNameConstant
    public let iconBundle: Bundle
    public let title: DisplayableString
    public let handler: () -> Void

    public init(
      iconName: ImageNameConstant,
      iconBundle: Bundle,
      title: DisplayableString,
      handler: @escaping () -> Void
    ) {
      self.iconName = iconName
      self.iconBundle = iconBundle
      self.title = title
      self.handler = handler
    }
  }

  public typealias Context = Array<Action>

  public static func instance(
    in context: Context,
    with features: FeatureFactory,
    cancellables: Cancellables
  ) -> Self {
    let linkOpener: LinkOpener = features.instance()

    let logsPresentationSubject: PassthroughSubject<Void, Never> = .init()
    let websiteHelpPresentationSubject: PassthroughSubject<Void, Never> = .init()

    func actions() -> Array<Action> {
      context + [
        .init(
          iconName: .bug,
          iconBundle: .uiCommons,
          title: .localized(
            key: "help.menu.show.logs.action.title",
            bundle: .sharedUIComponents
          ),
          handler: logsPresentationSubject.send
        ),
        .init(
          iconName: .open,
          iconBundle: .uiCommons,
          title: .localized(
            key: "help.menu.show.web.help.action.title",
            bundle: .sharedUIComponents
          ),
          handler: websiteHelpPresentationSubject.send
        ),
      ]
    }

    func logsPresentationPublisher() -> AnyPublisher<Void, Never> {
      logsPresentationSubject
        .eraseToAnyPublisher()
    }

    // swift-format-ignore: NeverForceUnwrap
    func websiteHelpPresentationPublisher() -> AnyPublisher<Void, Never> {
      websiteHelpPresentationSubject
        .map { _ -> AnyPublisher<Void, Never> in
          linkOpener
            .openLink(URL(string: "https://help.passbolt.com")!)
            .mapToVoid()
            .eraseToAnyPublisher()
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }

    return Self(
      actions: actions,
      logsPresentationPublisher: logsPresentationPublisher,
      websiteHelpPresentationPublisher: websiteHelpPresentationPublisher
    )
  }
}
