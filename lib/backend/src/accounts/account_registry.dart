// class AccountRegistry {
//   const AccountRegistry({
//     required this.accounts,
//     required this.defaultAccountId,
//   });
//
//   const AccountRegistry.create() : accounts = const [], defaultAccountId = null;
//
//   final List<AntinoteAccount> accounts;
//   final String? defaultAccountId;
//
//   factory AccountRegistry.fromJson(Map<String, dynamic> json) =>
//       AccountRegistry(
//         accounts: json.getLM('accounts').mapL((e) => e.asAntinoteAccount()),
//         defaultAccountId: json.get('defaultAccountId'),
//       );
//
//   Map<String, dynamic> toJson() => {
//     'accounts': [for (final account in accounts) account.asJson()],
//     'defaultAccountId': defaultAccountId,
//   };
//
//   AccountRegistry copyWith({
//     List<AntinoteAccount>? accounts,
//     String? defaultAccountId,
//     bool clearDefaultAccountId = false,
//   }) {
//     assert(
//       !(defaultAccountId != null && clearDefaultAccountId),
//       'Cannot set and clear the default account ID at the same time.',
//     );
//     return AccountRegistry(
//       accounts: accounts ?? this.accounts,
//       defaultAccountId: clearDefaultAccountId
//           ? null
//           : (defaultAccountId ?? this.defaultAccountId),
//     );
//   }
// }
