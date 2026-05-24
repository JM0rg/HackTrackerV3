/// Pragmatic email format check used by the sign-in screen. The pattern
/// requires `local@domain.tld` with no whitespace, at least one `@`, a dot
/// in the domain, and a TLD of 2+ chars. Loose enough to accept
/// `foo+tag@example.com` and uppercase, strict enough to reject obvious
/// typos like `foo@bar` or `foo @example.com`. Whitespace is trimmed before
/// matching so a trailing keyboard space doesn't reject a valid address.
abstract final class EmailValidator {
  static final RegExp _pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  static bool isValid(String input) => _pattern.hasMatch(input.trim());
}
