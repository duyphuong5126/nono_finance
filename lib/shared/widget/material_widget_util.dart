import 'package:flutter/material.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';

showActionsModalPopup<T extends Object>({
  required BuildContext context,
  required String title,
  required String cancelButtonLabel,
  required T selectedAction,
  required Map<T, String> actionMap,
  required Function(T) onActionSelected,
}) {
  final textTheme = Theme.of(context).textTheme;
  showAdaptiveActionSheet(
    context: context,
    title: Text(
      title,
      style: textTheme.headlineSmall,
    ),
    actions: actionMap.entries
        .map(
          (action) => BottomSheetAction(
            title: Text(
              action.value,
              style: textTheme.bodyLarge,
            ),
            onPressed: (context) {
              onActionSelected(action.key);
              Navigator.of(context).pop();
            },
          ),
        )
        .toList(),
    cancelAction: CancelAction(
      title: Text(cancelButtonLabel),
    ),
    androidBorderRadius: 0.0,
  );
}
