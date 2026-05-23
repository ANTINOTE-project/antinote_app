import "package:antinote_app/frontend/extensions/colors.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/widgets/animated/icon.dart";
import "package:antinote_app/frontend/widgets/customs/button.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
import "package:antinote_app/frontend/widgets/customs/modal.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:antinote_app/protos/account.pb.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";

class AccountWidget extends StatelessWidget {
  final AntinoteAccount account;
  final VoidCallback onPressed;

  final bool isLoggingIn;
  final bool isDefault;

  final Future<void> Function() onSetDefault;
  final Future<void> Function() onRemoveDefault;
  final Future<void> Function() onDelete;

  const AccountWidget({
    super.key,

    required this.account,
    required this.onPressed,

    required this.isLoggingIn,
    required this.isDefault,

    required this.onSetDefault,
    required this.onRemoveDefault,
    required this.onDelete,
  });

  void _openMenu(BuildContext context) {
    Modal.show(
      account.name,

      Column(
        spacing: 8,

        children: [
          if (isDefault)
            ButtonWidget(onPressed: () => onRemoveDefault(), label: context.l10n.disableAutoLogin)
          else
            ButtonWidget(onPressed: () => onSetDefault(), label: context.l10n.enableAutoLogin),

          ButtonWidget(
            onPressed: () => onDelete(),
            isDangerous: true,
            icon: HugeIconsSolid.delete02,
            label: context.l10n.delete,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPressed: onPressed,

      child: Card(
        color: context.c.surfaceContainerHigh,
        margin: const EdgeInsets.only(bottom: 8),

        child: ListTile(
          leading: isLoggingIn
              ? const LoadingWidget(size: 26)
              : IconWidget(
                  size: 26,
                  iconOn: HugeIconsSolid.star,
                  iconOff: HugeIconsSolid.userAccount,
                  value: isDefault,
                ),

          title: Text(
            account.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          subtitle: Text(
            [account.establishmentName, account.workspaceName].join("\n"),
            overflow: TextOverflow.ellipsis,
          ),

          trailing: Pressable(
            onPressed: () => _openMenu(context),
            behavior: HitTestBehavior.opaque,

            child: Icon(HugeIconsSolid.moreVertical, color: context.c.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}
