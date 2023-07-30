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

class InterestRepositoryImpl implements InterestRepository {
  @override
  Future<Iterable<BankInterest>> getBankInterestList() {
    StreamController<Iterable<BankInterest>> dataStream =
        StreamController.broadcast();
    callbackByCrawlerMap[interestCrawler]!.add((data) async {
      dataStream.add(await compute(_convertBankInterestData, data));
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
              -1.0,
        )
    };
    final onlineInterestMap = {
      for (BankInterestModel element in interestModel.onlineInterestRates)
        element.bankName: element.interestRates.map(
          (e) =>
              double.tryParse(
                e.replaceAll(',', '.'),
              ) ??
              -1.0,
        )
    };

    return bankNames.map(
      (name) => BankInterest(
        name: name,
        counterInterestByTermMap: {
          for (int i = 0; i < counterTerms.length; i++)
            counterTerms.elementAt(i):
                counterInterestMap[name]?.elementAt(i) ?? -1.0
        },
        onlineInterestByTermMap: {
          for (int i = 0; i < onlineTerms.length; i++)
            onlineTerms.elementAt(i):
                onlineInterestMap[name]?.elementAt(i) ?? -1.0
        },
      ),
    );
  }
}
