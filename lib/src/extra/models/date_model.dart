import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tenet_kit/flutter_tenet_kit.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:shamsi_date/shamsi_date.dart' as s;
import 'package:tenet_svg_collection/tenet_svg_collection.dart';

import '../ui/widgets/date_picker_widget.dart';


s.Jalali JALALIMIN = s.Jalali(1300);
s.Jalali JALALIMAX = s.Jalali(1450);

String jalaliToPersianText(s.Jalali date, {bool ignoreDay = false}) {
  const months = [
    '',
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  const weekdays = [
    'شنبه',
    'یکشنبه',
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنجشنبه',
    'جمعه',
  ];

  final weekday = weekdays[date.weekDay - 1];

  final text =
  '${ignoreDay ? '' : weekday} ${ignoreDay ? '' : date.day} ${months[date.month]} ${date.year}'
      .trim();

  return _toPersianDigits(text);
}

String _toPersianDigits(String input) {
  const en = '0123456789';
  const fa = '۰۱۲۳۴۵۶۷۸۹';

  return input.split('').map((c) {
    final index = en.indexOf(c);
    return index >= 0 ? fa[index] : c;
  }).join();
}

class DateModel {
  String? label;
  late s.Jalali date;

  DateModel({this.label, int? year, int? month, int? day, s.Jalali? date}) {
    if (date == null) {
      final monthDayLength = s.Jalali(year!, month!).monthLength;
      this.date = s.Jalali(year, month, day!.clamp(1, monthDayLength));
    } else {
      this.date = date;
    }
  }

  bool inValidRange({s.Jalali? begin, s.Jalali? end}) {
    begin ??= JALALIMIN;
    end ??= JALALIMAX;
    return isBefore(end) && isAfter(begin);
  }

  bool isBefore(s.Jalali date) {
    return this.date.toDateTime().isBefore(date.toDateTime());
  }
  bool isAfter(s.Jalali date) {
    return this.date.toDateTime().isAfter(date.toDateTime());
  }


  DateModel copy() => DateModel(label: label, date: date.copy());
  factory DateModel.now() {
    return DateModel(date: s.Jalali.now());
  }

  factory DateModel.next({int days = 0, int month = 0}) {
    return DateModel(date: s.Jalali.now().add(days: days, months: month));
  }

  s.Jalali clamp(s.Jalali begin, s.Jalali end) {
    if (isBefore(begin)) return begin;
    if (isAfter(end)) return end;
    return date;
  }

  @override
  String toString() => jalaliToPersianText(date);

  String toDateAndMonthString() => jalaliToPersianText(date, ignoreDay: true);

  String toFormattedString() =>
      '${date.year}/${date.month}/${date.day}'.toPersianDigit();
  void setDate(s.Jalali date) {
    this.date = date;
  }
}

class SecondaryDateField extends StatefulWidget {
  DateModel dateModel;
  Function(DateModel) onChanged;
  Color? borderColor;
  double radius;
  Color color;
  FocusedBorderStyle borderStyle;
  double height;
  double btnRadius;

  SecondaryDateField({
    super.key,
    required this.onChanged,
    required this.dateModel,
    this.height = 30,
    this.btnRadius = 5.0,
    FocusedBorderStyle? borderStyle,
    this.borderColor,
    this.radius = 8.0,
    Color? color,
  }) : borderStyle = borderStyle ?? FocusedBorderStyle.solid,
        color = color ?? Colors.white;

  @override
  State<SecondaryDateField> createState() => _SecondaryDateFieldState();
}

class _SecondaryDateFieldState extends State<SecondaryDateField> {
  late DateModel dateModel;
  s.Jalali get jalali => dateModel.date;

  late TextEditingController dayController;
  late TextEditingController monthController;
  late TextEditingController yearController;

  late FocusNode dayFocusNode;
  late FocusNode monthFocusNode;
  late FocusNode yearFocusNode;

  String _buildText(int n, {int length = 2}) =>
      n.toString().padLeft(length, '0').toPersianDigit();

  void _setFieldValues(
      s.Jalali jalali, {
        bool ignoreDay = false,
        bool ignoreMonth = false,
        ignoreYear = false,
      }) {
    if (!ignoreDay) {
      dayController.text = _buildText(jalali.day);
    }
    if (!ignoreMonth) {
      monthController.text = _buildText(jalali.month);
    }
    if (!ignoreYear) {
      yearController.text = _buildText(jalali.year, length: 4);
    }
  }

  @override
  void didUpdateWidget(SecondaryDateField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.dateModel != oldWidget.dateModel) {
      // _setFieldValues(widget.dateModel.date);
    }
  }

  void _handleDayChanged(String day) {
    final _dateModel = DateModel(
      year: dateModel.date.year,
      month: dateModel.date.month,
      day: int.parse(day.toEnglishDigit()),
    );
    dateModel = _dateModel;

    _setFieldValues(_dateModel.date, ignoreDay: true);
    widget.onChanged(_dateModel);
    setState(() {});
  }

  void _handleMonthChanged(String month) {
    final _dateModel = DateModel(
      year: dateModel.date.year,
      month: int.parse(month.toEnglishDigit()),
      day: dateModel.date.day,
    );

    dateModel = _dateModel;
    _setFieldValues(_dateModel.date, ignoreMonth: true);

    widget.onChanged(_dateModel);
    setState(() {});
  }

  void _handleYearChanged(String year) {
    final _dateModel = DateModel(
      year: int.parse(year.toEnglishDigit()),
      month: dateModel.date.month,
      day: dateModel.date.day,
    );
    dateModel = _dateModel;
    _setFieldValues(_dateModel.date, ignoreYear: true);

    widget.onChanged(_dateModel);
    setState(() {});
  }

  void _handleDayFocusNode() {
    if (!dayFocusNode.hasFocus) {
      _setFieldValues(jalali);
    }
  }

  void _handleMonthFocusNode() {
    if (!dayFocusNode.hasFocus) {
      _setFieldValues(jalali);
    }
  }

  void _handlYearFocusNode() {
    if (!dayFocusNode.hasFocus) {
      _setFieldValues(jalali);
    }
  }

  void initStream() {
    // dayController.addListener(_handleDayChangedListener);
    // monthController.addListener(_handleMonthChangedListener);
    // dayController.addListener(_handleYearChangedListener);

    dayFocusNode.addListener(_handleDayFocusNode);
    monthFocusNode.addListener(_handleMonthFocusNode);
    yearFocusNode.addListener(_handlYearFocusNode);
  }

  @override
  void initState() {
    super.initState();

    dateModel = widget.dateModel;
    dayController = TextEditingController(text: _buildText(jalali.day));
    monthController = TextEditingController(text: _buildText(jalali.month));
    yearController = TextEditingController(
      text: _buildText(jalali.year, length: 4),
    );

    dayFocusNode = FocusNode();
    monthFocusNode = FocusNode();
    yearFocusNode = FocusNode();
    dayFocusNode.addListener(() {
      setState(() {});
    });

    monthFocusNode.addListener(() {
      setState(() {});
    });
    yearFocusNode.addListener(() {
      setState(() {});
    });
    initStream();
  }

  bool get isValidRange => dateModel.inValidRange();
  bool get hasFocus =>
      dayFocusNode.hasFocus ||
          monthFocusNode.hasFocus ||
          yearFocusNode.hasFocus;

  @override
  Widget build(BuildContext context) {
    return FocusedBoxBorder(
      style: widget.borderStyle,

      // padding: EdgeInsets.only(left: 2.5, right: 5),
      borderColor:
      isValidRange
          ? widget.borderColor
          : const Color.fromARGB(255, 255, 22, 5),
      focusedBorderColor:
      !isValidRange ? const Color.fromARGB(255, 255, 22, 5) : widget.borderColor,
      hasFocus:
      dayFocusNode.hasFocus ||
          monthFocusNode.hasFocus ||
          yearFocusNode.hasFocus,
      radius: widget.radius,
      hasShadow: false,
      backgroundColor: Colors.transparent,
      child: Container(
        height: widget.height,
        color:
        isValidRange
            ? hasFocus
            ? widget.color
            : Colors.transparent
            : const Color.fromARGB(255, 255, 234, 233),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // spacing: 5,
          children: [
            Expanded(
              child: Row(
                spacing: 3,
                children: [
                  _Field(
                    value: jalali.day,
                    controller: dayController,

                    max:
                    s.Jalali(
                      dateModel.date.year,
                      dateModel.date.month,
                    ).monthLength,
                    focusNode: dayFocusNode,

                    onChanged: (v) {
                      _handleDayChanged(v);
                    },
                  ),
                  _Seprator(),
                  _Field(
                    value: jalali.month,
                    controller: monthController,
                    max: 12,
                    focusNode: monthFocusNode,
                    onChanged: (v) {
                      _handleMonthChanged(v);
                    },
                  ),
                  _Seprator(),
                  _Field(
                    value: jalali.year,
                    length: 4,
                    controller: yearController,
                    max: 2000,
                    focusNode: yearFocusNode,
                    onChanged: (v) {
                      _handleYearChanged(v);
                    },
                  ),
                ],
              ),
            ),

            if (isValidRange)
              HoverTracker(
                builder: (isHovered) {
                  return OverlayTriggerWidget(
                    offset: Offset(25, 20),
                    overlay: (hideoverlay) {
                      return OverlayWidgetV1(
                        width: 350,
                        child: SizedBox(
                          height: 450,
                          child: DatePickerWidget(
                            selectedDate: DateModel(date: JALALIMAX),
                            initial: dateModel.date,
                            firstDate: JALALIMIN,
                            onDateChanged: (d) {
                              final date = DateModel(date: d);
                              widget.onChanged(date);
                              dateModel = date;
                              _setFieldValues(d);
                              hideoverlay();
                            },
                          ),
                        ),
                      );
                    },
                    child: HoverTracker(
                      builder: (isHovered) {
                        return AspectRatio(
                          aspectRatio: 1.0,
                          child: Container(
                            margin: EdgeInsets.only(right: 0),
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: HexColor('f5f5f5'),
                              borderRadius: BorderRadius.circular(
                                widget.btnRadius,
                              ),
                            ),

                            alignment: Alignment.center,

                            child: SvgPicture.string(
                              SvgCollection.calendar,
                              color: isHovered ? Colors.black : Colors.black54,
                              width: 17,
                              height: 17,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _Seprator() {
    return Text(
      '\\',
      style: TextStyle(
        fontFamily: 'yekan bakh',
        fontSize: 12,
        color: Colors.black45,
      ),
    );
  }

  Widget _Field({
    required int value,
    required TextEditingController controller,
    required int max,
    required FocusNode focusNode,
    required Function(String) onChanged,
    int length = 2,
  }) {
    return IntrinsicWidth(
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 20),
        child: TextField(
          // value.toString().padLeft(length, '0').toPersianDigit(),
          controller: controller,
          textAlign: TextAlign.center,
          focusNode: focusNode,
          onChanged: onChanged,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'yekan bakh',
          ),

          textDirection: TextDirection.ltr,
          inputFormatters: [
            RangeTextInputFormatter(min: 1, max: max),
            ToPersianDigitFormatter(),
          ],

          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
            ),
          ),
        ),
      ),
    );
  }
}
