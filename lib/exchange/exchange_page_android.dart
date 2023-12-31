import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nono_finance/exchange/exchange_type.dart';
import 'package:nono_finance/exchange/exchange_page_cubit.dart';
import 'package:nono_finance/shared/colors.dart';
import 'package:nono_finance/shared/extension/data_ext.dart';
import 'package:nono_finance/shared/widget/error_body.dart';
import 'package:nono_finance/shared/widget/info_banner.dart';

import '../domain/entity/currency.dart';
import '../shared/dimens.dart';
import '../shared/formatter/date_time_formatter.dart';
import '../shared/widget/chart/bar_chart/nono_horizontal_bar_chart.dart';
import '../shared/widget/chart/bar_chart/not_applicable_text.dart';
import '../shared/widget/loading_body.dart';
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
              ExchangePageInitialState() => const LoadingBody(),
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
    final textTheme = Theme.of(context).textTheme;
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
        itemCount: state.exchangesByGroup.keys.length + 1,
        padding: const EdgeInsets.symmetric(
          vertical: spaceQuarter,
          horizontal: spaceHalf,
        ),
        itemBuilder: (context, itemIndex) {
          if (itemIndex == 0) {
            final updatedAtString = formatUpdatedTime(state.updatedAt);
            return Container(
              padding: const EdgeInsets.only(
                left: spaceHalf,
                right: spaceHalf,
                bottom: space1,
              ),
              child: InfoBanner(
                message: 'Cập nhật lúc: $updatedAtString',
                textStyle: textTheme.bodyMedium,
                backgroundColor: Colors.grey[400]!,
              ),
            );
          }
          final index = itemIndex - 1;
          final group = state.exchangesByGroup.keys.elementAt(index);
          final barData = state.exchangesByGroup[group]!;
          final theme = Theme.of(context);
          return NonoHorizontalBarChart(
            groupName: group,
            barData: barData,
            barColor: brandNormalColor,
            maxColor: brandPositiveColor,
            minColor: brandNegativeColor,
            axisColor: Colors.black,
            height: height,
            valueFormat: NumberFormat("#,##0.00", "en_US"),
            yValueFormat: NumberFormat("#,###", "en_US"),
            groupNameStyle: theme.textTheme.titleLarge,
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
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: space4),
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
