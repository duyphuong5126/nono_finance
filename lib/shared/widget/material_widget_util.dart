import 'package:flutter/material.dart';
import 'package:nono_finance/shared/dimens.dart';

showActionsModalPopup<T extends Object>({
  required BuildContext context,
  required String title,
  required String cancelButtonLabel,
  required T selectedAction,
  required Map<T, String> actionMap,
  required Function(T) onActionSelected,
}) {
  const radius = Radius.circular(popUpRadius);
  showModalBottomSheet(
    context: context,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
    ),
    builder: (bottomSheetContext) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: actionMap.keys.length,
              itemBuilder: (context, index) {
                final key = actionMap.keys.elementAt(index);
                return ListTile(
                  selected: key == selectedAction,
                  title: Text(actionMap[key]!),
                  onTap: () {
                    onActionSelected(key);
                    Navigator.of(bottomSheetContext).pop();
                  },
                );
              },
            ),
            ListTile(
              onTap: () {
                Navigator.of(bottomSheetContext).pop();
              },
              title: TextButton(
                onPressed: () {
                  Navigator.of(bottomSheetContext).pop();
                },
                child: Text(cancelButtonLabel),
              ),
              titleAlignment: ListTileTitleAlignment.center,
            ),
          ],
        ),
      );
    },
  );
}
