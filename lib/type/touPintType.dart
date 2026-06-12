class TouYingData {
  late int pageIndex;
  late String zmIds;
  late String zhutiTitle;
  late int titleFontSize;
  late String title;
  late String lyric;
  late int rows;
  late int fontSize;
  late int lineHeight;
  late String firstSliderBgImg;
  late String fontColor;
  late String bgColor;
  late String bgImageClass;
  late int textShadow;
  late bool qrisShow;
  late String textAlign;
  late int textStorkeWidth;
  late String textStorkeColor;
  late String fontFace;
  late int scrollProgress;
  late List<QuickOptions> quickOptions;
  late bool pagePattern;
  late String username;

  TouYingData(
      {
        required this.pageIndex,
        required this.zmIds,
        required this.zhutiTitle,
        required this.titleFontSize,
        required this.title,
        required this.lyric,
        required this.rows,
        required this.fontSize,
        required this.lineHeight,
        required this.firstSliderBgImg,
        required this.fontColor,
        required this.bgColor,
        required this.bgImageClass,
        required this.textShadow,
        required this.qrisShow,
        required this.textAlign,
        required this.textStorkeWidth,
        required this.textStorkeColor,
        required this.fontFace,
        required this.scrollProgress,
        required this.quickOptions,
        required this.pagePattern,
        required this.username});

  TouYingData.fromJson(Map<String, dynamic> json) {
    pageIndex = json['pageIndex'];
    zmIds = json['zmIds'];
    zhutiTitle = json['zhutiTitle'];
    titleFontSize = json['titleFontSize'];
    title = json['title'];
    lyric = json['lyric'];
    rows = json['rows'];
    fontSize = json['fontSize'];
    lineHeight = json['lineHeight'];
    firstSliderBgImg = json['firstSliderBgImg'];
    fontColor = json['fontColor'];
    bgColor = json['bgColor'];
    bgImageClass = json['bgImageClass'];
    textShadow = json['textShadow'];
    qrisShow = json['qrisShow'];
    textAlign = json['textAlign'];
    textStorkeWidth = json['textStorkeWidth'];
    textStorkeColor = json['textStorkeColor'];
    fontFace = json['fontFace'];
    scrollProgress = json['scrollProgress'];


    if (json['quickOptions'] != null) {

      List<QuickOptions> _quickOptions = [];
      json['quickOptions'].forEach((v) {
        _quickOptions.add(new QuickOptions.fromJson(v));
      });
      quickOptions = _quickOptions;
    } else {
      quickOptions = [];
    }


    pagePattern = json['pagePattern'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pageIndex'] = this.pageIndex;
    data['zmIds'] = this.zmIds;
    data['zhutiTitle'] = this.zhutiTitle;
    data['titleFontSize'] = this.titleFontSize;
    data['title'] = this.title;
    data['lyric'] = this.lyric;
    data['rows'] = this.rows;
    data['fontSize'] = this.fontSize;
    data['lineHeight'] = this.lineHeight;
    data['firstSliderBgImg'] = this.firstSliderBgImg;
    data['fontColor'] = this.fontColor;
    data['bgColor'] = this.bgColor;
    data['bgImageClass'] = this.bgImageClass;
    data['textShadow'] = this.textShadow;
    data['qrisShow'] = this.qrisShow;
    data['textAlign'] = this.textAlign;
    data['textStorkeWidth'] = this.textStorkeWidth;
    data['textStorkeColor'] = this.textStorkeColor;
    data['fontFace'] = this.fontFace;
    data['scrollProgress'] = this.scrollProgress;
    // if (this.quickOptions != null) {
    data['quickOptions'] = this.quickOptions.map((v) => v.toJson()).toList();
    // }
    data['pagePattern'] = this.pagePattern;
    data['username'] = this.username;
    return data;
  }
}

class QuickOptions {
  late String sId;
  // late String sOpenid;
  // late int createDate;
  // late DmtUrl dmtUrl;
  // late bool isad;
  // late bool isopern;
  late String lyric;
  // late String mulu;
  // late int shijiIndex;
  // late int updateDate;
  late String xuhao;
  // late String years;
  late String title;
  // late bool show;
  late bool selected;

  QuickOptions(
      {
        required this.sId,
        // required this.sOpenid,
        // required this.createDate,
        // required this.dmtUrl,
        // required this.isad,
        // required this.isopern,
        required this.lyric,
        // required this.mulu,
        // required this.shijiIndex,
        // required this.updateDate,
        required this.xuhao,
        // required this.years,
        required this.title,
        // required this.show,
        required this.selected});

  QuickOptions.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    // sOpenid = json['_openid'];
    // createDate = json['createDate'];
    // dmtUrl = new DmtUrl.fromJson(json['dmtUrl']);
    // isad = json['isad'];
    // isopern = json['isopern'];
    lyric = json['lyric'];
    // mulu = json['mulu'];
    // shijiIndex = json['shijiIndex'];
    // updateDate = json['updateDate'];
    xuhao = json['xuhao'];
    // years = json['years'];
    title = json['title'];
    // show = json['show'];
    selected = json['selected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    // data['_openid'] = this.sOpenid;
    // data['createDate'] = this.createDate;
    // if (this.dmtUrl != null) {
    //   data['dmtUrl'] = this.dmtUrl.toJson();
    // }
    // data['isad'] = this.isad;
    // data['isopern'] = this.isopern;
    data['lyric'] = this.lyric;
    // data['mulu'] = this.mulu;
    // data['shijiIndex'] = this.shijiIndex;
    // data['updateDate'] = this.updateDate;
    data['xuhao'] = this.xuhao;
    // data['years'] = this.years;
    data['title'] = this.title;
    // data['show'] = this.show;
    data['selected'] = this.selected;
    return data;
  }
}

class DmtUrl {
  late String adUrl;
  late String gepuUrl;
  late String pptUrl;

  DmtUrl({
    required this.adUrl,
    required this.gepuUrl,
    required this.pptUrl
  });

  DmtUrl.fromJson(Map<String, dynamic> json) {
    adUrl = json['adUrl'];
    gepuUrl = json['gepuUrl'];
    pptUrl = json['pptUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['adUrl'] = this.adUrl;
    data['gepuUrl'] = this.gepuUrl;
    data['pptUrl'] = this.pptUrl;
    return data;
  }
}
