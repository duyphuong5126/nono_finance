import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nono_finance/infrastructure/model/bank_interest_model.dart';
import 'package:nono_finance/util.dart';

import '../crawler/crawlers.dart';
import '../domain/entity/bank_interest.dart';
import 'model/interest_model.dart';

abstract class InterestRepository {
  Future<Iterable<BankInterest>> getBankInterestList();
}

const _monthSuffix = ' tháng';
const _cacheTime = 60 * 60 * 1000;

class InterestRepositoryImpl implements InterestRepository {
  final List<BankInterest> _bankInterests = [];
  int _lastUpdatedTime = -1;

  @override
  Future<Iterable<BankInterest>> getBankInterestList() {
    if (_bankInterests.isNotEmpty && _lastUpdatedTime != -1 ||
        DateTime.now().millisecondsSinceEpoch - _lastUpdatedTime < _cacheTime) {
      return Future.value(_bankInterests);
    }
    StreamController<Iterable<BankInterest>> dataStream =
        StreamController.broadcast();
    callbackByCrawlerMap[interestCrawler]!.add((data) async {
      _bankInterests.clear();
      _bankInterests.addAll(await compute(_convertBankInterestData, data));
      _lastUpdatedTime = DateTime.now().millisecondsSinceEpoch;
      dataStream.add(_bankInterests);
    });
    interestCrawler.loadUrl(urlByCrawlerMap[interestCrawler]!);
    return dataStream.stream.first;
  }

  static Iterable<BankInterest> _convertBankInterestData(
    Map<String, dynamic> interestData,
  ) {
    final interestModel = InterestModel.fromJson(interestData);
    final counterTerms = interestModel.counterTerms.map(
      (e) => e == 'KKH' ? -1 : int.parse(e.replaceAll(_monthSuffix, '')),
    );
    final onlineTerms = interestModel.onlineTerms.map(
      (e) => e == 'KKH' ? -1 : int.parse(e.replaceAll(_monthSuffix, '')),
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

    return bankNames.map(
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
  }
}
