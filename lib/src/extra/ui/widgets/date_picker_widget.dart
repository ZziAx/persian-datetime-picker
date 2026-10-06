
// import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart' as s;

import '../../../../persian_datetime_picker.dart' as d;
import '../../models/date_model.dart';

class DatePickerWidget extends StatelessWidget {
  DateModel selectedDate;
  s.Jalali firstDate;
  s.Jalali initial;
  Function(s.Jalali) onDateChanged;

  DatePickerWidget({
    super.key,
    required this.initial,
    required this.selectedDate,
    required this.firstDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontFamily: 'yekan bakh', fontSize: 13);

    return DatePickerTheme(
      data: DatePickerThemeData(
        dayStyle: textStyle,
        yearStyle: textStyle,
        weekdayStyle: textStyle,
      ),
      child: d.DatePickerDialog(
        decoration: BoxDecoration(color: Colors.white),
        dialogSize: Size(double.infinity, double.infinity),
        firstDate: firstDate,
        lastDate: s.Jalali(1450),
        currentDate: s.Jalali.now(),
        initialDate: initial,
        // selectedDate: widget.selectedDate.add(days: 2),
        selectedDate: s.Jalali(1410),
        onDateChanhed: onDateChanged,
        titleBar: (jalali) {
          return DateModel(date: jalali).toDateAndMonthString();
          // return selectedDate.toString();
        },
      ),
    );
  }
}
