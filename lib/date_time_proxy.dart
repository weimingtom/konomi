library kurumi;

import 'java.dart';

class DateTimeProxy {
  java_util_Calendar _calendar;

  DateTimeProxy() {
    this._calendar = Calendar_.getInstance(TimeZone.getTimeZone("GMT"));
  }

  DateTimeProxy(int year, int month, int day, int hour, int min, int sec) {
    this._calendar = Calendar_.getInstance(TimeZone.getTimeZone("GMT"));
    this._calendar.set(year, month, day, hour, min, sec);
  }

  void setUTCNow() {
    _calendar = Calendar_.getInstance(TimeZone.getTimeZone("UTC"));
  }

  void setNow() {
    _calendar = Calendar_.getInstance(TimeZone.getTimeZone("GMT"));
  }

  int getSecond() {
    return _calendar.get(Calendar_.SECOND);
  }

  int getMinute() {
    return _calendar.get(Calendar_.MINUTE);
  }

  int getHour() {
    return _calendar.get(Calendar_.HOUR_OF_DAY);
  }

  int getDay() {
    return _calendar.get(Calendar_.DATE);
  }

  int getMonth() {
    return _calendar.get(Calendar_.MONTH) + 1;
  }

  int getYear() {
    return _calendar.get(Calendar_.YEAR);
  }

  int getDayOfWeek() {
    return _calendar.get(Calendar_.DAY_OF_WEEK);
  }

  int getDayOfYear() {
    return _calendar.get(Calendar_.DAY_OF_YEAR);
  }

  bool IsDaylightSavingTime() {
    return _calendar.get(Calendar_.DST_OFFSET) != 0;
  }

  double getTicks() {
    return _calendar.getTime().getTime();
  }

  static const int _t0 = System.currentTimeMillis();

  static double getClock() {
    return (System.currentTimeMillis() - _t0) ~/ 1000;
  }
}
