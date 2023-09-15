import 'package:flutter/material.dart';
import 'package:nono_finance/domain/entity/product_type.dart';
import 'package:nono_finance/shared/constants.dart';
import 'package:nono_finance/shared/extension/data_ext.dart';

import '../shared/dimens.dart';
import '../shared/widget/nono_icon.dart';

class ProductPageAndroid extends StatelessWidget {
  const ProductPageAndroid({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giá cả'),
      ),
      body: const _ProductList(),
    );
  }
}

class _ProductList extends StatelessWidget {
  const _ProductList();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final productType = ProductType.values[index];
        return ListTile(
          onTap: () {
            switch (productType) {
              case ProductType.gold:
                Navigator.pushNamed(context, goldPricesRoute);
                break;
              case ProductType.gas:
                Navigator.pushNamed(context, gasPricesRoute);
                break;
            }
          },
          leading:
              NonoIcon(productType.iconPath, width: space2, height: space2),
          title: Text(
            productType.label.capitalize(),
            style: textTheme.bodyMedium,
          ),
          trailing: const Icon(Icons.chevron_right),
        );
      },
      separatorBuilder: (context, index) {
        return const SizedBox(height: spaceHalf);
      },
      itemCount: ProductType.values.length,
    );
  }
}
