class Pagination {
  int? totalPage;
  int? totalElement;
  int? currentPage;
  int? currentElement;

  Pagination({
    this.totalPage,
    this.totalElement,
    this.currentPage,
    this.currentElement,
  });

  Pagination.fromJson(Map<String, dynamic> json) {
    totalPage = json['ttlPages'];
    totalElement = json['ttlRecords'];
    currentPage = json['pageNo'];
    currentElement = json['pageRecords'];
  }

  Map<String, dynamic> toJson() {
    return {
      "ttlPages": totalPage,
      "ttlRecords": totalElement,
      "pageNo": currentPage,
      "pageRecords": currentElement,
    };
  }
}
