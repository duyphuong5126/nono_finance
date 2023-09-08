import 'package:flutter/cupertino.dart';
import 'package:nono_finance/shared/extension/data_ext.dart';

import '../domain/entity/product_type.dart';
import '../shared/constants.dart';
import '../shared/dimens.dart';
import '../shared/widget/nono_icon.dart';

class ProductsPageIOS extends StatelessWidget {
  const ProductsPageIOS({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Giá cả'),
      ),
      child: _ProductList(),
    );
  }
}

class _ProductList extends StatelessWidget {
  const _ProductList();

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final productType = ProductType.values[index];
        return CupertinoListTile(
          onTap: () {
            switch (productType) {
              case ProductType.gold:
                Navigator.pushNamed(context, goldPricesRoute);
                break;
              case ProductType.gas:
                break;
            }
          },
          leading:
              NonoIcon(productType.iconPath, width: space2, height: space2),
          title: Text(
            productType.label.capitalize(),
            style: textTheme.navTitleTextStyle,
          ),
          trailing: const Icon(CupertinoIcons.chevron_right),
        );
      },
      separatorBuilder: (context, index) {
        return const SizedBox(height: spaceHalf);
      },
      itemCount: ProductType.values.length,
    );
  }
}
