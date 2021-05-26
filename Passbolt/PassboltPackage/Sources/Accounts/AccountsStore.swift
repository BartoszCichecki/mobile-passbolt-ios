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

import Features
import Crypto

internal struct AccountsStore {
  
  internal var verifyDataIntegrity: () -> Void
  internal var storedAccounts: () -> Array<Account>
  internal var storeAccount: (Account, ArmoredPrivateKey) -> Void
  internal var deleteAccount: (Account) -> Void
}

extension AccountsStore: Feature {
  
  internal typealias Environment = Void
  
  internal static func load(
    in environment: Environment,
    using features: FeatureFactory,
    cancellables: inout Array<AnyCancellable>
  ) -> Self {
    
    func verifyDataIntegrity() {
      #warning("TODO: [PAS-84]")
    }
    
    func storedAccounts() -> Array<Account> {
      #warning("TODO: [PAS-84]")
      Commons.placeholder("TODO: [PAS-84]")
    }
    
    func store(account: Account, with key: ArmoredPrivateKey) {
      #warning("TODO: [PAS-84]")
      Commons.placeholder("TODO: [PAS-84]")
    }
    
    func delete(account: Account) {
      #warning("TODO: [PAS-84]")
      Commons.placeholder("TODO: [PAS-84]")
    }
    
    return Self(
      verifyDataIntegrity: verifyDataIntegrity,
      storedAccounts: storedAccounts,
      storeAccount: store(account:with:),
      deleteAccount: delete(account:)
    )
  }
  
  #if DEBUG
  internal static var placeholder: Self {
    Self(
      verifyDataIntegrity: Commons.placeholder("You have to provide mocks for used methods"),
      storedAccounts: Commons.placeholder("You have to provide mocks for used methods"),
      storeAccount: Commons.placeholder("You have to provide mocks for used methods"),
      deleteAccount: Commons.placeholder("You have to provide mocks for used methods")
    )
  }
  #endif
}