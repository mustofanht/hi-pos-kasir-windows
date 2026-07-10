import 'package:jaya_propertiy/app/utils/constant/string_constant.dart';

enum GeneralFilter {
  none,
  number,
  description,
  state,
  title,
  createdDate,
  assetTag,
  displayName,
  content,
  screenName,
}

extension GeneralFilterExt on GeneralFilter {
  String get label {
    switch (this) {
      case GeneralFilter.none:
        return constant.none;
      case GeneralFilter.number:
        return "Number";
      case GeneralFilter.description:
        return "Description";
      case GeneralFilter.state:
        return "State";
      case GeneralFilter.title:
        return "Title";
      case GeneralFilter.createdDate:
        return "Created Date";
      case GeneralFilter.assetTag:
        return "Asset Tag";
      case GeneralFilter.displayName:
        return "display name";
      case GeneralFilter.content:
        return "Content";
      case GeneralFilter.screenName:
        return "Screen Name";
      default:
        return constant.none;
    }
  }
}

enum SortType {
  asc,
  desc,
}

extension SortTypeExt on SortType {
  String get label {
    switch (this) {
      case SortType.asc:
        return "ASC";
      case SortType.desc:
        return "DESC";
      default:
        return "ASC";
    }
  }
}

enum FilterType {
  general,
  custom,
}

enum Connectors {
  AND,
  OR,
  AND_EXISTS,
  OR_EXISTS,
  ORDER_BY,
  GROUP_BY,
}

class OPERATOR_CONSTANTS {
  static String EQUALS = "=";
  static String NOT_EQUALS = "!=";
  static String GREATHER_THAN = ">";
  static String GREATHER_THAN_OR_EQUALS = ">=";
  static String LESS_THAN = "<";
  static String LESS_THAN_OR_EQUALS = "<=";
  static String LIKE = "_LIKE_";
  static String IS_NULL = "isnull";
  static String IS_NOT_NULL = "isnotnull";
}

class PAGINATIONS_CONSTANT {
  static int LIMIT_PAGE = 12;
}

class SORTING_CONSTANT {
  static String ASC = 'asc';
  static String DESC = 'desc';
}
