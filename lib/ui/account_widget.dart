import 'package:account_config_plugin/api/request_helper.dart';
import 'package:account_config_plugin/models/account_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountWidget extends StatefulWidget {
  const AccountWidget({
    super.key,
    required this.currentAccountId,
    required this.result,
    this.dialogWidth = 2,
    this.dialogHeight = 1.8,
  });
  final double dialogWidth;
  final double dialogHeight;
  final int currentAccountId;

  final Function(String url, int currentAccountId, String shortInitial) result;

  @override
  State<AccountWidget> createState() => _AccountWidgetState();
}

class _AccountWidgetState extends State<AccountWidget> {
  RequestHelper requestHelper = RequestHelper();

  int currentAccountId = 0;

  @override
  void initState() {
    super.initState();

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

    return Dialog(
      child: SizedBox(
        height: MediaQuery.of(context).size.height / widget.dialogHeight,
        width: MediaQuery.of(context).size.width / widget.dialogWidth,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
              child: TextField(
                controller: controller,
                maxLength: 4,
                obscureText: true,
                style: const TextStyle(fontSize: 40.0),
                decoration: const InputDecoration(border: InputBorder.none, counter: SizedBox()),
                showCursor: false,
              ),
            ),
            const Divider(height: 1.0),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
                crossAxisCount: 3,
                mainAxisExtent: 90.0,
              ),
              itemCount: buttons.length,
              itemBuilder: (_, int index) {
                var text = buttons[index];

                if (index == 9) {
                  text = 'C';
                }

                return GridTile(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
                            style: const TextStyle(fontSize: 22.0, color: Color(0XFF696969), fontWeight: FontWeight.bold),
                          )
                        : const Icon(Icons.backspace_outlined, weight: 27.0, color: Color(0XFF696969)),
                  ),
                );
              },
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

                var url = await requestHelper.getAccountUrl(currentAccountId);

                widget.result(url!, currentAccountId, currentAccount.shortInitial);
              }
            },
            groupValue: currentAccountId,
            child: ListView.builder(
              itemCount: accounts.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, int index) {
                return RadioListTile<int>(
                  title: Text(accounts.elementAt(index).name),
                  value: accounts.elementAt(index).id,
                  activeColor: Theme.of(context).primaryColor,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
