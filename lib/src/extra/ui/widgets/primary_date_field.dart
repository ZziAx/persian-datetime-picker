import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tenet_kit/flutter_tenet_kit.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

import '../../models/date_model.dart';
import 'date_picker_widget.dart';

class PrimaryDateField extends StatefulWidget {
  DateModel dateModel;
  Function(DateModel) onChanged;
  Color? borderColor;
  double radius;
  Color color;
  FocusedBorderStyle borderStyle;
  double height;
  double btnRadius;

  PrimaryDateField({
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
  State<PrimaryDateField> createState() => _PrimaryDateFieldState();
}

class _PrimaryDateFieldState extends State<PrimaryDateField> {
  late DateModel dateModel;
  Jalali get jalali => dateModel.date;

  late TextEditingController dayController;
  late TextEditingController monthController;
  late TextEditingController yearController;

  late FocusNode dayFocusNode;
  late FocusNode monthFocusNode;
  late FocusNode yearFocusNode;

  String _buildText(int n, {int length = 2}) =>
      n.toString().padLeft(length, '0').toPersianDigit();

  void _setFieldValues(
      Jalali jalali, {
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
  void didUpdateWidget(PrimaryDateField oldWidget) {
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
          ? widget.borderColor??Colors.black12
          : const Color.fromARGB(255, 255, 22, 5),
      focusedBorderColor:
      !isValidRange ? const Color.fromARGB(255, 255, 22, 5) : Colors.black12,
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
                    Jalali(
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
