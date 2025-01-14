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

import struct AegithalosCocoa.LocalizationKeyConstant
import class Foundation.Bundle
import func Foundation.NSLocalizedString

public enum DisplayableString {

  case raw(String)
  case localized(LocalizedString)
}

extension DisplayableString: Hashable {}

extension DisplayableString: ExpressibleByStringInterpolation {

  public init(stringLiteral string: String) {
    self = .raw(string)
  }
}

extension DisplayableString {

  public static func localized(
    key: LocalizedString.Key,
    tableName: String? = .none,
    bundle: Bundle = .main,
    arguments: Array<CVarArg> = .init()
  ) -> Self {
    .localized(
      .init(
        key: key,
        tableName: tableName,
        bundle: bundle,
        arguments: arguments
      )
    )
  }

  public func string(
    with arguments: Array<CVarArg> = .init(),
    localizaton: @escaping (_ key: LocalizationKeyConstant, _ tableName: String?, _ bundle: Bundle) -> String = {
      (key: LocalizationKeyConstant, tableName: String?, bundle: Bundle) -> String in
      NSLocalizedString(
        key.rawValue,
        tableName: tableName,
        bundle: bundle,
        comment: ""
      )
    }
  ) -> String {
    switch self {
    case let .raw(string):
      if arguments.isEmpty {
        return string
      }
      else {
        return String(
          format: string,
          arguments: arguments
        )
      }

    case let .localized(localizedString):
      return
        localizedString
        .resolve(
          with: arguments,
          localizaton: localizaton
        )
    }
  }
}
