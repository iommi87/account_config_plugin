import 'dart:math' as math;

import 'package:account_config_plugin/api/request_helper.dart';
import 'package:account_config_plugin/models/account_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountWidget extends StatefulWidget {
  const AccountWidget({
    super.key,
    required this.currentAccountId,
    required this.type,
    required this.result,
    this.dialogWidth = 2,
    this.dialogHeight = 1.8,
    @Deprecated('Passcode buttons now size themselves from the dialog constraints; this value is ignored.')
    this.buttonHeight = 90.0,
  });
  final double dialogWidth;
  final double dialogHeight;
  final int currentAccountId;
  final String type;
  final double buttonHeight;

  final Function(String url, int currentAccountId, String shortInitial) result;

  @override
  State<AccountWidget> createState() => _AccountWidgetState();
}

class _AccountWidgetState extends State<AccountWidget> {
  late RequestHelper requestHelper;

  int currentAccountId = 0;

  @override
  void initState() {
    super.initState();

    requestHelper = RequestHelper(context);

    currentAccountId = widget.currentAccountId;
  }

  Dialog getPassCodeDialog(String passCode) {
    final buttons = <String>['1', '2', '3', '4', '5', '6', '7', '8', '9', 'clear', '0', 'remove'];

    final TextEditingController controller = TextEditingController();
    controller.addListener(() {
      if (controller.text.length == 4) {
        if (passCode == controller.text) {
          Navigator.of(context).pop(true);
        } else {
          controller.text = '';
        }
      }
    });

    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    // Cap the dialog so it stays comfortable on tablets/desktops instead of
    // stretching edge to edge, while still shrinking to fit small phones.
    final maxWidth = math.min(screenSize.width / widget.dialogWidth, 420.0);
    final maxHeight = math.min(screenSize.height / widget.dialogHeight, 520.0);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight, minWidth: 280.0, minHeight: 360.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
              child: TextField(
                controller: controller,
                maxLength: 4,
                obscureText: true,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: theme.textTheme.headlineMedium?.copyWith(letterSpacing: 12.0),
                decoration: const InputDecoration(border: InputBorder.none, counter: SizedBox()),
                showCursor: false,
              ),
            ),
            const Divider(height: 1.0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    crossAxisCount: 3,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: buttons.length,
                  itemBuilder: (_, int index) {
                    var text = buttons[index];

                    if (index == 9) {
                      text = 'C';
                    }

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        shadowColor: Colors.transparent,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                      ),
                      onPressed: () {
                        if (index == 9) {
                          controller.text = '';
                        } else if (index == 11) {
                          if (controller.text.isNotEmpty) {
                            controller.text = controller.text.substring(0, controller.text.length - 1);
                          }
                        } else {
                          if (controller.text.length < 4) {
                            controller.text += text;
                          }
                        }
                      },
                      child: index != 11
                          ? Text(
                              text,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Icon(Icons.backspace_outlined, color: theme.colorScheme.onSurfaceVariant),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureProvider<List<AccountModel>>(
      create: (_) => requestHelper.getAccounts(),
      initialData: const [],
      child: Consumer<List<AccountModel>>(
        builder: (_, List<AccountModel> accounts, w) {
          if (accounts.isEmpty) return const SizedBox();

          return RadioGroup(
            onChanged: (int? value) async {
              var currentAccount = accounts.firstWhere((a) => a.id == value!);

              final result = await showDialog(context: context, builder: (context) => getPassCodeDialog(currentAccount.passCode));
              if (result != null) {
                setState(() {
                  currentAccountId = value!;
                });

                var url = await requestHelper.getAccountUrl(currentAccountId, widget.type);

                widget.result(url!, currentAccountId, currentAccount.shortInitial);
              }
            },
            groupValue: currentAccountId,
            child: ListView.separated(
              itemCount: accounts.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              separatorBuilder: (_, _) => const SizedBox(height: 8.0),
              itemBuilder: (_, int index) {
                final account = accounts.elementAt(index);
                final theme = Theme.of(context);
                final selected = account.id == currentAccountId;

                return Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  color: selected ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                  child: RadioListTile<int>(
                    title: Text(account.name, style: theme.textTheme.bodyLarge),
                    secondary: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      child: Text(account.shortInitial),
                    ),
                    value: account.id,
                    activeColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
