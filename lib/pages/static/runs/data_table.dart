import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:runalyzer_client/utils/extensions.dart';

typedef RunalyzerColumn = ({Comparator<dynamic>? comparator, String title});
typedef _Sort = ({int idx, bool ascending});

RunalyzerColumn doubleColumn(final String title) => (
  comparator: (dynamic a, dynamic b) {
    double aD = a is double ? a : double.nan;
    double bD = b is double ? b : double.nan;

    return aD.compareTo(bD);
  },
  title: title
);

RunalyzerColumn intColumn(final String title) => (
  comparator: (dynamic a, dynamic b) {
    double aD = a is int ? a.toDouble() : double.nan;
    double bD = b is int ? b.toDouble() : double.nan;

    return aD.compareTo(bD);
  },
  title: title
);

RunalyzerColumn stringColumn(final String title) => (
  comparator: (dynamic a, dynamic b) {
    String aS = a is String ? a.toLowerCase() : "";
    String bS = b is String ? b.toLowerCase() : "";

    return aS.compareTo(bS);
  },
  title: title
);

RunalyzerColumn booleanColumn(final String title) => (
  comparator: (a, b) => a == b ? 0 : (a is bool && a ? 1 : -1),
  title: title
);

class RunalyzerDataTable extends StatelessWidget {
  final List<RunalyzerColumn> columns;
  final List<RunalyzerRow> rows;
  final Rx<_Sort?> _sortedIdx = (null as _Sort?).obs;

  RunalyzerDataTable({
    super.key,
    required this.columns,
    required this.rows
  });

  @override
  Widget build(BuildContext context) => ObxValue(_theTable, _sortedIdx);
  
  Widget _theTable(final Rx<_Sort?> sort) => DataTable(
    columns: columns.mapIndexed(_dataColumn).toList(),
    rows: sort.value == null ? rows : _sortRows(sort.value!),
    dataRowMinHeight: 0,
    dataRowMaxHeight: 50,
    columnSpacing: 10,
  );

  DataColumn _dataColumn(final int idx, final RunalyzerColumn column) => DataColumn(
    label: GestureDetector(
      onTap: () {
        final _Sort? old = _sortedIdx.value;
        final int oldIdx = old?.idx ?? -1;
        final bool oldAsc = old?.ascending ?? true;

        _sortedIdx.value = (idx: idx, ascending: oldIdx == idx ? !oldAsc : false);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            column.title,
            style: const TextStyle(fontSize: 16)
          ),
          _sortedIdx.value?.idx != idx ? const SizedBox(width: 20) : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _sortedIdx.value == null || _sortedIdx.value!.idx != idx ? [] : [
              _sortIcon(Icons.arrow_drop_up_sharp, 5, _sortedIdx.value!.ascending),
              _sortIcon(Icons.arrow_drop_down_sharp, -5, !_sortedIdx.value!.ascending)
            ]
          ),
        ],
      ),
    )
  );

  Widget _sortIcon(final IconData icon, final double yOffs, final bool selected) => Transform.translate(
    offset: Offset(0, yOffs),
    child: Icon(
      icon,
      color: selected ? Colors.white : Colors.white38,
      size: 20
    ),
  );

  List<RunalyzerRow> _sortRows(final _Sort sort) {
    final int idx = sort.idx;
    final Comparator<dynamic>? comparator = columns[idx].comparator;
    if(comparator == null) {
      return rows;
    }

    final List<RunalyzerRow> sorted = rows..sort((a, b) => comparator(a.cells[idx].data, b.cells[idx].data));
    return sort.ascending ? sorted : sorted.reversed.toList();
  }
}

class RunalyzerRow extends DataRow {
  @override
  final List<RunalyzerCell> cells;

  const RunalyzerRow({
    super.key,
    super.selected = false,
    super.onSelectChanged,
    super.onLongPress,
    super.color,
    super.mouseCursor,
    required this.cells,
  }) : super(cells: cells);
}


class RunalyzerCell extends DataCell {
  final dynamic data;

  const RunalyzerCell({
    required this.data,
    required Widget child,
    super.placeholder,
    super.showEditIcon,
    super.onTap,
    super.onLongPress,
    super.onTapDown,
    super.onDoubleTap,
    super.onTapCancel
  }) : super(child);
}