import 'package:flutter/cupertino.dart';

showActionsModalPopup<T extends Object>({
  required BuildContext context,
  required String title,
  required String message,
  required String cancelButtonLabel,
  required T selectedAction,
  required Map<T, String> actionMap,
  required Function(T) onActionSelected,
}) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      title: Text(
        title,
        style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
      ),
      message: Text(message),
      actions: actionMap.entries
          .map(
            (action) => CupertinoActionSheetAction(
              isDefaultAction: action.key == selectedAction,
              onPressed: () {
                onActionSelected(action.key);
                Navigator.pop(context);
              },
              child: Text(action.value),
            ),
          )
          .toList(),
      cancelButton: CupertinoActionSheetAction(
        isDefaultAction: false,
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          cancelButtonLabel,
        ),
      ),
    ),
  );
}
