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
          showAxisLine: true,
          renderSpec: new charts.NoneRenderSpec()),
      seriesList,
      animate: animate,
      barGroupingType: charts.BarGroupingType.grouped,
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
      new OrdinalSales('2015', 50),
      new OrdinalSales('2016', 10),
      new OrdinalSales('2017', 20),
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
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        colorFn: (_, __) => charts.MaterialPalette.cyan.shadeDefault,

        data: tableSalesData,
      ),

      new charts.Series<OrdinalSales, String>(
        id: 'Desktop',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        colorFn: (_, __) => charts.MaterialPalette.cyan.shadeDefault.lighter,
        data: desktopSalesData,
      ),
      new charts.Series<OrdinalSales, String>(
        id: 'Tablet',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        colorFn: (_, __) => charts.MaterialPalette.cyan.shadeDefault,
        data: tableSalesData2,
      ),

    new charts.Series<OrdinalSales, String>(
    id: 'Tablet',
    domainFn: (OrdinalSales sales, _) => sales.year,
    measureFn: (OrdinalSales sales, _) => sales.sales,
      colorFn: (_, __) => charts.MaterialPalette.cyan.shadeDefault.lighter,
      data: tableSalesData3,
    )
    ];
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}