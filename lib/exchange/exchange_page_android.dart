import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nono_finance/domain/entity/exchange_type.dart';
import 'package:nono_finance/exchange/exchange_page_cubit.dart';
import 'package:nono_finance/shared/extension/data_ext.dart';
import 'package:nono_finance/shared/widget/error_body.dart';

import '../domain/entity/currency.dart';
import '../shared/dimens.dart';
import '../shared/widget/bar_chart_list_skeleton.dart';
import '../shared/widget/chart/bar_chart/nono_horizontal_bar_chart.dart';
import '../shared/widget/chart/bar_chart/not_applicable_text.dart';
import '../shared/widget/material_widget_util.dart';
import '../shared/widget/nono_icon.dart';
import 'exchange_page_state.dart';

class ExchangePageAndroid extends StatelessWidget {
  const ExchangePageAndroid({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = ModalRoute.of(context)?.settings.arguments as Currency;
    String pageTitle =
        '${currency.defaultName} (${currency.code.toUpperCase()})';
    return BlocProvider(
      create: (context) => ExchangePageCubit(currency)..init(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(pageTitle, maxLines: 2),
          actions: [
            BlocBuilder<ExchangePageCubit, ExchangePageState>(
              builder: (context, state) {
                return switch (state) {
                  ExchangePageInitialState() ||
                  ExchangePageFailureState() =>
                    const SizedBox.shrink(),
                  ExchangePageInitializedState() => IconButton(
                      padding: EdgeInsets.zero,
                      icon: const NonoIcon(
                        'assets/icon/ic_swap.svg',
                        width: actionBarIconSize,
                        height: actionBarIconSize,
                      ),
                      onPressed: () {
                        showActionsModalPopup(
                          context: context,
                          selectedAction: state.type,
                          title: 'Chọn danh mục',
                          cancelButtonLabel: 'Huỷ',
                          actionMap: {
                            for (final type in ExchangeType.values)
                              type: type.label
                          },
                          onActionSelected: (ExchangeType type) {
                            context.read<ExchangePageCubit>().changeType(type);
                          },
                        );
                      },
                    ),
                };
              },
            )
          ],
        ),
        body: BlocBuilder<ExchangePageCubit, ExchangePageState>(
          builder: (context, state) {
            return switch (state) {
              ExchangePageInitialState() => BarChartListSkeleton(
                  startColor: Colors.grey[800]!,
                  endColor: Colors.grey[400]!,
                ),
              ExchangePageInitializedState() => _InitializedBody(state),
              ExchangePageFailureState() => _ErrorBody(currency),
            };
          },
        ),
      ),
    );
  }
}

class _InitializedBody extends StatelessWidget {
  const _InitializedBody(this.state);

  final ExchangePageInitializedState state;

  @override
  Widget build(BuildContext context) {
    final height = state.type == ExchangeType.bank ? 300.0 : 1200.0;
    return RefreshIndicator(
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      edgeOffset: 0.0,
      onRefresh: () async {
        return context
            .read<ExchangePageCubit>()
            .changeType(state.type)
            .then((value) => Future.delayed(const Duration(seconds: 2)));
      },
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        itemCount: state.exchangesByGroup.keys.length,
        padding: const EdgeInsets.symmetric(
          vertical: space1,
          horizontal: spaceHalf,
        ),
        itemBuilder: (context, index) {
          final group = state.exchangesByGroup.keys.elementAt(index);
          final barData = state.exchangesByGroup[group]!;
          final theme = Theme.of(context);
          return NonoHorizontalBarChart(
            groupName: group,
            barData: barData,
            barColor: Colors.blue,
            maxColor: Colors.green,
            minColor: Colors.red,
            axisColor: Colors.black,
            height: height,
            valueFormat: NumberFormat("#,##0.00", "en_US"),
            groupNameStyle: theme.textTheme.bodyLarge,
            barValueTextStyle: theme.textTheme.bodySmall!,
            notes: _generateNoteWidgets(theme.textTheme, barData),
          );
        },
      ),
    );
  }

  Iterable<Widget> _generateNoteWidgets(
    TextTheme textTheme,
    Map<String, double> barData,
  ) {
    final hasNABar = barData.values
        .where((element) => element == double.negativeInfinity)
        .isNotEmpty;

    return [
      Text('* Đơn vị: đồng', style: textTheme.bodySmall),
      const SizedBox(height: spaceQuarter),
      if (hasNABar)
        NotApplicableText(
          textStyle: textTheme.bodySmall,
          notApplicableColor: Colors.red,
        ),
      const SizedBox(height: space2),
    ];
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody(this.currency);

  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return RefreshIndicator(
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      edgeOffset: 0.0,
      onRefresh: () async {
        return context
            .read<ExchangePageCubit>()
            .refresh()
            .then((value) => Future.delayed(const Duration(seconds: 2)));
      },
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: ErrorBody(
              errorMessage:
                  'Không tìm thấy thông tin tỉ giá của\n${currency.defaultName} - ${currency.code.toUpperCase()}',
              errorTextStyle: textTheme.titleMedium,
            ),
          )
        ],
      ),
    );
  }
}
