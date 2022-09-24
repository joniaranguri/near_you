/// Bar chart example
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class GroupedBarChart extends StatelessWidget {
  final List<charts.Series<dynamic, String>> seriesList;
  final bool animate;

  GroupedBarChart(this.seriesList, {required this.animate});

  factory GroupedBarChart.withSampleData() {
    return new GroupedBarChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      primaryMeasureAxis:
          new charts.NumericAxisSpec(renderSpec: new charts.NoneRenderSpec()),
      domainAxis: new charts.OrdinalAxisSpec(
        showAxisLine: false,
        // renderSpec: new charts.NoneRenderSpec()
      ),
      seriesList,
      animate: animate,
      barGroupingType: charts.BarGroupingType.grouped,
      defaultRenderer: charts.BarRendererConfig(
          cornerStrategy: const charts.ConstCornerStrategy(9)),
    );
  }

  /// Create series list with multiple series
  static List<charts.Series<OrdinalSales, String>> _createSampleData() {
    final desktopSalesData = [
      new OrdinalSales('2014', 40),
      new OrdinalSales('2015', 25),
      new OrdinalSales('2016', 60),
      new OrdinalSales('2017', 75),
    ];

    final tableSalesData = [
      new OrdinalSales('2014', 25),
      new OrdinalSales('2015', 90),
      new OrdinalSales('2016', 10),
      new OrdinalSales('2017', 20),
      new OrdinalSales('2018', 50),
      new OrdinalSales('2019', 80),
      new OrdinalSales('2020', 20),
    ];

    final tableSalesData2 = [
      new OrdinalSales('2018', 25),
      new OrdinalSales('2019', 50),
      new OrdinalSales('2020', 10),
      new OrdinalSales('2021', 20),
    ];

    final tableSalesData3 = [
      new OrdinalSales('2018', 25),
      new OrdinalSales('2019', 50),
      new OrdinalSales('2020', 10),
      new OrdinalSales('2021', 20),
    ];

    return [
      new charts.Series<OrdinalSales, String>(
        id: 'Tablet',
        labelAccessorFn: (OrdinalSales sales, _) => '${sales.sales}%',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        colorFn: (ordinary, __) {
          if (ordinary.sales >= 80)
            return charts.Color.fromHex(code: "#DCF0EF");
          return charts.Color.fromHex(code: "#2F8F9D");
        },
        data: tableSalesData,
      ),
    ];
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}
