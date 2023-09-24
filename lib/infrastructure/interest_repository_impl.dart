import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:nono_finance/infrastructure/model/bank_interest_model.dart';
import 'package:nono_finance/util.dart';

import '../crawler/crawlers.dart';
import '../domain/entity/bank_interest.dart';
import '../domain/entity/bank_interests.dart';
import '../domain/repository/interest_repository.dart';
import 'data_parsing_helper.dart';
import 'model/interest_model.dart';

const _monthSuffix = ' tháng';

class InterestRepositoryImpl implements InterestRepository {
  int _lastUpdatedTime = -1;

  @override
  Future<BankInterests> getBankInterestList() {
    StreamController<BankInterests> dataStream = StreamController.broadcast();
    callbackByCrawlerMap[interestCrawler]!.add((data) async {
      _lastUpdatedTime = DateTime.now().millisecondsSinceEpoch;
      dataStream.add(await compute(_convertBankInterestData, data));
    });
    interestCrawler.loadUrl(urlByCrawlerMap[interestCrawler]!);
    return dataStream.stream.first;
  }

  static int _parseMonthSuffix(String month) {
    try {
      return int.parse(month);
    } on Exception catch (e) {
      log('Month>>> Failed to parse month=$month with error $e');
      return -1;
    }
  }

  static BankInterests _convertBankInterestData(
    Map<String, dynamic> interestData,
  ) {
    final interestModel = InterestModel.fromJson(interestData);
    final counterTerms = interestModel.counterTerms.map(
      (e) =>
          e == 'KKH' ? -1 : _parseMonthSuffix(e.replaceAll(_monthSuffix, '')),
    );
    final onlineTerms = interestModel.onlineTerms.map(
      (e) =>
          e == 'KKH' ? -1 : _parseMonthSuffix(e.replaceAll(_monthSuffix, '')),
    );

    final bankNames =
        interestModel.counterInterestRates.map((e) => e.bankName).toSet();
    bankNames.addAll(interestModel.onlineInterestRates.map((e) => e.bankName));

    final counterInterestMap = {
      for (BankInterestModel element in interestModel.counterInterestRates)
        element.bankName: element.interestRates.map(
          (e) =>
              double.tryParse(
                e.replaceAll(',', '.'),
              ) ??
              double.negativeInfinity,
        )
    };
    final onlineInterestMap = {
      for (BankInterestModel element in interestModel.onlineInterestRates)
        element.bankName: element.interestRates.map(
          (e) =>
              double.tryParse(
                e.replaceAll(',', '.'),
              ) ??
              double.negativeInfinity,
        )
    };

    final bankInterests = bankNames.map(
      (name) => BankInterest(
        bankName: name,
        counterInterestByTermMap: {
          for (int i = 0; i < counterTerms.length; i++)
            counterTerms.elementAt(i): counterInterestMap[name]?.elementAt(i) ??
                double.negativeInfinity
        },
        onlineInterestByTermMap: {
          for (int i = 0; i < onlineTerms.length; i++)
            onlineTerms.elementAt(i):
                onlineInterestMap[name]?.elementAt(i) ?? double.negativeInfinity
        },
      ),
    );
    final updatedTime = getUpdatedTime(interestData) ?? DateTime.now();
    return BankInterests(
      interestList: bankInterests,
      updatedTime: updatedTime,
    );
  }
}
