import "package:antinote_app/frontend/app.dart";
import "package:antinote_app/frontend/extensions/colors.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/widgets/animated/icon.dart";
import "package:antinote_app/frontend/widgets/customs/button.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
import "package:antinote_app/frontend/widgets/customs/modal.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:antinote_app/protos/account.pb.dart";
import "package:antinote_app/utils.dart";
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

    this.onSetDefault = Utils.futureNoop,
    this.onRemoveDefault = Utils.futureNoop,
    this.onDelete = Utils.futureNoop,
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

      child: Container(
        decoration: BoxDecoration(color: context.c.surfaceContainerHigh, borderRadius: App.borderRadius),

        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(bottom: 8),

        child: Row(spacing: 16, children: [_buildLeading(), _buildBody(context), _buildTrailing(context)]),
      ),
    );
  }

  Widget _buildLeading() {
    return isLoggingIn ? _buildLeadingLoading() : _buildLeadingIcon();
  }

  Widget _buildLeadingLoading() {
    return const LoadingWidget(size: 26);
  }

  Widget _buildLeadingIcon() {
    return IconWidget(
      size: 26,
      iconOn: HugeIconsSolid.star,
      iconOff: HugeIconsSolid.userAccount,
      value: isDefault,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Spacer(),

          Text(
            account.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),

          const Spacer(flex: 3),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                account.establishmentName,
                style: TextStyle(fontWeight: FontWeight.w500, color: context.c.onSurfaceVariant),
                overflow: TextOverflow.ellipsis,
              ),

              Text(
                account.workspaceName,
                style: TextStyle(color: context.c.outline),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) => Pressable(
    onPressed: () => _openMenu(context),
    behavior: HitTestBehavior.opaque,

    child: Icon(HugeIconsSolid.moreVertical, color: context.c.onSurfaceVariant),
  );
}
