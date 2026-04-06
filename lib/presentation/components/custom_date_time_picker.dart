import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jaya_propertiy/app/utils/common/date_time_util.dart';
import 'package:jaya_propertiy/app/utils/constant/assets_constant.dart';
import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';
import 'package:jaya_propertiy/app/utils/styles/theme_style.dart';
import 'package:jaya_propertiy/presentation/components/custom_alert.dart';
import 'package:jaya_propertiy/presentation/components/custom_button.dart';

class CustomDateTimePicker extends StatefulWidget {
  final Text? label;
  final DateTime? newDate;
  final bool firstState;
  final DateTimePickerType type;
  final Function(DateTime)? onDateChanged;
  final Color? backgroundColor;
  final String? dateFormat;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool enable;
  final bool useTimePicker;
  final DateTime? minDateTime;

  const CustomDateTimePicker({
    Key? key,
    this.label,
    this.newDate,
    required this.firstState,
    this.type = DateTimePickerType.Default,
    this.onDateChanged,
    this.backgroundColor,
    this.dateFormat,
    this.border,
    this.boxShadow,
    required this.borderRadius,
    this.padding,
    this.margin,
    this.enable = true,
    this.useTimePicker = false,
    this.minDateTime,
  }) : super(key: key);

  @override
  State<CustomDateTimePicker> createState() => _CustomDateTimePickerState();
}

class _CustomDateTimePickerState extends State<CustomDateTimePicker> {
  TimeOfDay _time = const TimeOfDay(hour: 0, minute: 0);
  DateTime selectedYear = DateTime.now();
  DateTime date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.newDate != null) {
      date = widget.newDate as DateTime;
      selectedYear = widget.newDate as DateTime;
    }
  }

  @override
  void didUpdateWidget(covariant CustomDateTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.newDate != oldWidget.newDate) {
      setState(() {
        date = widget.newDate ?? DateTime.now();
        selectedYear = widget.newDate ?? DateTime.now();
      });
    }
  }

  // select year method
  _selectYear() {
    Get.defaultDialog(
      title: 'Select Year',
      contentPadding: EdgeInsets.all(layoutStyle.defaultMargin),
      content: SizedBox(
        width: layoutStyle.blockHorizontal * 85,
        height: layoutStyle.blockHorizontal * 85,
        child: YearPicker(
          firstDate: DateTime(1980),
          lastDate: DateTime(2050),
          initialDate: selectedYear,
          selectedDate: selectedYear,
          onChanged: (newYear) {
            setState(() {
              selectedYear = newYear;
              widget.onDateChanged!(newYear);
            });
          },
        ),
      ),
      barrierDismissible: false,
      cancel: CustomButton(
        width: layoutStyle.blockHorizontal * 30,
        height: layoutStyle.blockVertical * 5.5,
        onPressed: () {
          Get.back();
        },
        prefixIcon: Icon(
          Icons.close,
          color: colorStyle.red,
        ),
        label: Text(
          'Cancel',
          style: textStyle.redText,
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith(
            (states) => colorStyle.white,
          ),
          overlayColor: MaterialStateProperty.resolveWith(
            (states) => colorStyle.red.withOpacity(0.1),
          ),
          shadowColor: MaterialStateProperty.resolveWith(
            (states) => colorStyle.red,
          ),
          side: MaterialStateProperty.resolveWith(
            (states) => BorderSide(
              color: colorStyle.red,
              width: 2,
            ),
          ),
          shape: MaterialStateProperty.resolveWith(
            (states) => RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
  // end method

  // select  date method
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? newDate = await showDatePicker(
      context: context,
      locale: const Locale('id'),
      initialDate: date,
      firstDate: DateTime(1980),
      lastDate: DateTime(2030),
      helpText: 'Pilih Tanggal',
    );

    if (newDate != null) {
      setState(() {
        date = newDate;
      });
      if (widget.useTimePicker) {
        _selectTime(newDate);
      } else {
        widget.onDateChanged!(newDate);
      }
    }
  }
  // end method

  // select time
  void _selectTime(DateTime newDate) async {
    final newTime = await showTimePicker(
          context: context,
          initialTime: _time,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                alwaysUse24HourFormat: true, // Mengaktifkan format 24 jam
              ),
              child: child!,
            );
          },
        ) ??
        const TimeOfDay(hour: 0, minute: 0);

    // Buat DateTime berdasarkan waktu yang dipilih
    final selectedDateTime = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      newTime.hour,
      newTime.minute,
    );

    // Validasi minDate
    if (widget.minDateTime != null) {
      if (selectedDateTime.isBefore(widget.minDateTime!)) {
        // Tampilkan pesan error jika tidak valid
        alert.warning('Warning',
            'Waktu yang dipilih harus setelah ${dateTimeUtil.dateFormat(widget.minDateTime!, 'hh:mm:ss')}');
        return;
      }
    }

    setState(() {
      _time = newTime;
      date = selectedDateTime;
    });

    widget.onDateChanged!(date);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ??
          EdgeInsets.symmetric(
            vertical: layoutStyle.defaultMargin / 2,
            horizontal: layoutStyle.defaultMargin,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.label != null
              ? SizedBox(
                  child: widget.label,
                )
              : Container(),
          SizedBox(
            height: layoutStyle.defaultMargin / 2,
          ),
          InkWell(
            onTap: () {
              if (widget.enable) {
                if (widget.type == DateTimePickerType.OnlyYear) {
                  _selectYear();
                } else if (widget.type == DateTimePickerType.OnlyTime) {
                  _selectTime(date);
                } else {
                  _selectDate(context);
                }
              }
            },
            child: Container(
              height: layoutStyle.blockVertical * 6.5,
              padding: EdgeInsets.symmetric(
                horizontal: layoutStyle.defaultMargin / 2,
              ),
              decoration: BoxDecoration(
                color: widget.enable
                    ? widget.backgroundColor ?? colorStyle.white
                    : colorStyle.lightGrey,
                borderRadius: widget.borderRadius,
                border: widget.border,
                boxShadow: widget.boxShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.firstState
                          ? 'Select  Date'
                          : (widget.type == DateTimePickerType.OnlyYear)
                              ? dateTimeUtil.onlyYear(selectedYear)
                              : widget.type == DateTimePickerType.OnlyTime
                                  ? (widget.newDate == null
                                      ? ''
                                      : widget.dateFormat != null
                                          ? dateTimeUtil.getFormattedDate(
                                              date: date,
                                              format: DateFormat(
                                                widget.dateFormat ??
                                                    "dd-MM-yyyy",
                                                Get.locale.toString(),
                                              ),
                                            )
                                          : dateTimeUtil.onlyTime(date))
                                  : widget.dateFormat != null
                                      ? dateTimeUtil.getFormattedDate(
                                          date: date,
                                          format: DateFormat(
                                            widget.dateFormat ?? "dd-MM-yyyy",
                                            Get.locale.toString(),
                                          ),
                                        )
                                      : dateTimeUtil.dateWithDay(date),
                      style: widget.firstState
                          ? textStyle.greyText.copyWith(
                              fontWeight: fontWeight.medium,
                            )
                          : textStyle.blackText.copyWith(
                              fontWeight: fontWeight.medium,
                            ),
                    ),
                  ),
                  widget.type == DateTimePickerType.OnlyTime
                      ? Icon(
                          Icons.access_time,
                          color: colorStyle.grey,
                        )
                      : Image.asset(
                          assetsConstant.icInputCalendar,
                          width: 24,
                          height: 24,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
