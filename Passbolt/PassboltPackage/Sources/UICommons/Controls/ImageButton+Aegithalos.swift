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

import AegithalosCocoa

extension Mutation where Subject: ImageButton {

  public static func dynamicImage(dynamic image: DynamicImage) -> Self {
    .custom { (subject: Subject) in subject.dynamicImage = image }
  }

  public static func pressedDynamicImage(dynamic image: DynamicImage) -> Self {
    .custom { (subject: Subject) in subject.dynamicPressedImage = image }
  }

  public static func disabledDynamicImage(dynamic image: DynamicImage) -> Self {
    .custom { (subject: Subject) in subject.dynamicDisabledImage = image }
  }

  public static func image(symbol name: SymbolNameConstant) -> Self {
    .custom { (subject: Subject) in
      subject.dynamicImage = .default(UIImage(systemName: name.rawValue))
    }
  }

  @inlinable public static func image(
    named imageName: ImageNameConstant,
    from bundle: Bundle? = nil,
    compatibleWith traitCollection: UITraitCollection? = nil
  ) -> Self {
    Self { (subject: Subject) in
      let image: UIImage? = UIImage(
        named: imageName.rawValue,
        in: bundle,
        compatibleWith: traitCollection
      )

      subject.dynamicImage = .default(image)
    }
  }

  public static func imageInsets(
    _ value: UIEdgeInsets
  ) -> Self {
    .custom { (subject: Subject) in
      subject.imageInsets = value
    }
  }

  public static func imageContentMode(
    _ value: UIView.ContentMode
  ) -> Self {
    .custom { (subject: Subject) in
      subject.imageContentMode = value
    }
  }

}
