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

public func unreachable(
  _ message: String,
  file: StaticString = #filePath,
  line: UInt = #line
) -> Never {
  fatalError("Unexpected behaviour: " + message, file: (file), line: line)
}

public func unreachable<R>(
  _ message: String,
  file: StaticString = #filePath,
  line: UInt = #line
) -> () -> R {
  { fatalError("Unexpected behaviour: " + message, file: (file), line: line) }
}

public func unreachable<A1, R>(
  _ message: String,
  file: StaticString = #filePath,
  line: UInt = #line
) -> (A1) -> R {
  { _ in fatalError("Unexpected behaviour: " + message, file: (file), line: line) }
}

public func unreachable<A1, A2, R>(
  _ message: String,
  file: StaticString = #filePath,
  line: UInt = #line
) -> (A1, A2) -> R {
  { _, _ in fatalError("Unexpected behaviour: " + message, file: (file), line: line) }
}

public func unreachable<A1, A2, A3, R>(
  _ message: String,
  file: StaticString = #filePath,
  line: UInt = #line
) -> (A1, A2, A3) -> R {
  { _, _, _ in fatalError("Unexpected behaviour: " + message, file: (file), line: line) }
}

public func unreachable<A1, A2, A3, A4, R>(
  _ message: String,
  file: StaticString = #filePath,
  line: UInt = #line
) -> (A1, A2, A3, A4) -> R {
  { _, _, _, _ in fatalError("Unexpected behaviour: " + message, file: (file), line: line) }
}

public func unreachable<A1, A2, A3, A4, A5, R>(
  _ message: String,
  file: StaticString = #filePath,
  line: UInt = #line
) -> (A1, A2, A3, A4, A5) -> R {
  { _, _, _, _, _ in fatalError("Unexpected behaviour: " + message, file: (file), line: line) }
}

public func unreachable<A1, A2, A3, A4, A5, A6, R>(
  _ message: String,
  file: StaticString = #filePath,
  line: UInt = #line
) -> (A1, A2, A3, A4, A5, A6) -> R {
  { _, _, _, _, _, _ in fatalError("Unexpected behaviour: " + message, file: (file), line: line) }
}

public func unreachable<A1, A2, A3, A4, A5, A6, A7, R>(
  _ message: String,
  file: StaticString = #filePath,
  line: UInt = #line
) -> (A1, A2, A3, A4, A5, A6, A7) -> R {
  { _, _, _, _, _, _, _ in fatalError("Unexpected behaviour: " + message, file: (file), line: line) }
}

public func unreachable<A1, A2, A3, A4, A5, A6, A7, A8, R>(
  _ message: String,
  file: StaticString = #filePath,
  line: UInt = #line
) -> (A1, A2, A3, A4, A5, A6, A7, A8) -> R {
  { _, _, _, _, _, _, _, _ in fatalError("Unexpected behaviour: " + message, file: (file), line: line) }
}
