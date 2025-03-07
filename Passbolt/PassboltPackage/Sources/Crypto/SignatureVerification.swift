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
import Commons
import Foundation
import Security

public struct SignatureVerfication {

  // Verify message signature
  public var verify:
    (
      _ input: Data,
      _ signature: Data,
      _ key: PEMRSAPublicKey
    ) -> Result<Void, TheError>
}

extension SignatureVerfication {

  public static func rssha256() -> Self {
    Self { input, signature, pemKey in

      let key: Data? = pemKey
        .rawValue
        .replacingOccurrences(
          of: "\r",
          with: ""
        )
        .split(
          separator: "\n"
        )
        .filter {
          !($0.trimmingCharacters(
            in: .whitespacesAndNewlines
          )
          .isEmpty  // remove empty lines
            || $0.hasPrefix("-----")  // remove header and footer
            || $0.contains(":")  // remove header values
            )
        }
        .joined(separator: "")
        .base64DecodeFromURLEncoded()

      guard let key: Data = key
      else { return .failure(.invalidInputDataError()) }

      var error: Unmanaged<CFError>?
      guard
        !input.isEmpty,
        !signature.isEmpty
      else {
        return .failure(.invalidInputDataError())
      }

      let inputData: CFData = input as CFData
      let signatureData: CFData = signature as CFData

      guard
        let secKey: SecKey = SecKeyCreateWithData(
          key as CFData,
          [
            kSecAttrType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
          ] as CFDictionary,
          &error
        ),
        error == nil
      else { return Result.failure(.signatureError(error?.takeRetainedValue())) }

      let isValid: Bool = SecKeyVerifySignature(
        secKey,
        .rsaSignatureMessagePKCS1v15SHA256,
        inputData,
        signatureData,
        &error
      )

      guard isValid, error == nil else {
        return Result.failure(.signatureError(error?.takeRetainedValue()))
      }

      return .success
    }
  }
}

#if DEBUG
extension SignatureVerfication {

  public static var placeholder: Self {
    Self(
      verify: Commons.placeholder("You have to provide mocks for used methods")
    )
  }
}

#endif
