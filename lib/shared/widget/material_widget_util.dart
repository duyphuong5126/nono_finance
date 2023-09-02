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
  final listItemCount = actionMap.keys.length + 2;
  showModalBottomSheet(
    context: context,
    clipBehavior: Clip.antiAliasWithSaveLayer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(radius),
    ),
    builder: (bottomSheetContext) {
      return Padding(
        padding: const EdgeInsets.all(space1),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(radius),
          ),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: listItemCount,
            itemBuilder: (context, index) {
              if (index == 0) {
                return AppBar(
                  title: Text(title),
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                );
              } else if (index == listItemCount - 1) {
                return ListTile(
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
                );
              } else {
                final key = actionMap.keys.elementAt(index - 1);
                return ListTile(
                  selected: key == selectedAction,
                  title: Text(actionMap[key]!),
                  onTap: () {
                    onActionSelected(key);
                    Navigator.of(bottomSheetContext).pop();
                  },
                );
              }
            },
          ),
        ),
      );
    },
  );
}
